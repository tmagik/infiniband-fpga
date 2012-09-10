#define TESTAPP_GEN

/* $Id: xiic_selftest_example.c,v 1.1 2007/12/03 15:44:58 meinelte Exp $ */
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
*       (c) Copyright 2002-2005 Xilinx Inc.
*       All rights reserved.
*
*******************************************************************************/
/******************************************************************************/
/**
* @file xiic_selftest_example.c
*
* This file contains a example for using the IIC hardware device and
* XIic driver.
*
* @note
*
* None
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a sv   05/09/05 Initial release for TestApp integration.
* </pre>
*
*******************************************************************************/

#include "xparameters.h"
#include "xiic.h"

/************************** Constant Definitions ******************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define IIC_DEVICE_ID       XPAR_IIC_0_DEVICE_ID
#endif

/**************************** Type Definitions ********************************/


/***************** Macros (Inline Functions) Definitions **********************/


/************************** Function Prototypes *******************************/

XStatus IicSelfTestExample(Xuint16 DeviceId);

/************************** Variable Definitions ******************************/

/*
 * The following are declared globally so they are zeroed and so they are
 * easily accessible from a debugger
 */
XIic Iic; /* The driver instance for IIC Device */


/******************************************************************************/
/**
* Main function to call the example. This function is not included if the
* example is generated from the TestAppGen test tool.
*
* @param    None
*
* @return   XST_SUCCESS if successful, XST_FAILURE if unsuccessful
*
* @note     None
*
******************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
    XStatus Status;

    /*
     * Run the example, specify the device ID that is generated in
     * xparameters.h
     */
    Status = IicSelfTestExample(IIC_DEVICE_ID);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;

}
#endif

/*****************************************************************************/
/**
*
* This function does a selftest on the IIC device and XIic driver as an
* example
*
* @param    DeviceId is the XPAR_<IIC_instance>_DEVICE_ID value from
*           xparameters.h
*
* @return   XST_SUCCESS if successful, XST_FAILURE if unsuccessful
*
* @note     None
*
****************************************************************************/
XStatus IicSelfTestExample(Xuint16 DeviceId)
{
    XStatus Status;

    /*
     * Initialize the IIC driver so that it is ready to use.
     */
    Status = XIic_Initialize(&Iic, DeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Perform a self-test to ensure that the hardware was built
     * correctly
     */
    Status = XIic_SelfTest(&Iic);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }


    return XST_SUCCESS;
}

