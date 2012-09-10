------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) InfiniBand FPGA Project                                 --
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
-------------------------------------------------------------------------------
-- 
-- Copyright Jamil Khatib 1999
-- 
--
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIP Organization and any
-- coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html
--
--
-- Creator : Jamil Khatib
-- Date 10/10/99
--
-- version 0.19991226
--
-- This file was tested on the ModelSim 5.2EE
-- The test vecors for model sim is included in vectors.do file
-- This VHDL design file is proved through simulation but not verified on Silicon
--
-- http://www.geocities.com/SiliconValley/Pines/6639/ip/fifo_vhdl.html
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;



-- Dual port Memory core



ENTITY FIFODualPortMemory IS

	generic ( 
		
			--The length in bits of each buffer entry
			WORD_WIDTH	: natural := 8;
			
			--The number of address bits needed
			--2 ^ ADD_WIDTH = The # of entries in the buffer
			ADD_WIDTH	: natural := 3
			
			);
			
	port (
    
			--The system clock
			clk      : IN STD_LOGIC;
			
			--Asynchronous system reset, clears memory contents
			reset    : IN STD_LOGIC;
			
			--The memory address to write to
			W_add    : IN  STD_LOGIC_VECTOR(ADD_WIDTH -1 downto 0);
			
			--The memory address to write to
			R_add    : IN  STD_LOGIC_VECTOR(ADD_WIDTH -1 downto 0);
			
			--The incoming data to write to memory
			Data_In  : IN  STD_LOGIC_VECTOR(WORD_WIDTH - 1 downto 0);
			
			--The data read from memory
			Data_Out : OUT STD_LOGIC_VECTOR(WORD_WIDTH -1 downto 0);
			
			--Write enable
			WR       : IN STD_LOGIC;
			
			--Read enable
			RE       : IN STD_LOGIC
			
			);
end FIFODualPortMemory;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

ARCHITECTURE a OF FIFODualPortMemory IS


	--Create an array of integers for the memory
  type data_array is array (integer range <>) of std_logic_vector(WORD_WIDTH -1  downto 0);

  signal data : data_array(0 to (2** add_width) );  -- Local data


	--Clear memory contents when reset is asserted
  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;


begin  -- dpmem_v3

  process (clk, reset)

  begin  -- PROCESS


    -- activities triggered by asynchronous reset (active low)
    if reset = '0' then
      data_out <= (others => '1');
      init_mem ( data);

      -- activities triggered by rising edge of clock
    elsif clk'event and clk = '1' then
      if RE = '1' then
        data_out <= data(conv_integer(R_add));
      end if;

      if WR = '1' then
        data(conv_integer(W_add)) <= Data_In;
      end if;
    end if;

  end process;

end a;

