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
use ieee.numeric_std.all;

entity FIFOControl is

	generic (	
				
			--The length in bits of each buffer entry
			WORD_WIDTH	: natural := 8;
			
			--The number of address bits needed
			--2 ^ ADD_WIDTH = The # of entries in the buffer
			ADD_WIDTH	: natural := 3
			
			);
			
	port (	
		
			--The system clock
			clock		: IN STD_LOGIC;
			
			--Write request
			wreq		: IN STD_LOGIC;
			
			--Read request
			rreq		: IN STD_LOGIC;
			
			--Asynchronous system reset, resets all pointers
			reset		: in STD_LOGIC;
			
			--Memory address to read from
			rdaddress	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);
			
			--Memory address to write to
			wraddress	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);
			
			--Asserted when no more can be written to the buffer
			full		: inout STD_LOGIC;
			
			--Asserted when no more can be read from the bufer
			empty		: inout STD_LOGIC
		 );
end FIFOControl;

architecture a of FIFOControl is

	--Variables representing the front(read) and back(write) pointers
	shared variable front_temp, back_temp : UNSIGNED(ADD_WIDTH DOWNTO 0);

begin

	--This increments the read and write pointers appropriately
	--and asserts the full and empty signals if necessary
	PROCESS(clock, reset)
	begin
		empty <= '0';
		full <= '0';
		IF reset = '0' THEN
			front_temp := (others => '0');
			back_temp := (others => '0');
			empty <= '1';
		ELSIF rising_edge(clock) THEN
		
			--Move back the read pointer
			IF rreq = '1' AND empty = '0' THEN
				front_temp := front_temp + 1;
			END IF;
			
			--Move back the write pointer
			IF wreq = '1' AND full = '0' THEN
				back_temp := back_temp + 1;
			END IF;
			
		END IF;
		
		--If the pointers are the same, the buffer must be empty
		IF front_temp = back_temp THEN
			empty <= '1';
		
		--If the pointers differ only in their most significant bit
		--the write pointer must have wrapped around so the buffer's full
		ELSIF ( ( front_temp(ADD_WIDTH - 1 DOWNTO 0) = back_temp(ADD_WIDTH - 1 DOWNTO 0) ) AND ( front_temp(ADD_WIDTH) /= back_temp(ADD_WIDTH) ) ) THEN
			full <= '1';
			
		END IF;
		
		--Forget the most significant bit and output the read and write pointers/addresses
		FOR i IN 0 TO ADD_WIDTH - 1 LOOP
			rdaddress(i) <= front_temp(i);
			wraddress(i) <= back_temp(i);
		END LOOP;
		
	END PROCESS;
	
end architecture;
