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
-- File: HostSync.vhd
--
-- Description:
-- Takes asynchronous signals from the host interface and generates a signal that
-- is synchronized with the system clock.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity HostSync is
	port
	(
		Clock, CS, nCS, RnW : in std_logic;
		HostSyncPulse : out std_logic
	);
end entity HostSync;

architecture Behavioral of HostSync is
begin
	HostSyncInterface : process (Clock) is
		variable hostSync : std_logic_vector(2 downto 0) := (others => '0');
	begin
		-- Check for activity on every rising edge of the system clock.
		if Clock'event and Clock = '1' then
			-- A three-stage register that is used to synchronize a chip select
			-- and write event.  The first register in the stage connects directly
			-- to the chip select and R/W pins of the host interface.  This register
			-- will take any metastability issues that may occur from the async pins
			-- changing in relation to the system clock.  The second and third
			-- registers are used to detect the rising edges from the output of the
			-- first register.  The second and third registers are protected from
			-- metastability and their outputs can be reliably used as synchronous
			-- signals.  All together the three registers are connected in a shift
			-- configuration.
			hostSync(2) := hostSync(1);
			hostSync(1) := hostSync(0);
			if CS = '1' and nCS = '0' and RnW = '0' then
				hostSync(0) := '1';
			else
				hostSync(0) := '0';
			end if;
		end if;
		
		-- Create the rising edge pulse signal used by other modules on the chip.
		-- Pulse lasts for one system clock cycle and is used by other circuits
		-- included in the host operations.
		HostSyncPulse <= hostSync(1) and not hostSync(2);
	end process HostSyncInterface;
end architecture Behavioral;
