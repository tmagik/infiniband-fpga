library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library InfiniBand;
--use InfiniBand.PhysLayer.all;
library work;
use work.PhysLayer_Lib.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration************************

entity RocketIO_Wrapper is
generic
(
    GTX_SELECT                              : natural   := 1
);
port
(
    REFCLK_P        : in  STD_LOGIC;
    REFCLK_N        : in  STD_LOGIC;
    GTXRESET        : in  STD_LOGIC;
    PLL_LOCK_DETECT : out STD_LOGIC;
    USR_CLK         : out STD_LOGIC;
    USR_CLK2        : out STD_LOGIC;
    TX_DATA         : in  symbol_8b10b;
    RX_DATA         : out symbol_8b10b;
    SYNC            : out STD_LOGIC_VECTOR(1 downto 0);
    RXN_IN          : in  STD_LOGIC_VECTOR(1 downto 0);
    RXP_IN          : in  STD_LOGIC_VECTOR(1 downto 0);
    TXN_OUT         : out STD_LOGIC_VECTOR(1 downto 0);
    TXP_OUT         : out STD_LOGIC_VECTOR(1 downto 0)
);

end RocketIO_Wrapper;
    
architecture RTL of RocketIO_Wrapper is

--**************************Component Declarations*****************************


component ROCKETIO_GTX 
generic
(
    -- Simulation attributes
    WRAPPER_SIM_MODE                : string    := "FAST"; -- Set to Fast Functional Simulation Model
    WRAPPER_SIM_GTXRESET_SPEEDUP    : integer   := 0; -- Set to 1 to speed up sim reset
    WRAPPER_SIM_PLL_PERDIV2         : bit_vector:= x"140" -- Set to the VCO Unit Interval time
);
port
(
    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE0  (Location)

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_LOOPBACK0_IN                      : in   std_logic_vector(2 downto 0);
    TILE0_LOOPBACK1_IN                      : in   std_logic_vector(2 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISK1_OUT                    : out  std_logic;
    TILE0_RXDISPERR1_OUT                    : out  std_logic;
    TILE0_RXNOTINTABLE1_OUT                 : out  std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    TILE0_RXCLKCORCNT1_OUT                  : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
	 TILE0_RXLOSSOFSYNC1_OUT                 : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(7 downto 0);
    TILE0_RXUSRCLK0_IN                      : in   std_logic;
    TILE0_RXUSRCLK1_IN                      : in   std_logic;
    TILE0_RXUSRCLK20_IN                     : in   std_logic;
    TILE0_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_RXN0_IN                           : in   std_logic;
    TILE0_RXN1_IN                           : in   std_logic;
    TILE0_RXP0_IN                           : in   std_logic;
    TILE0_RXP1_IN                           : in   std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    TILE0_CLKIN_IN                          : in   std_logic;
    TILE0_GTXRESET_IN                       : in   std_logic;
    TILE0_PLLLKDET_OUT                      : out  std_logic;
    TILE0_REFCLKOUT_OUT                     : out  std_logic;
    TILE0_RESETDONE0_OUT                    : out  std_logic;
    TILE0_RESETDONE1_OUT                    : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TILE0_TXCHARISK1_IN                     : in   std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA1_IN                        : in   std_logic_vector(7 downto 0);
    TILE0_TXUSRCLK0_IN                      : in   std_logic;
    TILE0_TXUSRCLK1_IN                      : in   std_logic;
    TILE0_TXUSRCLK20_IN                     : in   std_logic;
    TILE0_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT                          : out  std_logic;
    TILE0_TXN1_OUT                          : out  std_logic;
    TILE0_TXP0_OUT                          : out  std_logic;
    TILE0_TXP1_OUT                          : out  std_logic;
	 TILE0_RXRESET0_IN                       : in   std_logic;
	 TILE0_RXRESET1_IN                       : in   std_logic
);
end component;


component MGT_USRCLK_SOURCE 
generic
(
    FREQUENCY_MODE   : string   := "LOW";    
    PERFORMANCE_MODE : string   := "MAX_SPEED"    
);
port
(
    DIV1_OUT                : out std_logic;
    DIV2_OUT                : out std_logic;
    DCM_LOCKED_OUT          : out std_logic;
    CLK_IN                  : in  std_logic;
    DCM_RESET_IN            : in  std_logic

);
end component;

component MGT_USRCLK_SOURCE_PLL 
generic
(
    MULT                 : integer          := 2;
    DIVIDE               : integer          := 2;    
    CLK_PERIOD           : real             := 6.4;    
    OUT0_DIVIDE          : integer          := 2;
    OUT1_DIVIDE          : integer          := 2;
    OUT2_DIVIDE          : integer          := 2;
    OUT3_DIVIDE          : integer          := 2;
    SIMULATION_P         : integer          := 1;
    LOCK_WAIT_COUNT      : std_logic_vector := "1000001000110101"  
);
port
( 
    CLK0_OUT                : out std_logic;
    CLK1_OUT                : out std_logic;
    CLK2_OUT                : out std_logic;
    CLK3_OUT                : out std_logic;
    CLK_IN                  : in  std_logic;
    PLL_LOCKED_OUT          : out std_logic;
    PLL_RESET_IN            : in  std_logic
);
end component;






-- Chipscope modules
attribute syn_black_box                : boolean;
attribute syn_noprune                  : boolean;


component shared_vio
port
(
    control                 : in  std_logic_vector(35 downto 0);
    async_in                : in  std_logic_vector(31 downto 0);
    async_out               : out std_logic_vector(31 downto 0)
);
end component;
attribute syn_black_box of shared_vio : component is TRUE;
attribute syn_noprune of shared_vio   : component is TRUE;

component icon
port
(
    control0                : out std_logic_vector(35 downto 0);
    control1                : out std_logic_vector(35 downto 0);
    control2                : out std_logic_vector(35 downto 0);
    control3                : out std_logic_vector(35 downto 0);
    control4                : out std_logic_vector(35 downto 0);
    control5                : out std_logic_vector(35 downto 0);
    control6                : out std_logic_vector(35 downto 0));
end component;


attribute syn_black_box of icon : component is TRUE;
attribute syn_noprune of icon   : component is TRUE;


component ila
port
(
    control                 : in  std_logic_vector(35 downto 0);
    clk                     : in  std_logic;
    trig0                   : in  std_logic_vector(84 downto 0)
);
end component;
attribute syn_black_box of ila : component is TRUE;
attribute syn_noprune of ila   : component is TRUE;


--***********************************Parameter Declarations********************

    constant DLY : time := 1 ns;

    
--************************** Register Declarations ****************************

    signal   tile0_tx_resetdone0_r           : std_logic;
    signal   tile0_tx_resetdone0_r2          : std_logic;
    signal   tile0_rx_resetdone0_r           : std_logic;
    signal   tile0_rx_resetdone0_r2          : std_logic;
    signal   tile0_tx_resetdone1_r           : std_logic;
    signal   tile0_tx_resetdone1_r2          : std_logic;
    signal   tile0_rx_resetdone1_r           : std_logic;
    signal   tile0_rx_resetdone1_r2          : std_logic;
  

--**************************** Wire Declarations ******************************

    -------------------------- MGT Wrapper Wires ------------------------------
    
    --________________________________________________________________________
    --________________________________________________________________________
    --TILE0   (X0Y5)

    ------------------------ Loopback and Powerdown Ports ----------------------
    signal  tile0_loopback0_i               : std_logic_vector(2 downto 0);
    signal  tile0_loopback1_i               : std_logic_vector(2 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    signal  tile0_rxcharisk0_i              : std_logic;
    signal  tile0_rxcharisk1_i              : std_logic;
    signal  tile0_rxdisperr0_i              : std_logic;
    signal  tile0_rxdisperr1_i              : std_logic;
    signal  tile0_rxnotintable0_i           : std_logic;
    signal  tile0_rxnotintable1_i           : std_logic;
    ------------------- Receive Ports - Clock Correction Ports -----------------
    signal  tile0_rxclkcorcnt0_i            : std_logic_vector(2 downto 0);
    signal  tile0_rxclkcorcnt1_i            : std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    signal  tile0_rxenmcommaalign0_i        : std_logic;
    signal  tile0_rxenmcommaalign1_i        : std_logic;
    signal  tile0_rxenpcommaalign0_i        : std_logic;
    signal  tile0_rxenpcommaalign1_i        : std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    signal  tile0_rxdata0_i                 : std_logic_vector(7 downto 0);
    signal  tile0_rxdata1_i                 : std_logic_vector(7 downto 0);
    signal  tile0_rxreset0_i                : std_logic;
    signal  tile0_rxreset1_i                : std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    signal  tile0_gtxreset_i                : std_logic;
    signal  tile0_plllkdet_i                : std_logic;
    signal  tile0_refclkout_i               : std_logic;
    signal  tile0_resetdone0_i              : std_logic;
    signal  tile0_resetdone1_i              : std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    signal  tile0_txcharisk0_i              : std_logic;
    signal  tile0_txcharisk1_i              : std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    signal  tile0_txdata0_i                 : std_logic_vector(7 downto 0);
    signal  tile0_txdata1_i                 : std_logic_vector(7 downto 0);
    signal  tile0_txreset0_i                : std_logic;
    signal  tile0_txreset1_i                : std_logic;


    ------------------------------- Global Signals -----------------------------
    signal  tile0_tx_system_reset0_c        : std_logic;
    signal  tile0_rx_system_reset0_c        : std_logic;
    signal  tile0_tx_system_reset1_c        : std_logic;
    signal  tile0_rx_system_reset1_c        : std_logic;
    signal  tied_to_ground_vec_i            : std_logic_vector(63 downto 0);
    signal  tied_to_vcc_i                   : std_logic;
    signal  tied_to_vcc_vec_i               : std_logic_vector(7 downto 0);
    signal  drp_clk_in_i                    : std_logic;
    
    signal  tile0_refclkout_bufg_i          : std_logic;
    
    
    ----------------------------- User Clocks ---------------------------------
    signal  tile0_txusrclk0_i               : std_logic;
    signal  tile0_txusrclk20_i              : std_logic;
    signal  refclkout_pll0_locked_i         : std_logic;
    signal  refclkout_pll0_reset_i          : std_logic;
    signal  tile0_refclkout_to_cmt_i        : std_logic;


    ----------------------- Frame check/gen Module Signals --------------------
    signal  tile0_refclk_i                  : std_logic;
    signal  tile0_matchn0_i                 : std_logic;
     
    signal  tile0_txcharisk0_float_i        : std_logic_vector(2 downto 0);
    signal  tile0_txdata0_float_i           : std_logic_vector(31 downto 0);
    
    
    signal  tile0_block_sync0_i             : std_logic;
    signal  tile0_error_count0_i            : std_logic_vector(7 downto 0);
    signal  tile0_frame_check0_reset_i      : std_logic;
    signal  tile0_inc_in0_i                 : std_logic;
    signal  tile0_inc_out0_i                : std_logic;
    signal  tile0_unscrambled_data0_i       : std_logic_vector(7 downto 0);
    signal  tile0_matchn1_i                 : std_logic;
     
    signal  tile0_txcharisk1_float_i        : std_logic_vector(2 downto 0);
    signal  tile0_txdata1_float_i           : std_logic_vector(31 downto 0);
    
    
    signal  tile0_block_sync1_i             : std_logic;
    signal  tile0_error_count1_i            : std_logic_vector(7 downto 0);
    signal  tile0_frame_check1_reset_i      : std_logic;
    signal  tile0_inc_in1_i                 : std_logic;
    signal  tile0_inc_out1_i                : std_logic;
    signal  tile0_unscrambled_data1_i       : std_logic_vector(7 downto 0);

    signal  reset_on_data_error_i           : std_logic;


    ----------------------- Chipscope Signals ---------------------------------

    signal  shared_vio_control_i            : std_logic_vector(35 downto 0);
    signal  tx_data_vio_control0_i          : std_logic_vector(35 downto 0);
    signal  tx_data_vio_control1_i          : std_logic_vector(35 downto 0);
    signal  rx_data_vio_control0_i          : std_logic_vector(35 downto 0);
    signal  rx_data_vio_control1_i          : std_logic_vector(35 downto 0);
    signal  ila_control0_i                  : std_logic_vector(35 downto 0);
    signal  ila_control1_i                  : std_logic_vector(35 downto 0);
    signal  shared_vio_in_i                 : std_logic_vector(31 downto 0);
    signal  shared_vio_out_i                : std_logic_vector(31 downto 0);
    signal  tx_data_vio_in0_i               : std_logic_vector(31 downto 0);
    signal  tx_data_vio_out0_i              : std_logic_vector(31 downto 0);
    signal  tx_data_vio_in1_i               : std_logic_vector(31 downto 0);
    signal  tx_data_vio_out1_i              : std_logic_vector(31 downto 0);
    signal  rx_data_vio_in0_i               : std_logic_vector(31 downto 0);
    signal  rx_data_vio_out0_i              : std_logic_vector(31 downto 0);
    signal  rx_data_vio_in1_i               : std_logic_vector(31 downto 0);
    signal  rx_data_vio_out1_i              : std_logic_vector(31 downto 0);
    signal  ila_in0_i                       : std_logic_vector(84 downto 0);
    signal  ila_in1_i                       : std_logic_vector(84 downto 0);

    signal  tile0_tx_data_vio_in0_i         : std_logic_vector(31 downto 0);
    signal  tile0_tx_data_vio_out0_i        : std_logic_vector(31 downto 0);
    signal  tile0_tx_data_vio_in1_i         : std_logic_vector(31 downto 0);
    signal  tile0_tx_data_vio_out1_i        : std_logic_vector(31 downto 0);
    signal  tile0_rx_data_vio_in0_i         : std_logic_vector(31 downto 0);
    signal  tile0_rx_data_vio_out0_i        : std_logic_vector(31 downto 0);
    signal  tile0_rx_data_vio_in1_i         : std_logic_vector(31 downto 0);
    signal  tile0_rx_data_vio_out1_i        : std_logic_vector(31 downto 0);
    signal  tile0_ila_in0_i                 : std_logic_vector(84 downto 0);
    signal  tile0_ila_in1_i                 : std_logic_vector(84 downto 0);


    signal  gtxreset_i                      : std_logic;
    signal  user_tx_reset_i                 : std_logic;
    signal  user_rx_reset_i                 : std_logic;
    signal  ila_clk0_i                      : std_logic;
    signal  ila_clk_mux_out0_i              : std_logic;
    signal  ila_clk1_i                      : std_logic;
    signal  ila_clk_mux_out1_i              : std_logic;
	 
--**************************** Main Body of Code *******************************
begin
	RX_DATA <= vec_to_e8b10b(tile0_rxcharisk0_i & tile0_rxdata0_i) when GTX_SELECT = 0 else
	           vec_to_e8b10b(tile0_rxcharisk1_i & tile0_rxdata1_i);
				  
	tile0_txcharisk0_i <= '1' when TX_DATA.K = K else '0';
	tile0_txdata0_i     <= e8b10b_to_vec(TX_DATA)(7 downto 0);
	tile0_txcharisk1_i <= '1' when TX_DATA.K = K else '0';
	tile0_txdata1_i     <= e8b10b_to_vec(TX_DATA)(7 downto 0);
	USR_CLK2 <= tile0_txusrclk20_i;
	USR_CLK  <= tile0_txusrclk0_i;
	

	
    --  Static signal Assigments
    tied_to_ground_vec_i                    <= x"0000000000000000";
    tied_to_vcc_i                           <= '1';
    tied_to_vcc_vec_i                       <= x"ff";

    -----------------------Dedicated GTX Reference Clock Inputs ---------------
    -- The dedicated reference clock inputs you selected in the GUI are implemented using
    -- IBUFDS instances.
    --
    -- In the UCF file for this example design, you will see that each of
    -- these IBUFDS instances has been LOCed to a particular set of pins. By LOCing to these
    -- locations, we tell the tools to use the dedicated input buffers to the GTX reference
    -- clock network, rather than general purpose IOs. To select other pins, consult the 
    -- Implementation chapter of UG196, or rerun the wizard.
    --
    -- This network is the highest performace (lowest jitter) option for providing clocks
    -- to the GTX transceivers.
    
    tile0_refclk_ibufds_i : IBUFDS
    port map
    (
        O                               =>      tile0_refclk_i,
        I                               =>      REFCLK_P,
        IB                              =>      REFCLK_N
    );
	 
    ----------------------------------- User Clocks ---------------------------
    
    -- The clock resources in this section were added based on userclk source selections on
    -- the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    -- * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
    --   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    -- * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    --   or multiples of the same frequency can be accomadated using DCMs and PLLs. Use caution when
    --   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    --   the channels using the clock are receiving data from TX channels that share a reference clock 
    --   source with each other.

    refclkout_pll0_bufg_i : BUFG
    port map
    (
        I                               =>      tile0_refclkout_i,
        O                               =>      tile0_refclkout_to_cmt_i
    );

    refclkout_pll0_reset_i                  <= not tile0_plllkdet_i;
    refclkout_pll0_i : MGT_USRCLK_SOURCE_PLL
    generic map
    (
        MULT                            =>      45,
        DIVIDE                          =>      4,
        CLK_PERIOD                      =>      16.0, 
        OUT0_DIVIDE                     =>      18,
        OUT1_DIVIDE                     =>      9,
        OUT2_DIVIDE                     =>      1,
        OUT3_DIVIDE                     =>      1,
        SIMULATION_P                    =>      0,
        LOCK_WAIT_COUNT                 =>      "0011110100001001"
    )
    port map
    (
        CLK0_OUT                        =>      tile0_txusrclk0_i,
        CLK1_OUT                        =>      tile0_txusrclk20_i,
        CLK2_OUT                        =>      open,
        CLK3_OUT                        =>      open,
        CLK_IN                          =>      tile0_refclkout_to_cmt_i,
        PLL_LOCKED_OUT                  =>      refclkout_pll0_locked_i,
        PLL_RESET_IN                    =>      refclkout_pll0_reset_i
    );

    ----------------------------- The GTX Wrapper -----------------------------
    
    -- Use the instantiation template in the examples directory to add the GTX wrapper to your design.
    -- In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    -- checker. The GTXs will reset, then attempt to align and transmit data. If channel bonding is 
    -- enabled, bonding should occur after alignment.


    -- Wire all PLLLKDET signals to the top level as output ports
    PLL_LOCK_DETECT                      <= tile0_plllkdet_i;

    -- Hold the TX in reset till the TX user clocks are stable
  
    tile0_txreset0_i                    <= not refclkout_pll0_locked_i;
  
    tile0_txreset1_i                    <= not refclkout_pll0_locked_i;

    -- Hold the RX in reset till the RX user clocks are stable
  
    tile0_rxreset0_i                    <= not refclkout_pll0_locked_i;
    tile0_rxreset1_i                    <= not refclkout_pll0_locked_i;

    rocketio_gtx_i : ROCKETIO_GTX
    generic map
    (
        WRAPPER_SIM_MODE                =>      "FAST",
        WRAPPER_SIM_GTXRESET_SPEEDUP    =>      1,
        WRAPPER_SIM_PLL_PERDIV2         =>      x"140"
    )
    port map
    (
        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE0  (X0Y5)

        ------------------------ Loopback and Powerdown Ports ----------------------
        TILE0_LOOPBACK0_IN              =>      tile0_loopback0_i,
        TILE0_LOOPBACK1_IN              =>      tile0_loopback1_i,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE0_RXCHARISK1_OUT            =>      tile0_rxcharisk1_i,
        TILE0_RXDISPERR1_OUT            =>      tile0_rxdisperr1_i,
        TILE0_RXNOTINTABLE1_OUT         =>      tile0_rxnotintable1_i,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        TILE0_RXCLKCORCNT1_OUT          =>      tile0_rxclkcorcnt1_i,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE0_RXENMCOMMAALIGN0_IN       =>      tile0_rxenmcommaalign0_i,
        TILE0_RXENMCOMMAALIGN1_IN       =>      tile0_rxenmcommaalign1_i,
        TILE0_RXENPCOMMAALIGN0_IN       =>      tile0_rxenpcommaalign0_i,
        TILE0_RXENPCOMMAALIGN1_IN       =>      tile0_rxenpcommaalign1_i,
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE0_RXDATA1_OUT               =>      tile0_rxdata1_i,
        TILE0_RXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_RXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE0_RXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE0_RXN0_IN                   =>      RXN_IN(0),           
        TILE0_RXN1_IN                   =>      RXN_IN(1),
        TILE0_RXP0_IN                   =>      RXP_IN(0),
        TILE0_RXP1_IN                   =>      RXP_IN(1),
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE0_CLKIN_IN                  =>      tile0_refclk_i,
        TILE0_GTXRESET_IN               =>      tile0_gtxreset_i,
        TILE0_PLLLKDET_OUT              =>      tile0_plllkdet_i,
        TILE0_REFCLKOUT_OUT             =>      tile0_refclkout_i,
        TILE0_RESETDONE0_OUT            =>      tile0_resetdone0_i,
        TILE0_RESETDONE1_OUT            =>      tile0_resetdone1_i,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE0_TXCHARISK1_IN             =>      tile0_txcharisk1_i,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE0_TXDATA1_IN                =>      tile0_txdata1_i,
        TILE0_TXUSRCLK0_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK1_IN              =>      tile0_txusrclk0_i,
        TILE0_TXUSRCLK20_IN             =>      tile0_txusrclk20_i,
        TILE0_TXUSRCLK21_IN             =>      tile0_txusrclk20_i,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE0_TXN0_OUT                  =>      TXN_OUT(0),
        TILE0_TXN1_OUT                  =>      TXN_OUT(1),
        TILE0_TXP0_OUT                  =>      TXP_OUT(0),
        TILE0_TXP1_OUT                  =>      TXP_OUT(1),
        TILE0_RXRESET0_IN               =>      tile0_rxreset0_i,
		  TILE0_RXRESET1_IN               =>      tile0_rxreset1_i,
		  TILE0_RXLOSSOFSYNC1_OUT         =>      SYNC

    );

    -------------------------- User Module Resets -----------------------------
    -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
    -- are held in reset till the RESETDONE goes high. 
    -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
    -- to the reset of the modules
    
    process( tile0_txusrclk20_i,tile0_resetdone0_i)
    begin
        if(tile0_resetdone0_i = '0') then
            tile0_rx_resetdone0_r  <= '0'   after DLY;
            tile0_rx_resetdone0_r2 <= '0'   after DLY;
        elsif(tile0_txusrclk20_i'event and tile0_txusrclk20_i = '1') then
            tile0_rx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
            tile0_rx_resetdone0_r2 <= tile0_rx_resetdone0_r   after DLY;
        end if;
    end process;
    process( tile0_txusrclk20_i,tile0_resetdone0_i)
    begin
        if(tile0_resetdone0_i = '0') then
            tile0_tx_resetdone0_r  <= '0'   after DLY;
            tile0_tx_resetdone0_r2 <= '0'   after DLY;
        elsif(tile0_txusrclk20_i'event and tile0_txusrclk20_i = '1') then
            tile0_tx_resetdone0_r  <= tile0_resetdone0_i   after DLY;
            tile0_tx_resetdone0_r2 <= tile0_tx_resetdone0_r   after DLY;
        end if;
    end process;
    process( tile0_txusrclk20_i,tile0_resetdone1_i)
    begin
        if(tile0_resetdone1_i = '0') then
            tile0_rx_resetdone1_r  <= '0'   after DLY;
            tile0_rx_resetdone1_r2 <= '0'   after DLY;
        elsif(tile0_txusrclk20_i'event and tile0_txusrclk20_i = '1') then
            tile0_rx_resetdone1_r  <= tile0_resetdone1_i   after DLY;
            tile0_rx_resetdone1_r2 <= tile0_rx_resetdone1_r   after DLY;
        end if;
    end process;
    process( tile0_txusrclk20_i,tile0_resetdone1_i)
    begin
        if(tile0_resetdone1_i = '0') then
            tile0_tx_resetdone1_r  <= '0'   after DLY;
            tile0_tx_resetdone1_r2 <= '0'   after DLY;
        elsif(tile0_txusrclk20_i'event and tile0_txusrclk20_i = '1') then
            tile0_tx_resetdone1_r  <= tile0_resetdone1_i   after DLY;
            tile0_tx_resetdone1_r2 <= tile0_tx_resetdone1_r   after DLY;
        end if;
    end process;


    -- If Chipscope is not being used, drive GTX reset signal
    -- from the top level ports
    tile0_gtxreset_i                        <= GTXRESET;

    -- assign resets for frame_gen modules
    tile0_tx_system_reset0_c                <= not tile0_tx_resetdone0_r2;
    tile0_tx_system_reset1_c                <= not tile0_tx_resetdone1_r2;
    -- assign resets for frame_check modules
    tile0_rx_system_reset0_c                <= not tile0_rx_resetdone0_r2;
    tile0_rx_system_reset1_c                <= not tile0_rx_resetdone1_r2;

    gtxreset_i                              <= '0';
    user_tx_reset_i                         <= '0';
    user_rx_reset_i                         <= '0';
    tile0_loopback0_i                       <= "000";
    tile0_loopback1_i                       <= "000";



end RTL;
