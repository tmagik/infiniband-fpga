##############################################################################
## Filename:          /tmp/infinibandfpga/Test_Harness/MyProcessorIPLib/drivers/ib_test_harness_plb_if_v1_00_a/data/ib_test_harness_plb_if_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Apr  7 16:18:08 2009 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "ib_test_harness_plb_if" "NUM_INSTANCES" "DEVICE_ID" "C_MEM0_BASEADDR" "C_MEM0_HIGHADDR" 
}
