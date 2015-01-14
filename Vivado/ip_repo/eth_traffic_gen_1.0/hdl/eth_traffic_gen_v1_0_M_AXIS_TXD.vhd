library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity eth_traffic_gen_v1_0_M_AXIS_TXD is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
    start_i        : in std_logic;
    force_error_i  : in std_logic;
    insert_fcs_i   : in std_logic;
    fcs_word_i     : in std_logic_vector(31 downto 0);
    pkt_word_len_i : in std_logic_vector(31 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TKEEP	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end eth_traffic_gen_v1_0_M_AXIS_TXD;

architecture implementation of eth_traffic_gen_v1_0_M_AXIS_TXD is
	--Total number of output data.
	-- Total number of output data                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := 3;                                   

  type FRAME is array (0 to NUMBER_OF_OUTPUT_WORDS-1) of std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);

  -- The ethernet frame that is sent
  -- The last word is the FCS (checksum). Normally we wouldn't provide the FCS to the MAC
  -- because it can calculate it automatically, but in our case, we need to provide it so
  -- that when we generate forced errors in the frame, they will cause the FCS to be
  -- incorrect for the frame. Thus the receiver MAC will reject it, and we can count a
  -- rejected frame.
  constant framedata : FRAME := (
                                  X"FFFFFFFF",X"1E00FFFF",X"A4A52737"
  
  
                                  -- X"FFFFFFFF",X"1E00FFFF",X"A4A52737",X"01000608",
                                  -- X"04060008",X"1E000100",X"A4A52737",X"0101A8C0",
                                  -- X"00000000",X"A8C00000",X"00000A01",X"00000000",
                                  -- X"00000000",X"00000000",X"00000000",X"A63112B7"
                                  );
  

	-- Define the states of state machine                                             
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO                                   
	type state is ( IDLE,        -- This is the initial/idle state                    
	                INIT_COUNTER,  -- This state initializes the counter, ones        
	                                -- the counter reaches C_M_START_COUNT count,     
	                                -- the state machine changes state to INIT_WRITE  
	                SEND_STREAM);  -- In this state the                               
	                             -- stream data is output through M_AXIS_TDATA        
	-- State variable                                                                 
	signal  mst_exec_state : state;                                                   
	-- Example design FIFO read pointer                                               
	signal read_pointer : std_logic_vector(15 downto 0);

	-- AXI Stream internal signals
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	--Last of the streaming data 
	signal axis_tlast	: std_logic;
	--Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay	: std_logic;
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done	: std_logic;

  signal start               : std_logic;
  signal tready              : std_logic;
  signal sending             : std_logic;
  signal sending_r           : std_logic;
  signal sending_trigger     : std_logic;
  signal force_error_r       : std_logic;
  signal force_error_trigger : std_logic;
  signal error_mask          : std_logic_vector(31 downto 0);
  signal pkt_word_len        : std_logic_vector(15 downto 0);
  signal ether_type          : std_logic_vector(15 downto 0);

	-- Random number generator
	signal lfsr          : std_logic_vector(31 downto 0);
	signal lfsr_next     : std_logic_vector(31 downto 0);
  
