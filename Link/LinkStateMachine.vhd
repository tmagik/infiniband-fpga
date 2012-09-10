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

entity LinkStateMachine is
	port(	--input clock
			clock : in STD_LOGIC;	
	
			--1-bit signal to reset the Link State Machine
			reset : in STD_LOGIC;
	
			--Flow control packet with Op code set to 0x0 or 0x1
			remote_init : in STD_LOGIC_VECTOR(47 DOWNTO 0);
			
			--Down = 0, Arm = 1, Active = 2
			c_port_state : in INTEGER RANGE 0 TO 2;
			
			--prevents premature transition from armed to active (boolean value)
			active_enable : in STD_LOGIC;
			
			--initiates transition from LinkArm to LinkActive
			--for routers and channel adapters: occurs on receipt of valid non-VL15 packet
			--for switches: only generated on port that received the packet
			active_trigger : in STD_LOGIC;
			
			--indicates that physical link has been down for 10ms +3%/-51%
			link_down_timeout : in STD_LOGIC;
			
			--from physical layer, indicates whether physical layer is up or down
			phy_link : in STD_LOGIC;
			
			--indicates whether to transmit non-SMP data packets
			data_pkt_xmit_enable : out STD_LOGIC;
			
			--indicates whether to receive non-SMP data packets
			data_pkt_rcv_enable : out STD_LOGIC;
			
			--indicates whether to transmit/receive SMP packets
			smp_enable : out STD_LOGIC;
			
			--indicates whether to transmit/receive link packets
			link_pkt_enable : out STD_LOGIC;
			
			--value of the PortState component of the PortInfo attribute
			--Down = 0, Initialize= 1, Arm = 2, Active = 3, ActDefer = 4
			port_state : out INTEGER RANGE 0 TO 4
	);
end LinkStateMachine;

architecture behavioral of LinkStateMachine is

	--these are the current and next states of the FSM
	signal currentState, nextState : INTEGER RANGE 0 TO 4;
	
	--For channel adapters: This is always false
	--For switches: this can be true or false
	--This determines whether data packets are transmitted in the Arm state
	signal forward_in_arm : STD_LOGIC;
	
	--For channel adapters: This is always true
	--For switches: all ports are set to true except for ESP0
	--This determines whether data packets are received in the Arm state
	signal rcv_in_arm : STD_LOGIC;

BEGIN
	
		--This process simply changes the state whenever a clock edge arives
		PROCESS(clock, reset, c_port_state)
		BEGIN
			IF reset = '1' OR c_port_state = 0 THEN
				currentState <= 0;
			ELSIF rising_edge(clock) THEN
				currentState <= nextState;
			END IF;
		END PROCESS;
		
		
		--This process asserts and deasserts any necessary signals
		PROCESS(currentState, remote_init, c_port_state, active_enable, active_trigger, link_down_timeout, phy_link)
		BEGIN
		
			CASE currentState IS
				--when in the Down state
				when 0 =>
					--don't receive any packets
					data_pkt_xmit_enable <= '0';
					data_pkt_rcv_enable <= '0';
					smp_enable <= '0';
					link_pkt_enable <= '0';
					port_state <= 0;
					
					--if physical layer is up, go to Initialize state
					IF phy_link = '1' THEN
						nextState <= 1;
					ELSE nextState <= 0;
					END IF;
				
				--when in the Initialize state	
				when 1 =>
					--receive only SMP packets
					data_pkt_xmit_enable <= '0';
					data_pkt_rcv_enable <= '0';
					smp_enable <= '1';
					link_pkt_enable <= '1';
					port_state <= 1;
					
					--if physical layer drops, reset
					--if CPortState goes to Arm and physical layer stays up, go to Arm state
					IF phy_link = '0' THEN
						nextState <= 0;
					ELSIF c_port_state = 1 AND phy_link = '1' THEN
						nextState <= 2;
					ELSE nextState <= 1;
					END IF;
				
				--when in the Arm state	
				when 2 =>
					--THIS VARIES FOR CHANNEL ADAPTERS AND SWITCHES
					--CAs: receive packets but don't send them
					--switches: your choice (essentially)
					data_pkt_xmit_enable <= forward_in_arm;
					data_pkt_rcv_enable <= rcv_in_arm;
					smp_enable <= '1';
					link_pkt_enable <= '1';
					port_state <= 2;
					
					--if physical layer drops, reset
					--if the other signals are asserted, go to Active state
					IF phy_link = '0' THEN
						nextState <= 0;
					ELSIF (c_port_state = 2 OR active_trigger = '1') AND phy_link = '1' AND active_enable = '1' THEN
						nextState <= 3;
					ELSE nextState <= 2;
					END IF;
				
				--when in the Active state
				when 3 =>
					--send and receive all packets
					data_pkt_xmit_enable <= '1';
					data_pkt_rcv_enable <= '1';
					smp_enable <= '1';
					link_pkt_enable <= '1';
					port_state <= 3;
					
					--if physical layer drops, go to ActDefer
					--otherwise DO SOMETHING WITH THE REMOTE_INIT
					IF phy_link = '0' THEN
						nextState <= 4;
					--ELSIF --REMOTE_INIT STUFF HERE, WHAT DOES IT MEAN? THEN
					--	nextState <= 0;
					ELSE nextState <= 3;
					END IF;
				
				--when in the ActDefer state	
				when 4 =>
					--don't send or receive anything, just wait for the physical layer to come back
					data_pkt_xmit_enable <= '0';
					data_pkt_rcv_enable <= '0';
					smp_enable <= '0';
					link_pkt_enable <= '0';
					port_state <= 3;
					
					--if physical layer comes back, go to Active state
					--if timeout expires, reset
					IF phy_link = '1' THEN
						nextState <= 3;
					ELSIF -- REMOTE_INIT CLAUSE
					(phy_link = '0' AND link_down_timeout = '1') THEN
						nextState <= 0;
					ELSE nextState <= 4;
					END IF;
					
			END CASE;
		
		END PROCESS;
	
end behavioral;
