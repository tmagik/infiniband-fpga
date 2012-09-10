library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.uart_components.all;
use work.ip_compatibility.all;

entity uart_fifo is
	generic ( ip_provider : ip_provider_t := xilinx );
	port 
	( 
		CLK      : in  std_logic;
		RESET    : in  std_logic;
		DATA_IN  : in  std_logic_vector (7 downto 0);
		DATA_OUT : out std_logic_vector (7 downto 0);
		RD_REQ   : in  std_logic;
		WR_REQ   : in  std_logic;
		EMPTY    : out std_logic;
		FULL     : out std_logic
	);
end uart_fifo;

architecture Behavioral of uart_fifo is
begin

	fifo_buffer0 : uart_fifo_xilinx
	port map
	(
		clk => CLK,
		din => DATA_IN,
		rd_en => RD_REQ, 
		rst => RESET, 
		wr_en => WR_REQ,
		dout => DATA_OUT,
		empty => EMPTY,
		full => FULL
	);
	
end Behavioral;

