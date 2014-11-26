/* 
 * Opsero Electronic Design Inc.
 * 
******************************************************************************/


#ifndef I2C_FMC_H_
#define I2C_FMC_H_

#include "xparameters.h"
#include "xiicps.h"

#define IIC_SCLK_RATE		100000

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define IIC_DEVICE_ID	XPAR_XIICPS_0_DEVICE_ID
#define INTC_DEVICE_ID	XPAR_SCUGIC_SINGLE_DEVICE_ID
#define IIC_INTR_ID	XPAR_XIICPS_0_INTR


extern XIicPs IicInstance;		/* The instance of the IIC device. */
extern volatile u8 TransmitComplete;	/* Flag to check completion of Transmission */
extern volatile u8 ReceiveComplete;	/* Flag to check completion of Reception */
extern volatile u32 TotalErrorCount;
extern u8 I2CReadBuffer[200];	/* Read buffer for reading a page. */


int I2CInitialize(void);
void I2CInterruptHandler(void *CallBackRef, u32 Event);
int WriteI2C(u8 addr, u8 *buf,u8 len);
int ReadI2C(u8 addr, u8 *cmd,u8 len);


#endif /* I2C_FMC_H_ */
