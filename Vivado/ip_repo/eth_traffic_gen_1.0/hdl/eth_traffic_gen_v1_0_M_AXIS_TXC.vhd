library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity eth_traffic_gen_v1_0_M_AXIS_TXC is
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
    start_o        : out std_logic;
    force_drop_i   : in std_logic;
    last_data_i    : in std_logic;
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
end eth_traffic_gen_v1_0_M_AXIS_TXC;

architecture implementation of eth_traffic_gen_v1_0_M_AXIS_TXC is
	--Total number of output data.
	-- Total number of output data                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := 6;                                   

  type FRAME is array (0 to NUMBER_OF_OUTPUT_WORDS-1) of std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);

  constant framedata : FRAME := (X"A0000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000");
  
	                                                                                  
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
	signal read_pointer : integer range 0 to NUMBER_OF_OUTPUT_WORDS+1;                               

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
  
  signal sending            : std_logic;
  signal sending_r1         : std_logic;
  signal sending_r2         : std_logic;
  signal sending_r3         : std_logic;
  signal sending_r4         : std_logic;
  signal start              : std_logic;
  signal force_drop         : std_logic;
  signal force_drop_r1      : std_logic;
  signal force_drop_r2      : std_logic;
  signal force_drop_trigger : std_logic;
  signal drop_pkt           : std_logic;
  signal wait_flag          : std_logic;
  signal last_data          : std_logic;

	-- Clock cycles between sent packets when forcing lost packets
	constant DELAY_BETWEEN_PKTS  : integer := 1000;
	-- Counter for forcing lost packets
	signal counter    : integer range 0 to DELAY_BETWEEN_PKTS-1 ;
  
begin
	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TKEEP	<= (others => '1');

  force_drop <= force_drop_i;
  last_data <= last_data_i;
  
  -- Register force drop packet signal
	process(M_AXIS_ACLK)
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        force_drop_r1 <= '0';
        force_drop_r2 <= '0';
      else
        force_drop_r1 <= force_drop;
        force_drop_r2 <= force_drop_r1;
	    end if;                                                                                    
	  end if;                                                                                      
	end process;
  
  force_drop_trigger <= '1' when ((force_drop_r1 = '1') and (force_drop_r2 = '0')) else '0';
  
  -- Drop packet signal goes high when software requests a dropped packet
  -- then waits until last data signal from M_AXIS_TXD to reset.
	process(M_AXIS_ACLK)
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        drop_pkt <= '0';
      -- If drop_pkt is low, wait for force drop trigger
      elsif (drop_pkt = '0') then
        drop_pkt <= force_drop_trigger;
        --if (force_drop_trigger = '1') then
        --  drop_pkt <= '1';
        --end if;
      -- If drop_pkt is high, wait for last data in
      elsif (last_data = '1') then
      --elsif (force_drop_trigger = '1') then
        drop_pkt <= '0';
      end if;
	  end if;
	end process;
  
  -- Timer for delaying next packet when dropped packet is requested.
	process(M_AXIS_ACLK)
	begin
	  if (rising_edge (M_AXIS_ACLK)) then
	    if(M_AXIS_ARESETN = '0') then
	      counter <= 0;
	    else
        -- Load counter when drop_pkt is high and last data received
	      if ((drop_pkt = '1') and (last_data = '1')) then
          counter <= DELAY_BETWEEN_PKTS-1;
        elsif (counter > 0) then
          counter <= counter - 1;
	      end  if;
	    end if;
	  end if;
	end process;
  
  -- wait flag prevents us from sending a new packet
  -- and is used when software requests a forced lost packet
  wait_flag <= '1' when (counter > 0) else '0';
  
  -- Sending
	process(M_AXIS_ACLK)                                                                           
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then                                                              
        sending <= '0';
	    else
        -- If not transmitting, wait for TREADY
        if(sending = '0') then
          if ((M_AXIS_TREADY = '1') and (wait_flag = '0') and (sending_r1 = '0')) then
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
  
	process(M_AXIS_ACLK)                                                                           
	begin                                                                                          
	  if (rising_edge (M_AXIS_ACLK)) then                                                          
	    if(M_AXIS_ARESETN = '0') then   
        sending_r1 <= '0';
        sending_r2 <= '0';
        sending_r3 <= '0';
        sending_r4 <= '0';
	    else
        sending_r1 <= sending;
        sending_r2 <= sending_r1;
        sending_r3 <= sending_r2;
        sending_r4 <= sending_r3;
      end if;
	  end if;                                                                                      
	end process;         
  
  start_o <= '1' when ((sending_r3 = '1') and (sending_r4 = '0')) else '0';
  
	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	--axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < NUMBER_OF_OUTPUT_WORDS)) else '0';
	axis_tvalid <= '1' when ((sending = '1') and (read_pointer < NUMBER_OF_OUTPUT_WORDS)) else '0';
	
	-- AXI tlast generation                                                                        
	-- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
	-- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
	axis_tlast <= '1' when (read_pointer = NUMBER_OF_OUTPUT_WORDS-1) else '0';                     
	
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                        
	process(M_AXIS_ACLK)                                                                           
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

	process(M_AXIS_ACLK)                                                       
	begin                                                                            
	  if (rising_edge (M_AXIS_ACLK)) then                                            
	    if(M_AXIS_ARESETN = '0') then                                                
	      read_pointer <= 0;                                                         
	    else                                                                         
        if (tx_en = '1') then
          if (read_pointer < NUMBER_OF_OUTPUT_WORDS-1) then                         
	          read_pointer <= read_pointer + 1;                                      
          elsif (read_pointer = NUMBER_OF_OUTPUT_WORDS-1) then                         
            read_pointer <= 0;
          end if;
	      end  if;                                                                   
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     


	--FIFO read enable generation 

	tx_en <= M_AXIS_TREADY and axis_tvalid;                                   
	
	-- FIFO Implementation                                                          
	
	-- Streaming output data is read from FIFO                                      
	  process(M_AXIS_ACLK)                                                          
	  begin                                                                         
	    if (rising_edge (M_AXIS_ACLK)) then                                         
	      if(M_AXIS_ARESETN = '0') then                                             
	    	  stream_data_out <= (others => '0');
	      elsif (axis_tvalid = '1') then
	        stream_data_out <= framedata(read_pointer);
	      end if;
	     end if;
	   end process;

	-- Add user logic here

	-- User logic ends

end implementation;
