------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) 2008 Tim Prince                                         --
--                                                                          --
--    This file is part of the InfiniBand FPGA Project.                     --
--                                                                          --
--    This program is free software: you can redistribute it and/or modify  --
--    it under the terms of the GNU General Public License as published by  --
--    the Free Software Foundation, either version 3 of the License, or     --
--    (at your option) any later version.                                   --
--                                                                          --
--    This program is distributed in the hope that it will be useful,       --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of        --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         --
--    GNU General Public License for more details.                          --
--                                                                          --
--    You should have received a copy of the GNU General Public License     --
--    along with this program.  If not, see <http://www.gnu.org/licenses/>. --
--                                                                          --
------------------------------------------------------------------------------
-- Engineer: Tim Prince                                                     --
--                                                                          --
-- Create Date:    10:47:39 01/30/2009                                      --
-- Module Name:    Idle_LFSR                                                --
-- Description:                                                             --
--     Generates the idle sequence transmitted by InfiniBand devices when   --
--     there is no data to be sent over the link.                           --
--                                                                          --
-- Dependencies:                                                            --
--     None, apart from standard libraries.                                 --
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library InfiniBand;
--use InfiniBand.PhysLayer_Lib.all;
library work;
use work.PhysLayer_Lib.all;

entity Idle_LFSR is
	Port 
	(
		Clock        : in  STD_LOGIC;
		PowerOnReset : in  STD_LOGIC;
		TxData       : out symbol_8b10b
	);
end Idle_LFSR;

architecture Behavioral of Idle_LFSR is
	signal current_value : std_logic_vector(10 downto 0) := SXT("1", 11) ;
	signal next_value    : std_logic_vector(10 downto 0);

	constant seed : std_logic_vector(10 downto 0) := EXT("1", 11);
	constant poly : std_logic_vector(10 downto 0) := "10100000001";
begin
	TxData <= vec_to_e8b10b("0" & current_value(10 downto 3));

	sync_logic : process ( Clock, PowerOnReset ) is begin
		if ( PowerOnReset = '1' ) then
			current_value <= SEED;
		elsif ( rising_edge( Clock ) ) then
			current_value <= next_value;
		end if;
	end process sync_logic;

	next_logic : process ( current_value ) is 
		variable shift_bit : std_logic := '0';
	begin
		shift_bit := '0';
		for i in 0 to 9 loop
			if ( POLY(10 - i) = '1' ) then
				shift_bit := shift_bit xor current_value(i);
			end if;
		end loop;
	
		next_value <= shift_bit & current_value(10 downto 1);
	end process next_logic;

end Behavioral;

