library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity eth_traffic_gen_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Master Bus Interface M_AXIS_TXD
		C_M_AXIS_TXD_TDATA_WIDTH	: integer	:= 32;
		C_M_AXIS_TXD_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M_AXIS_TXC
		C_M_AXIS_TXC_TDATA_WIDTH	: integer	:= 32;
		C_M_AXIS_TXC_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S_AXIS_RXD
		C_S_AXIS_RXD_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S_AXIS_RXS
		C_S_AXIS_RXS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Master Bus Interface M_AXIS_TXD
		m_axis_txd_aclk	: in std_logic;
		m_axis_txd_aresetn	: in std_logic;
		m_axis_txd_tvalid	: out std_logic;
		m_axis_txd_tdata	: out std_logic_vector(C_M_AXIS_TXD_TDATA_WIDTH-1 downto 0);
		m_axis_txd_tkeep	: out std_logic_vector((C_M_AXIS_TXD_TDATA_WIDTH/8)-1 downto 0);
		m_axis_txd_tlast	: out std_logic;
		m_axis_txd_tready	: in std_logic;

		-- Ports of Axi Master Bus Interface M_AXIS_TXC
		m_axis_txc_aclk	: in std_logic;
		m_axis_txc_aresetn	: in std_logic;
		m_axis_txc_tvalid	: out std_logic;
		m_axis_txc_tdata	: out std_logic_vector(C_M_AXIS_TXC_TDATA_WIDTH-1 downto 0);
		m_axis_txc_tkeep	: out std_logic_vector((C_M_AXIS_TXC_TDATA_WIDTH/8)-1 downto 0);
		m_axis_txc_tlast	: out std_logic;
		m_axis_txc_tready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXIS_RXD
		s_axis_rxd_aclk	: in std_logic;
		s_axis_rxd_aresetn	: in std_logic;
		s_axis_rxd_tready	: out std_logic;
		s_axis_rxd_tdata	: in std_logic_vector(C_S_AXIS_RXD_TDATA_WIDTH-1 downto 0);
		s_axis_rxd_keep	: in std_logic_vector((C_S_AXIS_RXD_TDATA_WIDTH/8)-1 downto 0);
		s_axis_rxd_tlast	: in std_logic;
		s_axis_rxd_tvalid	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXIS_RXS
		s_axis_rxs_aclk	: in std_logic;
		s_axis_rxs_aresetn	: in std_logic;
		s_axis_rxs_tready	: out std_logic;
		s_axis_rxs_tdata	: in std_logic_vector(C_S_AXIS_RXS_TDATA_WIDTH-1 downto 0);
		s_axis_rxs_keep	: in std_logic_vector((C_S_AXIS_RXS_TDATA_WIDTH/8)-1 downto 0);
		s_axis_rxs_tlast	: in std_logic;
		s_axis_rxs_tvalid	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
end eth_traffic_gen_v1_0;

architecture arch_imp of eth_traffic_gen_v1_0 is

	-- component declaration
	component eth_traffic_gen_v1_0_M_AXIS_TXD is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
    force_error_i : in std_logic;
    start_i       : in std_logic;
    insert_fcs_i  : in std_logic;
    fcs_word_i     : in std_logic_vector(31 downto 0);
    pkt_word_len_i : in std_logic_vector(31 downto 0);
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TKEEP	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component eth_traffic_gen_v1_0_M_AXIS_TXD;

	component eth_traffic_gen_v1_0_M_AXIS_TXC is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
    force_drop_i  : in std_logic;
    start_o       : out std_logic;
    last_data_i   : in std_logic;
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TKEEP	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component eth_traffic_gen_v1_0_M_AXIS_TXC;

	component eth_traffic_gen_v1_0_S_AXIS_RXD is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
    rst_counters_i : in std_logic;
    bit_errors_o   : out std_logic_vector(31 downto 0);
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_KEEP	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component eth_traffic_gen_v1_0_S_AXIS_RXD;

	component eth_traffic_gen_v1_0_S_AXIS_RXS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
    rst_counters_i  : in std_logic;
    last_data_i     : in std_logic;
    max_delay_i     : in std_logic_vector(15 downto 0);
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_KEEP	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component eth_traffic_gen_v1_0_S_AXIS_RXS;

	component eth_traffic_gen_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
    rst_counters_o      : out std_logic;
    force_error_o       : out std_logic;
    force_drop_o        : out std_logic;
    insert_fcs_o        : out std_logic;
    bit_errors_i        : in std_logic_vector(31 downto 0);
    max_delay_o         : out std_logic_vector(15 downto 0);
    fcs_word_o          : out std_logic_vector(31 downto 0);
    pkt_word_len_o      : out std_logic_vector(31 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component eth_traffic_gen_v1_0_S_AXI;

  signal start        : std_logic;
  signal rst_counters : std_logic;
  signal force_error  : std_logic;
  signal force_drop   : std_logic;
  signal insert_fcs   : std_logic;
  signal bit_errors   : std_logic_vector(31 downto 0);
  signal max_delay    : std_logic_vector(15 downto 0);
  signal fcs_word     : std_logic_vector(31 downto 0);
  signal pkt_word_len : std_logic_vector(31 downto 0);
  signal txc_last_data_in : std_logic;
  signal txd_tlast    : std_logic;
  
begin

-- Instantiation of Axi Bus Interface M_AXIS_TXD
eth_traffic_gen_v1_0_M_AXIS_TXD_inst : eth_traffic_gen_v1_0_M_AXIS_TXD
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M_AXIS_TXD_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M_AXIS_TXD_START_COUNT
	)
	port map (
    force_error_i => force_error,
    start_i       => start,
    insert_fcs_i  => insert_fcs,
    fcs_word_i     => fcs_word,
    pkt_word_len_i => pkt_word_len,
		M_AXIS_ACLK	=> m_axis_txd_aclk,
		M_AXIS_ARESETN	=> m_axis_txd_aresetn,
		M_AXIS_TVALID	=> m_axis_txd_tvalid,
		M_AXIS_TDATA	=> m_axis_txd_tdata,
		M_AXIS_TKEEP	=> m_axis_txd_tkeep,
		M_AXIS_TLAST	=> txd_tlast,
		M_AXIS_TREADY	=> m_axis_txd_tready
	);

  m_axis_txd_tlast <= txd_tlast;

