library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library InfiniBand;
--use InfiniBand.PhysLayer.all;

library work;
use work.uart_components.all;
use work.ip_compatibility.all;
use work.physlayer.all;

entity RocketIO_Demo is
	port 
	( 
		GTX_REFCLK_P : in  STD_LOGIC;
		GTX_REFCLK_N : in  STD_LOGIC;
		RESET        : in  STD_LOGIC;
		UART_RX      : in  STD_LOGIC;
		UART_TX      : out STD_LOGIC;
		GTX_RXP      : in  STD_LOGIC_VECTOR (1 downto 0);
		GTX_RXN      : in  STD_LOGIC_VECTOR (1 downto 0);
		GTX_TXP      : out STD_LOGIC_VECTOR (1 downto 0);
		GTX_TXN      : out STD_LOGIC_VECTOR (1 downto 0);
		TX_INHIBIT   : in  STD_LOGIC;
		LEDS         : out STD_LOGIC_VECTOR(7 downto 0);
		SW           : in  STD_LOGIC_VECTOR(2  downto 0)
	);
end RocketIO_Demo;

architecture Behavioral of RocketIO_Demo is
	
	component demo_rx_fsm is
		port
		(
			GTX_USR_CLK    : in  std_logic;
			RESET          : in  std_logic;
			PLL_LOCKED     : in  std_logic;
			GTX_TX_DATA    : out symbol_8b10b;
			UART_RECV_RDY  : in  std_logic;
			UART_RECV_DATA : in  std_logic_vector(7 downto 0)
		);
	end component demo_rx_fsm;
	
	component demo_tx_fsm is
		port 
		( 
			GTX_USR_CLK    : in  STD_LOGIC;
			RESET          : in  STD_LOGIC;
			PLL_LOCKED     : in  STD_LOGIC;
			GTX_RX_DATA    : in  symbol_8b10b;
			UART_XMIT_REQ  : out STD_LOGIC;
			UART_XMIT_DATA : out STD_LOGIC_VECTOR (7 downto 0);
			UART_XMIT_FULL : in  STD_LOGIC
		);
	end component demo_tx_fsm;
	
	component xmit_fifo IS
		port 
		(
			rd_clk : IN  std_logic;
			wr_clk : IN  std_logic;
			din    : IN  std_logic_VECTOR(7 downto 0);
			rd_en  : IN  std_logic;
			rst    : IN  std_logic;
			wr_en  : IN  std_logic;
			dout   : OUT std_logic_VECTOR(7 downto 0);
			empty  : OUT std_logic;
			full   : OUT std_logic
		);
	END component xmit_fifo;
	
	signal uart_xmit_req : std_logic;
	signal uart_xmit_en  : std_logic;
	
	signal uart_xmit_data : std_logic_vector(7 downto 0);
	signal uart_recv_data : std_logic_vector(7 downto 0);
	signal uart_fifo_data : std_logic_vector(7 downto 0);	

	signal uart_recv_rdy  : std_logic;
	signal uart_xmit_rdy  : std_logic;
	
	signal gtx_usr_clk  : std_logic;
	signal gtx_usr_clk2 : std_logic;
	signal gtx_pll_lked : std_logic;
	signal gtx_tx_data  : symbol_8b10b;
	signal gtx_rx_data  : symbol_8b10b;
	
	signal fifo_empty : std_logic;
	signal fifo_full  : std_logic;

	signal reset_or_unlocked : std_logic;
	signal fifo_wr_en : std_logic;
	
	signal tx_fsm_reset : std_logic;
	signal sync : std_logic_vector(1 downto 0);
