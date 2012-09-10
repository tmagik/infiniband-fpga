--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:16:29 03/27/2009
-- Design Name:   
-- Module Name:   /tmp/infinibandfpga/Prototyping/RocketIO_Demo_HW/RocketIO_Demo_tb.vhd
-- Project Name:  RocketIO_Demo_HW
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RocketIO_Demo
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY RocketIO_Demo_tb IS
END RocketIO_Demo_tb;
 
ARCHITECTURE behavior OF RocketIO_Demo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RocketIO_Demo
    PORT(
         GTX_REFCLK_P : IN  std_logic;
         GTX_REFCLK_N : IN  std_logic;
         RESET : IN  std_logic;
         UART_RX : IN  std_logic;
         UART_TX : OUT  std_logic;
         GTX_RXP : IN  std_logic_vector(1 downto 0);
         GTX_RXN : IN  std_logic_vector(1 downto 0);
         GTX_TXP : OUT  std_logic_vector(1 downto 0);
         GTX_TXN : OUT  std_logic_vector(1 downto 0);
			TX_INHIBIT : IN  std_logic;
			LEDS : out std_logic_vector(7 downto 0);
			SW : in std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal GTX_REFCLK_P : std_logic := '0';
   signal GTX_REFCLK_N : std_logic := '0';
   signal RESET : std_logic := '0';
   signal UART_RX : std_logic := '1';
   signal GTX_RXP : std_logic_vector(1 downto 0) := (others => '0');
   signal GTX_RXN : std_logic_vector(1 downto 0) := (others => '0');
	signal TX_INHIBIT : std_logic := '1';
	signal SW : std_logic_vector(1 downto 0) := "00";

 	--Outputs
   signal UART_TX : std_logic;
   signal GTX_TXP : std_logic_vector(1 downto 0);
   signal GTX_TXN : std_logic_vector(1 downto 0);
	signal LEDS : std_logic_vector(7 downto 0);
	
	constant GTX_REFCLK_P_period : time := 16 ns;
	constant rs232_period : time := 8680 ns;
BEGIN
 
	GTX_REFCLK_N <= not GTX_REFCLK_P;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RocketIO_Demo PORT MAP (
          GTX_REFCLK_P => GTX_REFCLK_P,
          GTX_REFCLK_N => GTX_REFCLK_N,
          RESET => RESET,
          UART_RX => UART_RX,
          UART_TX => UART_TX,
          GTX_RXP => GTX_RXP,
          GTX_RXN => GTX_RXN,
          GTX_TXP => GTX_TXP,
          GTX_TXN => GTX_TXN,
			 TX_INHIBIT => TX_INHIBIT,
			 SW=>SW
        );
		  
   GTX_REFCLK_P_process : process
   begin
		GTX_REFCLK_P <= '0';
		wait for GTX_REFCLK_P_period/2;
		GTX_REFCLK_P <= '1';
		wait for GTX_REFCLK_P_period/2;
   end process;
 
	process begin
		TX_INHIBIT <= '1';
		wait for 110000 ns;
		TX_INHIBIT <= '0';
		wait;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
		RESET <= '1';
      wait for GTX_REFCLK_P_period*15;
		RESET <= '0';
		wait for rs232_period*5;
      
		UART_RX <= '0';
		wait for rs232_period;
		
		UART_RX <= '1';
		wait for rs232_period * 2;

		UART_RX <= '0';
		wait for rs232_period;
		
		UART_RX <= '1';
		wait for rs232_period;
		
		UART_RX <= '0';
		wait for rs232_period * 2;
		
		UART_RX <= '1';
		wait for rs232_period;
		
		UART_RX <= '0';
		wait for rs232_period;
		
		UART_RX <= '1';
		wait for rs232_period;

      wait;
   end process;

END;
