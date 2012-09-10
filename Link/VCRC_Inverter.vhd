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

entity VCRC_Inverter is
	port(	
			--This is the 16-bit input stream from the VCRC machine
			input : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--This is the 16-bit result.  Both bytes
			--have been flipped, 
			--i.e. bit 0 -> bit 7
			--bit 7 -> bit 0
			--bit 15 -> bit 8
			--bit 8 -> bit 15
			output : out STD_LOGIC_VECTOR(15 DOWNTO 0)
			
		);
end VCRC_Inverter;

architecture dataflow of VCRC_Inverter is

begin

output(15) <= NOT input(8);
output(14) <= NOT input(9);
output(13) <= NOT input (10);
output(12) <= NOT input (11);
output(11) <= NOT input(12);
output(10) <= NOT input(13);
output(9) <= NOT input(14);
output(8) <= NOT input(15);

output(7) <= NOT input(0);
output(6) <= NOT input(1);
output(5) <= NOT input(2);
output(4) <= NOT input(3);
output(3) <= NOT input(4);
output(2) <= NOT input(5);
output(1) <= NOT input(6);
output(0) <= NOT input(7);
	
end dataflow;