begin
	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TKEEP	<= (others => '1');
  
  tready <= M_AXIS_TREADY;
  start <= start_i;

  -- Register packet word length
	process(M_AXIS_ACLK) is
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        pkt_word_len <= (others => '1');
        ether_type <= (others => '0');
      elsif(insert_fcs_i = '1') then
        -- Actual packet word length = 3 (MAC addresses) + 1 (EtherType and padding) + payload + 1 (FCS)
        pkt_word_len <= pkt_word_len_i(15 downto 0)+5;
        ether_type(15 downto 8) <= pkt_word_len_i(23 downto 16);
        ether_type(7 downto 0) <= pkt_word_len_i(31 downto 24);
	    else
        pkt_word_len <= pkt_word_len_i(15 downto 0)+4;
        ether_type(15 downto 8) <= pkt_word_len_i(23 downto 16);
        ether_type(7 downto 0) <= pkt_word_len_i(31 downto 24);
	    end if;
	  end if;                                                                                      
	end process;
  
  -- Register force error signal
	process(M_AXIS_ACLK) is
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        force_error_r <= '0';
	    else
        force_error_r <= force_error_i;
	    end if;                                                                                    
	  end if;                                                                                      
	end process;
  
  force_error_trigger <= '1' when ((force_error_i = '1') and (force_error_r = '0')) else '0';
  
  -- Error mask
	process(M_AXIS_ACLK) is
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        error_mask <= (others => '0');
	    elsif (force_error_trigger = '1') then
        error_mask <= X"00000001";
      elsif (tx_en = '1') then
        error_mask <= (others => '0');
      else
        error_mask <= error_mask;
	    end if;
	  end if;
	end process;
  
  -- Sending
	process(M_AXIS_ACLK) is
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        sending <= '0';
        sending_r <= '0';
	    else
        sending_r <= sending;
        -- If not transmitting, wait for TREADY
        if(sending = '0') then
          if((start = '1') or ((tready = '1') and (sending_r = '0'))) then
            sending <= '1';
          end if;
        -- If transmitting, wait for TLAST
        else
          if(axis_tlast = '1') then
            sending <= '0';
          end if;
        end if;
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   
  
  sending_trigger <= '1' when ((sending = '1') and (sending_r = '0')) else '0';
  
	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	--axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < NUMBER_OF_OUTPUT_WORDS)) else '0';
	axis_tvalid <= '1' when ((sending = '1') and (read_pointer < pkt_word_len)) else '0';
	                                                                                               
	-- AXI tlast generation                                                                        
	-- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
	-- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
	axis_tlast <= '1' when (read_pointer = pkt_word_len-1) else '0';                     
	                                                                                               
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                        
	process(M_AXIS_ACLK) is
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
	      axis_tvalid_delay <= '0';                                                                
	      axis_tlast_delay <= '0';                                                                 
	    else                                                                                       
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   


	--read_pointer pointer

	process(M_AXIS_ACLK) is
	begin                                                                            
	  if (rising_edge (M_AXIS_ACLK)) then                                            
	    if(M_AXIS_ARESETN = '0') then                                                
	      read_pointer <= (others => '0');
        lfsr <= (others => '1');
	    else
        if (tx_en = '1') then
          if (read_pointer < pkt_word_len-1) then                         
	          read_pointer <= read_pointer + 1;
            lfsr <= lfsr_next;
          elsif (read_pointer = pkt_word_len-1) then                         
            read_pointer <= (others => '0');
            lfsr <= (others => '1');
          end if;
	      end  if;                                                                   
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     

  process (lfsr) is
  begin
    lfsr_next <= lfsr(30 downto 0) & lfsr(31);
    lfsr_next(2) <= lfsr(1) xor lfsr(31);
    lfsr_next(6) <= lfsr(5) xor lfsr(31);
    lfsr_next(7) <= lfsr(6) xor lfsr(31);
  end process;

	--FIFO read enable generation 

	tx_en <= (tready and axis_tvalid) or sending_trigger;
	
	-- FIFO Implementation                                                          
	
	-- Streaming output data is read from FIFO                                      
	  process(M_AXIS_ACLK) is
	  begin                                                                         
	    if (rising_edge (M_AXIS_ACLK)) then                                         
	      if(M_AXIS_ARESETN = '0') then
	    	  stream_data_out <= (others => '0');
	      elsif (tx_en = '1') then
          if((axis_tlast = '1') and (insert_fcs_i = '1')) then
            stream_data_out <= fcs_word_i xor error_mask;
          elsif(read_pointer < X"0003") then
            stream_data_out <= framedata(conv_integer(unsigned(read_pointer))) xor error_mask;
          elsif(read_pointer = X"0003") then
            stream_data_out <= (X"0000" & ether_type) xor error_mask;
          else
            stream_data_out <= lfsr xor error_mask;
          end if;
	      end if;
	    end if;
	  end process;

	-- Add user logic here

	-- User logic ends

end implementation;
