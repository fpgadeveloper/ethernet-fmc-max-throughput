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
  -- DUT constants
  -----------------------------------------------------------------------
	-- Parameters of Axi Slave Bus Interface S_AXI
	constant C_S_AXI_DATA_WIDTH	: integer	:= 32;
	constant C_S_AXI_ADDR_WIDTH	: integer	:= 4;
   
	-- Parameters of Axi Slave Bus Interface S_AXIS
	constant C_S_AXIS_TDATA_WIDTH	: integer	:= 32;
   
	-- Parameters of Axi Master Bus Interface M_AXIS
	constant C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
	constant C_M_AXIS_START_COUNT	: integer	:= 32;
  
  -----------------------------------------------------------------------
  -- DUT input signals
  -----------------------------------------------------------------------

  -- General inputs
  signal aresetn        : std_logic := '0';
  signal aclk           : std_logic := '0';  -- the master clock

	-- Ports of Axi Slave Bus Interface S_AXI
	signal s_axi_aclk   	: std_logic := '0';
	signal s_axi_aresetn	: std_logic := '0';
	signal s_axi_awaddr	  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal s_axi_awprot	  : std_logic_vector(2 downto 0) := (others => '0');
	signal s_axi_awvalid	: std_logic := '0';
	signal s_axi_awready	: std_logic := '0';
	signal s_axi_wdata	  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
	signal s_axi_wstrb	  : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
	signal s_axi_wvalid	  : std_logic := '0';
	signal s_axi_wready	  : std_logic := '0';
	signal s_axi_bresp	  : std_logic_vector(1 downto 0) := (others => '0');
	signal s_axi_bvalid	  : std_logic := '0';
	signal s_axi_bready	  : std_logic := '0';
	signal s_axi_araddr	  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal s_axi_arprot	  : std_logic_vector(2 downto 0) := (others => '0');
	signal s_axi_arvalid	: std_logic := '0';
	signal s_axi_arready	: std_logic := '0';
	signal s_axi_rdata	  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
	signal s_axi_rresp	  : std_logic_vector(1 downto 0) := (others => '0');
	signal s_axi_rvalid	  : std_logic := '0';
	signal s_axi_rready	  : std_logic := '0';

	-- Ports of Axi Slave Bus Interface S_AXIS_RXD
	signal s_axis_rxd_aclk	  : std_logic := '0';
	signal s_axis_rxd_aresetn	: std_logic := '0';
	signal s_axis_rxd_tready	: std_logic := '0';
	signal s_axis_rxd_tdata	  : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
	signal s_axis_rxd_keep	  : std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
	signal s_axis_rxd_tlast	  : std_logic := '0';
	signal s_axis_rxd_tvalid	: std_logic := '0';

	-- Ports of Axi Slave Bus Interface S_AXIS_RXS
	signal s_axis_rxs_aclk	  : std_logic := '0';
	signal s_axis_rxs_aresetn	: std_logic := '0';
	signal s_axis_rxs_tready	: std_logic := '0';
	signal s_axis_rxs_tdata	  : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
	signal s_axis_rxs_keep	  : std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
	signal s_axis_rxs_tlast	  : std_logic := '0';
	signal s_axis_rxs_tvalid	: std_logic := '0';

	-- Ports of Axi Master Bus Interface M_AXIS_TXD
	signal m_axis_txd_aclk	  : std_logic := '0';
	signal m_axis_txd_aresetn	: std_logic := '0';
	signal m_axis_txd_tvalid	: std_logic := '0';
	signal m_axis_txd_tdata	  : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
	signal m_axis_txd_tkeep	  : std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
	signal m_axis_txd_tlast	  : std_logic := '0';
	signal m_axis_txd_tready	: std_logic := '0';
  
	-- Ports of Axi Master Bus Interface M_AXIS_TXC
	signal m_axis_txc_aclk	  : std_logic := '0';
	signal m_axis_txc_aresetn	: std_logic := '0';
	signal m_axis_txc_tvalid	: std_logic := '0';
	signal m_axis_txc_tdata	  : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
	signal m_axis_txc_tkeep	  : std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
	signal m_axis_txc_tlast	  : std_logic := '0';
	signal m_axis_txc_tready	: std_logic := '0';
  
  -----------------------------------------------------------------------
  -- Aliases for AXI channel TDATA and TUSER fields
  -- These are a convenience for viewing data in a simulator waveform viewer.
  -- If using ModelSim or Questa, add "-voptargs=+acc=n" to the vsim command
  -- to prevent the simulator optimizing away these signals.
  -----------------------------------------------------------------------


  signal end_of_simulation : boolean := false;

  --signal force_error : std_logic := '0';
  --signal force_drop  : std_logic := '0';
  
