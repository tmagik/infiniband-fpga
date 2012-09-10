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

entity LinkPacketCheckMachine is
	port(	
			--System clock
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
			
			--A packet counter
			count : in STD_LOGIC_VECTOR(10 DOWNTO 0);
			
			--The 32-bit CRC appended to the end of the incoming packet
			CRCFromPacket : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			--A 3-bit code indicating if there was an error, and if so, what it was
			error : out STD_LOGIC_VECTOR(2 DOWNTO 0);
			
			--The 8-bits being sent on to flow control
			flow_control_out : out STD_LOGIC_VECTOR(7 DOWNTO 0)			
		);
end LinkPacketCheckMachine;

architecture dataflow of LinkPacketCheckMachine is

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
	
	component Op_check
		port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the four Op bits from the Flow Control Packet
			input : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an LVer error, 0 otherwise
			error : out STD_LOGIC );
	end component;
	
	
	component f_length_check
		port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--This value will come from a counter; it represents
			--the actual length of the received packet (in bytes)
			received_bytes : in STD_LOGIC_VECTOR(10 DOWNTO 0);
			
			--This is an enable signal that is only asserted
			--when the header of a packet is flowing through
			--the data packet check machine
			enable : in STD_LOGIC;
			
			--This is 1 if there is an LVer error, 0 otherwise
			error : out STD_LOGIC );
	end component;
	
	
	component VL_Link_check
		port(	
			--This is the clock whose rising edges trigger error evaluations if enable is high
			clock : in STD_LOGIC;
			
			--These are the four VL bits from the Local Route Header
			inputVL : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
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
	
	
	component LinkErrorPriorityEncoder
		port (	
			--These are the signals from the various check routines
			--A value of 1 means that check didn't pass
			input : in STD_LOGIC_VECTOR(3 downto 0);
			
			--This output will take care of reporting only the most
			--important error according to the IB spec
			output : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;
	
	component LinkRegister
	port(	
			--System clock
			clock : in STD_LOGIC;
			
			--These are the 8 bits from the physical layer
			rcv_stream : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--The 8 bits received from the phyiscal layer are passed through here
			all8 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			--The upper four bits of teh stream are output here
			--This represents the opcode in the firse byte and
			--the VL in the second byte
			first4 : out STD_LOGIC_VECTOR(3 DOWNTO 0)			
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
	
	component VCRCComparator
	port(	--Our computed CRC
			computed : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--The CRC from the end of the packet
			from_packet : in STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--A bit representing their equality
			output : out STD_LOGIC
		);
	end component;
	
	component LinkPacketCheckMachineFSM
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
			
			--Enable the Op_check OneBitRegister
			op_en : out STD_LOGIC;
			
			--Enable the f_length_check OneBitRegister
			f_length_en : out STD_LOGIC;
			
			--Enable the VL_check OneBitRegister
			vl_en : out STD_LOGIC
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
	
	--From the LinkRegister to the check modules
	signal LinkRegisterEightBits : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal LinkRegisterFourBits : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	--Output from the VCRC check modules
	signal LPCRCOutput : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	--Output from the CRC compare module
	--This determines if the calculated CRC
	--is the same as the one in the packet
	signal CRCOutput : STD_LOGIC;
	
	--Outputs from the other 3 check modules
	signal OPCheckOutput : STD_LOGIC;
	signal FLengthOutput : STD_LOGIC;
	signal VLCheckOutput : STD_LOGIC;
	
	--Wires from OneBitRegisters to the
	--priority encoder
	signal CRCRegToEncoder : STD_LOGIC;
	signal OPRegToEncoder : STD_LOGIC;
	signal FLengthRegToEncoder : STD_LOGIC;
	signal VLRegToEncoder : STD_LOGIC;
	
	--Enable signals for the check
	--modules and OneBitRegisters
	signal CRCRegEnable : STD_LOGIC;
	signal OPRegEnable : STD_LOGIC;
	signal FLengthRegEnable : STD_LOGIC;
	signal VLRegEnable : STD_LOGIC;
	
	--signals from FIFO to FSM Controller
	signal FIFOFull : STD_LOGIC;
	signal FIFOEmpty : STD_LOGIC;
	
	--signals from FSM Controller to FIFO
	signal FIFOReset : STD_LOGIC;
	signal FIFORead : STD_LOGIC;
	signal FIFOWrite : STD_LOGIC;
	
begin

	--This calculates the VCC (LPCRC) of the incoming packet
	myLPCRC	: VCRC PORT MAP(LinkRegisterEightBits, clock, reset, LPCRCOutput);
	
	--This compares the calculated CRC to the CRC appended to the end of the packet
	myComp	: VCRCComparator PORT MAP(LPCRCOutput, CRCFromPacket, CRCOutput);
	
	--The next three check for more specific errors
	myOp	: Op_check PORT MAP(clock, LinkRegisterFourBits, OPRegEnable, OPCheckOutput);
	
	myFlen	: f_length_check PORT MAP(clock, count, FLengthRegEnable, FLengthOutput);
	
	myVL	: VL_Link_check PORT MAP(clock, LinkRegisterFourBits, PortState, OperationalVLs, VLRegEnable, VLCheckOutput);
	
	--If there's an error, this guy reports it in the right order
	myEnc	: LinkErrorPriorityEncoder PORT MAP(VLRegToEncoder & FLengthRegToEncoder & OpRegToEncoder & CRCRegToEncoder, error);

	--This is a big FIFO to hold the incoming data while it's being validated
	myBuf	: FIFO PORT MAP(LinkRegisterEightBits, clock, FIFOWrite, FIFORead, FIFOReset, flow_control_out, FIFOFull, FIFOEmpty);

	--Every clock cycle the 8 bits from the physical layer are moved to this register
	--It sends the correct bits of the header to the check modules that need them
	myReg	: LinkRegister PORT MAP (clock, rcv_stream, LinkRegisterEightBits, LinkRegisterFourBits);
	
	--These 4 registers are enabled when their corresponding check modules have evaluated their data
	--These will be enabled at different clock cycles, but once the passed through the CRCReg
	--can be enabled and the priority encoder is free to decide if an error exists
	CRCReg	: OneBitRegister PORT MAP(clock, CRCRegEnable, CRCOutput, CRCRegToEncoder);
	
	OpReg	: OneBitRegister PORT MAP(clock, OPRegEnable, OPCheckOutput, OPRegToEncoder);
	
	FLenReg	: OneBitRegister PORT MAP(clock, FLengthRegEnable, FLengthOutput, FLengthRegToEncoder);
	
	VLReg	: OneBitRegister PORT MAP(clock, VLRegEnable, VLCheckOutput, VLRegToEncoder);
	
	--This guy makes everything happen at the correct time.  Based on what the
	--Packet Receiver State Machine's state is, this module enables the corresponding check
	--modules/registers when their part of the header arrives.  It also tells the FIFO when
	--to reset and/or release its contents to the network layer
	myFSM	: LinkPacketCheckMachineFSM PORT MAP(clock, reset, rcv_stream_status, FIFOFull, FIFOEmpty, FIFORead, FIFOWrite, FIFOReset, CRCRegEnable, OpRegEnable, FLengthRegEnable, VLRegEnable);
	
end dataflow;
