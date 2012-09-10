######################################################################
# Joseph Zambreno
# setup.sh - shell configuration for CprE 381 labs
######################################################################

SDIR=`dirname "$BASH_SOURCE"`
CDIR=`readlink -f "$SDIR"`

export XLNX_VER=12.4
export ARCH_VER=64
export VSIM_VER=6.5c


printf "Setting up environment variables for %s-bit Xilinx tools, version %s..." $ARCH_VER $XLNX_VER 
source /remote/Xilinx/$XLNX_VER/settings$ARCH_VER.sh
printf "done.\n"

printf "Setting up path for %s-bit Modelsim tools, version %s..." $ARCH_VER $VSIM_VER
export PATH=$PATH:/remote/Modelsim/$VSIM_VER/modeltech/linux_x86_64/
printf "done.\n"

printf "Setting up license file..."
export LM_LICENSE_FILE=1717@io.ece.iastate.edu:27006@io.ece.iastate.edu
printf "done.\n"