begin

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------

eth_traffic_gen_v1_0_inst : entity work.eth_traffic_gen_v1_0
	port map (
		-- Users to add ports here
    --force_error_i => force_error,
    --force_drop_i  => force_drop,
		-- User ports ends
		-- Do not modify the ports beyond this line
		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	  => s_axi_aclk	  ,
		s_axi_aresetn	=> s_axi_aresetn	,
		s_axi_awaddr	=> s_axi_awaddr	,
		s_axi_awprot	=> s_axi_awprot	,
		s_axi_awvalid	=> s_axi_awvalid	,
		s_axi_awready	=> s_axi_awready	,
		s_axi_wdata	  => s_axi_wdata	  ,
		s_axi_wstrb	  => s_axi_wstrb	  ,
		s_axi_wvalid	=> s_axi_wvalid	,
		s_axi_wready	=> s_axi_wready	,
		s_axi_bresp	  => s_axi_bresp	  ,
		s_axi_bvalid	=> s_axi_bvalid	,
		s_axi_bready	=> s_axi_bready	,
		s_axi_araddr	=> s_axi_araddr	,
		s_axi_arprot	=> s_axi_arprot	,
		s_axi_arvalid	=> s_axi_arvalid	,
		s_axi_arready	=> s_axi_arready	,
		s_axi_rdata	  => s_axi_rdata	  ,
		s_axi_rresp	  => s_axi_rresp	  ,
		s_axi_rvalid	=> s_axi_rvalid	,
		s_axi_rready	=> s_axi_rready	,

		-- Ports of Axi Slave Bus Interface S_AXIS_RXD
		s_axis_rxd_aclk	    => s_axis_rxd_aclk	  ,
		s_axis_rxd_aresetn	=> s_axis_rxd_aresetn,
		s_axis_rxd_tready	  => s_axis_rxd_tready	,
		s_axis_rxd_tdata	  => s_axis_rxd_tdata	,
    s_axis_rxd_keep    => s_axis_rxd_keep,
		s_axis_rxd_tlast	  => s_axis_rxd_tlast	,
		s_axis_rxd_tvalid	  => s_axis_rxd_tvalid	,

		-- Ports of Axi Slave Bus Interface S_AXIS_RXS
		s_axis_rxs_aclk	    => s_axis_rxs_aclk	  ,
		s_axis_rxs_aresetn	=> s_axis_rxs_aresetn,
		s_axis_rxs_tready	  => s_axis_rxs_tready	,
		s_axis_rxs_tdata	  => s_axis_rxs_tdata	,
    s_axis_rxs_keep    => s_axis_rxs_keep,
		s_axis_rxs_tlast	  => s_axis_rxs_tlast	,
		s_axis_rxs_tvalid	  => s_axis_rxs_tvalid	,

		-- Ports of Axi Master Bus Interface M_AXIS_TXD
		m_axis_txd_aclk	    => m_axis_txd_aclk	  ,
		m_axis_txd_aresetn	=> m_axis_txd_aresetn,
		m_axis_txd_tvalid	  => m_axis_txd_tvalid	,
		m_axis_txd_tdata	  => m_axis_txd_tdata	,
    m_axis_txd_tkeep    => m_axis_txd_tkeep,
		m_axis_txd_tlast	  => m_axis_txd_tlast	,
		m_axis_txd_tready	  => m_axis_txd_tready,

		-- Ports of Axi Master Bus Interface M_AXIS_TXC
		m_axis_txc_aclk	    => m_axis_txc_aclk	  ,
		m_axis_txc_aresetn	=> m_axis_txc_aresetn,
		m_axis_txc_tvalid	  => m_axis_txc_tvalid	,
		m_axis_txc_tdata	  => m_axis_txc_tdata	,
    m_axis_txc_tkeep    => m_axis_txc_tkeep,
		m_axis_txc_tlast	  => m_axis_txc_tlast	,
		m_axis_txc_tready	  => m_axis_txc_tready
  );

  -- AXI slave
  s_axi_aclk <= aclk;
  s_axi_aresetn <= aresetn;
  
  -- AXI streaming slave
  s_axis_rxd_aclk <= aclk;
  s_axis_rxd_aresetn <= aresetn;
  s_axis_rxs_aclk <= aclk;
  s_axis_rxs_aresetn <= aresetn;
  
  -- AXI streaming master
  m_axis_txd_aclk <= aclk;
  m_axis_txd_aresetn <= aresetn;
  m_axis_txc_aclk <= aclk;
  m_axis_txc_aresetn <= aresetn;
  
  ---- TXD to RXD loopback
  --s_axis_rxd_tvalid	 <= m_axis_txd_tvalid;
  --s_axis_rxd_tdata	 <= m_axis_txd_tdata;
  --s_axis_rxd_keep    <= m_axis_txd_tkeep;
  --s_axis_rxd_tlast	 <= m_axis_txd_tlast;
  --m_axis_txd_tready  <= s_axis_rxd_tready;
  --
  ---- TXC to RXS loopback
  --s_axis_rxs_tvalid  <= m_axis_txc_tvalid;
  --s_axis_rxs_tdata	 <= m_axis_txc_tdata;
  --s_axis_rxs_keep    <= m_axis_txc_tkeep;
  --s_axis_rxs_tlast	 <= m_axis_txc_tlast;
  --m_axis_txc_tready  <= s_axis_rxs_tready;
  
  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------

  -- Clock generator
  clock_x_gen : process
  begin
    aclk <= '0';
    if (end_of_simulation) then
      wait;
    else
      wait for CLOCK_PERIOD;
      loop
        aclk <= '0';
        wait for CLOCK_PERIOD/2;
        aclk <= '1';
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
    aresetn <= '0';

    -- Drive inputs T_HOLD time after rising edge of clock
    wait until rising_edge(aclk);
    wait for T_HOLD;

    wait for T_RST;
    aresetn <= '1';
    
    wait for CLOCK_PERIOD*3;
    
    -- Ready for receive control data
    m_axis_txc_tready <= '1';
    
    --for cycle in 0 to 5 loop
    --  wait until m_axis_txc_tdata = X"A0000000";
    --  wait for CLOCK_PERIOD*2;
    --  m_axis_txc_tready <= '0';
    --  wait for CLOCK_PERIOD*4;
    --  m_axis_txc_tready <= '1';
    --  
    --  -- When last control word is sent:
    --  -- * deassert TXC tready
    --  -- * assert TXD tready
    --  wait until m_axis_txc_tlast = '1';
    --  wait for CLOCK_PERIOD;
    --  m_axis_txc_tready <= '0';
    --  wait for CLOCK_PERIOD*3;
    --  m_axis_txd_tready <= '1';
    --  
    --  -- When last data word is sent:
    --  -- * deassert TXD tready
    --  -- * assert TXC tready
    --  wait until m_axis_txd_tlast = '1';
    --  wait for CLOCK_PERIOD;
    --  m_axis_txd_tready <= '0';
    --  wait for CLOCK_PERIOD*5;
    --  m_axis_txc_tready <= '1';
    --end loop;
    --
    --force_drop <= '1';
    
    for cycle in 0 to 5 loop
      wait until m_axis_txc_tdata = X"A0000000";
      wait for CLOCK_PERIOD*2;
      m_axis_txc_tready <= '0';
      wait for CLOCK_PERIOD*4;
      m_axis_txc_tready <= '1';
      
      -- When last control word is sent:
      -- * deassert TXC tready
      -- * assert TXD tready
      wait until m_axis_txc_tlast = '1';
      wait for CLOCK_PERIOD;
      m_axis_txc_tready <= '0';
      wait for CLOCK_PERIOD*3;
      m_axis_txd_tready <= '1';
      
      -- When last data word is sent:
      -- * deassert TXD tready
      -- * assert TXC tready
      wait until m_axis_txd_tlast = '1';
      wait for CLOCK_PERIOD;
      m_axis_txd_tready <= '0';
      wait for CLOCK_PERIOD*5;
      m_axis_txc_tready <= '1';
    end loop;
    
    wait for CLOCK_PERIOD*500;
    
    -- End of test
    end_of_simulation <= true;           
    report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
    wait;

  end process stimuli;



end tb;

