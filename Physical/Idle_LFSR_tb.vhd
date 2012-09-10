------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) 2008 Tim Prince                                         --
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
-- Engineer: Tim Prince                                                     --
--                                                                          --
-- Create Date:    10:47:39 01/30/2009                                      --
-- Module Name:    InfiniBand_Idle_LFSR_tb                                  --
-- Description:                                                             --
--     Basic test bench for the InfiniBand_Idle_LFSR module.                --
--                                                                          --
-- Dependencies:                                                            --
--     None, apart from standard libraries.                                 --
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY InfiniBand_Idle_LFSR_tb IS
END InfiniBand_Idle_LFSR_tb;
 
ARCHITECTURE behavior OF InfiniBand_Idle_LFSR_tb IS 
    constant ORDER : natural := 11;
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT InfiniBand_Idle_LFSR
	 Generic ( order : natural := 11 );
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         OUTPUT : OUT  std_logic_vector(ORDER - 1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal OUTPUT : std_logic_vector(ORDER - 1 downto 0);
   constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: InfiniBand_Idle_LFSR PORT MAP (
          CLK => CLK,
          RESET => RESET,
          OUTPUT => OUTPUT
        );
 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		RESET <= '1';
      wait for 100 ns;	
		RESET <= '0';
      wait for clk_period*17;

      -- insert stimulus here 

      wait;
   end process;

END;
