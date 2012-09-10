library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.physlayer_lib.all;
use work.ltsmdefinitions.all;

entity TSWriter is
	generic
	(
		TSNumber : natural range 1 to 2
	);
	port 
	( 
		Clock        : in  STD_LOGIC;
		PowerOnReset : in  STD_LOGIC;
		TxCmd        : in  TxCmdType;
		TxData       : out Symbol_8b10b
	);
end TSWriter;

architecture Behavioral of TSWriter is
	signal counter : natural range 0 to 15 := 0;
begin

	ClockProc : process ( Clock, PowerOnReset, TxCmd ) is
	begin
		if ( PowerOnReset = '1' or 
			(TxCmd /= SendTS1 and TSNumber = 1) or 
			(TxCmd /= SendTS2 and TSNumber = 2)
		) then
			counter <= 0;
		elsif ( rising_edge( Clock ) ) then
			counter <= (counter + 1) mod 16;
		end if;
	end process;

	TxDataProc : process ( counter ) is
	begin
		case counter is
		when 0 =>
			TxData <= Symbol_Comma;
		when 1 =>
			-- Lane identifier -- physical lane 0
			TxData <= (D, 0, 0); 
		when others =>
			-- 14 symbols of D10.2 or D5.2 depending on the TS sequence.
			if ( TSNumber = 1 ) then
				TxData <= (D, 10, 2);
			else
				TxData <= (D, 5, 2);
			end if;
		end case;
	end process;

end Behavioral;

