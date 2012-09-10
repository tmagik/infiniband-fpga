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
use work.PCK_CRC32_D8.all;

entity ICRC is
	port(	
			--This is the 8-bit input from the incoming data stream
			input : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--This indicates the arrival of a new byte from the data stream
			clock : in STD_LOGIC;
			
			--This presets the ICRC to X"FFFFFFFF"
			reset : in STD_LOGIC;
			
			--This is the 32-bit output from the ICRC machine
			output : out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
end ICRC;

architecture dataflow of ICRC is

	signal mid : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
begin
	
	PROCESS(clock, reset)
	BEGIN
	
		IF reset = '1' THEN
			mid <= X"FFFFFFFF";
		ELSIF rising_edge(clock) THEN
			mid <= nextCRC32_D8(input, mid);
		END IF;
		
	END PROCESS;
	
	output(31) <= NOT mid(24);
	output(30) <= NOT mid(25);
	output(29) <= NOT mid(26);
	output(28) <= NOT mid(27);
	output(27) <= NOT mid(28);
	output(26) <= NOT mid(29);
	output(25) <= NOT mid(30);
	output(24) <= NOT mid(31);
	
	output(23) <= NOT mid(16);
	output(22) <= NOT mid(17);
	output(21) <= NOT mid(18);
	output(20) <= NOT mid(19);
	output(19) <= NOT mid(20);
	output(18) <= NOT mid(21);
	output(17) <= NOT mid(22);
	output(16) <= NOT mid(23);
	
	output(15) <= NOT mid(8);
	output(14) <= NOT mid(9);
	output(13) <= NOT mid(10);
	output(12) <= NOT mid(11);
	output(11) <= NOT mid(12);
	output(10) <= NOT mid(13);
	output(9) <= NOT mid(14);
	output(8) <= NOT mid(15);
	
	output(7) <= NOT mid(0);
	output(6) <= NOT mid(1);
	output(5) <= NOT mid(2);
	output(4) <= NOT mid(3);
	output(3) <= NOT mid(4);
	output(2) <= NOT mid(5);
	output(1) <= NOT mid(6);
	output(0) <= NOT mid(7);
	
end dataflow;
