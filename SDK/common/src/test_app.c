/*
 * Copyright (c) 2016 Opsero Electronic Design Inc.  All rights reserved.
 *
 */

/*
 * test_app.c: Test application for Ethernet FMC
 *
 * This application sets up the AXI Ethernet cores and the
 * Marvell PHYs on the Ethernet FMC to autonegotiate the
 * link speed and disable MAC address filtering.
 *
 * The main loop does the following:
 *  - force a bit error into a transmitted frame on all ports
 *  - poll the rejected frame interrupt flag for about 1 second
 *  - increment counters when dropped frames are detected
 *  - display the value of the counters
 *  - display the value of the bit error counters
 *
 * The console will display the dropped frame and bit error
 * counts for all ports about once a second. The dropped frame
 * values should be incrementing by one for each reading.
 * The bit error counts should always be zero.
 * In normal operation, the dropped frame counter for each
 * port should be the same which indicates that there have
 * been no dropped packets besides those in which an error was
 * forced by the Ethernet Traffic Generator.
 *
 * Example (normal) output:
 *
 * Dropped frames:Bit errors (P0,P1,P2,P3):    1:0     1:0     1:0     1:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    2:0     2:0     2:0     2:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    3:0     3:0     3:0     3:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    4:0     4:0     4:0     4:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    5:0     5:0     5:0     5:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    6:0     6:0     6:0     6:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    7:0     7:0     7:0     7:0
 *
 * Example output where a frame was lost on port 2:
 *
 * Dropped frames:Bit errors (P0,P1,P2,P3):    1:0     1:0     1:0     1:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    2:0     2:0     2:0     2:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    3:0     3:0     4:0     3:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    4:0     4:0     5:0     4:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    5:0     5:0     6:0     5:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    6:0     6:0     7:0     6:0
 * Dropped frames:Bit errors (P0,P1,P2,P3):    7:0     7:0     8:0     7:0
 *
 */

#include "xparameters.h"
#include <stdio.h>
#include "xil_types.h"
#include "platform.h"
#include "ethfmc_axie.h"
#include "xeth_traffic_gen.h"

/*
 * The following DEFINE sets the number of words
 * to put in the payload of the Ethernet packets to send.
 * The payload is filled with random data and the first 2
 * bytes are 0x00. The actual payload size in bytes will
 * be: (PAYLOAD_WORD_SIZE * 4) + 2
 *
 * Maximum value is 374 (1496 bytes + 2 pad bytes)
 * Minimum value is 12 (48 bytes + 2 pad bytes)
 *
 */

#define PAYLOAD_WORD_SIZE  374

#define PAYLOAD_BYTE_SIZE	((PAYLOAD_WORD_SIZE*4)+2)

// Ethernet traffic generators and pointers to them
XEth_traffic_gen eth_pkt_gen[XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES];

XAxiEthernet *axi_ethernet[4];

