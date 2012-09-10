###############################################################################
##$Date: 2008/05/30 00:57:53 $
##$RCSfile: example_wave_do.ejava,v $
##$Revision: 1.1.2.1 $
###############################################################################
## example_wave.do
###############################################################################
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {FRAME CHECK MODULE tile0_frame_check1 }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/begin_r
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/track_data_r
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/data_error_detected_r
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/start_of_packet_detected_r
add wave -noupdate -format Logic -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/RX_DATA
add wave -noupdate -format Logic -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1/ERROR_COUNT
add wave -noupdate -divider {TILE0_ROCKETIO_GTX }
add wave -noupdate -divider {Loopback and Powerdown Ports }
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/LOOPBACK0_IN
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/LOOPBACK1_IN
add wave -noupdate -divider {Receive Ports - 8b10b Decoder }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXCHARISK1_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXDISPERR1_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXNOTINTABLE1_OUT
add wave -noupdate -divider {Receive Ports - Clock Correction Ports }
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXCLKCORCNT1_OUT
add wave -noupdate -divider {Receive Ports - Comma Detection and Alignment }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXENMCOMMAALIGN0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXENMCOMMAALIGN1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXENPCOMMAALIGN0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXENPCOMMAALIGN1_IN
add wave -noupdate -divider {Receive Ports - RX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXDATA1_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXRESET0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXRESET1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXUSRCLK0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXUSRCLK1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXUSRCLK20_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXUSRCLK21_IN
add wave -noupdate -divider {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXN0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXN1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXP0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXP1_IN
add wave -noupdate -divider {Receive Ports - RX Loss-of-sync State Machine }
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RXLOSSOFSYNC1_OUT
add wave -noupdate -divider {Shared Ports - Tile and PLL Ports }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/CLKIN_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/GTXRESET_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/PLLLKDET_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/REFCLKOUT_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RESETDONE0_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/RESETDONE1_OUT
add wave -noupdate -divider {Transmit Ports - 8b10b Encoder Control Ports }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXCHARISK1_IN
add wave -noupdate -divider {Transmit Ports - TX Data Path interface }
add wave -noupdate -format Literal -radix hexadecimal /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXDATA1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXUSRCLK0_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXUSRCLK1_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXUSRCLK20_IN
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXUSRCLK21_IN
add wave -noupdate -divider {Transmit Ports - TX Driver and OOB signalling }
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXN0_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXN1_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXP0_OUT
add wave -noupdate -format Logic /EXAMPLE_TB/example_mgt_top_i/rocketio_gtx_i/tile0_rocketio_gtx_i/TXP1_OUT

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 282
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {5236 ps}
