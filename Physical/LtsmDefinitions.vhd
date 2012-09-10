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
--    Engineer: Tim Prince (tim.prince@gmail.com)                           --
--                                                                          --
--    Create Date: 2/13/2009                                                --
--    Module Name: LtsmDefinitions.vhd                                      --
--    Description:                                                          --
--        Helper functions for the link training state machine.             --
--                                                                          --
--    Dependencies:                                                         --
--        Standard IEEE libraries.                                          --
--                                                                          --
--    Comments:                                                             --
--        See ltsm.vhd for implementation notes. See the InfiniBand speci-  --
--    fications for a functional description of the state machine.          --
--                                                                          --
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package LtsmDefinitions is
	type SuperStateType         is ( Disabled, Polling, Sleeping, Config, LinkUp, Recovery );
	type PollingStateType       is ( Disabled, Active, Quiet );
	type SleepingStateType      is ( Disabled, Delay, Quiet );
	type ConfigurationStateType is ( Disabled, Debounce, RcvrCfg, WaitRmt, Idle );
	type RecoveryStateType      is ( Disabled, Retrain, WaitRmt, Idle );

	type RxCmdType is ( Disabled, WaitTS1, WaitTS2, WaitIdle, EnConfig, EnDeSkew, Enabled );
	type TxCmdType is ( Disabled, SendTS1, SendTS2, SendIdle, Enabled );

	type DelayAmount is ( Delay0ms, Delay2ms, Delay100ms, Delay150ms, Delay400ms );

	type LtsmStateType is
	record
		SuperState         : SuperStateType;
		PollingState       : PollingStateType;
		SleepingState      : SleepingStateType;
		ConfigurationState : ConfigurationStateType;
		RecoveryState      : RecoveryStateType;
		FailureState       : SuperStateType;
	end record;

	constant InitialLtsmState : LtsmStateType := 
	(
		SuperState => Polling,
		PollingState => Active,
		SleepingState => Disabled,
		ConfigurationState => Disabled,
		RecoveryState => Disabled,
		FailureState => Polling 
	);
	
	function RxCmdState ( State : LtsmStateType )
		return RxCmdType;
		
	function TxCmdState ( State : LtsmStateType )
		return TxCmdType;
	
	function NextSuperState 
	( 
		State : LtsmStateType; 
		RcvdTS1 : boolean; 
		RcvdIdle : boolean; 
		DelayTimer : natural; 
		RxMajorError : boolean;
		HeartbeatError : boolean; 
		LinkPhyRecover : std_logic 
	) return SuperStateType;
	
	function NextPollingState ( State : LtsmStateType; DelayTimer : natural; RecvdTS1 : boolean ) 
		return PollingStateType;

	function NextSleepingState ( State : LtsmStateType; DelayTimer : natural; RecvdTS1 : boolean ) 
		return SleepingStateType;
		
	function GetTimeout ( State : LtsmStateType ) 
		return DelayAmount;

	function NextConfigurationState 
	( 
		State          : LtsmStateType; 
		DelayTimer     : natural;
		RxTrained      : boolean;
		LaneOrderError : boolean;
		RecvdTS1       : boolean;
		RecvdTS2       : boolean;
		RecvdIdle      : boolean 
	) return ConfigurationStateType;
	
	function NextRecoveryState 
	( 
		State        : LtsmStateType; 
		DelayTimer   : natural;
		RxTrained    : boolean; 
		RxMajorError : boolean;
		RecvdTS2     : boolean;
		RecvdIdle    : boolean
	) return RecoveryStateType;
	
end LtsmDefinitions;

