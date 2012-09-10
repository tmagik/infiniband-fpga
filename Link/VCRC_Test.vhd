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
use work.PCK_CRC16_D8.all;

entity VCRC_Test is
	port(	
			--This is a 16-bit test packet
		--	input : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--This is the 16-bit CRC result
			output : out STD_LOGIC_VECTOR(15 DOWNTO 0)
			
		);
end VCRC_Test;

architecture structural of VCRC_Test is

signal between : STD_LOGIC_VECTOR(15 DOWNTO 0);

component VCRC
	PORT (output : out STD_LOGIC_VECTOR(15 DOWNTO 0) );
end component;

component VCRC_Inverter
	PORT ( input : in STD_LOGIC_VECTOR(15 DOWNTO 0);
				output : out STD_LOGIC_VECTOR(15 DOWNTO 0 ) );
end component;


begin

	machine: VCRC PORT MAP (between);
	invert : VCRC_Inverter PORT MAP (between, output);

end structural;
