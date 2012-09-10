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

entity PacketReceiverStateMachine is
	port(	--input clock
			clock : in STD_LOGIC;	
	
			--1-bit signal to reset the Link State Machine
			reset : in STD_LOGIC;
	
			--from physical layer, indicates whether physical layer is up or down
			phy_link : in STD_LOGIC;
			
			--this is the type of byte stream we're receiving from the physical layer
			--Data = 0: Data and link packet contents
			--Error = 1: code violation
			--SDP = 2: start data packet delimiter
			--SLP = 3: start link packet delimiter
			--EGP = 4: end good packet delimiter
			--EBP = 5: end bad packet delimiter
			--Idle = 6: idle
			rcv_stream : in INTEGER RANGE 0 TO 6;
			
			--value of the PortState component of the PortInfo attribute
			--Down = 0, Initialize= 1, Arm = 2, Active = 3, ActDefer = 4
			port_state : in INTEGER RANGE 0 TO 4;
			
			--this signal is asserted when the byte received from the
			--phy layer can be sent to the Data Packet Checker
			to_data_packet_checker : out STD_LOGIC;
			
			--this signal is asserted when the byte received from the
			--phy layer can be sent to the Link Packet Checker
			to_link_packet_checker : out STD_LOGIC;
			
			--this signal is asserted when the byte received from the
			--phy layer can be discarded
			discard_packet : out STD_LOGIC;
			
			--this signal is asserted when the byte received from the
			--phy layer can be corrupted
			corrupt_packet : out STD_LOGIC
	);
end PacketReceiverStateMachine;

architecture behavioral of PacketReceiverStateMachine is

	--these are the current and next states of the FSM
	--RcvInit = 0, Idle = 1, RcvDataPacket = 2, RcvLinkPacker = 3,
	--DataPacketDone = 4, MarkedBadPacket = 5, BadPacket = 6,
	--BadPacketDiscard = 7, LinkPacketDone = 8
	signal currentState, nextState : INTEGER RANGE 0 TO 8;
	
BEGIN
	
		--This process simply changes the state whenever a clock edge arives
		PROCESS(clock, port_state, phy_link)
		BEGIN
			IF reset = '1' OR port_state = 0 OR phy_link = '0' THEN
				currentState <= 0;
			ELSIF rising_edge(clock) THEN
				currentState <= nextState;
			END IF;
		END PROCESS;
		
		
		--This process asserts and deasserts any necessary signals
		PROCESS(currentState, rcv_stream, port_state)
		BEGIN
		
			to_data_packet_checker <= '0';
			to_link_packet_checker <= '0';
			discard_packet <= '0';
			corrupt_packet <= '0';
		
			CASE currentState IS
				--when in the RcvInit state
				when 0 =>
										
					--if PortState is not Down, go to Idle state
					IF port_state /= 0 THEN
						nextState <= 1;
					ELSE nextState <= 0;
					END IF;
				
				--when in the Idle state	
				when 1 =>
					
					--if we receive an SDP or SLP, go to the associated receive state
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSE nextState <= 1;
					END IF;
									
				--when in the RcvDataPacket state	
				when 2 =>
					
					--If we receive an
					--EGP: go to DataPacketDone
					--EBP: go to MarkedBadPacket
					--data: stay here
					--anything else: go to BadPacket
					IF rcv_stream = 4 THEN
						nextState <= 4;
					ELSIF rcv_stream = 5 THEN
						nextState <= 5;
					ELSIF rcv_stream = 0 THEN
						nextState <= 2;
					ELSE nextState <= 6;
					END IF;
				
				--when in the RcvLinkPacket state
				when 3 =>
					
					--If we receive an
					--EGP: go to LinkPacketDone
					--data: stay here
					--anything else: go to BadPacketDiscard
					IF rcv_stream = 4 THEN
						nextState <= 8;
					ELSIF rcv_stream = 0 THEN
						nextState <= 3;
					ELSE nextState <= 3;
					END IF;
				
				--when in the DataPacketDone state	
				when 4 =>
					
					to_data_packet_checker <= '1';
					
					--If we receive an
					--SDP: go to RcvDataPacket
					--SLP: go to RcvLinkPacket
					--idle: go to Idle
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSIF rcv_stream = 6 THEN
						nextState <= 1;
					ELSE nextState <= 4;
					END IF;
				
				--when in the MarkedBadPacket state
				when 5 =>
				
					discard_packet <= '1';
					corrupt_packet <= '1';
					
					--If we receive an
					--SDP: go to RcvDataPacket
					--SLP: go to RcvLinkPacket
					--idle: go to Idle
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSIF rcv_stream = 6 THEN
						nextState <= 1;
					ELSE nextState <= 4;
					END IF;
				
				--when in the BadPacket state
				when 6 =>
					
					discard_packet <= '1';
					corrupt_packet <= '1';
					
					--If we receive an
					--SDP: go to RcvDataPacket
					--SLP: go to RcvLinkPacket
					--idle: go to Idle
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSIF rcv_stream = 6 THEN
						nextState <= 1;
					ELSE nextState <= 4;
					END IF;
					
				--when in the BadPacketDiscard state
				when 7 =>
					
					discard_packet <= '1';
					
					--If we receive an
					--SDP: go to RcvDataPacket
					--SLP: go to RcvLinkPacket
					--idle: go to Idle
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSIF rcv_stream = 6 THEN
						nextState <= 1;
					ELSE nextState <= 4;
					END IF;
					
				--when in the LinkPacketDone state
				when 8 =>
					
					to_data_packet_checker <= '1';
					
					--If we receive an
					--SDP: go to RcvDataPacket
					--SLP: go to RcvLinkPacket
					--idle: go to Idle
					IF rcv_stream = 2 THEN
						nextState <= 2;
					ELSIF rcv_stream = 3 THEN
						nextState <= 3;
					ELSIF rcv_stream = 6 THEN
						nextState <= 1;
					ELSE nextState <= 4;
					END IF;
					
					
			END CASE;
		
		END PROCESS;
	
end behavioral;
