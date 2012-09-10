------------------------------------------------------------------------------
--                                                                          --
--    Copyright (C) 2008 InfiniBand FPGA Project                            --
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
-----------------------------------------------------------------------
-- File:  PCK_CRC16_D8.vhd                              
-- Date:  Thu Feb 14 03:47:59 2008                                                      
--                                                                     
-- Copyright (C) 1999-2003 Easics NV.                 
-- This source file may be used and distributed without restriction    
-- provided that this copyright statement is not removed from the file 
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose: VHDL package containing a synthesizable CRC function
--   * polynomial: (0 1 3 12 16)
--   * data width: 8
--                                                                     
-- Info: tools@easics.be
--       http://www.easics.com                                  
--		 http://www.easics.com/webtools/crctool
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package PCK_CRC16_D8 is

  -- polynomial: (0 1 3 12 16)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC16_D8
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(15 downto 0) )
    return std_logic_vector;

end PCK_CRC16_D8;

library IEEE;
use IEEE.std_logic_1164.all;

package body PCK_CRC16_D8 is

  -- polynomial: (0 1 3 12 16)
  -- data width: 8
  -- convention: the first serial data bit is D(7)
  function nextCRC16_D8  
    ( Data:  std_logic_vector(7 downto 0);
      CRC:   std_logic_vector(15 downto 0) )
    return std_logic_vector is

    variable D: std_logic_vector(7 downto 0);
    variable C: std_logic_vector(15 downto 0);
    variable NewCRC: std_logic_vector(15 downto 0);

  begin

    D := Data;
    C := CRC;

    NewCRC(0) := D(4) xor D(0) xor C(8) xor C(12);
    NewCRC(1) := D(5) xor D(4) xor D(1) xor D(0) xor C(8) xor C(9) xor 
                 C(12) xor C(13);
    NewCRC(2) := D(6) xor D(5) xor D(2) xor D(1) xor C(9) xor C(10) xor 
                 C(13) xor C(14);
    NewCRC(3) := D(7) xor D(6) xor D(4) xor D(3) xor D(2) xor D(0) xor 
                 C(8) xor C(10) xor C(11) xor C(12) xor C(14) xor C(15);
    NewCRC(4) := D(7) xor D(5) xor D(4) xor D(3) xor D(1) xor C(9) xor 
                 C(11) xor C(12) xor C(13) xor C(15);
    NewCRC(5) := D(6) xor D(5) xor D(4) xor D(2) xor C(10) xor C(12) xor 
                 C(13) xor C(14);
    NewCRC(6) := D(7) xor D(6) xor D(5) xor D(3) xor C(11) xor C(13) xor 
                 C(14) xor C(15);
    NewCRC(7) := D(7) xor D(6) xor D(4) xor C(12) xor C(14) xor C(15);
    NewCRC(8) := D(7) xor D(5) xor C(0) xor C(13) xor C(15);
    NewCRC(9) := D(6) xor C(1) xor C(14);
    NewCRC(10) := D(7) xor C(2) xor C(15);
    NewCRC(11) := C(3);
    NewCRC(12) := D(4) xor D(0) xor C(4) xor C(8) xor C(12);
    NewCRC(13) := D(5) xor D(1) xor C(5) xor C(9) xor C(13);
    NewCRC(14) := D(6) xor D(2) xor C(6) xor C(10) xor C(14);
    NewCRC(15) := D(7) xor D(3) xor C(7) xor C(11) xor C(15);

    return NewCRC;

  end nextCRC16_D8;

end PCK_CRC16_D8;

