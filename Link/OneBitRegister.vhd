------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) 2008 Mark Ciecior                                       --
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
library ieee;
use ieee.std_logic_1164.all;

entity OneBitRegister is
	port(	--input clock
			clock : in STD_LOGIC;	
	
			--1-bit signal to enable the register
			enable : in STD_LOGIC;
			
			--1-bit input
			input : in STD_LOGIC;
			
			--1-bit output
			output : out STD_LOGIC
	);
end OneBitRegister;

architecture behavioral of OneBitRegister is

begin
	
	PROCESS(clock)
	begin
	
		IF rising_edge(clock) THEN
			IF enable = '1' THEN
				output <= input;
			END IF;
		END IF;
		
	END PROCESS;
		
	
end behavioral;
