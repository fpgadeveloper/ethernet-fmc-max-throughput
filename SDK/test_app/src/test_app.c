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
#include "platform.h"
#include "ethfmc_axie.h"


int main()
{
	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] =
	{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	init_platform();

	xil_printf("Ethernet Port 0:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_0_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 1:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_1_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 2:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_2_BASEADDR,mac_ethernet_address);
	xil_printf("Ethernet Port 3:\n\r");
	EthFMC_init_axiemac(XPAR_AXIETHERNET_3_BASEADDR,mac_ethernet_address);


	while (1) {
	}

	return 0;
}
