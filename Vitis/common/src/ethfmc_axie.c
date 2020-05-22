/*
 * Copyright (C) 2014 Opsero Electronic Design Inc.  All rights reserved.
 *
 * The following code is derived from parts of the lwIP example design that
 * is generated by the SDK (lwIP echo server). It contains the code that
 * is needed to configure the AXI Ethernet cores and the PHYs.
 *
 * The link speed is autonegotiated. The MACs are placed in promiscuous
 * mode which allows them to pass on packets even when they are addressed
 * to another MAC - this is necessary for the loopback because the lwIP
 * swaps the MAC addresses when it returns packets.
 */

#include "xparameters.h"
#include "ethfmc_axie.h"
#include "stdlib.h"
#include "board.h"

static void __attribute__ ((noinline)) AxiEthernetUtilPhyDelay(unsigned int Seconds);

unsigned EthFMC_get_IEEE_phy_speed(XAxiEthernet *xaxiemacp)
{
	u16 temp;
	u32 phy_addr = 0;
	u16 phy_identifier;
	u16 phy_model;
	u16 control;
	u16 status;
	u16 partner_capabilities;

	/* Get the PHY Identifier and Model number */
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, 2, &phy_identifier);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, 3, &phy_model);
	phy_model = phy_model & PHY_MODEL_NUM_MASK;

	/* The PHY ID for Marvel is 0x0141 */
	if(phy_identifier != 0x0141)
		xil_printf("PHY ID is NOT Marvell: 0x%04X\n\r",phy_identifier);
	/* The PHY model for 88E1510 is 0x01D0 */
	if(phy_model != 0x01D0)
		xil_printf("PHY model is NOT 88E1510: 0x%04X\n\r",phy_model);
	xil_printf("Starting PHY autonegotiation\r\n");

	/* RGMII with both TX and RX internal delays enabled (the default for 88E1510)
	   Note that the Vivado designs for "max throughput" example designs all contain a
	   constraint that disables the TX clock skew in the FPGA, hence the need to enable
	   the TX clock skew in the PHY (done in the lines below).
	   For explanation: http://ethernetfmc.com/rgmii-interface-timing-considerations/ 
	   DOES NOT APPLY TO ULTRASCALE DESIGNS */
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 2);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_MAC, &control);
	// Ultrascale designs implement TX clock skew in the FPGA
#ifdef PLATFORM_ZYNQMP
  control &= ~(IEEE_RGMII_TX_CLOCK_DELAYED_MASK);
#else
  control |= IEEE_RGMII_TX_CLOCK_DELAYED_MASK;
#endif
	control |= IEEE_RGMII_RX_CLOCK_DELAYED_MASK;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_MAC, control);

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, &control);
	control |= IEEE_ASYMMETRIC_PAUSE_MASK;
	control |= IEEE_PAUSE_MASK;
	control |= ADVERTISE_100;
	control |= ADVERTISE_10;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_AUTONEGO_ADVERTISE_REG, control);

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
																	&control);
	control |= ADVERTISE_1000;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_1000_ADVERTISE_REG_OFFSET,
																	control);

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_PAGE_ADDRESS_REGISTER, 0);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																&control);
	control |= (7 << 12);	/* max number of gigabit attempts */
	control |= (1 << 11);	/* enable downshift */
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_CONTROL_REG,
																control);
	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_AUTONEGOTIATE_ENABLE;
	control |= IEEE_STAT_AUTONEGOTIATE_RESTART;

	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);


	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
	control |= IEEE_CTRL_RESET_MASK;
	XAxiEthernet_PhyWrite(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, control);

	while (1) {
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_CONTROL_REG_OFFSET, &control);
		if (control & IEEE_CTRL_RESET_MASK)
			continue;
		else
			break;
	}
	xil_printf("Waiting for PHY to complete autonegotiation...\r\n");

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET, &status);
	while ( !(status & IEEE_STAT_AUTONEGOTIATE_COMPLETE) ) {
		AxiEthernetUtilPhyDelay(1);
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_COPPER_SPECIFIC_STATUS_REG_2,
																	&temp);
		if (temp & IEEE_AUTONEG_ERROR_MASK) {
			xil_printf("Auto negotiation error \r\n");
		}
		XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_STATUS_REG_OFFSET,
																&status);
		}

	xil_printf("Autonegotiation complete\r\n");

	XAxiEthernet_PhyRead(xaxiemacp, phy_addr, IEEE_SPECIFIC_STATUS_REG, &partner_capabilities);

	if ( ((partner_capabilities >> 14) & 3) == 2)/* 1000Mbps */
		return 1000;
	else if ( ((partner_capabilities >> 14) & 3) == 1)/* 100Mbps */
		return 100;
	else					/* 10Mbps */
		return 10;
}

unsigned EthFMC_Phy_Setup (XAxiEthernet *xaxiemacp)
{
	unsigned link_speed = 1000;

	if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_RGMII_1_3) {
		; /* Add PHY initialization code for RGMII 1.3 */
	} else if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_RGMII_2_0) {
		; /* Add PHY initialization code for RGMII 2.0 */
	} else if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_SGMII) {
#ifdef  CONFIG_LINKSPEED_AUTODETECT
		u32 phy_wr_data = IEEE_CTRL_AUTONEGOTIATE_ENABLE |
					IEEE_CTRL_LINKSPEED_1000M;
		phy_wr_data &= (~PHY_R0_ISOLATE);

		XAxiEthernet_PhyWrite(xaxiemacp,
				XPAR_AXIETHERNET_0_PHYADDR,
				IEEE_CONTROL_REG_OFFSET,
				phy_wr_data);
#endif
	} else if (XAxiEthernet_GetPhysicalInterface(xaxiemacp) ==
						XAE_PHY_TYPE_1000BASE_X) {
		; /* Add PHY initialization code for 1000 Base-X */
	}
