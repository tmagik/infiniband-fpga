##############################################################################
## Filename:          /tmp/infinibandfpga/Test_Harness/xps_project/drivers/infiniband_test_harness_v1_00_a/data/infiniband_test_harness_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Apr  7 15:24:14 2009 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "infiniband_test_harness" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
