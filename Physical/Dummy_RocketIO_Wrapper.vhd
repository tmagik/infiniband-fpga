library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.physlayer_lib.all;

entity RocketIO_Wrapper is
	Port 
	( 
		REFCLK_P        : in  STD_LOGIC;
		REFCLK_N        : in  STD_LOGIC;
		GTXRESET        : in  STD_LOGIC;
		PLL_LOCK_DETECT : out STD_LOGIC;
		USR_CLK         : out STD_LOGIC;
		USR_CLK2        : out STD_LOGIC;
		TX_DATA         : in  symbol_8b10b;
		RX_DATA         : out symbol_8b10b;
		SYNC            : out STD_LOGIC_VECTOR (1 downto 0);
		RXN_IN          : in  STD_LOGIC;
		RXP_IN          : in  STD_LOGIC;
		TXN_OUT         : out STD_LOGIC;
		TXP_OUT         : out STD_LOGIC
	);
end RocketIO_Wrapper;

architecture Behavioral of RocketIO_Wrapper is
	signal clkdiv : std_logic := '0';
	
	type dmem_arr is array(0 to 99) of symbol_8b10b;
	signal delay_mem : dmem_arr;
begin
	-- A very simple black box replacement for RocketIO for simulation only.
	USR_CLK2 <= REFCLK_P;
	USR_CLK  <= clkdiv;
	PLL_LOCK_DETECT <= not GTXRESET;
	RX_DATA <= delay_mem(99);
	TXN_OUT <= RXN_IN;
	TXP_OUT <= RXP_IN;
	SYNC <= "10";

	clkdiv_proc : process ( GTXRESET, REFCLK_P ) is
	begin
		if ( GTXRESET = '1' ) then
			clkdiv <= '0';
		elsif ( rising_edge(REFCLK_P) ) then
			clkdiv <= not clkdiv;
		end if;
	end process clkdiv_proc;
	
	delay_proc : process ( REFCLK_P ) is
	begin
	   if ( rising_edge(REFCLK_P) ) then
	     delay_mem(0) <= TX_DATA;
	     for i in 1 to 99 loop
	       delay_mem(i) <= delay_mem(i - 1);
	     end loop;
	   end if;
	 end process;

end Behavioral;

