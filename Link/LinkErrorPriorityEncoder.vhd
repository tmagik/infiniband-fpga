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

entity LinkErrorPriorityEncoder is  
	port (	
		--These are the signals from the various check routines
		--A value of 1 means that check didn't pass
		input : in STD_LOGIC_VECTOR(3 downto 0);
		
		--This output will take care of reporting only the most
		--important error according to the IB spec
		output : out STD_LOGIC_VECTOR(2 downto 0)

	);
end LinkErrorPriorityEncoder;

architecture dataflow of LinkErrorPriorityEncoder is  
begin    

	output <=	"001" when input(0) = '1' else --CRC error
				"010" when input(1) = '1' else --Unknown Op Code
				"011" when input(2) = '1' else --Length error
				"100" when input(3) = '1' else --VL error
				"000"; --no errors, good packet

end dataflow;