int main()
{
	int Status;
	u32 reg;
	volatile u32 i;
	volatile u32 dropped_frames[4];
	volatile u32 bit_errors[XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES];

	xil_printf("\n\r");
	xil_printf("##########################################\n\r");
	xil_printf("## Ethernet FMC Maximum Throughput Test ##\n\r");
	xil_printf("##########################################\n\r");
	xil_printf("\n\r");

	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] =
	{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	init_platform();

	// Initialize Ethernet Traffic Generators
	for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
		Status = XEth_traffic_gen_Initialize(&(eth_pkt_gen[i]),i);
		if (Status != XST_SUCCESS) {
			xil_printf("ERROR: Failed to initialize Ethernet Packet Generator 0\n\r");
			return XST_FAILURE;
		}
	}
	
	// Set MAC addresses
	for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
	  XEth_traffic_gen_Set_dst_mac_lo_V(&(eth_pkt_gen[i]),0xFFFF1E00);
	  XEth_traffic_gen_Set_dst_mac_hi_V(&(eth_pkt_gen[i]),0xFFFF);
	  XEth_traffic_gen_Set_src_mac_lo_V(&(eth_pkt_gen[i]),0xA4A52737);
	  XEth_traffic_gen_Set_src_mac_hi_V(&(eth_pkt_gen[i]),0xFFFF);
	}

	// Set packet payload length
	for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
		XEth_traffic_gen_Set_pkt_len_V(&(eth_pkt_gen[i]),PAYLOAD_WORD_SIZE);
	}

	// Reset force error
	for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
		XEth_traffic_gen_Set_force_error_V(&(eth_pkt_gen[i]),0);
	}

	// Initialize the AXI Ethernet MACs
	axi_ethernet[0] = EthFMC_init_axiemac(XPAR_AXIETHERNET_0_BASEADDR,mac_ethernet_address);
	axi_ethernet[1] = EthFMC_init_axiemac(XPAR_AXIETHERNET_1_BASEADDR,mac_ethernet_address);
	axi_ethernet[2] = EthFMC_init_axiemac(XPAR_AXIETHERNET_2_BASEADDR,mac_ethernet_address);
	axi_ethernet[3] = EthFMC_init_axiemac(XPAR_AXIETHERNET_3_BASEADDR,mac_ethernet_address);

	sleep(1);
	
	// Start the AXI Ethernet MACs and the PHYs
	for(i = 0; i < 4; i++){
		xil_printf("Port %d:\n\r",i);
		EthFMC_start_axiemac(axi_ethernet[i]);
		// Reset the dropped frame counters
		dropped_frames[i] = 0;
	}

	// Reset the reject frame interrupt flags
	XAxiEthernet_WriteReg(XPAR_AXIETHERNET_0_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
	XAxiEthernet_WriteReg(XPAR_AXIETHERNET_1_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
	XAxiEthernet_WriteReg(XPAR_AXIETHERNET_2_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
	XAxiEthernet_WriteReg(XPAR_AXIETHERNET_3_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);

	while (1) {
		/* Force an error to be sent by all ports
		 * --------------------------------------
		 * The following register writes will make the Ethernet
		 * traffic generator/checker force a single bit error into
		 * a single transmitted Ethernet frame. The bit error
		 * results in a rejected (dropped) frame at the receiving
		 * end (whichever port that may be and it depends on how
		 * the ports are looped back to each other).
		 * The purpose of forcing an error like this is to ensure
		 * that our method for counting dropped frames is actually
		 * working.
		 */
		// Set force error
		for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
			XEth_traffic_gen_Set_force_error_V(&(eth_pkt_gen[i]),1);
		}

		/* Poll for dropped packets and increment counters
		 * -----------------------------------------------
		 * This loop will repeatedly poll the rejected frame
		 * interrupt flag of the AXI Ethernet IP. If the flag
		 * is asserted, the dropped frame counter for that
		 * port is incremented and the interrupt flag is
		 * cleared by writing a 1 to it.
		 */
		for(i=0; i<1000000; i++){
			// Read the interrupt status register
			reg = XAxiEthernet_ReadReg(XPAR_AXIETHERNET_0_BASEADDR,XAE_IS_OFFSET);
			if((reg & XAE_INT_RXRJECT_MASK)){
				// Reset the interrupt
				XAxiEthernet_WriteReg(XPAR_AXIETHERNET_0_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
				// Increment the counter
				dropped_frames[0]++;
			}
			// Read the interrupt status register
			reg = XAxiEthernet_ReadReg(XPAR_AXIETHERNET_1_BASEADDR,XAE_IS_OFFSET);
			if((reg & XAE_INT_RXRJECT_MASK)){
				// Reset the interrupt
				XAxiEthernet_WriteReg(XPAR_AXIETHERNET_1_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
				// Increment the counter
				dropped_frames[1]++;
			}
			// Read the interrupt status register
			reg = XAxiEthernet_ReadReg(XPAR_AXIETHERNET_2_BASEADDR,XAE_IS_OFFSET);
			if((reg & XAE_INT_RXRJECT_MASK)){
				// Reset the interrupt
				XAxiEthernet_WriteReg(XPAR_AXIETHERNET_2_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
				// Increment the counter
				dropped_frames[2]++;
			}
			// Read the interrupt status register
			reg = XAxiEthernet_ReadReg(XPAR_AXIETHERNET_3_BASEADDR,XAE_IS_OFFSET);
			if((reg & XAE_INT_RXRJECT_MASK)){
				// Reset the interrupt
				XAxiEthernet_WriteReg(XPAR_AXIETHERNET_3_BASEADDR,XAE_IS_OFFSET,XAE_INT_RXRJECT_MASK);
				// Increment the counter
				dropped_frames[3]++;
			}
		}

		// Reset force error
		for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
			XEth_traffic_gen_Set_force_error_V(&(eth_pkt_gen[i]),0);
		}

		// Read the bit error counters
		for(i = 0; i < XPAR_XETH_TRAFFIC_GEN_NUM_INSTANCES; i++){
			bit_errors[i] = XEth_traffic_gen_Get_err_count_V(&(eth_pkt_gen[i]));
		}

		/* Display the dropped frame counter values
		 * ----------------------------------------
		 * Using good Ethernet cables and an environment with low EMI,
		 * there should be no bit errors affecting the links between
		 * the ports. In this case, there should not be any dropped
		 * frames apart from those that are forced each iteration of
		 * the main loop. Thus you should expect all counters to have
		 * the same value always.
		 *
		 */
		xil_printf("Dropped frames:Bit errors (P0,P1,P2,P3): %4d:%-4d %4d:%-4d %4d:%-4d %4d:%-4d\n\r",
					dropped_frames[0],bit_errors[0],
					dropped_frames[1],bit_errors[1],
					dropped_frames[2],bit_errors[2],
					dropped_frames[3],bit_errors[3]);
	}

	return 0;
}


