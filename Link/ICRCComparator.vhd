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

entity ICRCComparator is
	port(	--Our computed CRC
			computed : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--The CRC from the end of the packet
			from_packet : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--A bit representing their equality
			output : out STD_LOGIC
		);
end ICRCComparator;

architecture dataflow of ICRCComparator is
begin

	PROCESS(computed, from_packet)
	begin
	
		IF computed = from_packet THEN
			output <= '1';
		ELSE output <= '0';
		END IF;
		
	END PROCESS;

end dataflow;
