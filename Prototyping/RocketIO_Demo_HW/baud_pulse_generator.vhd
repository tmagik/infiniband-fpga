library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baud_pulse_generator is
	generic 
	( 
		clk_freq : natural := 156250000;
		baud     : natural := 115200
	);
	port 
	( 
		CLK    : in  STD_LOGIC;
		RESET  : in  STD_LOGIC;
		BPULSE : out STD_LOGIC
	);
end baud_pulse_generator;

architecture Behavioral of baud_pulse_generator is
	signal counter : natural range 0 to (clk_freq / baud) := 0;
begin

	BPULSE <= '1' when counter = (clk_freq / baud) else '0';

	process ( CLK, RESET ) begin
		if ( RESET = '1' ) then
			counter <= 0;
		elsif ( CLK = '1' and CLK'event ) then
			if ( counter >= (clk_freq / baud) ) then
				counter <= 0;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;

end Behavioral;

