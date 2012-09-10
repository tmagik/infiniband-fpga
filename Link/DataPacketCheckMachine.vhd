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

entity DataPacketCheckMachine is
	port(	--System clock
			clock : in STD_LOGIC;
			
			--System reset
			reset : in STD_LOGIC;
		
			--Incoming data from the physical layer, 8 bits per clock cycle
			rcv_stream : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--The status of the phyLink stream
			--0 : idle
			--1 : SDP, Start of Data Packet
			--2 : SLP, Start of Link Packet
			--3 : EGP, End of good Packet
			--4 : EBP, End of Bad Packet
			rcv_stream_status : in INTEGER RANGE 0 TO 4;
			
			--The PortInfo.PortState attribute
			PortState : in INTEGER RANGE 0 TO 4;
			
			--The PortInfo.OperationalVLs attribute
			OperationalVLs : in STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--The PortInfo.MTU attribute
			MTU : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--The Destination Local ID (DLID) of this device
			myDLID : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--A packet counter
			count : in STD_LOGIC_VECTOR(10 DOWNTO 0);
			
			--The 31-bit CRC appended to the end of the incoming packet
			ICRCFromPacket : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--The 16-bit CRC appended to the end of the incoming packet
			VCRCFromPacket : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--A 3-bit code indicating if there was an error, and if so, what it was
			error : out STD_LOGIC_VECTOR(2 DOWNTO 0);
			
			--The 8-bits being sent on to the network layer
			network_layer_out : out STD_LOGIC_VECTOR(7 DOWNTO 0)
			
			
		);
end DataPacketCheckMachine;

