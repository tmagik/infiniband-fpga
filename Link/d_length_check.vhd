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
use ieee.std_logic_unsigned.all;

entity d_length_check is
	port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the eleven Packet Length bits from the Local Route Header
			pktlen : STD_LOGIC_VECTOR(10 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This value will come from a counter; it represents
			--the actual length of the received packet (in bytes)
			received_bytes : in STD_LOGIC_VECTOR(10 DOWNTO 0);
			
			--These are the two LNH bits from the Local Route Header
			--They'll be used to determine the packet's minimum length
			inputLNH : in STD_LOGIC_VECTOR(1 DOWNTO 0);
			
			--This is the MTU of the link, stored in PortInfo.MTUCap
			MTU : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--This is 1 if there is an LVer error, 0 otherwise
			error : out STD_LOGIC
			
		);
end d_length_check;

architecture dataflow of d_length_check is

	--Used to store the packet's required minimum length
	signal min_length : STD_LOGIC_VECTOR(2 DOWNTO 0);

begin

	
	--if the xport bit is '0', min_length is 5, otherwise it's 6
	min_length <=	"101" when inputLNH(1) = '0' else "110";

	PROCESS(clock)
	BEGIN
	
		IF enable = '1' THEN
	
			IF ( ( (pktlen * "0100" + "0010") = received_bytes) AND ( (SHR((MTU + "1111100"),"10") >= pktlen ) AND (pktlen >= min_length) ) ) THEN
				error <= '0';
			ELSE error <= '1';
			END IF;
		
		ELSE error <= '1';
			
		END IF;
	
	END PROCESS;
	
end dataflow;
