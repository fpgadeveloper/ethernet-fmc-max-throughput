--------------------------------------------------------------------------------
-- RTL Testbench for the Ethernet Traffic Generator IP
-- Opsero Electronic Design Inc.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_loopback is
end tb_loopback;

architecture tb of tb_loopback is

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant CLOCK_PERIOD   : time := 100 ns;
  constant T_HOLD         : time := 10 ns;
  constant T_STROBE       : time := CLOCK_PERIOD - (1 ns);
  constant T_RST          : time := 1000 ns;

  -----------------------------------------------------------------------
  -- DUT input signals
  -----------------------------------------------------------------------

  -- General inputs
  signal ap_clk : STD_LOGIC;
  signal init_done : STD_LOGIC;
  signal reset_n : STD_LOGIC;
  signal init_start :  STD_LOGIC;
  signal s_axis_rxd_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_rxd_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axis_rxd_tlast : STD_LOGIC_VECTOR ( 0 to 0 );
  signal s_axis_rxd_tready : STD_LOGIC;
  signal s_axis_rxd_tvalid : STD_LOGIC;
  signal s_axis_rxs_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_rxs_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axis_rxs_tlast : STD_LOGIC_VECTOR ( 0 to 0 );
  signal s_axis_rxs_tready : STD_LOGIC;
  signal s_axis_rxs_tvalid : STD_LOGIC;
  signal m_axis_txc_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal m_axis_txc_tlast : STD_LOGIC_VECTOR ( 0 to 0 );
  signal m_axis_txc_tready : STD_LOGIC;
  signal m_axis_txc_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal m_axis_txc_tvalid : STD_LOGIC;
  signal m_axis_txd_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal m_axis_txd_tlast : STD_LOGIC_VECTOR ( 0 to 0 );
  signal m_axis_txd_tready : STD_LOGIC;
  signal m_axis_txd_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal m_axis_txd_tvalid : STD_LOGIC;

  

  signal end_of_simulation : boolean := false;

begin

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------

design_2_wrapper_inst : entity work.design_2_wrapper
	port map (
    ap_clk => ap_clk,
    init_done => init_done,
    reset_n => reset_n,
    init_start => init_start,
    s_axis_rxd_tdata(31 downto 0) => s_axis_rxd_tdata(31 downto 0),
    s_axis_rxd_tkeep(3 downto 0) => s_axis_rxd_tkeep(3 downto 0),
    s_axis_rxd_tlast(0) => s_axis_rxd_tlast(0),
    s_axis_rxd_tready => s_axis_rxd_tready,
    s_axis_rxd_tvalid => s_axis_rxd_tvalid,
    s_axis_rxs_tdata(31 downto 0) => s_axis_rxs_tdata(31 downto 0),
    s_axis_rxs_tkeep(3 downto 0) => s_axis_rxs_tkeep(3 downto 0),
    s_axis_rxs_tlast(0) => s_axis_rxs_tlast(0),
    s_axis_rxs_tready => s_axis_rxs_tready,
    s_axis_rxs_tvalid => s_axis_rxs_tvalid,
    m_axis_txc_tdata(31 downto 0) => m_axis_txc_tdata(31 downto 0),
    m_axis_txc_tlast(0) => m_axis_txc_tlast(0),
    m_axis_txc_tready => m_axis_txc_tready,
    m_axis_txc_tkeep(3 downto 0) => m_axis_txc_tkeep(3 downto 0),
    m_axis_txc_tvalid => m_axis_txc_tvalid,
    m_axis_txd_tdata(31 downto 0) => m_axis_txd_tdata(31 downto 0),
    m_axis_txd_tlast(0) => m_axis_txd_tlast(0),
    m_axis_txd_tready => m_axis_txd_tready,
    m_axis_txd_tkeep(3 downto 0) => m_axis_txd_tkeep(3 downto 0),
    m_axis_txd_tvalid => m_axis_txd_tvalid
  );

  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------

  -- Clock generator
  clock_x_gen : process
  begin
    ap_clk <= '0';
    if (end_of_simulation) then
      wait;
    else
      wait for CLOCK_PERIOD;
      loop
        ap_clk <= '0';
        wait for CLOCK_PERIOD/2;
        ap_clk <= '1';
        wait for CLOCK_PERIOD/2;
      end loop;
    end if;
  end process clock_x_gen;

  -----------------------------------------------------------------------
  -- TX-RX loopback
  -----------------------------------------------------------------------
  s_axis_rxd_tdata <= m_axis_txd_tdata;
  s_axis_rxd_tkeep <= m_axis_txd_tkeep;
  s_axis_rxd_tlast(0) <= m_axis_txd_tlast(0);
  s_axis_rxd_tvalid <= m_axis_txd_tvalid;
  s_axis_rxs_tdata <= m_axis_txc_tdata;
  s_axis_rxs_tkeep <= m_axis_txc_tkeep;
  s_axis_rxs_tlast(0) <= m_axis_txc_tlast(0);
  s_axis_rxs_tvalid <= m_axis_txc_tvalid;
  m_axis_txc_tready <= s_axis_rxs_tready;
  m_axis_txd_tready <= s_axis_rxd_tready;
  
  -----------------------------------------------------------------------
  -- Generate inputs
  -----------------------------------------------------------------------

  stimuli : process
    variable bytenum : unsigned(7 downto 0);  -- byte number
  begin
    init_start <= '0';
    reset_n <= '0';

    -- Drive inputs T_HOLD time after rising edge of clock
    wait until rising_edge(ap_clk);
    wait for T_HOLD;

    -- Release reset
    wait for T_RST;
    reset_n <= '1';
    
    -- Start AXI software register initialization
    init_start <= '1';
    
    -- Wait until software registers are initialized
    wait until init_done = '1';
    init_start <= '0';
    
    -- Allow some time for packets to flow
    wait for CLOCK_PERIOD*500;
    
    -- End of test
    end_of_simulation <= true;           
    report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
    wait;

  end process stimuli;



end tb;

