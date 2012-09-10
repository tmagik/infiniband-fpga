library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library InfiniBand;
--use InfiniBand.PhysLayer.all;
library work;
use work.PhysLayer.all;

entity demo_tx_fsm is
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
end entity demo_tx_fsm;

architecture Behavioral of demo_tx_fsm is
	type state is ( Idle, Send );
	
	signal cstate : state := Idle;
	signal nstate : state ;
begin
	UART_XMIT_DATA <= e8b10b_to_vec(GTX_RX_DATA)(7 downto 0);
	
	clk_logic : process ( GTX_USR_CLK, RESET, PLL_LOCKED ) is
	begin
		if ( RESET = '1' or PLL_LOCKED = '0' ) then
			cstate <= Idle;
		elsif ( rising_edge(GTX_USR_CLK) ) then
			cstate <= nstate;
		end if;
	end process clk_logic;
	
	async_logic : process ( GTX_RX_DATA, UART_XMIT_FULL, cstate ) is
	begin	
		nstate <= cstate;
		UART_XMIT_REQ <= '0';
		
		case cstate is
		when Idle =>
			if ( GTX_RX_DATA = Symbol_SDP ) then
				nstate <= Send;
			end if;
		when Send =>
			if ( GTX_RX_DATA = Symbol_EGP ) then
				nstate <= Idle;
			elsif ( UART_XMIT_FULL /= '1' ) then
				UART_XMIT_REQ <= '1';
			end if;
		end case;
		
	end process async_logic;

end Behavioral;

