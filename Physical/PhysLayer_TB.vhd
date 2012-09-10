LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library work;
use work.physlayer_lib.all;

ENTITY PhysLayer_TB IS
END PhysLayer_TB;

ARCHITECTURE behavior OF PhysLayer_TB IS 
	component PhysLayer is
		Generic
		(
			-- 10 kHz here to speed up delays in the sim.
			-- Naturally this will be higher for actual hardware.
			ClockRate : natural := 10000
		);
		Port
		( 
			REFCLK_P         : in  STD_LOGIC;
			REFCLK_N         : in  STD_LOGIC;
			POWER_ON_RESET   : in  STD_LOGIC;
			SYSCLK           : out STD_LOGIC;
			SYSRESET         : out STD_LOGIC;
			RXN_IN           : in  STD_LOGIC;
			RXP_IN           : in  STD_LOGIC;
			TXN_OUT          : out STD_LOGIC;
			TXP_OUT          : out STD_LOGIC;
			LINK_PHY_TX_DATA : in  symbol_8b10b;
			LINK_PHY_RX_DATA : out symbol_8b10b;
			LINK_PHY_RESET   : in  STD_LOGIC;
			LINK_PHY_RECOVER : in  STD_LOGIC;
			LINK_PHY_UP      : out STD_LOGIC
		);
	end component PhysLayer;
	
	signal REFCLK_P         :  STD_LOGIC := '0';
	signal REFCLK_N         :  STD_LOGIC := '1';
	signal POWER_ON_RESET   :  STD_LOGIC := '1';
	signal RXN_IN           :  STD_LOGIC := '0';
	signal RXP_IN           :  STD_LOGIC := '0';
	signal LINK_PHY_RESET   :  STD_LOGIC := '0';
	signal LINK_PHY_RECOVER :  STD_LOGIC := '0';
	signal LINK_PHY_TX_DATA :  symbol_8b10b := (K, 0, 0);

	signal SYSCLK           :  STD_LOGIC;
	signal SYSRESET         :  STD_LOGIC;
	signal TXN_OUT          :  STD_LOGIC;
	signal TXP_OUT          :  STD_LOGIC;
	signal LINK_PHY_UP      :  STD_LOGIC;
	signal LINK_PHY_RX_DATA :  symbol_8b10b;
BEGIN
	-- Component Instantiation
	uut: PhysLayer
	generic map
	(
		ClockRate => 100000
	)
	PORT MAP
	(
		REFCLK_P => REFCLK_P,
		REFCLK_N => REFCLK_N,
		POWER_ON_RESET => POWER_ON_RESET,
		RXN_IN => RXN_IN,
		RXP_IN => RXP_IN,
		LINK_PHY_RESET => LINK_PHY_RESET,
		LINK_PHY_RECOVER => LINK_PHY_RECOVER,
		LINK_PHY_TX_DATA => LINK_PHY_TX_DATA,
		SYSCLK => SYSCLK,
		SYSRESET => SYSRESET,
		TXN_OUT => TXN_OUT,
		TXP_OUT => TXP_OUT,
		LINK_PHY_UP => LINK_PHY_UP,
		LINK_PHY_RX_DATA => LINK_PHY_RX_DATA
	);

	stim_proc : process
	BEGIN
		POWER_ON_RESET <= '1';
		wait for 100 ns;
		POWER_ON_RESET <= '0';
		wait;
	END PROCESS stim_proc;

	Clk_Proc : PROCESS
	BEGIN
		while True loop
			wait for 5 ns;
			REFCLK_P <= not REFCLK_P;
			REFCLK_N <= not REFCLK_N;
		end loop;
	END PROCESS Clk_Proc;

END;
