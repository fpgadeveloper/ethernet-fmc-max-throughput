/* ----------------------------------------------
 * AXI Software Register Initializer
 * ----------------------------------------------
 * NOTE: THIS IP IS ONLY USED FOR TESTING AND SIMULATION.
 * 
 * This IP is used for simulation of other IP cores that contain
 * AXI software registers which require initialization.
 * It is an alternative to the AXI BFM (see link).
 * http://www.xilinx.com/products/intellectual-property/do-axi-bfm.html
 *
 */
#include <stdio.h>
#include <string.h>
#include <ap_int.h>

void axi_init(volatile int *a){

#pragma HLS INTERFACE m_axi port=a depth=50

  int addr;
  // dst mac addr lo
  addr = (0x44A00018 >> 2);
  *(a+addr) = 0xFFFF1E00;

  // dst mac addr hi
  addr = (0x44A00020 >> 2);
  *(a+addr) = 0xFFFF;

  // src mac addr lo
  addr = (0x44A00028 >> 2);
  *(a+addr) = 0xA4A52737;

  // src mac addr hi
  addr = (0x44A00030 >> 2);
  *(a+addr) = 0xFFFF;

  // pkt len
  addr = (0x44A00038 >> 2);
  *(a+addr) = 16;

  // force error
  addr = (0x44A00010 >> 2);
  *(a+addr) = 0x1;

}

