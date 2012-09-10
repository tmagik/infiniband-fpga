#define TESTAPP_GEN

/* $Id: xsysace_selftest_example.c,v 1.4 2007/09/05 04:45:09 svemula Exp $ */
/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2005-2007 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xsysace_selftest_example.c
*
* This file contains a design example using the SystemACE driver.
*
* This example does a simple read/write test of the System Ace Control Register.
*
* @note
*
* None
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- ---------------------------------------------------------
* 1.00a ecm  01/25/05 First release for TestApp integration
* 1.00a sv   06/06/05 Minor changes to comply to Doxygen and coding guidelines
* 1.11a sv   09/03/07 Simplified the example
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xstatus.h"
#include "xsysace.h"

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define SYSACE_DEVICE_ID		XPAR_SYSACE_0_DEVICE_ID
#endif


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

int SysAceSelfTestExample(u16 DeviceId);

/************************** Variable Definitions *****************************/

XSysAce SysAce;		/* An instance of the device */

/****************************************************************************/
/**
*
* This function is the main function of this Example.
*
* @param	None
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None
*
*****************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
	int Status;

	Status = SysAceSelfTestExample(SYSACE_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
#endif

/*****************************************************************************/
/**
*
* An example of using the System ACE driver interface to run a simple
* read/write test after the initialization of the driver.
*
* @param	DeviceId is the XPAR_<SYSTEM_ACE_INSTANCE_NUM>_DEVICE_ID value
*		from xparameters.h.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int SysAceSelfTestExample(u16 DeviceId)
{
	int Status;
	u32 ControlReg;

	/*
	 * Initialize the instance. The device defaults to polled mode.
	 */
	Status = XSysAce_Initialize(&SysAce, DeviceId);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Read the initial value of the Control Register.
	 */
	ControlReg = XSysAce_mGetControlReg(SysAce.BaseAddress);

	/*
	 * Disable all the interrupts in the Control Register.
	 */
	 XSysAce_DisableInterrupt(&SysAce);

	/*
	 * Verify that the interrupts are disabled.
	 */
	if (XSysAce_mGetControlReg(SysAce.BaseAddress) &
		(XSA_CR_DATARDYIRQ_MASK | XSA_CR_ERRORIRQ_MASK |
		 XSA_CR_CFGDONEIRQ_MASK)) {

		 Status |= XST_FAILURE;
	}

	/*
	 * Enable the Error interrupt in the Control Register.
	 */
	XSysAce_EnableInterrupt(&SysAce);

	/*
	 * Verify that the Error interrupt is enabled.
	 */
	if (XSysAce_mGetControlReg(SysAce.BaseAddress) &
				XSA_CR_ERRORIRQ_MASK){
		Status |= XST_SUCCESS;
	}
	else {
		Status |= XST_FAILURE;
	}

	/*
	 * Restore the initial value of the Control Register.
	 */
	XSysAce_mSetControlReg(SysAce.BaseAddress, ControlReg);


	if (Status & XST_FAILURE) {
		return XST_FAILURE;
	} else {
		return XST_SUCCESS;
	}

}


