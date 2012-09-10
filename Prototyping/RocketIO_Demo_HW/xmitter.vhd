library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.uart_components.all;

entity xmitter is
	generic 
	(
		clk_freq : natural := 156250000;
		baud     : natural := 115200
	);
	port 
	( 
		CLK             : in   STD_LOGIC;
		RESET           : in   STD_LOGIC;
		TX_DATA         : in   STD_LOGIC_VECTOR (7 downto 0);
		TX_INIT         : in   STD_LOGIC;
		TX_DONE         : out  STD_LOGIC;
		TX              : out  STD_LOGIC
	);
end xmitter;

architecture Behavioral of xmitter is	
	signal bpulse : std_logic;
	signal last_bpulse : std_logic := '0';
	signal bgen_reset : std_logic := '0';
	
	signal tx_register : std_logic_vector(8 downto 0) := SXT("1", 9);
	signal tx_count : natural range 0 to 10 := 0;
	signal tx_finished : std_logic := '1';
begin
	TX <= tx_register(0);
	TX_DONE <= tx_finished;

	process ( CLK, RESET, TX_DATA, TX_INIT, BPULSE, LAST_BPULSE, TX_REGISTER ) begin
		if ( RESET = '1' ) then
			-- Fill the TX register with 1's for idle state
			tx_register <= SXT("1", 9);
			last_bpulse <= '0';
			tx_finished <= '1';
			bgen_reset <= '0';
		elsif ( CLK = '1' and CLK'event ) then
			if ( TX_INIT = '1' and tx_finished = '1' ) then
				tx_register <= TX_DATA & "0"; 
				tx_count <= 0;
				tx_finished <= '0';
				bgen_reset <= '1';
			elsif ( bgen_reset = '0' and bpulse = '1' and last_bpulse = '0' and tx_finished = '0') then
				if ( tx_count < 10 ) then
					tx_register <= "1" & tx_register(8 downto 1);
					tx_count <= tx_count + 1;
				else
					tx_finished <= '1';
				end if;
			else
			      bgen_reset <= '0';
			end if;
		
			last_bpulse <= bpulse;
		end if;
		
	end process;
	
	bpulse_gen: baud_pulse_generator 
	generic map 
	( 
		clk_freq => clk_freq,
		baud => baud
	)
	PORT MAP(
		CLK => CLK,
		RESET => bgen_reset,
		BPULSE => bpulse
	);

end Behavioral;

