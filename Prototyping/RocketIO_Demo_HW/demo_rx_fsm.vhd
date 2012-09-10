library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library InfiniBand;
--use InfiniBand.PhysLayer.all;
library work;
use work.PhysLayer.all;

entity demo_rx_fsm is
	port
	(
		GTX_USR_CLK    : in  std_logic;
		RESET          : in  std_logic;
		PLL_LOCKED     : in  std_logic;
		GTX_TX_DATA    : out symbol_8b10b;
		UART_RECV_RDY  : in  std_logic;
		UART_RECV_DATA : in  std_logic_vector(7 downto 0)
	);
end entity demo_rx_fsm;

architecture Behavioral of demo_rx_fsm is
	type state is ( Idle, Start, Send, Stop );
	
	signal cstate    : state := Idle;
	signal nstate    : state ;
	signal idle_gen_data : symbol_8b10b;
	signal idle_data     : symbol_8b10b;
	signal counter : natural range 0 to 4095 := 0;
	
	signal recvd_char : symbol_8b10b := ( D, 0, 0 );
begin

	process ( idle_gen_data, counter ) is
	begin
		case counter is
		when 0 =>
			idle_data <= Symbol_COMMA;
		when 1 =>
			idle_data <= Symbol_SKP;
		when 2 =>
			idle_data <= Symbol_SKP;
		when 3 =>
			idle_data <= Symbol_SKP;
		when others =>
			idle_data <= idle_gen_data;
		end case;
	end process;
	
	lfsr_inst : Idle_LFSR 
	port map
	(
		CLK => GTX_USR_CLK,
		RESET => RESET,
		OUTPUT => idle_gen_data
	);

	clk_logic : process ( GTX_USR_CLK, RESET, PLL_LOCKED ) is
	begin
		if ( RESET = '1' or PLL_LOCKED = '0' ) then
			cstate <= Idle;
			recvd_char <= ( D, 0, 0 );
		elsif ( rising_edge(GTX_USR_CLK) ) then
			if (cstate = Idle) then
				if (counter < 4095) then
					counter <= counter + 1;
				else
					counter <= 0;
				end if;
			end if;
			cstate <= nstate;
			
			if ( uart_recv_rdy = '1' ) then
				recvd_char <= vec_to_e8b10b("0" & UART_RECV_DATA);
			end if;
		end if;
	end process clk_logic;

	async_logic : process ( cstate, UART_RECV_RDY, idle_data, UART_RECV_DATA ) is
	begin
		nstate <= cstate;
		GTX_TX_DATA <= idle_data;
		
		case cstate is
		when Idle =>
			if ( UART_RECV_RDY = '1' ) then
				nstate <= Start;
				GTX_TX_DATA <= Symbol_COMMA;
			end if;
		when Start =>
			GTX_TX_DATA <= Symbol_SDP;
			nstate <= Send;
		when Send =>
			GTX_TX_DATA <= recvd_char;
			nstate <= Stop;
		when Stop =>
			GTX_TX_DATA <= Symbol_EGP;
			nstate <= Idle;
		end case;
	end process async_logic;

end Behavioral;

