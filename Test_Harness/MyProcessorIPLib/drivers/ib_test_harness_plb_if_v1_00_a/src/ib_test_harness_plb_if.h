//////////////////////////////////////////////////////////////////////////////
// Filename:          /tmp/infinibandfpga/Test_Harness/MyProcessorIPLib/drivers/ib_test_harness_plb_if_v1_00_a/src/ib_test_harness_plb_if.h
// Version:           1.00.a
// Description:       ib_test_harness_plb_if Driver Header File
// Date:              Tue Apr  7 16:18:08 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef IB_TEST_HARNESS_PLB_IF_H
#define IB_TEST_HARNESS_PLB_IF_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xio.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/


/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a IB_TEST_HARNESS_PLB_IF register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the IB_TEST_HARNESS_PLB_IF device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void IB_TEST_HARNESS_PLB_IF_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define IB_TEST_HARNESS_PLB_IF_mWriteReg(BaseAddress, RegOffset, Data) \
 	XIo_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a IB_TEST_HARNESS_PLB_IF register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the IB_TEST_HARNESS_PLB_IF device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	Xuint32 IB_TEST_HARNESS_PLB_IF_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define IB_TEST_HARNESS_PLB_IF_mReadReg(BaseAddress, RegOffset) \
 	XIo_In32((BaseAddress) + (RegOffset))


/**
 *
 * Write/Read 32 bit value to/from IB_TEST_HARNESS_PLB_IF user logic memory (BRAM).
 *
 * @param   Address is the memory address of the IB_TEST_HARNESS_PLB_IF device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void IB_TEST_HARNESS_PLB_IF_mWriteMemory(Xuint32 Address, Xuint32 Data)
 * 	Xuint32 IB_TEST_HARNESS_PLB_IF_mReadMemory(Xuint32 Address)
 *
 */
#define IB_TEST_HARNESS_PLB_IF_mWriteMemory(Address, Data) \
 	XIo_Out32(Address, (Xuint32)(Data))
#define IB_TEST_HARNESS_PLB_IF_mReadMemory(Address) \
 	XIo_In32(Address)

/************************** Function Prototypes ****************************/


/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the IB_TEST_HARNESS_PLB_IF instance to be worked on.
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
XStatus IB_TEST_HARNESS_PLB_IF_SelfTest(void * baseaddr_p);

#endif // IB_TEST_HARNESS_PLB_IF_H