begin
	reset_or_unlocked <= not gtx_pll_lked or reset;
	fifo_wr_en <= uart_xmit_req when tx_inhibit = '0' else '0';
	uart_xmit_en <= uart_xmit_rdy and not fifo_empty;
	
	tx_fsm_reset <= reset_or_unlocked or TX_INHIBIT;

	process ( SW ) is
	begin
		case conv_integer(SW) is
		when 0 =>
			LEDS <= uart_fifo_data;
		when 1 => 
			LEDS <= uart_xmit_data;
		when 2 =>
			LEDS <= uart_recv_data;
		when 3 =>
			LEDS <= EXT(sync, 8);
		when 4 =>
			LEDS <= EXT("0", 8);
			case gtx_rx_data is
			when ( K, 28, 5 ) =>
				LEDS(0) <= '1';
			when ( K, 27, 7 ) => 
				LEDS(1) <= '1';
			when ( K, 29, 7 ) =>
				LEDS(2) <= '1';
			when ( K, 28, 0 ) =>
				LEDS(3) <= '1';
			when others =>
			end case;
			if (gtx_rx_data.k = k) then
				LEDS(4) <= '1';
			end if;
		when others =>
			LEDS <= uart_xmit_req & uart_xmit_en & uart_recv_rdy & uart_xmit_rdy & fifo_empty & fifo_full & reset_or_unlocked & fifo_wr_en;
		end case;
	end process;

	xmit_fifo_i : xmit_fifo
	port map
	(
		rd_clk => gtx_usr_clk,
		wr_clk => gtx_usr_clk2,
		rst    => reset_or_unlocked,
		din    => uart_xmit_data,
		wr_en  => fifo_wr_en,
		dout   => uart_fifo_data,
		rd_en  => uart_xmit_en,
		full   => fifo_full,
		empty  => fifo_empty
	);

	recv_i : receiver
	generic map
	(
		clk_freq => 78125000,
		baud     => 115200
	)
	port map
	(
		CLK => gtx_usr_clk2,
		RESET => reset_or_unlocked,
		RX => UART_RX,
		RX_DATA => uart_recv_data,
		RX_DONE => uart_recv_rdy
	);
	
	xmit_i : xmitter
	generic map
	(
		clk_freq => 78125000 / 2,
		baud     => 115200
	)
	port map
	(
		CLK => gtx_usr_clk,
		RESET => reset_or_unlocked,
		TX_DATA => uart_fifo_data,
		TX_INIT => uart_xmit_en,
		TX_DONE => uart_xmit_rdy,
		TX => uart_tx
	);

	uart_rx_fsm_i : demo_rx_fsm
	port map
	(
		GTX_USR_CLK    => gtx_usr_clk2,
		RESET          => reset_or_unlocked,
		PLL_LOCKED     => gtx_pll_lked,
		GTX_TX_DATA    => gtx_tx_data,
		UART_RECV_RDY  => uart_recv_rdy,
		UART_RECV_DATA => uart_recv_data
	);
	
	gtx_rx_fsm_i : demo_tx_fsm
	port map
	(
		GTX_USR_CLK => gtx_usr_clk2,
		RESET => tx_fsm_reset,
		PLL_LOCKED => gtx_pll_lked,
		GTX_RX_DATA => gtx_rx_data,
		UART_XMIT_REQ => uart_xmit_req,
		UART_XMIT_DATA => uart_xmit_data,
		UART_XMIT_FULL => fifo_full
	);
	
	gtx_i : RocketIO_Wrapper
	port map
	(
		 TILE0_REFCLK_PAD_N_IN => GTX_REFCLK_N,
		 TILE0_REFCLK_PAD_P_IN => GTX_REFCLK_P,
		 GTXRESET_IN           => RESET,
		 TILE0_PLLLKDET_OUT    => gtx_pll_lked,
		 USR_CLK               => gtx_usr_clk,
		 USR_CLK2              => gtx_usr_clk2,
		 TX_DATA               => gtx_tx_data,
		 RX_DATA               => gtx_rx_data,
		 RXN_IN                => GTX_RXN,
		 RXP_IN                => GTX_RXP,
		 TXN_OUT               => GTX_TXN,
		 TXP_OUT               => GTX_TXP,
		 SYNC                  => sync
	);
	
end Behavioral;

