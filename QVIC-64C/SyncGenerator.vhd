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
-- File: SyncGenerator.vhd
--
-- Description:
-- Generates the horizontal and vertical sync signals for the VGA monitor.  The
-- sync signals are negative so they are usually keep at logic high.  For the
-- horizontal sync the signal goes logic low from 331 to 377 inclusive for a
-- total of 47 pixel times.  For the verical sync the signal goes logic low from
-- 492 to 493 inclusive for a total of two horizontal lines and this sync signal
-- only changes when the horizontal count register is at the end of the
-- horizontal line (399).  Each sync register is clocked at cycle 3.
---------------------------------------------------------------------------------
-- DJB 12/31/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SyncGenerator is
	port
	(
		Clock, Cycle3 : in std_logic;
		HorizontalCount : in std_logic_vector(8 downto 0);
		VerticalCount : in std_logic_vector(9 downto 0);
		HSync, VSync : out std_logic
	);
end SyncGenerator;

architecture Behavioral of SyncGenerator is
begin
	SyncGeneration : process (Clock) is
		variable horizontalSyncRegister : std_logic := '1';
		variable verticalSyncRegister : std_logic := '1';
	begin
		-- On every rising edge of the system clock, during cycle 3, do sync work.
		if Clock'event and Clock = '1' then
			if Cycle3 = '1' then
				-- First do horizontal sync.  If the horizontal count register is 331
				-- to 377 inclusive then generate a horizontal sync pulse by bringing
				-- the state of the horizontal sync signal to a logic low.  Otherwise
				-- leave it logic high.
				if unsigned(HorizontalCount) > 330 and unsigned(HorizontalCount) < 378 then
					horizontalSyncRegister := '0';
				else
					horizontalSyncRegister := '1';
				end if;

				-- Now do vertical sync only if the horizontal count register is at
				-- the end of the horizontal line (399).
				if unsigned(HorizontalCount) = 399 then
					-- If the vertical count register is 492 to 493 inclusive then
					-- generate a vertical sync pulse by bringing the state of the
					-- vertical sync signal to a logic low.  Otherwise leave it logic
					-- high.
					if unsigned(VerticalCount) >= 492 and unsigned(VerticalCount) < 494 then
						verticalSyncRegister := '0';
					else
						verticalSyncRegister := '1';
					end if;
				else
					verticalSyncRegister := verticalSyncRegister;
				end if;
			else
				horizontalSyncRegister := horizontalSyncRegister;
				verticalSyncRegister := verticalSyncRegister;
			end if;
		end if;

		-- Create sync outputs that will drive the sync pins.
		HSync <= horizontalSyncRegister;
		VSync <= verticalSyncRegister;
	end process SyncGeneration;
end architecture Behavioral;