/* set PHY <--> MAC data clock */
	link_speed = EthFMC_get_IEEE_phy_speed(xaxiemacp);
	xil_printf("Auto-negotiated link speed: %d Mbps\r\n", link_speed);
	return link_speed;
}

XAxiEthernet_Config *EthFMC_xaxiemac_lookup_config(unsigned mac_base)
{
	extern XAxiEthernet_Config XAxiEthernet_ConfigTable[];
	XAxiEthernet_Config *CfgPtr = NULL;
	int i;

	for (i = 0; i < XPAR_XAXIETHERNET_NUM_INSTANCES; i++) {
		if (XAxiEthernet_ConfigTable[i].BaseAddress == mac_base) {
			CfgPtr = &XAxiEthernet_ConfigTable[i];
			break;
		}
	}

	return (CfgPtr);
}




XAxiEthernet *EthFMC_init_axiemac(unsigned mac_address,unsigned char *mac_eth_addr)
{
	unsigned options;
	XAxiEthernet *axi_ethernet;
	XAxiEthernet_Config *mac_config;

	axi_ethernet = malloc(sizeof(XAxiEthernet));
	if (axi_ethernet == NULL) {
		xil_printf("EthFMC_low_level_init: out of memory\r\n");
		return NULL;
	}

	/* obtain config of this emac */
	mac_config = EthFMC_xaxiemac_lookup_config(mac_address);

	XAxiEthernet_CfgInitialize(axi_ethernet, mac_config, mac_config->BaseAddress);

	options = XAxiEthernet_GetOptions(axi_ethernet);
	// Disable recognize flow control frames
	options &= ~XAE_FLOW_CONTROL_OPTION;
	//options |= XAE_FLOW_CONTROL_OPTION;
#ifdef USE_JUMBO_FRAMES
	options |= XAE_JUMBO_OPTION;
#endif
	options |= XAE_TRANSMITTER_ENABLE_OPTION;
	options |= XAE_RECEIVER_ENABLE_OPTION;
	// Disable FCS strip
	options &= ~XAE_FCS_STRIP_OPTION;
	// Disable FCS insert (we have included it in the frame)
	options &= ~XAE_FCS_INSERT_OPTION;
	//options |= XAE_FCS_INSERT_OPTION;
	options |= XAE_MULTICAST_OPTION;
	// Using promiscuous option to disable mac address filtering
	// and allow the loopback to function.
	options |= XAE_PROMISC_OPTION;
	XAxiEthernet_SetOptions(axi_ethernet, options);
	XAxiEthernet_ClearOptions(axi_ethernet, ~options);

	/* set mac address */
	XAxiEthernet_SetMacAddress(axi_ethernet, mac_eth_addr);
  
  return axi_ethernet;
}

int EthFMC_start_axiemac(XAxiEthernet *axi_ethernet)
{
	unsigned link_speed = 1000;

	link_speed = EthFMC_Phy_Setup(axi_ethernet);
    XAxiEthernet_SetOperatingSpeed(axi_ethernet, link_speed);

	/* Setting the operating speed of the MAC needs a delay. */
	{
		volatile int wait;
		for (wait=0; wait < 100000; wait++);
		for (wait=0; wait < 100000; wait++);
	}

#ifdef NOTNOW
        /* in a soft temac implementation, we need to explicitly make sure that
         * the RX DCM has been locked. See xps_ll_temac manual for details.
         * This bit is guaranteed to be 1 for hard temac's
         */
        lock_message_printed = 0;
        while (!(XAxiEthernet_ReadReg(axi_ethernet->Config.BaseAddress, XAE_IS_OFFSET)
                    & XAE_INT_RXDCMLOCK_MASK)) {
                int first = 1;
                if (first) {
                        print("Waiting for RX DCM to lock..");
                        first = 0;
                        lock_message_printed = 1;
                }
        }

        if (lock_message_printed)
                print("RX DCM locked.\r\n");
#endif

	/* start the temac */
    XAxiEthernet_Start(axi_ethernet);

	/* enable MAC interrupts */
	XAxiEthernet_IntEnable(axi_ethernet, XAE_INT_RECV_ERROR_MASK);

  return 0;
}



static void __attribute__ ((noinline)) AxiEthernetUtilPhyDelay(unsigned int Seconds)
{
#if defined (__MICROBLAZE__) || defined(__PPC__)
	static int WarningFlag = 0;

	/* If MB caches are disabled or do not exist, this delay loop could
	 * take minutes instead of seconds (e.g., 30x longer).  Print a warning
	 * message for the user (once).  If only MB had a built-in timer!
	 */
	if (((mfmsr() & 0x20) == 0) && (!WarningFlag)) {
		WarningFlag = 1;
	}

#define ITERS_PER_SEC   (XPAR_CPU_CORE_CLOCK_FREQ_HZ / 6)
    asm volatile ("\n"
			"1:               \n\t"
			"addik r7, r0, %0 \n\t"
			"2:               \n\t"
			"addik r7, r7, -1 \n\t"
			"bneid  r7, 2b    \n\t"
			"or  r0, r0, r0   \n\t"
			"bneid %1, 1b     \n\t"
			"addik %1, %1, -1 \n\t"
			:: "i"(ITERS_PER_SEC), "d" (Seconds));
#else
    sleep(Seconds);
#endif
}

