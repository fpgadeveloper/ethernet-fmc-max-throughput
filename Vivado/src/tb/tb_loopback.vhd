--------------------------------------------------------------------------------
-- RTL Testbench for the Ethernet Traffic Generator IP
-- Opsero Electronic Design Inc.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.eth_traffic_gen_0;

entity tb_loopback is
end tb_loopback;

architecture tb of tb_loopback is

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant CLOCK_PERIOD   : time := 5 ns;
  constant T_HOLD         : time := 10 ns;
  constant T_STROBE       : time := CLOCK_PERIOD - (1 ns);
  constant T_RST          : time := 15 ns;

  -----------------------------------------------------------------------
  -- DUT input signals
  -----------------------------------------------------------------------

  -- General inputs
  signal ap_clk : STD_LOGIC;
  signal ap_rst_n : STD_LOGIC;
  signal s_axis_rxd_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_rxd_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axis_rxd_tstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axis_rxd_tlast : STD_LOGIC_VECTOR ( 0 to 0 );
  signal s_axis_rxd_tready : STD_LOGIC;
  signal s_axis_rxd_tvalid : STD_LOGIC;
  signal s_axis_rxs_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_rxs_tkeep : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axis_rxs_tstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
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

  signal S_AXI_AWADDR  :  std_logic_vector(7 downto 0);
  signal S_AXI_AWVALID :  std_logic;
  signal S_AXI_WDATA   :  std_logic_vector(31 downto 0);
  signal S_AXI_WSTRB   :  std_logic_vector((32/8)-1 downto 0);
  signal S_AXI_WVALID  :  std_logic;
  signal S_AXI_BREADY  :  std_logic;
  signal S_AXI_ARADDR  :  std_logic_vector(5 downto 0);
  signal S_AXI_ARVALID :  std_logic;
  signal S_AXI_RREADY  :  std_logic;
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA   : std_logic_vector(31 downto 0);
  signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID  : std_logic;
  signal S_AXI_WREADY  : std_logic;
  signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID  : std_logic;
  signal S_AXI_AWREADY : std_logic;
  

  signal end_of_simulation : boolean := false;
    
  shared variable ClockCount : integer range 0 to 50_000 := 10;
  signal sendIt : std_logic := '0';
  signal readIt : std_logic := '0';
    
