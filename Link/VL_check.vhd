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

entity VL_check is
	port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the four VL bits from the Local Route Header
			inputVL : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--These are the 16 DLID bits from the Local Route Header
			inputDLID : STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--value of the PortState component of the PortInfo attribute
			--Down = 0, Initialize= 1, Arm = 2, Active = 3, ActDefer = 4
			port_state : INTEGER RANGE 0 TO 4;
			
			--value of the OperationalVLs component of the PortInfo attribute
			--1 = VL0 is active
			--2 = VL0 - VL1 are active
			--3 = VL0 - VL3 are active
			--4 = VL0 - VL7 are active
			--5 = VL0 - VL14 are active
			--0, 6-15 = reserved, not valid
			opVLs : in STD_LOGIC_VECTOR(3 DOWNTO 0);
						
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an VL15 error, 0 otherwise
			error : out STD_LOGIC
			
		);
end VL_check;

architecture dataflow of VL_check is

		signal VLisOperational : STD_LOGIC;
begin


	PROCESS(clock)
	begin
	
			IF (opVLs =  "0001") THEN
				VLisOperational <= (NOT inputVL(3)) AND (NOT inputVL(2)) AND (NOT inputVL(1)) AND (NOT inputVL(0));
				
			ELSIF (opVLs = "0010") THEN
				VLisOperational <= (NOT inputVL(3)) AND (NOT inputVL(2)) AND (NOT inputVL(1));
			
			ELSIF (opVLs = "0011") THEN
				VLisOperational <= (NOT inputVL(3)) AND (NOT inputVL(2));
				
			ELSIF (opVLs = "0100") THEN
				VLisOperational <= (NOT inputVL(3));
			
			ELSIF (opVLs = "0101") THEN
				VLisOperational <= NOT (inputVL(3) AND inputVL(2) AND inputVL(1) AND inputVL(0));
			
			ELSE
				VLisOperational <= '0';
				
			END IF;
				
	END PROCESS;
	

	PROCESS(clock)
	BEGIN
	
		IF enable = '1' THEN
	
			IF ( VLisOperational = '1' AND (port_state = 2 OR port_state = 3) )
				OR
				(inputVL = "1111" AND (inputDLID = X"FFFF" OR inputDLID < X"C000")) THEN
				
				error <= '0';
			ELSE error <= '1';
			END IF;
			
		ELSE error <= '1';
		
		END IF;
	
	END PROCESS;
	
end dataflow;
