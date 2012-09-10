//////////////////////////////////////////////////////////////////////////////
// Filename:          /tmp/infinibandfpga/Test_Harness/MyProcessorIPLib/drivers/infiniband_test_harness_v1_00_a/src/infiniband_test_harness_selftest.c
// Version:           1.00.a
// Description:       Contains a diagnostic self-test function for the infiniband_test_harness driver
// Date:              Tue Apr  7 15:26:24 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "infiniband_test_harness.h"

/************************** Constant Definitions ***************************/


/************************** Variable Definitions ****************************/


/************************** Function Definitions ***************************/

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the INFINIBAND_TEST_HARNESS instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus INFINIBAND_TEST_HARNESS_SelfTest(void * baseaddr_p)
{
  int     Index;
  Xuint32 baseaddr;
  Xuint8  Reg8Value;
  Xuint16 Reg16Value;
  Xuint32 Reg32Value;
  
  /*
   * Check and get the device address
   */
  XASSERT_NONVOID(baseaddr_p != XNULL);
  baseaddr = (Xuint32) baseaddr_p;

  xil_printf("******************************\n\r");
  xil_printf("* User Peripheral Self Test\n\r");
  xil_printf("******************************\n\n\r");

  /*
   * Write to user logic slave module register(s) and read back
   */
  xil_printf("User logic slave module test...\n\r");
  xil_printf("   - write 1 to slave register 0 word 0\n\r");
  INFINIBAND_TEST_HARNESS_mWriteSlaveReg0(baseaddr, 0, 1);
  Reg32Value = INFINIBAND_TEST_HARNESS_mReadSlaveReg0(baseaddr, 0);
  xil_printf("   - read %d from register 0 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 1 )
  {
    xil_printf("   - slave register 0 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - slave register write/read passed\n\n\r");

  /*
   * Write to the Write Packet FIFO and read back from the Read Packet FIFO
   */
  xil_printf("Packet FIFO test...\n\r");
  xil_printf("   - reset write packet FIFO to initial state\n\r");
  INFINIBAND_TEST_HARNESS_mResetWriteFIFO(baseaddr);
  xil_printf("   - reset read packet FIFO to initial state \n\r");
  INFINIBAND_TEST_HARNESS_mResetReadFIFO(baseaddr);
  xil_printf("   - push data to write packet FIFO\n\r");
  for ( Index = 0; Index < 4; Index++ )
  {
    xil_printf("     0x%08x", Index*1+1);
    INFINIBAND_TEST_HARNESS_mWriteToFIFO(baseaddr, 0, Index*1+1);
    xil_printf("\n\r");
  }
  xil_printf("   - write packet FIFO is %s\n\r", ( INFINIBAND_TEST_HARNESS_mWriteFIFOFull(baseaddr) ? "full" : "not full" ));
  xil_printf("   - pop data out from read packet FIFO\n\r");
  for ( Index = 0; Index < 4; Index++ )
  {
    Reg32Value = INFINIBAND_TEST_HARNESS_mReadFromFIFO(baseaddr, 0);
    xil_printf("     0x%08x", Reg32Value);
    if ( Reg32Value != (Xuint32) Index*1+1 )
    {
      xil_printf("\n\r");
      xil_printf("   - unexpected value read from read packet FIFO\n\r");
      xil_printf("   - write/read packet FIFO failed\n\r");
      INFINIBAND_TEST_HARNESS_mResetWriteFIFO(baseaddr);
      INFINIBAND_TEST_HARNESS_mResetReadFIFO(baseaddr);
      return XST_FAILURE;
    }
    xil_printf("\n\r");
  }
  xil_printf("   - read packet FIFO is %s\n\r", ( INFINIBAND_TEST_HARNESS_mReadFIFOEmpty(baseaddr) ? "empty" : "not empty" ));
  INFINIBAND_TEST_HARNESS_mResetWriteFIFO(baseaddr);
  INFINIBAND_TEST_HARNESS_mResetReadFIFO(baseaddr);
  xil_printf("   - write/read packet FIFO passed \n\n\r");

  return XST_SUCCESS;
}
