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
-- File: HorizontalCountRegister.vhd
--
-- Description:
-- Keeps track of the horizontal pixel count.  The screen resolution of the chip
-- is 320 x 240 (QVGA).  This counter counts from 0 to 399 inclusive and then
-- resets back to zero.  This register only counts at cycle 3.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HorizontalCountRegister is
	port
	(
		Clock, Cycle3 : in std_logic;
		HorizontalCount : out std_logic_vector(8 downto 0)
	);
end entity HorizontalCountRegister;

architecture Behavioral of HorizontalCountRegister is
begin
	counter : process (Clock) is
		variable horizontalCounter : std_logic_vector(8 downto 0) := (others => '0');
	begin
		-- On every rising edge of the system clock, at cycle 3, increment the
		-- counter mod 400 (0 to 399).
		if Clock'event and Clock = '1' then
			if Cycle3 = '1' then
				horizontalCounter := std_logic_vector((unsigned(horizontalCounter) + 1) mod 400);
			else
				horizontalCounter := horizontalCounter;
			end if;
		end if;

		-- Create an output of the current state of the horizontal count register
		-- for other modules on the chip to use.
		HorizontalCount <= horizontalCounter;
	end process counter;
end architecture Behavioral;
