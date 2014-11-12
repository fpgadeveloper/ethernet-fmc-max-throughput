library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity eth_traffic_gen_v1_0_S_AXIS_RXD is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
    rst_counters_i : in std_logic;
    bit_errors_o   : out std_logic_vector(31 downto 0);
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
		S_AXIS_KEEP 	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end eth_traffic_gen_v1_0_S_AXIS_RXD;

architecture arch_imp of eth_traffic_gen_v1_0_S_AXIS_RXD is

	-- Total number of output data                                              
	constant NUMBER_OF_INPUT_WORDS : integer := 16;                                   

  type FRAME is array (0 to NUMBER_OF_INPUT_WORDS-1) of std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);

  -- Ethernet frame to expect - includes FCS (checksum) in the last word
  constant framedata : FRAME := (
                                  X"FFFFFFFF",X"1E00FFFF",X"A4A52737",X"01000608",
                                  X"04060008",X"1E000100",X"A4A52737",X"0101A8C0",
                                  X"00000000",X"A8C00000",X"00000A01",X"00000000",
                                  X"00000000",X"00000000",X"00000000",X"A63112B7"
                                  );

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
	-- FIFO full flag
	signal fifo_full_flag : std_logic;
	-- FIFO write pointer
	signal read_pointer : integer range 0 to NUMBER_OF_INPUT_WORDS+1 ;
	-- sink has accepted all the streaming data and stored in FIFO
	signal writes_done : std_logic;

  signal errors       : std_logic_vector(31 downto 0);
  signal total_errors : std_logic_vector(31 downto 0);
  
begin
	-- I/O Connections assignments

	S_AXIS_TREADY	<= '1';
  
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      read_pointer <= 0;
	    else
	      if (read_pointer <= NUMBER_OF_INPUT_WORDS-1) then
	        if (S_AXIS_TVALID = '1') then
	          -- write pointer is incremented after every write to the FIFO
	          -- when FIFO write signal is enabled.
	          read_pointer <= read_pointer + 1;
	        end if;
	        if ((read_pointer = NUMBER_OF_INPUT_WORDS-1) or S_AXIS_TLAST = '1') then
	          -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	          -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
            read_pointer <= 0;
	        end if;
	      end  if;
	    end if;
	  end if;
	end process;

	-- Error detector
	process (S_AXIS_ACLK)
	begin
		if (rising_edge (S_AXIS_ACLK)) then
			if (S_AXIS_ARESETN = '0') then
				errors <= (others => '0');
			-- If data in registered is valid, compare with buffer
			elsif (S_AXIS_TVALID = '1') then
				errors <= S_AXIS_TDATA xor framedata(read_pointer);
			else
				errors <= (others => '0');
			end if;
		end if;
	end process;

	-- Total errors
	process (S_AXIS_ACLK)
	begin
		if (rising_edge (S_AXIS_ACLK)) then
			if ((S_AXIS_ARESETN = '0') or (rst_counters_i = '1')) then
				total_errors <= (others => '0');
			else
				total_errors <= total_errors + errors;
			end if;
		end if;
	end process;

  -- Outputs
  bit_errors_o <= total_errors;
  
end arch_imp;
