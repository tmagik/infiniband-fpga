/*
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * Xilinx EDK 10.1.03 EDK_K_SP3.6
 *
 * This file is a sample test application
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * XPS project when you run the "Generate Libraries" menu item
 * in XPS.
 *
 * Your XPS project directory is at:
 *    /tmp/infinibandfpga/Test_Harness/xps_project/
 */


// Located in: ppc440_0/include/xparameters.h
#include "xparameters.h"

#include "stdio.h"

#include "xintc.h"
#include "xexception_l.h"
#include "intc_header.h"
#include "xbasic_types.h"
#include "xgpio.h"
#include "gpio_header.h"
#include "iic_header.h"
#include "xsysace.h"
#include "sysace_header.h"

//====================================================

int main (void) {


   static XIntc intc;

   print("-- Entering main() --\r\n");


   {
      XStatus status;
      
      print("\r\n Runnning IntcSelfTestExample() for xps_intc_0...\r\n");
      
      status = IntcSelfTestExample(XPAR_XPS_INTC_0_DEVICE_ID);
      
      if (status == 0) {
         print("IntcSelfTestExample PASSED\r\n");
      }
      else {
         print("IntcSelfTestExample FAILED\r\n");
      }
   } 
	
   {
       XStatus Status;

       Status = IntcInterruptSetup(&intc, XPAR_XPS_INTC_0_DEVICE_ID);
       if (Status == 0) {
          print("Intc Interrupt Setup PASSED\r\n");
       } 
       else {
         print("Intc Interrupt Setup FAILED\r\n");
      } 
   }

   /*
    * Peripheral SelfTest will not be run for RS232_Uart_1
    * because it has been selected as the STDOUT device
    */



   {
      Xuint32 status;
      
      print("\r\nRunning GpioOutputExample() for LEDs_8Bit...\r\n");

      status = GpioOutputExample(XPAR_LEDS_8BIT_DEVICE_ID,8);
      
      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioOutputExample() for LEDs_Positions...\r\n");

      status = GpioOutputExample(XPAR_LEDS_POSITIONS_DEVICE_ID,5);
      
      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioInputExample() for Push_Buttons_5Bit...\r\n");

      Xuint32 DataRead;
      
      status = GpioInputExample(XPAR_PUSH_BUTTONS_5BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioInputExample() for DIP_Switches_8Bit...\r\n");

      Xuint32 DataRead;
      
      status = GpioInputExample(XPAR_DIP_SWITCHES_8BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      XStatus status;
            
      
      print("\r\n Runnning IicSelfTestExample() for IIC_EEPROM...\r\n");
      
      status = IicSelfTestExample(XPAR_IIC_EEPROM_DEVICE_ID);
      
      if (status == 0) {
         print("IicSelfTestExample PASSED\r\n");
      }
      else {
         print("IicSelfTestExample FAILED\r\n");
      }
   }


   {
      XStatus status;
      
      print("\r\nRunning SysAceSelfTestExample() for SysACE_CompactFlash...\r\n");
      status = SysAceSelfTestExample(XPAR_SYSACE_COMPACTFLASH_DEVICE_ID);
      if (status == 0) {
         print("SysAceSelfTestExample PASSED\r\n");
      }
      else {
         print("SysAceSelfTestExample FAILED\r\n");
      }
   }

   print("-- Exiting main() --\r\n");
   return 0;
}