architecture dataflow of DataPacketCheckMachine is

	component ICRC
		port(	
			--This is the 8-bit input from the incoming data stream
			input : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--This indicates the arrival of a new byte from the data stream
			clock : in STD_LOGIC;
			
			--This presets the ICRC to X"FFFFFFFF"
			reset : in STD_LOGIC;
			
			--This is the 32-bit output from the ICRC machine
			output : out STD_LOGIC_VECTOR(31 DOWNTO 0) );
	end component;
	
	component VCRC
		port(	
			--This is the 8-bit input stream
			input : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--This indicates the arrival of a new byte from the data stream
			clock : in STD_LOGIC;
			
			--This presets the VCRC to X"FFFF"
			reset : in STD_LOGIC;
			
			--This is the 16-bit output from the VCRC machine
			output : out STD_LOGIC_VECTOR(15 DOWNTO 0) );
	end component;
	
	
	component LVer_check
		port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the four LVer bits from the Local Route Header
			input : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an LVer error, 0 otherwise
			error : out STD_LOGIC );
	end component;
	
	
	component d_length_check
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
			error : out STD_LOGIC );
	end component;
	
	
	component dlid_check
		port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--This is the 16 bit Destination Local ID from the Local Route Header
			dlid : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--These are the four VL bits from the Local Route Header
			inputVL : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--This is the LID for this hardware port from PortInfo.LID
			myDLID : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an LVer error, 0 otherwise
			error : out STD_LOGIC );
	end component;
	
	
	component VL_check
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
			error : out STD_LOGIC );
	end component;
	
	
	component VL15_check
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
			error : out STD_LOGIC );
	end component;
	
	component ErrorPriorityEncoder
		port (	
			--These are the signals from the various check routines
			--A value of 1 means that check didn't pass
			input : in STD_LOGIC_VECTOR(6 downto 0);
			
			--This output will take care of reporting only the most
			--important error according to the IB spec
			output : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;
	
	component DataRegister
	port(	
			--System clock
			clock : in STD_LOGIC;
			
			--These are the 8 bits from the physical layer
			rcv_stream : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--The 8 bits received from the phyiscal layer are passed through here
			all8 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--The upper two bits of the stream are output here
			--This represents the 2-bit LNH value
			first2 : out STD_LOGIC_VECTOR(1 DOWNTO 0);
			
			--The upper three bits of the stream are output here
			--This represents the three most significant bits
			--of the 11-bit Packet Length value
			first3 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
			
			--The upper four bits of teh stream are output here
			--This represents the opcode in the firse byte and
			--the VL in the second byte
			first4 : out STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--The lower four bits of the stream are output here
			--This represents the LVer in the second byte
			last4 : out STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	end component;
	
	component OneBitRegister
	port(	--input clock
			clock : in STD_LOGIC;	
	
			--1-bit signal to enable the register
			enable : in STD_LOGIC;
			
			--1-bit input
			input : in STD_LOGIC;
			
			--1-bit output
			output : out STD_LOGIC
	);
	end component;
	
	component ICRCComparator
	port(	--Our computed CRC
			computed : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--The CRC from the end of the packet
			from_packet : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--A bit representing their equality
			output : out STD_LOGIC
		);
	end component;
	
	component VCRCComparator
	port(	--Our computed CRC
			computed : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--The CRC from the end of the packet
			from_packet : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--A bit representing their equality
			output : out STD_LOGIC
		);
	end component;
	
	component DataPacketCheckMachineFSM
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
	end component;
	
	component FIFO
    
		generic (
			--The length in bits of each buffer entry
			WORD_WIDTH	: natural := 8;
			
			--The number of address bits needed
			--2 ^ ADD_WIDTH = The # of entries in the buffer
			ADD_WIDTH	: natural := 3 );
			
			
		port (	
			--The incoming buffer data
			data_in		: in STD_LOGIC_VECTOR(WORD_WIDTH - 1 DOWNTO 0);
			
			--The system clock
			clock		: in STD_LOGIC;
			
			--A write request
			wreq		: in STD_LOGIC;
			
			--A read request
			rreq		: in STD_LOGIC;
			
			--Asynchronous system reset.  This resets all pointers
			--and clears the memory contents
			reset		: in STD_LOGIC;
			
			--Buffer's output
			data_out	: out STD_LOGIC_VECTOR(WORD_WIDTH - 1 DOWNTO 0);
			
			--Asserted when the buffer can store no more data
			full		: inout STD_LOGIC;
			
			--Asserted when the buffer cannot perform any more reads
			empty		: inout STD_LOGIC);
			
	end component;
	
	--From the DataRegister to the check modules
	signal DataRegisterEightBits : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal DataRegisterTopFourBits : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal DataRegisterBottomFourBits : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal DataRegisterThreeBits : STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal DataRegisterTwoBits : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	--Outputs from the CRC check modules
	signal VCRCOutput : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal ICRCOutput : STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--Outputs from the CRC compare modules
	--These determine if the calculated CRC
	--is the same as the one in the packet
	signal ICRCCompared : STD_LOGIC;
	signal VCRCCompared : STD_LOGIC;
	
	--The final CRC output signal
	--1 if an error, 0 if not
	signal CRCOutput : STD_LOGIC;
	
	--Outputs from the other 5 check modules
	signal LVCheckOutput : STD_LOGIC;
	signal DLengthOutput : STD_LOGIC;
	signal DLIDCheckOutput : STD_LOGIC;
	signal VLCheckOutput : STD_LOGIC;
	signal VL15CheckOutput : STD_LOGIC;
	
	--Wires from OneBitRegisters to the
	--priority encoder
	signal CRCRegToEncoder : STD_LOGIC;
	signal LVRegToEncoder : STD_LOGIC;
	signal DLengthRegToEncoder : STD_LOGIC;
	signal DLIDRegToEncoder : STD_LOGIC;
	signal VLRegToEncoder : STD_LOGIC;
	signal VL15RegToEncoder : STD_LOGIC;
	
	--Enable signals for the check
	--modules and OneBitRegisters
	signal CRCRegEnable : STD_LOGIC;
	signal LVRegEnable : STD_LOGIC;
	signal DLengthRegEnable : STD_LOGIC;
	signal DLIDRegEnable : STD_LOGIC;
	signal VLRegEnable : STD_LOGIC;
	signal VL15RegEnable : STD_LOGIC;
	
	--signals from FIFO to FSM Controller
	signal FIFOFull : STD_LOGIC;
	signal FIFOEmpty : STD_LOGIC;
	
	--signals from FSM Controller to FIFO
	signal FIFOReset : STD_LOGIC;
	signal FIFORead : STD_LOGIC;
	signal FIFOWrite : STD_LOGIC;
	
begin

	--These two calculate the CRC of the incoming packet
	myICRC	: ICRC PORT MAP(DataRegisterEightBits, clock, reset, ICRCOutput);
	
	myVCRC	: VCRC PORT MAP(DataRegisterEightBits, clock, reset, VCRCOutput);
	
	--These two compare the computed CRC and the value embedded in the packet
	ICRCCom	: ICRCComparator PORT MAP(ICRCOutput, ICRCFromPacket, ICRCCompared);
		
	VCRCCom	: VCRCComparator PORT MAP(VCRCOutput, VCRCFromPacket, VCRCCompared);
	
	--CRC error if: VCRC is good AND (ICRC is good OR xport = raw)
	--xport=raw if LNH[1] = '0'
	CRCOutput <= VCRCCompared AND (ICRCCompared OR (NOT DataRegisterTwoBits(1)));
	
	--These 5 output 1 if they find their respective error
	myLV	: LVer_check PORT MAP(clock, DataRegisterBottomFourBits, LVRegEnable, LVCheckOutput);
	
	myDlen	: d_length_check PORT MAP(clock, DataRegisterThreeBits & DataRegisterEightBits, DLengthRegEnable, count, DataRegisterTwoBits, MTU, DLengthOutput);
	
	dlid	: dlid_check PORT MAP(clock, DataRegisterEightBits & DataRegisterEightBits, DataRegisterTopFourBits, myDLID, DLIDRegEnable, DLIDCheckOutput);
	
	myVL	: VL_check PORT MAP(clock, DataRegisterTopFourBits, DataRegisterEightBits & DataRegisterEightBits, PortState, OperationalVLs, VLRegEnable, VLCheckOutput);
	
	myVL15	: VL15_check PORT MAP(clock, DataRegisterTopFourBits, DataRegisterTwoBits, VL15RegEnable, VL15CheckOutput);
	
	--If there's an error, this guy reports it in the right order
	myEnc	: ErrorPriorityEncoder PORT MAP('1' & VL15RegToEncoder & VLRegToEncoder & DLIDRegToEncoder & DLengthRegToEncoder & LVRegToEncoder & CRCRegToEncoder, error);

	--This is a big FIFO to hold the incoming data while it's being validated
	myBuf	: FIFO PORT MAP(DataRegisterEightBits, clock, FIFOWrite, FIFORead, reset, network_layer_out, FIFOFull, FIFOEmpty);
	
	--Every clock cycle the 8 bits from the physical layer are moved to this register
	--It sends the correct bits of the header to the check modules that need them
	myReg	: DataRegister PORT MAP(clock, rcv_stream, DataRegisterEightBits, DataRegisterTwoBits, DataRegisterThreeBits, DataRegisterTopFourBits, DataRegisterBottomFourBits);
	
	--These 6 registers are enabled when their corresponding check modules have evaluated their data
	--These will be enabled at different clock cycles, but once the passed through the CRCReg
	--can be enabled and the priority encoder is free to decide if an error exists
	CRCReg	: OneBitRegister PORT MAP(clock, CRCRegEnable, CRCOutput, CRCRegToEncoder);
	
	LVReg	: OneBitRegister PORT MAP(clock, LVRegEnable, LVCheckOutput, LVRegToEncoder);
	
	DlenReg	: OneBitRegister PORT MAP(clock, DLengthRegEnable, DLengthOutput, DLengthRegToEncoder);
	
	DlidReg	: OneBitRegister PORT MAP(clock, DLIDRegEnable, DLIDCheckOutput, DLIDRegToEncoder);
	
	VLReg	: OneBitRegister PORT MAP(clock, VLRegEnable, VLCheckOutput, VLRegToEncoder);
	
	VL15Reg	: OneBitRegister PORT MAP(clock, VL15RegEnable, VL15CheckOutput, VL15RegToEncoder);
	
	--This guy makes everything happen at the correct time.  Based on what the
	--Packet Receiver State Machine's state is, this module enables the corresponding check
	--modules/registers when their part of the header arrives.  It also tells the FIFO when
	--to reset and/or release its contents to the network layer
	myFSM	: DataPacketCheckMachineFSM PORT MAP(clock, reset, rcv_stream_status, FIFOFull, FIFOEmpty, FIFORead, FIFOWrite, FIFOReset, CRCRegEnable, LVRegEnable, DLengthRegEnable, DLIDRegEnable, VLRegEnable, VL15RegEnable);
	
end dataflow;
