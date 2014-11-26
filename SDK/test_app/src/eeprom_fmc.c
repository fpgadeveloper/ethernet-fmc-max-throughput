/* 
 * Opsero Electronic Design Inc.
 * 
******************************************************************************/

#include "eeprom_fmc.h"
#include "xil_types.h"
#include "i2c_fmc.h"
#include "sleep.h"

#define TEST_LEN  200


/*****************************************************************************/
/**
* EEPROM Test function
*
* This function tests the FMC EEPROM by writing a sequence of bytes and
* reading them back. The read bytes are compared with the bytes that were
* written to the EEPROM.
*
****************************************************************************/
int EepromTest(void)
{
	volatile u8 buffer[TEST_LEN];
	u32 i;
  u32 n;

  /* Fill the buffer with data */
  for(i=0; i<TEST_LEN; i++)
    buffer[i] = i+10;
  
  /* Write the buffer to the EEPROM */
  if (WriteEeprom(0,buffer,TEST_LEN) == XST_FAILURE){
		xil_printf("EepromTest: Failed to write to EEPROM\r\n");
		return(XST_FAILURE);
  }
  
  /* Clear the buffer */
  for(i=0; i<TEST_LEN; i++)
    buffer[i] = 0;
  
  /* Read the EEPROM */
  if (ReadEeprom(0,TEST_LEN,buffer) == XST_FAILURE){
		xil_printf("EepromTest: Failed to read from EEPROM\r\n");
		return(XST_FAILURE);
  }
  
  /* Check the contents of the EEPROM */
  for(i=0; i<TEST_LEN; i++){
    if(buffer[i] != i+10){
      xil_printf("EepromTest: Read invalid data back from EEPROM\r\n");
      xil_printf("            ");
      for(n=0; n<TEST_LEN; n++)
        xil_printf("0x%2X ",buffer[n]);
      xil_printf("\r\n");
      return(XST_FAILURE);
    }
  }
  
	return(XST_SUCCESS);
}

/*****************************************************************************/
/**
* EEPROM Write function
*
* This function is written for the M24128-DRDW3TP/K part which is
* used on the Ethernet FMC. See datasheet for more information:
*
* http://www.st.com/web/en/resource/technical/document/datasheet/DM00068315.pdf
*
****************************************************************************/
int WriteEeprom(u16 addr,u8 *data,u32 n)
{
	u8 buffer[20];
	u32 i;
	u32 offset;
	u32 len;

	// Write blocks of 16 bytes at a time
	for(offset=0; offset<n; offset=offset+16){
		// Calculate number of bytes to transfer
		if(offset + 16 > n){
			len = n - offset;
		}
		else{
			len = 16;
		}
		// Write to EEPROM
		buffer[0] = (u8) ((addr+offset) >> 8);
		buffer[1] = (u8) ((addr+offset) & 0xFF);
		// Copy the data into the data buffer
		for(i = 0;i < len;i++){
			buffer[i+2] = data[i+offset];
		}
		if (WriteI2C(IIC_EEPROM_ADDR,buffer,len+2) == XST_FAILURE){
			xil_printf("WriteEeprom: Failed to write %d %d %d\r\n",offset,n,len);
			return(XST_FAILURE);
		}
		usleep(10000);
	}

	return(XST_SUCCESS);
}

/*****************************************************************************/
/**
* EEPROM Read function
*
* This function is written for the M24128-DRDW3TP/K part which is
* used on the Ethernet FMC. See datasheet for more information:
*
* http://www.st.com/web/en/resource/technical/document/datasheet/DM00068315.pdf
*
****************************************************************************/
int ReadEeprom(u16 addr,u32 n,u8 *data)
{
	u8 buffer[200];
	u32 i;
	u32 offset;
	u32 len;

	// Send address to EEPROM
	buffer[0] = (u8)(addr>>8);
	buffer[1] = (u8)(addr&0xFF);
	if (WriteI2C(IIC_EEPROM_ADDR,buffer,2) == XST_FAILURE){
		xil_printf("ReadEeprom: Failed to set read address\r\n");
		return(XST_FAILURE);
	}

	// Read blocks of 16 bytes at a time
	for(offset=0; offset<n; offset=offset+16){
		// Calculate number of bytes to transfer
		if(offset + 16 > n){
			len = n - offset;
		}
		else{
			len = 16;
		}
		// Read from EEPROM
		if (ReadI2C(IIC_EEPROM_ADDR,buffer,len) == XST_FAILURE){
			xil_printf("ReadEeprom: Failed to read\r\n");
			return(XST_FAILURE);
		}

		// Copy the received data into the data buffer
		for(i = 0;i < len;i++){
			data[i+offset] = I2CReadBuffer[i];
		}
	}
	return(XST_SUCCESS);
}