package body LtsmDefinitions is

	-- Receive command output logic
	function RxCmdState ( State : LtsmStateType )
		return RxCmdType is
		variable result : RxCmdType := Disabled;
	begin
		case State.SuperState is
			when Polling =>
				return WaitTS1;
			when Sleeping =>
				if ( State.SleepingState = Delay ) then
					return Disabled;
				else
					return WaitTS1;
				end if;
			when Config =>
				case State.ConfigurationState is
					when Debounce => return WaitTS1;
					when RcvrCfg => return EnConfig;
					when WaitRmt => return WaitTS2;
					when Idle => return WaitIdle;
					when others => return Disabled;
				end case;
			when LinkUp =>
				return Enabled;
			when Recovery =>
				case State.RecoveryState is
					when ReTrain => return EnDeSkew;
					when WaitRmt => return WaitTS2;
					when Idle => return WaitIdle;
					when others => Return Disabled;
				end case;
			when others =>
				return Disabled;
		end case;
	end function RxCmdState;
	
	-- Transmit command output logic
	function TxCmdState ( State : LtsmStateType )
		return TxCmdType is
	begin
		case State.SuperState is
			when Polling =>
				if ( State.PollingState = Active ) then
					return SendTS1;
				else
					return Disabled;
				end if;
			when Sleeping =>
				return Disabled;
			when Config =>
				case State.ConfigurationState is
					when Debounce => return SendTS1;
					when RcvrCfg => return SendTS1;
					when WaitRmt => return SendTS2;
					when Idle => return SendIdle;
					when others => return Disabled;
				end case;
			when LinkUp =>
				return Enabled;
			when Recovery =>
				case State.RecoveryState is 
					when ReTrain => return SendTS1;
					when WaitRmt => return SendTS2;
					when Idle => return SendIdle;
					when others => return Disabled;
				end case;
			when others =>
				return Disabled;
		end case;
	end function TxCmdState;
	
	-- Super State transition logic.
	function NextSuperState 
	( 
		State : LtsmStateType; 
		RcvdTS1 : boolean; 
		RcvdIdle : boolean; 
		DelayTimer : natural; 
		RxMajorError : boolean;
		HeartbeatError : boolean; 
		LinkPhyRecover : std_logic 
	) 
		return SuperStateType is
	begin
		case State.SuperState is
			when Polling =>
				if ( RcvdTS1 ) then
					return Config;
				end if;
			when Sleeping =>
				if ( RcvdTS1 ) then
					return Config;
				end if;
			when Config =>
				if ( State.ConfigurationState = Idle and RcvdIdle ) then
					return LinkUp;
				elsif ( State.ConfigurationState = RcvrCfg and DelayTimer = 0 ) then
					return State.FailureState;
				end if;
			when LinkUp =>
				if ( RxMajorError or LinkPhyRecover = '1' ) then return Recovery;
				elsif ( HeartbeatError ) then return State.FailureState;
				end if;
			when Recovery =>
				if ( State.RecoveryState = Idle and RcvdIdle ) then return LinkUp;
				elsif ( DelayTimer = 0 ) then return State.FailureState;
				end if;
			when Disabled =>
				return Disabled;
			when others =>
				return State.FailureState;
		end case;
		return State.SuperState;
	end function NextSuperState;
	
	-- Polling state transition logic.
	function NextPollingState ( State : LtsmStateType; DelayTimer : natural; RecvdTS1 : boolean ) 
		return PollingStateType is
	begin
		if ( State.SuperState = Polling or
		    (State.FailureState = Polling and (State.SuperState = Recovery or State.SuperState = Config))) then
			case State.PollingState is
			when Active =>
				if ( RecvdTS1 ) then
					return Disabled;
				elsif ( DelayTimer = 0 ) then
					return Quiet;
				end if;
			when Quiet =>
				if ( RecvdTS1 ) then
					return Disabled;
				elsif ( DelayTimer = 0 ) then
					return Active;
				end if;
			when Disabled =>
				if ( State.SuperState = Recovery and DelayTimer = 0 and State.FailureState = Polling ) then
					return Quiet;
				end if;
			end case;
		end if;
		
		return State.PollingState;
	end function NextPollingState;

	-- Sleeping state transition logic.
	function NextSleepingState ( State : LtsmStateType; DelayTimer : natural; RecvdTS1 : boolean ) 
		return SleepingStateType is
	begin
		if ( State.SuperState = Sleeping or
		    (State.FailureState = Sleeping and (State.SuperState = Recovery or State.SuperState = Config))) then
			case State.SleepingState is
				when Delay =>
					if ( DelayTimer = 0 ) then
						return Quiet;
					else
						return Delay;
					end if;
				when Quiet =>
					if ( RecvdTS1 ) then
						return Disabled;
					else
						return Quiet;
					end if;
				when Disabled =>
					if ( State.SuperState = Recovery and DelayTimer = 0 and State.FailureState = Sleeping ) then
						return Quiet;
					end if;
			end case;
		end if;
		
		return State.SleepingState;
	end function NextSleepingState;

	-- Configuration state transition logic.
	function NextConfigurationState 
	( 
		State          : LtsmStateType; 
		DelayTimer     : natural;
		RxTrained      : boolean;
		LaneOrderError : boolean;
		RecvdTS1       : boolean;
		RecvdTS2       : boolean;
		RecvdIdle      : boolean
	) return ConfigurationStateType is
	begin
		if ( State.SuperState = Config ) then
			case State.ConfigurationState is
				when Debounce => 
					if ( DelayTimer = 0 ) then
						return RcvrCfg;
					else
						return Debounce;
					end if;
				when RcvrCfg =>
					if ( RxTrained ) then
						return WaitRmt;
					elsif ( DelayTimer = 0 ) then
						return Disabled;
					end if;
				when WaitRmt =>
					if ( RecvdTS2 ) then
						return Idle;
					elsif ( DelayTimer = 0 or LaneOrderError ) then
						return RcvrCfg;
					else
						return WaitRmt;
					end if;
				when Idle =>
					if ( DelayTimer = 0 or LaneOrderError or RecvdTS1 ) then
						return RcvrCfg;
					elsif ( RecvdIdle ) then
						return Disabled;
					else
						return Idle;
					end if;
				when others =>
					return Disabled;
			end case;
		elsif ( State.SuperState = Polling and RecvdTS1 ) then
			return Debounce;
		elsif ( State.SleepingState = Quiet and RecvdTS1 ) then
			return Debounce;
		end if;
		return State.ConfigurationState;
	end function NextConfigurationState;
	
	-- Recovery state transition logic.
	function NextRecoveryState 
	( 
		State        : LtsmStateType; 
		DelayTimer   : natural;
		RxTrained    : boolean; 
		RxMajorError : boolean;
		RecvdTS2     : boolean;
		RecvdIdle    : boolean
	) return RecoveryStateType is
	begin
		if ( State.SuperState = Recovery ) then
			case State.RecoveryState is
				when Retrain =>
					if ( RxTrained ) then
						return WaitRmt;
					elsif ( DelayTimer = 0 ) then
						return Disabled;
					else
						return Retrain;
					end if;
				when WaitRmt =>
					if ( RecvdTS2 ) then
						return Idle;
					elsif ( DelayTimer = 0 ) then
						return Disabled;
					else
						return WaitRmt;
					end if;
				when Idle =>
					if ( RecvdIdle or DelayTimer = 0 ) then
						return Disabled;
					else 
						return Idle;
					end if;
				when others =>
					return Disabled;
			end case;
		elsif ( State.SuperState = LinkUp and RxMajorError ) then
			return Retrain;
		end if;
		
		return State.RecoveryState;
	end function NextRecoveryState;

	-- Get state timeout in milliseconds
	function GetTimeout ( State : LtsmStateType ) 
		return DelayAmount is
	begin
		case State.SuperState is
			when Polling =>
				if ( State.PollingState = Active ) then
					return Delay2ms;
				else
					return Delay100ms;
				end if;
			when Sleeping =>
				if ( State.SleepingState = Delay ) then
					return Delay400ms;
				end if;
			when Config =>
				case State.ConfigurationState is
					when Idle => return Delay2ms;
					when WaitRmt => return Delay2ms;
					when RcvrCfg => return Delay150ms;
					when Debounce => return Delay100ms;
					when others => return Delay0ms;
				end case;
			when Recovery =>
				return Delay2ms;
			when others => return Delay0ms;
		end case;
		return Delay0ms;
	end function GetTimeout;
end LtsmDefinitions;
