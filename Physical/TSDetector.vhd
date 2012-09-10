library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.physlayer_lib.all;
use work.ltsmdefinitions.all;

entity TSDetector is
	generic 
	(
		TSNumber : natural range 1 to 2
	);
	Port 
	( 
		Clock        : in  STD_LOGIC;
		PowerOnReset : in  STD_LOGIC;
		RxCmd        : in  RxCmdType;
		RxData       : in  Symbol_8b10b;
		RecvdTS      : out boolean
	);
end TSDetector;

architecture Behavioral of TSDetector is
	signal state      : natural := 0;
	signal next_state : natural;
	signal detect     : boolean;
	signal d_count    : natural := 0;
begin

	ClockProcess : process ( Clock, PowerOnReset ) is
	begin
		if ( PowerOnReset = '1' ) then 
			state <= 0;
			RecvdTS <= false;
			d_count <= 0;
		elsif ( rising_edge(Clock) ) then
		  if ( (TSNumber = 1 and RxCmd /= WaitTS1 ) or
		       (TSNumber = 2 and RxCmd /= WaitTS2 ) ) then
		       d_count <= 0;
		       state <= 0;
		       RecvdTS <= false;
		  else
			     state <= next_state;
			     if (detect and d_count < 8) then 
			          d_count <= d_count + 1;
			     end if;
			     if (TSNumber = 1) then
			          RecvdTS <= detect;
			     else
			          RecvdTS <= d_count = 8;
			     end if;
			end if;
		end if;
	end process ClockProcess;

	DetectProcess : process ( state, RxData, RxCmd ) is
	begin
		next_state <= 0;
		detect <= false;
		
		if ( (TSNumber = 1 and RxCmd = WaitTS1 ) or
		     (TSNumber = 2 and RxCmd = WaitTS2 ) ) then
			case state is
				when 0 =>
					if ( RxData = Symbol_Comma ) then
						next_state <= 1;
					end if;
				when 1 =>
					if ( RxData = (D,  0, 0) or RxData = (D,  1, 0) or
					     RxData = (D,  2, 0) or RxData = (D,  4, 0) or
						  RxData = (D,  8, 0) or RxData = (D, 15, 0) or
						  RxData = (D, 16, 0) or RxData = (D, 23, 0) or
						  RxData = (D, 24, 0) or RxData = (D, 27, 0) or
						  RxData = (D, 29, 0) or RxData = (D, 30, 0) ) then
						  next_state <= 2;
					end if;
				when others =>
					if ( (TSNumber = 1 and RxData = (D, 10, 2)) or
						  (TSNumber = 2 and RxData = (D,  5, 2)) ) then
						if (state < 15) then
							next_state <= state + 1;
						elsif (state = 15) then
							detect <= true;
						end if;
					end if;
				end case;
		end if;
	end process DetectProcess;

end Behavioral;

