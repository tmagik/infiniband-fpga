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

entity DataPacketCheckMachineFSM is
	port(	
			--System clock
			clock : in STD_LOGIC;
			
			--System reset
			reset : in STD_LOGIC;
			
			--The status of the phyLink stream
			--0 : idle
			--1 : SDP, Start of Data Packet
			--2 : SLP, Start of Link Packet
			--3 : EGP, End of good Packet
			--4 : EBP, End of Bad Packet
			rcv_stream_status : in INTEGER RANGE 0 TO 4;
		
			--The buffer asserts this signal when it can write no more data
			FIFOFull : in STD_LOGIC;
			
			--The buffer asserts this signal when it can read no more data
			FIFOEmpty : in STD_LOGIC;
			
			--Tell the buffer to send the next byte to flow control
			FIFORead : out STD_LOGIC;
			
			--Tell the buffer to write the incoming byte to memory
			FIROWrite : out STD_LOGIC;
			
			--Tell the buffer to clear its contents and reset the pointers
			FIFOReset : out STD_LOGIC;
			
			--Enable the CRC OneBitRegister
			crc_en : out STD_LOGIC;
			
			--Enable the LVer_check OneBitRegister
			lv_en : out STD_LOGIC;
			
			--Enable the d_length_check OneBitRegister
			d_length_en : out STD_LOGIC;
			
			--Enable the DLID_check OneBitRegister
			dlid_en : out STD_LOGIC;
			
			--Enable the VL_check OneBitRegister
			vl_en : out STD_LOGIC;
			
			--Enable the VL15_check OneBitRegister
			vl15_en : out STD_LOGIC
		);
end dataPacketCheckMachineFSM;

architecture dataflow of DataPacketCheckMachineFSM is

begin




end dataflow;
