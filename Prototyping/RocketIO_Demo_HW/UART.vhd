library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.uart_components.all;
use work.ip_compatibility.all;

entity UART is
	generic 
	( 
		fosc        : natural := 156250000;
		baud        : natural := 115200;
		ip_provider : ip_provider_t := xilinx
	);
	port 
	(
		CLK       : in  std_logic;
		RESET     : in  std_logic;
		TEST_MODE : in  std_logic;
		RXD       : in  std_logic;
		XMIT_REQ  : in  std_logic;
		RECV_REQ  : in  std_logic;
		XMIT_DATA : in  std_logic_vector(7 downto 0);
		RECV_RDY  : out std_logic;
		RECV_FULL : out std_logic;
		XMIT_FULL : out std_logic;
		RECV_DATA : out std_logic_vector(7 downto 0);
		TXD       : out std_logic
	);
end UART;

architecture structural of UART is
	
	signal rx_empty : std_logic;
	signal tx_empty : std_logic;
	
	signal rx_done : std_logic;
	signal tx_done : std_logic;
	signal tx_rdreq : std_logic;
	signal tx_init : std_logic;
	signal last_tx_rdreq : std_logic := '0';
	
	signal rx_data : std_logic_vector(7 downto 0);
	signal tx_data : std_logic_vector(7 downto 0);
	
	signal internal_rxd : std_logic;
	signal internal_txd : std_logic;
begin
	TXD <= internal_txd when (TEST_MODE = '0') else '1';
	internal_rxd <= RXD when (TEST_MODE = '0') else internal_txd;

	tx_rdreq <= tx_done and not tx_empty and not last_tx_rdreq;
	
	RECV_RDY <= not rx_empty;
	tx_init <= last_tx_rdreq;

	synch_w : process ( CLK, RESET ) begin
		if ( RESET = '1' ) then
			last_tx_rdreq <= '0';
		elsif ( rising_edge(CLK) ) then
			last_tx_rdreq <= tx_rdreq;
		end if;
	end process synch_w;

	rx_fifo : uart_fifo
	generic map ( ip_provider => ip_provider )
	Port map
	(
		RESET => RESET,
		CLK => CLK, 
		DATA_IN => rx_data, 
		RD_REQ => RECV_REQ, 
		WR_REQ => rx_done, 
		EMPTY => rx_empty, 
		FULL => RECV_FULL, 
		DATA_OUT => RECV_DATA
	);
	
	tx_fifo : uart_fifo
	generic map ( ip_provider => ip_provider )
	Port map
	(
		RESET => RESET,
		CLK => CLK, 
		DATA_IN => XMIT_DATA, 
		RD_REQ => tx_rdreq, 
		WR_REQ => XMIT_REQ, 
		EMPTY => tx_empty, 
		FULL => XMIT_FULL, 
		DATA_OUT => tx_data
	);
	
	
	rx_unit : receiver
	generic map
	(
		baud => baud,
		clk_freq => fosc
	)
	Port map
	(
		CLK => CLK, 
		RESET => RESET, 
		RX => internal_rxd, 
		RX_DATA => rx_data, 
		RX_DONE => rx_done
	);
	
	tx_unit : xmitter
	generic map
	(
		baud => baud,
		clk_freq => fosc
	)
	Port map
	(
		CLK => CLK, 
		RESET => RESET, 
		TX => internal_txd, 
		TX_INIT => tx_init, 
		TX_DONE => tx_done, 
		TX_DATA => tx_data
	);
end structural;