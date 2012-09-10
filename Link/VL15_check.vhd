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

entity VL15_check is
	port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the four VL bits from the Local Route Header
			inputVL : in STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--These are the two LNH bits from the Local Route Header
			inputLNH : in STD_LOGIC_VECTOR(1 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an VL15 error, 0 otherwise
			error : out STD_LOGIC
			
		);
end VL15_check;

architecture dataflow of VL15_check is
begin


	PROCESS(clock)
	BEGIN
	
		IF enable = '1' THEN
	
			IF inputVL /= "1111" OR  inputLNH = "10" THEN
				error <= '0';
			ELSE error <= '1';
			END IF;
			
		ELSE error <= '1';
		END IF;
	
	END PROCESS;
	
end dataflow;
