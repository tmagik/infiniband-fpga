//////////////////////////////////////////////////////////////////////////////
//$Date: 2008/07/21 19:48:46 $
//$RCSfile: mgt_wrapper.ejava,v $
//$Revision: 1.1.2.2 $
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 1.5 
//  \   \         Application : RocketIO GTX Wizard 
//  /   /         Filename : rocketio_gtx_tile.v
// /___/   /\     Timestamp : 09/02/2006 09:12:43
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module ROCKETIO_GTX_TILE (a GTX Tile Wrapper)
// Generated by Xilinx RocketIO GTX Wizard



`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

module ROCKETIO_GTX_TILE #
(
    // Simulation attributes
    parameter   TILE_SIM_MODE              =   "FAST",  // Set to Fast Functional Simulation Model
    parameter   TILE_SIM_GTXRESET_SPEEDUP  =   0,      // Set to 1 to speed up sim reset
    parameter   TILE_SIM_PLL_PERDIV2       =   9'h140,    // Set to the VCO Unit Interval time
    
    // Channel bonding attributes
    parameter   TILE_CHAN_BOND_MODE_0      =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   TILE_CHAN_BOND_LEVEL_0     =   0,      // 0 to 7. See UG for details
    
    parameter   TILE_CHAN_BOND_MODE_1      =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   TILE_CHAN_BOND_LEVEL_1     =   0       // 0 to 7. See UG for details
)
(
    //---------------------- Loopback and Powerdown Ports ----------------------
    LOOPBACK0_IN,
    LOOPBACK1_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISK1_OUT,
    RXDISPERR1_OUT,
    RXNOTINTABLE1_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT1_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    RXENMCOMMAALIGN0_IN,
    RXENMCOMMAALIGN1_IN,
    RXENPCOMMAALIGN0_IN,
    RXENPCOMMAALIGN1_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    RXDATA1_OUT,
    RXRESET0_IN,
    RXRESET1_IN,
    RXUSRCLK0_IN,
    RXUSRCLK1_IN,
    RXUSRCLK20_IN,
    RXUSRCLK21_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    RXN0_IN,
    RXN1_IN,
    RXP0_IN,
    RXP1_IN,
    //------------- Receive Ports - RX Loss-of-sync State Machine --------------
    RXLOSSOFSYNC1_OUT,
    //------------------- Shared Ports - Tile and PLL Ports --------------------
    CLKIN_IN,
    GTXRESET_IN,
    PLLLKDET_OUT,
    REFCLKOUT_OUT,
    RESETDONE0_OUT,
    RESETDONE1_OUT,
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK1_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    TXDATA1_IN,
    TXUSRCLK0_IN,
    TXUSRCLK1_IN,
    TXUSRCLK20_IN,
    TXUSRCLK21_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    TXN0_OUT,
    TXN1_OUT,
    TXP0_OUT,
    TXP1_OUT


);

// synthesis attribute X_CORE_INFO of ROCKETIO_GTX_TILE is "gtxwizard_v1_5, Coregen v10.1_ip3";

//***************************** Port Declarations *****************************
        

    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   LOOPBACK0_IN;
    input   [2:0]   LOOPBACK1_IN;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output          RXCHARISK1_OUT;
    output          RXDISPERR1_OUT;
    output          RXNOTINTABLE1_OUT;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   RXCLKCORCNT1_OUT;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    input           RXENMCOMMAALIGN0_IN;
    input           RXENMCOMMAALIGN1_IN;
    input           RXENPCOMMAALIGN0_IN;
    input           RXENPCOMMAALIGN1_IN;
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [7:0]   RXDATA1_OUT;
    input           RXRESET0_IN;
    input           RXRESET1_IN;
    input           RXUSRCLK0_IN;
    input           RXUSRCLK1_IN;
    input           RXUSRCLK20_IN;
    input           RXUSRCLK21_IN;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    input           RXN0_IN;
    input           RXN1_IN;
    input           RXP0_IN;
    input           RXP1_IN;
    //------------- Receive Ports - RX Loss-of-sync State Machine --------------
    output  [1:0]   RXLOSSOFSYNC1_OUT;
    //------------------- Shared Ports - Tile and PLL Ports --------------------
    input           CLKIN_IN;
    input           GTXRESET_IN;
    output          PLLLKDET_OUT;
    output          REFCLKOUT_OUT;
    output          RESETDONE0_OUT;
    output          RESETDONE1_OUT;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input           TXCHARISK1_IN;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [7:0]   TXDATA1_IN;
    input           TXUSRCLK0_IN;
    input           TXUSRCLK1_IN;
    input           TXUSRCLK20_IN;
    input           TXUSRCLK21_IN;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    output          TXN0_OUT;
    output          TXN1_OUT;
    output          TXP0_OUT;
    output          TXP1_OUT;



//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;


   

   

    //RX Datapath signals
    wire    [31:0]  rxdata1_i;       
    wire    [2:0]   rxchariscomma1_float_i;
    wire    [2:0]   rxcharisk1_float_i;
    wire    [2:0]   rxdisperr1_float_i;
    wire    [2:0]   rxnotintable1_float_i;
    wire    [2:0]   rxrundisp1_float_i;

    //TX Datapath signals
    wire    [31:0]  txdata1_i;           
    wire    [2:0]   txkerr1_float_i;
    wire    [2:0]   txrundisp1_float_i;


   
   


// 
//********************************* Main Body of Code**************************
                       
    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
                                            

    //-------------------  GTX Datapath byte mapping  -----------------
    
    
    
    assign  RXDATA1_OUT    =   rxdata1_i[7:0];
    
    assign  txdata1_i    =   {tied_to_ground_vec_i[23:0],TXDATA1_IN};    






    
    //------------------------- GTX Instantiations  --------------------------   

    GTX_DUAL # 
    (
        //_______________________ Simulation-Only Attributes __________________

        .SIM_RECEIVER_DETECT_PASS_0  ("TRUE"),
        
        .SIM_RECEIVER_DETECT_PASS_1  ("TRUE"),

        .SIM_MODE                    (TILE_SIM_MODE), 
        .SIM_GTXRESET_SPEEDUP        (TILE_SIM_GTXRESET_SPEEDUP),
        .SIM_PLL_PERDIV2             (TILE_SIM_PLL_PERDIV2),
 

        //___________________________ Shared Attributes _______________________
         
        //---------------------- Tile and PLL Attributes ----------------------

        .CLK25_DIVIDER               (3), 
        .CLKINDC_B                   ("TRUE"),
        .CLKRCV_TRST                 ("TRUE"),
        .OOB_CLK_DIVIDER             (2),
        .OVERSAMPLE_MODE             ("FALSE"),
        .PLL_COM_CFG                 (24'h21680a),
        .PLL_CP_CFG                  (8'h00),
        .PLL_DIVSEL_FB               (5),
        .PLL_DIVSEL_REF              (1),
        .PLL_FB_DCCEN                ("FALSE"),
        .PLL_LKDET_CFG               (3'b101),
        .PLL_TDCC_CFG                (3'b000),
        .PMA_COM_CFG                 (69'h000000000000000000),

        //______________________ Transmit Interface Attributes ________________

 
        //----------------- TX Buffering and Phase Alignment ------------------   

        .TX_BUFFER_USE_0            ("TRUE"),
        .TX_XCLK_SEL_0              ("TXOUT"),
        .TXRX_INVERT_0              (3'b011),        

        .TX_BUFFER_USE_1            ("TRUE"),
        .TX_XCLK_SEL_1              ("TXOUT"),
        .TXRX_INVERT_1              (3'b011),        

        //------------------- TX Gearbox Settings -----------------------------

        .GEARBOX_ENDEC_0            (3'b000), 
        .TXGEARBOX_USE_0            ("FALSE"),

        .GEARBOX_ENDEC_1            (3'b000), 
        .TXGEARBOX_USE_1            ("FALSE"),

        //------------------- TX Serial Line Rate settings --------------------   

        .PLL_TXDIVSEL_OUT_0         (1),
	
        .PLL_TXDIVSEL_OUT_1         (4), 

        //------------------- TX Driver and OOB signalling --------------------  
       
        .CM_TRIM_0                 (2'b10),
        .PMA_TX_CFG_0              (20'h80082),
        .TX_DETECT_RX_CFG_0        (14'h1832),
        .TX_IDLE_DELAY_0           (3'b010),
        
        .CM_TRIM_1                 (2'b10),
        .PMA_TX_CFG_1              (20'h80082),
        .TX_DETECT_RX_CFG_1        (14'h1832),
        .TX_IDLE_DELAY_1           (3'b010),

        //---------------- TX Pipe Control for PCI Express/SATA ---------------

        .COM_BURST_VAL_0            (4'b1111),

        .COM_BURST_VAL_1            (4'b1111),

        //_______________________ Receive Interface Attributes ________________


        //---------- RX Driver,OOB signalling,Coupling and Eq.,CDR ------------  
        
        .AC_CAP_DIS_0               ("TRUE"),
        .OOBDETECT_THRESHOLD_0      (3'b111),
        .PMA_CDR_SCAN_0             (27'h6404035), 
        .PMA_RX_CFG_0               (25'h0f44088),
        .RCV_TERM_GND_0             ("FALSE"),
        .RCV_TERM_VTTRX_0           ("TRUE"),
        .TERMINATION_IMP_0          (50),

        .AC_CAP_DIS_1               ("TRUE"),
        .OOBDETECT_THRESHOLD_1      (3'b111),
        .PMA_CDR_SCAN_1             (27'h6404035), 
        .PMA_RX_CFG_1               (25'h0f44088),  
        .RCV_TERM_GND_1             ("FALSE"),
        .RCV_TERM_VTTRX_1           ("TRUE"),
        .TERMINATION_IMP_1          (50),

        .TERMINATION_CTRL           (5'b10100),
        .TERMINATION_OVRD           ("FALSE"),

        //-------------- RX Decision Feedback Equalizer(DFE)  ----------------  

        .DFE_CFG_0                  (10'b1001111011),
                  
        .DFE_CFG_1                  (10'b1001111011),

        .DFE_CAL_TIME               (5'b00110),

        //------------------- RX Serial Line Rate Settings --------------------   

        .PLL_RXDIVSEL_OUT_0         (1),
        .PLL_SATA_0                 ("FALSE"),

        .PLL_RXDIVSEL_OUT_1         (4),
        .PLL_SATA_1                 ("FALSE"),


        //------------------------- PRBS Detection ----------------------------  

        .PRBS_ERR_THRESHOLD_0       (32'h00000001),

        .PRBS_ERR_THRESHOLD_1       (32'h00000001),

        //------------------- Comma Detection and Alignment -------------------  

        .ALIGN_COMMA_WORD_0         (1),
        .COMMA_10B_ENABLE_0         (10'b1111111111),
        .COMMA_DOUBLE_0             ("FALSE"),
        .DEC_MCOMMA_DETECT_0        ("TRUE"),
        .DEC_PCOMMA_DETECT_0        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_0     ("TRUE"),
        .MCOMMA_10B_VALUE_0         (10'b1010000011),
        .MCOMMA_DETECT_0            ("TRUE"),
        .PCOMMA_10B_VALUE_0         (10'b0101111100),
        .PCOMMA_DETECT_0            ("TRUE"),
        .RX_SLIDE_MODE_0            ("PCS"),

        .ALIGN_COMMA_WORD_1         (1),
        .COMMA_10B_ENABLE_1         (10'b1111111111),
        .COMMA_DOUBLE_1             ("FALSE"),
        .DEC_MCOMMA_DETECT_1        ("TRUE"),
        .DEC_PCOMMA_DETECT_1        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_1     ("TRUE"),
        .MCOMMA_10B_VALUE_1         (10'b1010000011),
        .MCOMMA_DETECT_1            ("TRUE"),
        .PCOMMA_10B_VALUE_1         (10'b0101111100),
        .PCOMMA_DETECT_1            ("TRUE"),
        .RX_SLIDE_MODE_1            ("PCS"),


        //------------------- RX Loss-of-sync State Machine -------------------  

        .RX_LOSS_OF_SYNC_FSM_0      ("FALSE"),
        .RX_LOS_INVALID_INCR_0      (8),
        .RX_LOS_THRESHOLD_0         (128),

        .RX_LOSS_OF_SYNC_FSM_1      ("FALSE"),
        .RX_LOS_INVALID_INCR_1      (8),
        .RX_LOS_THRESHOLD_1         (128),

        //------------------- RX Gearbox Settings -----------------------------

        .RXGEARBOX_USE_0            ("FALSE"),

        .RXGEARBOX_USE_1            ("FALSE"),

        //------------ RX Elastic Buffer and Phase alignment ports ------------   
        
        .PMA_RXSYNC_CFG_0           (7'h00),
        .RX_BUFFER_USE_0            ("TRUE"),
        .RX_XCLK_SEL_0              ("RXREC"),

        .PMA_RXSYNC_CFG_1           (7'h00),
        .RX_BUFFER_USE_1            ("TRUE"),
        .RX_XCLK_SEL_1              ("RXREC"),

        //--------------------- Clock Correction Attributes -------------------   

        .CLK_CORRECT_USE_0          ("FALSE"),
        .CLK_COR_ADJ_LEN_0          (1),
        .CLK_COR_DET_LEN_0          (1),
        .CLK_COR_INSERT_IDLE_FLAG_0 ("FALSE"),
        .CLK_COR_KEEP_IDLE_0        ("FALSE"),
        .CLK_COR_MAX_LAT_0          (18),
        .CLK_COR_MIN_LAT_0          (16),
        .CLK_COR_PRECEDENCE_0       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_0      (0),
        .CLK_COR_SEQ_1_1_0          (10'b0000000000),
        .CLK_COR_SEQ_1_2_0          (10'b0000000000),
        .CLK_COR_SEQ_1_3_0          (10'b0000000000),
        .CLK_COR_SEQ_1_4_0          (10'b0000000000),
        .CLK_COR_SEQ_1_ENABLE_0     (4'b0000),
        .CLK_COR_SEQ_2_1_0          (10'b0000000000),
        .CLK_COR_SEQ_2_2_0          (10'b0000000000),
        .CLK_COR_SEQ_2_3_0          (10'b0000000000),
        .CLK_COR_SEQ_2_4_0          (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_0     (4'b0000),
        .CLK_COR_SEQ_2_USE_0        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_0      ("FALSE"),

        .CLK_CORRECT_USE_1          ("TRUE"),
        .CLK_COR_ADJ_LEN_1          (1),
        .CLK_COR_DET_LEN_1          (1),
        .CLK_COR_INSERT_IDLE_FLAG_1 ("FALSE"),
        .CLK_COR_KEEP_IDLE_1        ("FALSE"),
        .CLK_COR_MAX_LAT_1          (18),
        .CLK_COR_MIN_LAT_1          (16),
        .CLK_COR_PRECEDENCE_1       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_1      (0),
        .CLK_COR_SEQ_1_1_1          (10'b0100011100),
        .CLK_COR_SEQ_1_2_1          (10'b0000000000),
        .CLK_COR_SEQ_1_3_1          (10'b0000000000),
        .CLK_COR_SEQ_1_4_1          (10'b0000000000),
        .CLK_COR_SEQ_1_ENABLE_1     (4'b0001),
        .CLK_COR_SEQ_2_1_1          (10'b0000000000),
        .CLK_COR_SEQ_2_2_1          (10'b0000000000),
        .CLK_COR_SEQ_2_3_1          (10'b0000000000),
        .CLK_COR_SEQ_2_4_1          (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_1     (4'b0000),
        .CLK_COR_SEQ_2_USE_1        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_1      ("TRUE"),

        //-------------------- Channel Bonding Attributes ---------------------   

        .CB2_INH_CC_PERIOD_0        (8),
        .CHAN_BOND_1_MAX_SKEW_0     (1),
        .CHAN_BOND_2_MAX_SKEW_0     (1),
        .CHAN_BOND_KEEP_ALIGN_0     ("FALSE"),
        .CHAN_BOND_LEVEL_0          (TILE_CHAN_BOND_LEVEL_0),
        .CHAN_BOND_MODE_0           (TILE_CHAN_BOND_MODE_0),
        .CHAN_BOND_SEQ_1_1_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_0   (4'b0000),
        .CHAN_BOND_SEQ_2_1_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_0   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_0      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_0        (1),
        .PCI_EXPRESS_MODE_0         ("FALSE"),     
     
        .CB2_INH_CC_PERIOD_1        (8),
        .CHAN_BOND_1_MAX_SKEW_1     (1),
        .CHAN_BOND_2_MAX_SKEW_1     (1),
        .CHAN_BOND_KEEP_ALIGN_1     ("FALSE"),
        .CHAN_BOND_LEVEL_1          (TILE_CHAN_BOND_LEVEL_1),
        .CHAN_BOND_MODE_1           (TILE_CHAN_BOND_MODE_1),
        .CHAN_BOND_SEQ_1_1_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_1   (4'b0000),
        .CHAN_BOND_SEQ_2_1_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_1   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_1      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_1        (1),
        .PCI_EXPRESS_MODE_1         ("FALSE"),

        //------ RX Attributes to Control Reset after Electrical Idle  ------

        .RX_EN_IDLE_HOLD_DFE_0      ("TRUE"),
        .RX_EN_IDLE_RESET_BUF_0     ("TRUE"),
        .RX_IDLE_HI_CNT_0           (4'b1000),
        .RX_IDLE_LO_CNT_0           (4'b0000),

        .RX_EN_IDLE_HOLD_DFE_1      ("TRUE"),
        .RX_EN_IDLE_RESET_BUF_1     ("TRUE"),
        .RX_IDLE_HI_CNT_1           (4'b1000),
        .RX_IDLE_LO_CNT_1           (4'b0000),


        .CDR_PH_ADJ_TIME            (5'b01010),
        .RX_EN_IDLE_RESET_FR        ("TRUE"),
        .RX_EN_IDLE_HOLD_CDR        ("FALSE"),
        .RX_EN_IDLE_RESET_PH        ("TRUE"),

        //---------------- RX Attributes for PCI Express/SATA ---------------
        
        .RX_STATUS_FMT_0            ("PCIE"),
        .SATA_BURST_VAL_0           (3'b100),
        .SATA_IDLE_VAL_0            (3'b100),
        .SATA_MAX_BURST_0           (9),
        .SATA_MAX_INIT_0            (27),
        .SATA_MAX_WAKE_0            (9),
        .SATA_MIN_BURST_0           (5),
        .SATA_MIN_INIT_0            (15),
        .SATA_MIN_WAKE_0            (5),
        .TRANS_TIME_FROM_P2_0       (16'h003c),
        .TRANS_TIME_NON_P2_0        (16'h0019),
        .TRANS_TIME_TO_P2_0         (16'h0064),

        .RX_STATUS_FMT_1            ("PCIE"),
        .SATA_BURST_VAL_1           (3'b100),
        .SATA_IDLE_VAL_1            (3'b100),
        .SATA_MAX_BURST_1           (9),
        .SATA_MAX_INIT_1            (27),
        .SATA_MAX_WAKE_1            (9),
        .SATA_MIN_BURST_1           (5),
        .SATA_MIN_INIT_1            (15),
        .SATA_MIN_WAKE_1            (5),
        .TRANS_TIME_FROM_P2_1       (16'h003c),
        .TRANS_TIME_NON_P2_1        (16'h0019),
        .TRANS_TIME_TO_P2_1         (16'h0064)         
     ) 
     gtx_dual_i 
     (

        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK0                      (LOOPBACK0_IN),
        .LOOPBACK1                      (LOOPBACK1_IN),
        .RXPOWERDOWN0                   (tied_to_ground_vec_i[1:0]),
        .RXPOWERDOWN1                   (tied_to_ground_vec_i[1:0]),
        .TXPOWERDOWN0                   (tied_to_ground_vec_i[1:0]),
        .TXPOWERDOWN1                   (tied_to_ground_vec_i[1:0]),
        //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        .RXDATAVALID0                   (),
        .RXDATAVALID1                   (),
        .RXGEARBOXSLIP0                 (tied_to_ground_i),
        .RXGEARBOXSLIP1                 (tied_to_ground_i),
        .RXHEADER0                      (),
        .RXHEADER1                      (),
        .RXHEADERVALID0                 (),
        .RXHEADERVALID1                 (),
        .RXSTARTOFSEQ0                  (),
        .RXSTARTOFSEQ1                  (),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA0                 (),
        .RXCHARISCOMMA1                 (),
        .RXCHARISK0                     (),
        .RXCHARISK1                     ({rxcharisk1_float_i,RXCHARISK1_OUT}),
        .RXDEC8B10BUSE0                 (tied_to_ground_i),
        .RXDEC8B10BUSE1                 (tied_to_vcc_i),
        .RXDISPERR0                     (),
        .RXDISPERR1                     ({rxdisperr1_float_i,RXDISPERR1_OUT}),
        .RXNOTINTABLE0                  (),
        .RXNOTINTABLE1                  ({rxnotintable1_float_i,RXNOTINTABLE1_OUT}),
        .RXRUNDISP0                     (),
        .RXRUNDISP1                     (),
        //----------------- Receive Ports - Channel Bonding Ports ------------------
        .RXCHANBONDSEQ0                 (),
        .RXCHANBONDSEQ1                 (),
        .RXCHBONDI0                     (tied_to_ground_vec_i[3:0]),
        .RXCHBONDI1                     (tied_to_ground_vec_i[3:0]),
        .RXCHBONDO0                     (),
        .RXCHBONDO1                     (),
        .RXENCHANSYNC0                  (tied_to_ground_i),
        .RXENCHANSYNC1                  (tied_to_ground_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT0                   (),
        .RXCLKCORCNT1                   (RXCLKCORCNT1_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED0               (),
        .RXBYTEISALIGNED1               (),
        .RXBYTEREALIGN0                 (),
        .RXBYTEREALIGN1                 (),
        .RXCOMMADET0                    (),
        .RXCOMMADET1                    (),
        .RXCOMMADETUSE0                 (tied_to_vcc_i),
        .RXCOMMADETUSE1                 (tied_to_vcc_i),
        .RXENMCOMMAALIGN0               (RXENMCOMMAALIGN0_IN),
        .RXENMCOMMAALIGN1               (RXENMCOMMAALIGN1_IN),
        .RXENPCOMMAALIGN0               (RXENPCOMMAALIGN0_IN),
        .RXENPCOMMAALIGN1               (RXENPCOMMAALIGN1_IN),
        .RXSLIDE0                       (tied_to_ground_i),
        .RXSLIDE1                       (tied_to_ground_i),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET0                  (tied_to_ground_i),
        .PRBSCNTRESET1                  (tied_to_ground_i),
        .RXENPRBSTST0                   (tied_to_ground_vec_i[1:0]),
        .RXENPRBSTST1                   (tied_to_ground_vec_i[1:0]),
        .RXPRBSERR0                     (),
        .RXPRBSERR1                     (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA0                        (),
        .RXDATA1                        (rxdata1_i),
        .RXDATAWIDTH0                   (2'b00),
        .RXDATAWIDTH1                   (2'b00),
        .RXRECCLK0                      (),
        .RXRECCLK1                      (),
        .RXRESET0                       (RXRESET0_IN),
        .RXRESET1                       (RXRESET1_IN),
        .RXUSRCLK0                      (RXUSRCLK0_IN),
        .RXUSRCLK1                      (RXUSRCLK1_IN),
        .RXUSRCLK20                     (RXUSRCLK20_IN),
        .RXUSRCLK21                     (RXUSRCLK21_IN),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .DFECLKDLYADJ0                  (tied_to_ground_vec_i[5:0]),
        .DFECLKDLYADJ1                  (tied_to_ground_vec_i[5:0]),
        .DFECLKDLYADJMONITOR0           (),
        .DFECLKDLYADJMONITOR1           (),
        .DFEEYEDACMONITOR0              (),
        .DFEEYEDACMONITOR1              (),
        .DFESENSCAL0                    (),
        .DFESENSCAL1                    (),
        .DFETAP10                       (tied_to_ground_vec_i[4:0]),
        .DFETAP11                       (tied_to_ground_vec_i[4:0]),
        .DFETAP1MONITOR0                (),
        .DFETAP1MONITOR1                (),
        .DFETAP20                       (tied_to_ground_vec_i[4:0]),
        .DFETAP21                       (tied_to_ground_vec_i[4:0]),
        .DFETAP2MONITOR0                (),
        .DFETAP2MONITOR1                (),
        .DFETAP30                       (tied_to_ground_vec_i[3:0]),
        .DFETAP31                       (tied_to_ground_vec_i[3:0]),
        .DFETAP3MONITOR0                (),
        .DFETAP3MONITOR1                (),
        .DFETAP40                       (tied_to_ground_vec_i[3:0]),
        .DFETAP41                       (tied_to_ground_vec_i[3:0]),
        .DFETAP4MONITOR0                (),
        .DFETAP4MONITOR1                (),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXCDRRESET0                    (tied_to_ground_i),
        .RXCDRRESET1                    (tied_to_ground_i),
        .RXELECIDLE0                    (),
        .RXELECIDLE1                    (),
        .RXENEQB0                       (tied_to_ground_i),
        .RXENEQB1                       (tied_to_ground_i),
        .RXEQMIX0                       (2'b00),
        .RXEQMIX1                       (2'b00),
        .RXEQPOLE0                      (4'b0000),
        .RXEQPOLE1                      (4'b0000),
        .RXN0                           (RXN0_IN),
        .RXN1                           (RXN1_IN),
        .RXP0                           (RXP0_IN),
        .RXP1                           (RXP1_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET0                    (tied_to_ground_i),
        .RXBUFRESET1                    (tied_to_ground_i),
        .RXBUFSTATUS0                   (),
        .RXBUFSTATUS1                   (),
        .RXCHANISALIGNED0               (),
        .RXCHANISALIGNED1               (),
        .RXCHANREALIGN0                 (),
        .RXCHANREALIGN1                 (),
        .RXENPMAPHASEALIGN0             (tied_to_ground_i),
        .RXENPMAPHASEALIGN1             (tied_to_ground_i),
        .RXPMASETPHASE0                 (tied_to_ground_i),
        .RXPMASETPHASE1                 (tied_to_ground_i),
        .RXSTATUS0                      (),
        .RXSTATUS1                      (),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC0                  (),
        .RXLOSSOFSYNC1                  (RXLOSSOFSYNC1_OUT),
        //-------------------- Receive Ports - RX Oversampling ---------------------
        .RXENSAMPLEALIGN0               (tied_to_ground_i),
        .RXENSAMPLEALIGN1               (tied_to_ground_i),
        .RXOVERSAMPLEERR0               (),
        .RXOVERSAMPLEERR1               (),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS0                     (),
        .PHYSTATUS1                     (),
        .RXVALID0                       (),
        .RXVALID1                       (),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .RXPOLARITY0                    (tied_to_ground_i),
        .RXPOLARITY1                    (tied_to_ground_i),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (tied_to_ground_vec_i[6:0]),
        .DCLK                           (tied_to_ground_i),
        .DEN                            (tied_to_ground_i),
        .DI                             (tied_to_ground_vec_i[15:0]),
        .DO                             (),
        .DRDY                           (),
        .DWE                            (tied_to_ground_i),
        //------------------- Shared Ports - Tile and PLL Ports --------------------
        .CLKIN                          (CLKIN_IN),
        .GTXRESET                       (GTXRESET_IN),
        .GTXTEST                        (14'b10000000000000),
        .INTDATAWIDTH                   (tied_to_vcc_i),
        .PLLLKDET                       (PLLLKDET_OUT),
        .PLLLKDETEN                     (tied_to_vcc_i),
        .PLLPOWERDOWN                   (tied_to_ground_i),
        .REFCLKOUT                      (REFCLKOUT_OUT),
        .REFCLKPWRDNB                   (tied_to_vcc_i),
        .RESETDONE0                     (RESETDONE0_OUT),
        .RESETDONE1                     (RESETDONE1_OUT),
        //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        .TXGEARBOXREADY0                (),
        .TXGEARBOXREADY1                (),
        .TXHEADER0                      (tied_to_ground_vec_i[2:0]),
        .TXHEADER1                      (tied_to_ground_vec_i[2:0]),
        .TXSEQUENCE0                    (tied_to_ground_vec_i[6:0]),
        .TXSEQUENCE1                    (tied_to_ground_vec_i[6:0]),
        .TXSTARTSEQ0                    (tied_to_ground_i),
        .TXSTARTSEQ1                    (tied_to_ground_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXBYPASS8B10B0                 (tied_to_ground_vec_i[3:0]),
        .TXBYPASS8B10B1                 (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPMODE0                (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPMODE1                (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPVAL0                 (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPVAL1                 (tied_to_ground_vec_i[3:0]),
        .TXCHARISK0                     (tied_to_ground_vec_i[3:0]),
        .TXCHARISK1                     ({tied_to_ground_vec_i[2:0],TXCHARISK1_IN}),
        .TXENC8B10BUSE0                 (tied_to_ground_i),
        .TXENC8B10BUSE1                 (tied_to_vcc_i),
        .TXKERR0                        (),
        .TXKERR1                        (),
        .TXRUNDISP0                     (),
        .TXRUNDISP1                     (),
        //----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        .TXBUFSTATUS0                   (),
        .TXBUFSTATUS1                   (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA0                        (tied_to_ground_vec_i[31:0]),
        .TXDATA1                        (txdata1_i),
        .TXDATAWIDTH0                   (2'b00),
        .TXDATAWIDTH1                   (2'b00),
        .TXOUTCLK0                      (),
        .TXOUTCLK1                      (),
        .TXRESET0                       (tied_to_ground_i),
        .TXRESET1                       (tied_to_ground_i),
        .TXUSRCLK0                      (TXUSRCLK0_IN),
        .TXUSRCLK1                      (TXUSRCLK1_IN),
        .TXUSRCLK20                     (TXUSRCLK20_IN),
        .TXUSRCLK21                     (TXUSRCLK21_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXBUFDIFFCTRL0                 (3'b101),
        .TXBUFDIFFCTRL1                 (3'b101),
        .TXDIFFCTRL0                    (TXDIFFCTRL0_IN),
        .TXDIFFCTRL1                    (TXDIFFCTRL1_IN),
        .TXINHIBIT0                     (tied_to_ground_i),
        .TXINHIBIT1                     (tied_to_ground_i),
        .TXN0                           (TXN0_OUT),
        .TXN1                           (TXN1_OUT),
        .TXP0                           (TXP0_OUT),
        .TXP1                           (TXP1_OUT),
        .TXPREEMPHASIS0                 (4'b0000),
        .TXPREEMPHASIS1                 (4'b0101),
        //------ Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
        .TXENPMAPHASEALIGN0             (tied_to_ground_i),
        .TXENPMAPHASEALIGN1             (tied_to_ground_i),
        .TXPMASETPHASE0                 (tied_to_ground_i),
        .TXPMASETPHASE1                 (tied_to_ground_i),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST0                   (tied_to_ground_vec_i[1:0]),
        .TXENPRBSTST1                   (tied_to_ground_vec_i[1:0]),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY0                    (tied_to_ground_i),
        .TXPOLARITY1                    (tied_to_ground_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDETECTRX0                    (tied_to_ground_i),
        .TXDETECTRX1                    (tied_to_ground_i),
        .TXELECIDLE0                    (tied_to_ground_i),
        .TXELECIDLE1                    (tied_to_ground_i),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .TXCOMSTART0                    (tied_to_ground_i),
        .TXCOMSTART1                    (tied_to_ground_i),
        .TXCOMTYPE0                     (tied_to_ground_i),
        .TXCOMTYPE1                     (tied_to_ground_i)

     );







     
endmodule

