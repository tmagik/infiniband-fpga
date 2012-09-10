--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:49:07 02/27/2009
-- Design Name:   
-- Module Name:   C:/Users/Xiang/Documents/link_training_state_machine/ltsm_tb.vhd
-- Project Name:  LinkTrainingStateMachine
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LinkTrainingStateMachine
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

library work;
use work.LtsmDefinitions.all;

ENTITY ltsm_tb IS
END ltsm_tb;
 
ARCHITECTURE behavior OF ltsm_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LinkTrainingStateMachine
    	generic
	(
		ClockRate : natural := 1000000
	);
	Port 
	(
				-- Signal inputs
		Clock        : in  STD_LOGIC;
		PowerOnReset : in  STD_LOGIC;
		LinkPhyReset : in  STD_LOGIC;
		
		-- FSM inputs
		LinkPhyRecover : in boolean;
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
    END COMPONENT;
    

   --Inputs
   signal Clock : std_logic := '0';
   signal PowerOnReset : std_logic := '0';
   signal LinkPhyReset : std_logic := '0';
   signal LinkPhyRecover : boolean := false;
   signal RecvdTS1 : boolean := false;
   signal RecvdTS2 : boolean := false;
   signal RecvdIdle : boolean := false;
   signal RxTrained : boolean := false;
   signal RxMajorError : boolean := false;
   signal LaneOrderError : boolean := false;
   signal HeartbeatError : boolean := false;

 	--Outputs
   signal RxCmd : RxCmdType;
   signal TxCmd : TxCmdType;
	constant clock_period : time := 10 ns;
	BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LinkTrainingStateMachine PORT MAP (
          Clock => Clock,
          PowerOnReset => PowerOnReset,
          LinkPhyReset => LinkPhyReset,
          LinkPhyRecover => LinkPhyRecover,
          RecvdTS1 => RecvdTS1,
          RecvdTS2 => RecvdTS2,
          RecvdIdle => RecvdIdle,
          RxTrained => RxTrained,
          RxMajorError => RxMajorError,
          LaneOrderError => LaneOrderError,
          HeartbeatError => HeartbeatError,
          RxCmd => RxCmd,
          TxCmd => TxCmd
        );
 
 
   Clock_process :process
   begin
		Clock <= '0';
		wait for Clock_period/2;
		Clock <= '1';
		wait for Clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		PowerOnReset <= '1';
		wait for 100 ns;
		PowerOnReset <= '0';
		wait for 100 ns;
		wait for 20 us;
		
		RecvdTS1 <= true;
		wait for clock_period;
		RecvdTS1 <= false;
		wait for 1 ms;
            wait for 100 ns;
		
		RxTrained <= true;
		wait for clock_period;
		RxTrained <= false;
		wait for 10 us;
		
		RecvdTS2 <= true;
		wait for clock_period;
		RecvdTS2 <= false;
		wait for 10 us;
		
		RecvdIdle <= true;
		wait for clock_period;
		RecvdIdle <= false;
      wait;
   end process;

END;
