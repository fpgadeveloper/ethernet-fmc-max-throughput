--------------------------------------------------------------------------------
-- Testbench for the Slave AXI interface
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

  --signal force_error : std_logic := '0';
  --signal force_drop  : std_logic := '0';
  
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
  -- Generate inputs
  -----------------------------------------------------------------------

  stimuli : process
    variable bytenum : unsigned(7 downto 0);  -- byte number
  begin
  -- leave RXS and RXD grounded
    s_axis_rxd_tdata(31 downto 0) <= (others => '0');
    s_axis_rxd_tkeep(3 downto 0) <= (others => '1');
    s_axis_rxd_tlast(0) <= '0';
    s_axis_rxd_tvalid <= '0';
    s_axis_rxs_tdata(31 downto 0) <= (others => '0');
    s_axis_rxs_tkeep(3 downto 0) <= (others => '1');
    s_axis_rxs_tlast(0) <= '0';
    s_axis_rxs_tvalid <= '0';

  
    m_axis_txc_tready <= '0';
    m_axis_txd_tready <= '0';
    init_start <= '0';
--    start_traffic_gen <= '0';    
    reset_n <= '0';

    -- Drive inputs T_HOLD time after rising edge of clock
    wait until rising_edge(ap_clk);
    wait for T_HOLD;

    wait for T_RST;
    reset_n <= '1';
    
    -- start AXI register initialization
    init_start <= '1';
    
    wait until init_done = '1';
--    wait for CLOCK_PERIOD;
    init_start <= '0';
--    start_traffic_gen <= '1';    
    
    --wait until m_axis_txc_tdata = X"A0000000";
    wait for CLOCK_PERIOD*3;
    
    for cycle in 0 to 5 loop
      -- Ready for receive control data
      m_axis_txc_tready <= '1';
      m_axis_txd_tready <= '1';
      --wait until txc_tdata = X"A0000000";
      --wait for CLOCK_PERIOD*2;
      --m_axis_txc_tready <= '0';
      --wait for CLOCK_PERIOD*4;
      --m_axis_txc_tready <= '1';
      
      -- When last control word is sent:
      -- * deassert TXC tready
      -- * assert TXD tready
      wait until m_axis_txc_tlast(0) = '1';
      wait for CLOCK_PERIOD;
      m_axis_txc_tready <= '0';
      wait for CLOCK_PERIOD*3;
      m_axis_txd_tready <= '1';
      
      -- When last data word is sent:
      -- * deassert TXD tready
      -- * assert TXC tready
      wait until m_axis_txd_tlast(0) = '1';
      wait for CLOCK_PERIOD;
      m_axis_txd_tready <= '0';
      wait for CLOCK_PERIOD*5;
      --m_axis_txc_tready <= '1';
    end loop;
    
    wait for CLOCK_PERIOD*500;
    
    -- End of test
    end_of_simulation <= true;           
    report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
    wait;

  end process stimuli;



end tb;

