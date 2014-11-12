/*
 * Copyright (c) 2014 Opsero Electronic Design Inc.  All rights reserved.
 *
 */

/*
 * test_app.c: Test application for Ethernet FMC
 *
 * This application sets up the AXI Ethernet cores and the
 * Marvell PHYs on the Ethernet FMC to autonegotiate the
 * link speed and disable MAC address filtering.
 *
 */

#include <stdio.h>
#include "xbasic_types.h"
#include "platform.h"
#include "ethfmc_axie.h"

#define MAX_DELAY 0x00640000

Xuint32 *eth_pkt_gen_0_p = (Xuint32 *)XPAR_ETH_TRAFFIC_GEN_0_S_AXI_BASEADDR;
Xuint32 *eth_pkt_gen_1_p = (Xuint32 *)XPAR_ETH_TRAFFIC_GEN_1_S_AXI_BASEADDR;
Xuint32 *eth_pkt_gen_2_p = (Xuint32 *)XPAR_ETH_TRAFFIC_GEN_2_S_AXI_BASEADDR;
Xuint32 *eth_pkt_gen_3_p = (Xuint32 *)XPAR_ETH_TRAFFIC_GEN_3_S_AXI_BASEADDR;


int main()
{
	volatile Xuint32 reg;
	volatile Xuint32 i;
	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] =
	{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };


	init_platform();

	// Set max delay to
	reg = (*eth_pkt_gen_0_p) & 0x0000FFFF;
	*eth_pkt_gen_0_p = reg | MAX_DELAY;
	reg = (*eth_pkt_gen_1_p) & 0x0000FFFF;
	*eth_pkt_gen_1_p = reg | MAX_DELAY;
	reg = (*eth_pkt_gen_2_p) & 0x0000FFFF;
	*eth_pkt_gen_2_p = reg | MAX_DELAY;
	reg = (*eth_pkt_gen_3_p) & 0x0000FFFF;
	*eth_pkt_gen_3_p = reg | MAX_DELAY;

	xil_printf("Ethernet Port 0:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_0_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 1:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_1_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 2:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_2_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 3:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_3_BASEADDR,mac_ethernet_address);

	// Reset counters
	reg = *eth_pkt_gen_0_p;
	*eth_pkt_gen_0_p = reg | 0x00000001;
	reg = *eth_pkt_gen_1_p;
	*eth_pkt_gen_1_p = reg | 0x00000001;
	reg = *eth_pkt_gen_2_p;
	*eth_pkt_gen_2_p = reg | 0x00000001;
	reg = *eth_pkt_gen_3_p;
	*eth_pkt_gen_3_p = reg | 0x00000001;
	reg = *eth_pkt_gen_0_p;
	*eth_pkt_gen_0_p = reg & ~(0x00000001);
	reg = *eth_pkt_gen_1_p;
	*eth_pkt_gen_1_p = reg & ~(0x00000001);
	reg = *eth_pkt_gen_2_p;
	*eth_pkt_gen_2_p = reg & ~(0x00000001);
	reg = *eth_pkt_gen_3_p;
	*eth_pkt_gen_3_p = reg & ~(0x00000001);

	// Delay
	for(i=0; i<100000000; i++){}

	// Force an error
	reg = *eth_pkt_gen_0_p;
	*eth_pkt_gen_0_p = reg | 0x00000004;
	// Delay
	for(i=0; i<100000; i++){}
	reg = *eth_pkt_gen_0_p;
	*eth_pkt_gen_0_p = reg & ~(0x00000004);


	while (1) {
		// Read from the bit error register
		xil_printf("- Bit errors:      %8d %8d %8d %8d\n\r",
					*(eth_pkt_gen_0_p+1),
					*(eth_pkt_gen_1_p+1),
					*(eth_pkt_gen_2_p+1),
					*(eth_pkt_gen_3_p+1)
					);
		xil_printf("- Dropped packets: %8d %8d %8d %8d\n\r",
					*(eth_pkt_gen_0_p+2),
					*(eth_pkt_gen_1_p+2),
					*(eth_pkt_gen_2_p+2),
					*(eth_pkt_gen_3_p+2)
					);
		// Delay
		for(i=0; i<100000000; i++){}
	}

	return 0;
}
