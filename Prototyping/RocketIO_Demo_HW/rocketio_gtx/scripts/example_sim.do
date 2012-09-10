   
################################################################################
##$Date: 2008/05/30 00:57:53 $
##$RCSfile: example_sim_do.ejava,v $
##$Revision: 1.1.2.1 $
################################################################################
##   ____  ____ 
##  /   /\/   / 
## /___/  \  /    Vendor: Xilinx 
## \   \   \/     Version : 1.5
##  \   \         Application : RocketIO GTX Wizard 
##  /   /         Filename : example_sim.do
## /___/   /\     Timestamp : 02/08/2005 09:12:43
## \   \  /  \ 
##  \___\/\___\ 
##
##
## Script EXAMPLE_SIM.DO
## Generated by Xilinx RocketIO GTX Wizard


##***************************** Beginning of Script ***************************
        
## If MTI_LIBS is defined, map unisim and simprim directories using MTI_LIBS
## This mode of mapping the unisims libraries is provided for backward 
## compatibility with previous wizard releases. If you don't set MTI_LIBS
## the unisim libraries will be loaded from the paths set up by compxlib in
## your modelsim.ini file

set XILINX   $env(XILINX)
if [info exists env(MTI_LIBS)] {    
    set MTI_LIBS $env(MTI_LIBS)
    vlib UNISIMS_VER
    vlib SECUREIP
    vmap UNISIMS_VER $MTI_LIBS/unisims_ver
    vmap SECUREIP $MTI_LIBS/secureip
   
}

## Create and map work directory
vlib work
vmap work work


##MGT Wrapper
vlog -work work  ../src/rocketio_gtx_tile.v;
vlog -work work  ../src/rocketio_gtx.v;


vlog -work work  ../src/mgt_usrclk_source_pll.v;


##Example Design modules
vlog -work work  ../example/frame_gen.v;
vlog -work work  ../example/frame_check.v;
vlog -work work  ../example/example_mgt_top.v;
vlog -work work  ../testbench/example_tb.v;

##Other modules
vlog -work work $XILINX/verilog/src/glbl.v;

##Load Design
vsim -t 1ps -L SECUREIP -L UNISIMS_VER work.EXAMPLE_TB work.glbl

##Load signals in wave window
view wave
do example_wave.do

##Run simulation
run 50 us



