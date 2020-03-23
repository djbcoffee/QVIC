---------------------------------------------------------------------------------
-- Copyright (C) 2018 Donald J. Bartley <djbcoffee@gmail.com>
--
-- This source file may be used and distributed without restriction provided that
-- this copyright statement is not removed from the file and that any derivative
-- work contains the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software Foundation; either version 2 of the License, or (at your option) any
-- later version.
--
-- This source file is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
-- details.
--
-- You should have received a copy of the GNU General Public License along with
-- this source file.  If not, see <http://www.gnu.org/licenses/> or write to the
-- Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
-- 02110-1301, USA.
---------------------------------------------------------------------------------
-- File: CycleCounter.vhd
--
-- Description:
-- Generates the cycle signals used to syncronize operations in the QVIC-16C.
-- There are four cycles.  This counter increments with every rising edge of the
-- main clock.  It counts from 0 to 3 inclusive and then resets back to zero.
-- Each cycle lasts 19.861nS with a 50.35MHz clock.  Four cycles complete a pixel
-- time of 79.444nS.
--
-- Cycles:
--	0 - If a host read was being done then latch data read from SRAM into the low
--     byte of the working register.  Put the name table row and column on the
--     SRAM address lines to read the character number being displayed at that
--     position.
-- 1 - Latch the character number from SRAM.  Concatonate the current pixel row
--     being drawn for the character on SRAM address lines to read the the proper
--     byte for the character from the pattern table.
-- 2 - Evaluate the current pixel being drawn from the pattern table received
--     from the SRAM and put the proper color table index on the SRAM address
--     lines to read which color to draw the pixel.
--	3 - Latch color read from SRAM into the pixel color register.  Change the
--     horizontal and vertical counter registers.  Put the host address from the
--     working register on the SRAM address lines.  If a write is being done
--     output the write enable pin and change the SRAM data pins to output.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CycleCounter is
	port
	(
		Clock : in std_logic;
		Cycle0, Cycle3 : out std_logic;
		CycleCounterContent : out std_logic_vector(1 downto 0)
	);
end entity CycleCounter;

architecture Behavioral of CycleCounter is
begin
	counter : process (Clock) is
		variable cycleCounterRegister : std_logic_vector(1 downto 0) := (others => '0');
	begin
		-- On every rising edge of the system clock increment the counter mod 4 (0
		-- to 3).
		if Clock'event and Clock = '1' then
			cycleCounterRegister := std_logic_vector((unsigned(cycleCounterRegister) + 1) mod 4);
		end if;
		
		-- Create cycle signals used by other modules on the chip.
		Cycle0 <= not cycleCounterRegister(0) and not cycleCounterRegister(1);
		Cycle3 <= cycleCounterRegister(0) and cycleCounterRegister(1);
		
		-- Output the content of the cycle counter register to be used by other
		-- modules on the chip.
		CycleCounterContent <= cycleCounterRegister;
	end process counter;
end architecture Behavioral;