begin

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------

  eth_traffic_gen: entity work.eth_traffic_gen_0
    port map (
      ap_clk => ap_clk,
      ap_rst_n => ap_rst_n,
      s_axi_p0_AWADDR  => S_AXI_AWADDR(5 downto 0),
      s_axi_p0_awvalid => S_AXI_AWVALID,
      s_axi_p0_awready => S_AXI_AWREADY,
      s_axi_p0_wdata   => S_AXI_WDATA,
      s_axi_p0_wstrb   => S_AXI_WSTRB,
      s_axi_p0_wvalid  => S_AXI_WVALID,
      s_axi_p0_wready  => S_AXI_WREADY,
      s_axi_p0_bresp   => S_AXI_BRESP,
      s_axi_p0_bvalid  => S_AXI_BVALID,
      s_axi_p0_bready  => S_AXI_BREADY,
      s_axi_p0_araddr  => S_AXI_ARADDR,
      s_axi_p0_arvalid => S_AXI_ARVALID,
      s_axi_p0_arready => S_AXI_ARREADY,
      s_axi_p0_rdata   => S_AXI_RDATA,
      s_axi_p0_rresp   => S_AXI_RRESP,
      s_axi_p0_rvalid  => S_AXI_RVALID,
      s_axi_p0_rready  => S_AXI_RREADY,
    s_axis_rxd_TDATA(31 downto 0) => s_axis_rxd_tdata(31 downto 0),
    s_axis_rxd_TKEEP(3 downto 0) => s_axis_rxd_tkeep(3 downto 0),
    s_axis_rxd_TSTRB(3 downto 0) => s_axis_rxd_tstrb(3 downto 0), 
    s_axis_rxd_tlast(0) => s_axis_rxd_tlast(0),
    s_axis_rxd_tready => s_axis_rxd_tready,
    s_axis_rxd_tvalid => s_axis_rxd_tvalid,
    s_axis_rxs_tdata(31 downto 0) => s_axis_rxs_tdata(31 downto 0),
    s_axis_rxs_tkeep(3 downto 0) => s_axis_rxs_tkeep(3 downto 0),
    s_axis_rxs_tstrb(3 downto 0) => s_axis_rxs_tstrb(3 downto 0), 
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

 S_AXI_AWADDR(7 downto 6) <= "00"; 

 -- Generate ap_clk signal
 GENERATE_REFCLOCK : process
 begin
   wait for (CLOCK_PERIOD / 2);
   ClockCount:= ClockCount+1;
   ap_clk <= '1';
   wait for (CLOCK_PERIOD / 2);
   ap_clk <= '0';
 end process;

 -- Initiate process which simulates a master wanting to write.
 -- This process is blocked on a "Send Flag" (sendIt).
 -- When the flag goes to 1, the process exits the wait state and
 -- execute a write transaction.
 send : PROCESS
 BEGIN
    S_AXI_AWVALID<='0';
    S_AXI_WVALID<='0';
    S_AXI_BREADY<='0';
    loop
        wait until sendIt = '1';
        wait until ap_clk= '0';
            S_AXI_AWVALID<='1';
            S_AXI_WVALID<='1';
        wait until (S_AXI_AWREADY and S_AXI_WREADY) = '1';  --Client ready to read address/data        
            S_AXI_BREADY<='1';
        wait until S_AXI_BVALID = '1';  -- Write result valid
            assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
            S_AXI_AWVALID<='0';
            S_AXI_WVALID<='0';
            S_AXI_BREADY<='1';
        wait until S_AXI_BVALID = '0';  -- All finished
            S_AXI_BREADY<='0';
    end loop;
 END PROCESS send;

  -- Initiate process which simulates a master wanting to read.
  -- This process is blocked on a "Read Flag" (readIt).
  -- When the flag goes to 1, the process exits the wait state and
  -- execute a read transaction.
  read : PROCESS
  BEGIN
    S_AXI_ARVALID<='0';
    S_AXI_RREADY<='0';
     loop
         wait until readIt = '1';
         wait until ap_clk= '0';
             S_AXI_ARVALID<='1';
             S_AXI_RREADY<='1';
         wait until (S_AXI_RVALID and S_AXI_ARREADY) = '1';  --Client provided data
            assert S_AXI_RRESP = "00" report "AXI data not written" severity failure;
             S_AXI_ARVALID<='0';
            S_AXI_RREADY<='0';
     end loop;
  END PROCESS read;

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
    ap_rst_n <= '0';
    sendIt <= '0';

    -- Drive inputs T_HOLD time after rising edge of clock
    wait until rising_edge(ap_clk);
    wait for T_HOLD;

    -- Release reset
    wait for T_RST;
    ap_rst_n <= '1';
    
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"00";         -- dst mac addr lo
    S_AXI_WDATA<=x"FFFF1E00";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"20";         -- dst mac addr hi
    S_AXI_WDATA<=x"0000FFFF";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"28";         -- src mac addr lo
    S_AXI_WDATA<=x"A4A52737";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"30";         -- src mac addr hi
    S_AXI_WDATA<=x"0000FFFF";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"38";         -- packet length
    S_AXI_WDATA<=x"00000010";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished
    S_AXI_WSTRB<=b"0000";
    S_AXI_AWADDR<=x"10";         -- force error
    S_AXI_WDATA<=x"00000001";
    S_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
    wait until S_AXI_BVALID = '1';
    wait until S_AXI_BVALID = '0';  --AXI Write finished

    -- Wait until software registers are initialized
    wait for 1 ns;
    
    -- Allow some time for packets to flow
    wait for CLOCK_PERIOD*500;
    
    -- End of test
    end_of_simulation <= true;           
    report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
    wait;

  end process stimuli;



end tb;