-- Instantiation of Axi Bus Interface M_AXIS_TXC
eth_traffic_gen_v1_0_M_AXIS_TXC_inst : eth_traffic_gen_v1_0_M_AXIS_TXC
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M_AXIS_TXC_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M_AXIS_TXC_START_COUNT
	)
	port map (
    force_drop_i  => force_drop,
    start_o       => start,
    last_data_i   => txc_last_data_in,
		M_AXIS_ACLK	=> m_axis_txc_aclk,
		M_AXIS_ARESETN	=> m_axis_txc_aresetn,
		M_AXIS_TVALID	=> m_axis_txc_tvalid,
		M_AXIS_TDATA	=> m_axis_txc_tdata,
		M_AXIS_TKEEP	=> m_axis_txc_tkeep,
		M_AXIS_TLAST	=> m_axis_txc_tlast,
		M_AXIS_TREADY	=> m_axis_txc_tready
	);
  
  txc_last_data_in <= txd_tlast and m_axis_txd_tready;

-- Instantiation of Axi Bus Interface S_AXIS_RXD
eth_traffic_gen_v1_0_S_AXIS_RXD_inst : eth_traffic_gen_v1_0_S_AXIS_RXD
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S_AXIS_RXD_TDATA_WIDTH
	)
	port map (
    rst_counters_i => rst_counters,
    bit_errors_o  => bit_errors,
		S_AXIS_ACLK	=> s_axis_rxd_aclk,
		S_AXIS_ARESETN	=> s_axis_rxd_aresetn,
		S_AXIS_TREADY	=> s_axis_rxd_tready,
		S_AXIS_TDATA	=> s_axis_rxd_tdata,
		S_AXIS_KEEP	=> s_axis_rxd_keep,
		S_AXIS_TLAST	=> s_axis_rxd_tlast,
		S_AXIS_TVALID	=> s_axis_rxd_tvalid
	);

-- Instantiation of Axi Bus Interface S_AXIS_RXS
eth_traffic_gen_v1_0_S_AXIS_RXS_inst : eth_traffic_gen_v1_0_S_AXIS_RXS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S_AXIS_RXS_TDATA_WIDTH
	)
	port map (
    rst_counters_i  => rst_counters,
    last_data_i     => s_axis_rxd_tlast,
    max_delay_i     => max_delay,
		S_AXIS_ACLK	=> s_axis_rxs_aclk,
		S_AXIS_ARESETN	=> s_axis_rxs_aresetn,
		S_AXIS_TREADY	=> s_axis_rxs_tready,
		S_AXIS_TDATA	=> s_axis_rxs_tdata,
		S_AXIS_KEEP	=> s_axis_rxs_keep,
		S_AXIS_TLAST	=> s_axis_rxs_tlast,
		S_AXIS_TVALID	=> s_axis_rxs_tvalid
	);

-- Instantiation of Axi Bus Interface S_AXI
eth_traffic_gen_v1_0_S_AXI_inst : eth_traffic_gen_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
    rst_counters_o => rst_counters,
    force_error_o  => force_error,
    force_drop_o   => force_drop,
    insert_fcs_o   => insert_fcs,
    bit_errors_i   => bit_errors,
    max_delay_o    => max_delay,
    fcs_word_o     => fcs_word,
    pkt_word_len_o => pkt_word_len,
		S_AXI_ACLK	=> s_axi_aclk,
		S_AXI_ARESETN	=> s_axi_aresetn,
		S_AXI_AWADDR	=> s_axi_awaddr,
		S_AXI_AWPROT	=> s_axi_awprot,
		S_AXI_AWVALID	=> s_axi_awvalid,
		S_AXI_AWREADY	=> s_axi_awready,
		S_AXI_WDATA	=> s_axi_wdata,
		S_AXI_WSTRB	=> s_axi_wstrb,
		S_AXI_WVALID	=> s_axi_wvalid,
		S_AXI_WREADY	=> s_axi_wready,
		S_AXI_BRESP	=> s_axi_bresp,
		S_AXI_BVALID	=> s_axi_bvalid,
		S_AXI_BREADY	=> s_axi_bready,
		S_AXI_ARADDR	=> s_axi_araddr,
		S_AXI_ARPROT	=> s_axi_arprot,
		S_AXI_ARVALID	=> s_axi_arvalid,
		S_AXI_ARREADY	=> s_axi_arready,
		S_AXI_RDATA	=> s_axi_rdata,
		S_AXI_RRESP	=> s_axi_rresp,
		S_AXI_RVALID	=> s_axi_rvalid,
		S_AXI_RREADY	=> s_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
