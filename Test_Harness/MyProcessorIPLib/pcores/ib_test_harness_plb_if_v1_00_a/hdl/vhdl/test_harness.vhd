library ieee;
use ieee.std_logic_1164.all;

library work;
use work.physlayer_lib.all;

entity InfiniBand_Test_Harness is
	port
	(
		REFCLK_P     : in  std_logic;
		REFCLK_N     : in  std_logic;
		SCR_VAL      : in  std_logic_vector(15 downto 0);
		RDFIFO_VAL   : out std_logic_vector(9 downto 0);
		RDFIFO_WR    : out std_logic;
		WRFIFO_VAL   : in  std_logic_vector(9 downto 0);
		WRFIFO_RD    : out std_logic;
		WRFIFO_EMPTY : in  std_logic;
		RDFIFO_FULL  : in  std_logic
	);
end entity;

architecture dummy of InfiniBand_Test_Harness is
begin
	RDFIFO_VAL <= WRFIFO_VAL;
	RDFIFO_WR  <= not WRFIFO_EMPTY and not RDFIFO_FULL;
	WRFIFO_RD  <= not WRFIFO_EMPTY and not RDFIFO_FULL;
end architecture dummy;
