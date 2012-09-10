library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.uart_components.all;

entity receiver is
	generic
	(
		clk_freq : natural := 156250000;
		baud     : natural := 115200
	);
	Port ( CLK : in  STD_LOGIC;
	       RESET : in  STD_LOGIC;
	       RX : in  STD_LOGIC;
	       RX_DATA : out  STD_LOGIC_VECTOR (7 downto 0) := EXT("0", 8);
	       RX_DONE : out  STD_LOGIC);
end receiver;

architecture Behavioral of receiver is
	signal half_counter : natural range 0 to 15;
	signal bit_counter  : natural range 0 to 9;
	
	signal rx_register  : std_logic_vector(7 downto 0) := EXT("0", 8);
	
	signal baud_tick : std_logic;
	signal done_pulse : std_logic := '0';
begin

	RX_DONE <= done_pulse;

	process ( CLK, RX, RESET, half_counter, bit_counter, rx_register, baud_tick, done_pulse ) begin
		if ( RESET = '1' ) then
			RX_DATA <= EXT("0", 8);
			rx_register <= EXT("0", 8);
			half_counter <= 0;
			bit_counter <= 0;
		elsif ( rising_edge(CLK) ) then
			if ( done_pulse = '1' ) then 
				done_pulse <= '0';
			end if;
			
			if ( baud_tick = '1' ) then
				case bit_counter is
				when 0 =>
					-- Catch the start bit
					if ( half_counter = 15 ) then
						bit_counter <= 1;
						half_counter <= 0;
					elsif ( RX = '1' and half_counter < 7 ) then
						half_counter <= 0;
					else
						half_counter <= half_counter + 1;
					end if;
				when 9 => 
					-- Catch the stop bit and output the received data
					if ( RX = '1' ) then
					   bit_counter <= 0;
					   half_counter <= 0;
					   RX_DATA <= rx_register;
					   done_pulse <= '1';
					end if;
				when others =>
					if ( half_counter = 7 ) then
						rx_register <= rx & rx_register(7 downto 1);
						half_counter <= half_counter + 1;
					elsif ( half_counter = 15 ) then
						half_counter <= 0;
						bit_counter <= bit_counter + 1;
					else
						half_counter <= half_counter + 1;
					end if;
				end case;
			end if;
		end if;
	end process;

	baud_gen : baud_pulse_generator
	generic map 
	( 
		clk_freq => clk_freq, 
		baud => 16 * baud
	)
	port map ( CLK => CLK, 
	           RESET => RESET, 
	           BPULSE => baud_tick
	         );

end Behavioral;
