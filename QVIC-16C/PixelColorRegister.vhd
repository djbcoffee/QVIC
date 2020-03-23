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
-- File: PixelColorRegister.vhd
--
-- Description:
-- Holds the color that was read from the SRAM for the length of one pixel time.
-- This data is output as 8-bit truecolor (3 for red, 3 for green, and 2 for
-- blue <https://en.wikipedia.org/wiki/8-bit_color>).  This register is loaded at
-- cycle 3.  The horizontal and vertical counter register values are also fed
-- into this module to keep all the color outputs held low during the blanking
-- time of the screen.  Any horizontal value of 320 and above constitutes the
-- blanking area for the remainder of the line.  Any vertical value of 480 and
-- above constitutes the blanking area for the remainder of the frame.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PixelColorRegister is
	port
	(
		Clock, Cycle3 : in std_logic;
		HorizontalCount : in std_logic_vector(8 downto 0);
		VerticalCount : in std_logic_vector(9 downto 0);
		SramDataBus : in std_logic_vector(7 downto 0);
		PixelColor : out std_logic_vector(7 downto 0)
	);
end entity PixelColorRegister;

architecture Behavioral of PixelColorRegister is
begin
	LoadPixelColor : process (Clock) is
		variable colorRegister : std_logic_vector(7 downto 0) := (others => '0');
	begin
		-- On every rising edge of the system clock, at cycle 3, do pixel color
		-- work.
		if Clock'event and Clock = '1' then
			if Cycle3 = '1' then
				-- If this is a pixel on the screen then output the current pixel
				-- color.  Otherwise, output all zeros (black).
				if unsigned(HorizontalCount) < 320 and unsigned(VerticalCount) < 480 then
					colorRegister := SramDataBus;
				else
					colorRegister := (others => '0');
				end if;
			else
				colorRegister := colorRegister;
			end if;
		end if;
		
		-- Move the data in the register unto pixel color pins.
		PixelColor <= colorRegister;
	end process LoadPixelColor;
end architecture Behavioral;
