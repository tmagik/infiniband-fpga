------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) 2008, 2009 Iowa State University Research Foundation,   --
--    Inc.                                                                  --
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
--    If you would like to utilize this file to generate non-modifiable     --
--    FPGA or ASIC cores, please contact troy@scl.ameslab.gov or the ISU    --
--    Research Foundation for alternate licensing agreements.               --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
--    Engineer: Tim Prince                                                  --
--                                                                          --
--    Create Date: 2/13/2009                                                --
--    Module Name: link_training_state_machine                              --
--    Description:                                                          --
--        The brains of the link/physical layer.                            --
--                                                                          --
--    Dependencies:                                                         --
--        LtsmFunctions library.                                            --
--                                                                          --
--    Comments:                                                             --
--        Next state logic is defined in the definitions library. I do it   --
--    this way to help break up the next state logic, which would otherwise --
--    be an indecipherable Big Block O' Text (TM). If you'd like to see the --
--    general layout of this FSM, see the InfiniBand specifications, upon   --
--    which this code is based.                                             --
--        This implementation is of the legacy (Pre-1.2) version as we      --
--    don't currently support enhanced signaling or test mode. Support for  --
--    reversed connections is not implemented.                              --
--        In the future, if there's enough time, implementing test mode is  --
--    probably worth looking into since this project is primarily for       --
--    research purposes.                                                    --
--                                                                          --
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.LtsmDefinitions.all;

entity LinkTrainingStateMachine is
	generic
	(
		ClockRate : natural := 100000000
	);
	Port 
	(
		-- Signal inputs
		Clock          : in STD_LOGIC;
		PowerOnReset   : in STD_LOGIC;
		LinkPhyReset   : in STD_LOGIC;
		LinkPhyRecover : in STD_LOGIC;
		
		-- FSM inputs
		RecvdTS1       : in boolean;
		RecvdTS2       : in boolean;
		RecvdIdle      : in boolean;
		RxTrained      : in boolean;
		RxMajorError   : in boolean;
		LaneOrderError : in boolean;
		HeartbeatError : in boolean;
		
		-- FSM outputs
		RxCmd : out RxCmdType;
		TxCmd : out TxCmdType
	);
end entity LinkTrainingStateMachine;

architecture Behavioral of LinkTrainingStateMachine is
	signal State     : LtsmStateType := InitialLtsmState;
	signal NextState : LtsmStateType ;
	
	-- Down counter for delay timing
	signal DelayTimer     : natural := 0;
	signal NewDelayTimer  : natural ;
	signal DelayTimerLoad : boolean ;
begin
   -- Output logic
	RxCmd <= RxCmdState( State );
	TxCmd <= TxCmdState( State );

	-- Clock logic
	ClockLogic : process ( Clock, PowerOnReset, LinkPhyReset ) is
	begin
		if ( PowerOnReset = '1' or LinkPhyReset = '1' ) then
			State <= InitialLtsmState;
			DelayTimer <= 0;
		elsif ( rising_edge(Clock) ) then
			State <= NextState;
			
			if ( DelayTimerLoad ) then
				DelayTimer <= NewDelayTimer;
			elsif ( DelayTimer /= 0 ) then
				DelayTimer <= DelayTimer - 1;
			end if;
		end if;
	end process ClockLogic;

	-- State transition logic
	-- See LtsmFunctions.vhd for implementation details.
	StateLogic : process (State, DelayTimer, RecvdTS1, RecvdTS2, RecvdIdle, RxTrained, RxMajorError, LaneOrderError) is
	begin
		NextState <= 
		(
			SuperState => NextSuperState(State, RecvdTS1, RecvdIdle, DelayTimer, RxMajorError, HeartbeatError, LinkPhyRecover),
			PollingState => NextPollingState(State, DelayTimer, RecvdTS1),
			SleepingState => NextSleepingState(State, DelayTimer, RecvdTS1),
			ConfigurationState => NextConfigurationState(State, DelayTimer, RxTrained, LaneOrderError, RecvdTS1, RecvdTS2, RecvdIdle),
			RecoveryState => NextRecoveryState(State, DelayTimer, RxTrained, RxMajorError, RecvdTS2, RecvdIdle),
			FailureState => State.FailureState
		);
	end process StateLogic;
	
	-- Logic for delay timer.
	DelayLogic : process (State, NextState) is
	begin
		if ( NextState /= State ) then
			DelayTimerLoad <= True;
			
			case GetTimeout(NextState) is
				when Delay2ms   => NewDelayTimer <=   2 * (ClockRate / 1000);
				when Delay100ms => NewDelayTimer <= 100 * (ClockRate / 1000);
				when Delay150ms => NewDelayTimer <= 150 * (ClockRate / 1000);
				when Delay400ms => NewDelayTimer <= 400 * (ClockRate / 1000);
				when others     => NewDelayTimer <= 0;
			end case;
		else
			DelayTimerLoad <= False;
			NewDelayTimer <= 0;
		end if;
	end process DelayLogic;
	
end architecture Behavioral;

