/*
 * Opsero Electronic Design Inc.
 *
 */

#ifndef EEPROM_FMC_H_
#define EEPROM_FMC_H_

#include "xil_types.h"

/*
 * This defines the I2C address of the EEPROM that is
 * used on the Ethernet FMC. When GA0 and GA1 are
 * both LOW as is the case on the ZedBoard, the address
 * of the EEPROM is 0x50. For other carriers, the lower
 * significant bits must be changed according to GA0
 * and GA1.
 */
#define IIC_EEPROM_ADDR 0x50

int EepromTest(void);
int WriteEeprom(u16 addr,u8 *data,u32 n);
int ReadEeprom(u16 addr,u32 n,u8 *data);

#endif /* EEPROM_FMC_H_ */
