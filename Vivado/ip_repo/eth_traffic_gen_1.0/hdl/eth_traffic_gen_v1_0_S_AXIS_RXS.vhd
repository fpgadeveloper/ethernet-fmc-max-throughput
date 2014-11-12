library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity eth_traffic_gen_v1_0_S_AXIS_RXS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
    rst_counters_i  : in std_logic;
    last_data_i     : in std_logic;
    dropped_pkts_o  : out std_logic_vector(31 downto 0);
    max_delay_i     : in std_logic_vector(15 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_KEEP  	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end eth_traffic_gen_v1_0_S_AXIS_RXS;

architecture arch_imp of eth_traffic_gen_v1_0_S_AXIS_RXS is
	-- function called clogb2 that returns an integer which has the 
	-- value of the ceiling of the log base 2.
	function clogb2 (bit_depth : integer) return integer is 
	variable depth  : integer := bit_depth;
	  begin
	    if (depth = 0) then
	      return(0);
	    else
	      for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	        if(depth <= 1) then 
	          return(clogb2);      
	        else
	          depth := depth / 2;
	        end if;
	      end loop;
	    end if;
	end;    

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS  : integer := 8;
	-- bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	constant bit_num  : integer := clogb2(NUMBER_OF_INPUT_WORDS-1);
	-- Define the states of state machine
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO
	type state is ( IDLE,        -- This is the initial/idle state 
	                WRITE_FIFO); -- In this state FIFO is written with the
	                             -- input stream data S_AXIS_TDATA 
	signal axis_tready	: std_logic;
	-- State variable
	signal  mst_exec_state : state;  
	-- FIFO implementation signals
	signal  byte_index : integer;    
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- FIFO full flag
	signal fifo_full_flag : std_logic;
	-- FIFO write pointer
	signal write_pointer : integer range 0 to NUMBER_OF_INPUT_WORDS+1 ;
	-- sink has accepted all the streaming data and stored in FIFO
	signal writes_done : std_logic;

	type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector(((C_S_AXIS_TDATA_WIDTH/4)-1)downto 0);
  
	-- Counter for detecting lost packets
	signal counter          : std_logic_vector(15 downto 0);
  
  signal pkt_lost         : std_logic;
  signal pkt_lost_r       : std_logic;
  signal pkt_lost_trigger : std_logic;
  
  signal dropped_pkts     : std_logic_vector(31 downto 0);
  
begin
	-- I/O Connections assignments

	--S_AXIS_TREADY	<= axis_tready;
  S_AXIS_TREADY <= '1';
	-- Control state machine implementation
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      -- Synchronous reset (active low)
	      mst_exec_state      <= IDLE;
	    else
	      case (mst_exec_state) is
	        when IDLE     => 
	          -- The sink starts accepting tdata when 
	          -- there tvalid is asserted to mark the
	          -- presence of valid streaming data 
	          if (S_AXIS_TVALID = '1')then
	            mst_exec_state <= WRITE_FIFO;
	          else
	            mst_exec_state <= IDLE;
	          end if;
	      
	        when WRITE_FIFO => 
	          -- When the sink has accepted all the streaming input data,
	          -- the interface swiches functionality to a streaming master
	          if (writes_done = '1') then
	            mst_exec_state <= IDLE;
	          else
	            -- The sink accepts and stores tdata 
	            -- into FIFO
	            mst_exec_state <= WRITE_FIFO;
	          end if;
	        
	        when others    => 
	          mst_exec_state <= IDLE;
	        
	      end case;
	    end if;  
	  end if;
	end process;
	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	axis_tready <= '1' when ((mst_exec_state = WRITE_FIFO) and (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) else '0';

	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      write_pointer <= 0;
	      writes_done <= '0';
	    else
	      if (write_pointer <= NUMBER_OF_INPUT_WORDS-1) then
	        if (fifo_wren = '1') then
	          -- write pointer is incremented after every write to the FIFO
	          -- when FIFO write signal is enabled.
	          write_pointer <= write_pointer + 1;
	          writes_done <= '0';
	        end if;
	        if ((write_pointer = NUMBER_OF_INPUT_WORDS-1) or S_AXIS_TLAST = '1') then
	          -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	          -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
	          writes_done <= '1';
	        end if;
	      end  if;
	    end if;
	  end if;
	end process;

	-- FIFO write enable generation
	fifo_wren <= S_AXIS_TVALID and axis_tready;

	-- FIFO Implementation
	 FIFO_GEN: for byte_index in 0 to (C_S_AXIS_TDATA_WIDTH/8-1) generate

	 signal stream_data_fifo : BYTE_FIFO_TYPE;
	 begin   
	  -- Streaming input data is stored in FIFO
	  process(S_AXIS_ACLK)
	  begin
	    if (rising_edge (S_AXIS_ACLK)) then
	      if (fifo_wren = '1') then
	        stream_data_fifo(write_pointer) <= S_AXIS_TDATA((byte_index*8+7) downto (byte_index*8));
	      end if;  
	    end  if;
	  end process;

	end generate FIFO_GEN;

  -- Timer for detecting lost packets
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      counter <= max_delay_i;
	    else
        -- Load counter when last data received from a packet
	      if (last_data_i = '1') then
          counter <= max_delay_i;
        elsif (counter /= 0) then
          counter <= counter - 1;
	      end  if;
	    end if;
	  end if;
	end process;
  
  pkt_lost <= '1' when (counter = 0) else '0';

  -- Packet lost register
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      pkt_lost_r <= '0';
	    else
	      pkt_lost_r <= pkt_lost;
	    end if;
	  end if;
	end process;
  
  pkt_lost_trigger <= '1' when ((pkt_lost = '1') and (pkt_lost_r = '0')) else '0';
  
  -- Packet lossed counter
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if((S_AXIS_ARESETN = '0') or (rst_counters_i = '1')) then
	      dropped_pkts <= (others => '0');
	    else
        -- Increment counter when triggered
	      if (pkt_lost_trigger = '1') then
          dropped_pkts <= dropped_pkts + 1;
	      end  if;
	    end if;
	  end if;
	end process;
  
  -- Outputs
  dropped_pkts_o <= dropped_pkts;

end arch_imp;
