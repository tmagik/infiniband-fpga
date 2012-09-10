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
use ieee.numeric_std.all;

entity FIFO is
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
			empty		: inout STD_LOGIC
			
			--For debugging purposes, points to the next bufer entry to read
			--read_ptr	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);
			
			--For debugging purposes, points to the next bufer entry to write
			--write_ptr	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0)
			
		 );
end FIFO;

architecture a of FIFO is

	--Back-end memory module to store buffer contents
	component FIFODualPortMemory
	generic (	ADD_WIDTH: integer := 8;
				WORD_WIDTH : integer := 8);
	  port (
		clk      : in  std_logic;                                -- write clock
		reset    : in  std_logic;                                -- System Reset
		W_add    : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Write Address
		R_add    : in  std_logic_vector(ADD_WIDTH -1 downto 0);  -- Read Address
		Data_In  : in  std_logic_vector(WORD_WIDTH - 1  downto 0);    -- input data
		Data_Out : out std_logic_vector(WORD_WIDTH -1   downto 0);    -- output Data
		WR       : in  std_logic;                                -- Write Enable
		RE       : in  std_logic);     
	end component;
	
	--Buffer control logic, tells the memory module what to do
	component FIFOControl
	generic (	ADD_WIDTH : integer := 8;
				WORD_WIDTH : integer := 8);
	port (	clock, wreq, rreq, reset	: in STD_LOGIC;
			rdaddress	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);
			wraddress	: out STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);
			full, empty	: inout STD_LOGIC
		 );
	end component;

	--Connections between the memory and control modules
	signal wren, ren, rdclock, wrclock, full_sig, empty_sig : STD_LOGIC;
	signal rdaddress, wraddress : STD_LOGIC_VECTOR(ADD_WIDTH - 1 DOWNTO 0);


begin

	--Only write data if the buffer's not full
	wren <= wreq AND (NOT full_sig);
	
	--Only read data if the buffer's not empty
	ren <= rreq AND (NOT empty_sig);

	myRAM : FIFODualPortMemory
			GENERIC MAP ( ADD_WIDTH, WORD_WIDTH )
			PORT MAP	(clock, reset, wraddress, rdaddress, data_in, data_out, wren, ren);
	
	myCon : FIFOControl
			GENERIC MAP ( ADD_WIDTH, WORD_WIDTH )
			PORT MAP	(clock, wreq, rreq, reset, rdaddress, wraddress, full_sig, empty_sig);
			
	--For debugging purposes:
	--these pointers are to help see what's going on internally
	--read_ptr <= rdaddress;
	--write_ptr <= wraddress;
	
	--Can't write anything if full
	full <= full_sig;
	
	--Can't write anything if empty
	empty <= empty_sig;

end architecture;
