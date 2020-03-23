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
-- File: HostSramOpRegister.vhd
--
-- Description:
-- State machine that keeps track of any SRAM operations that the host initiated.
-- Also controls the signal that enables the output drivers of the SRAM data
-- pins, the SRAM write enable pin, and directly controls the state of the write
-- enable pin.
---------------------------------------------------------------------------------
-- DJB 12/31/18 Created.
---------------------------------------------------------------------------------

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use work.universal.all;

entity HostSramOpRegister is
	port
	(
		Clock, Cycle0, Cycle3, HostSyncPulse : in std_logic;
		HostAddress : in std_logic_vector(1 downto 0);
		HostSramOpRegisterContents : out std_logic_vector(1 downto 0);
		SramOutEnable, SramnWE : inout std_logic
	);
end entity HostSramOpRegister;

architecture Behavioral of HostSramOpRegister is
	signal SramWriteEnableOutput : std_logic;
begin
	-- Uses primitives for the output buffers that are specific to the XC9500XL
	-- series CPLD.  The output buffer uses the active high enable.
	WriteEnableOutBuffer : OBUFE
		port map (O => SramnWE, I => SramWriteEnableOutput, E => SramOutEnable);

	HostSramOperations : process (Clock, Cycle0) is
		variable hostSramOperationsRegister : std_logic_vector(1 downto 0) := HOST_SRAM_IDLE;
	begin
		-- Check the state machine at the rising edge of each clock.
		if Clock'event and Clock = '1' then
			case hostSramOperationsRegister is
				when HOST_SRAM_WRITTING =>
					-- We are in a state where host data is currently being written to
					-- the SRAM.  If we are at cycle 0 we can return the state back to
					-- idle as the write is complete.
					if Cycle0 = '1' then
						hostSramOperationsRegister := HOST_SRAM_IDLE;
					else
						hostSramOperationsRegister := hostSramOperationsRegister;
					end if;
				when HOST_SRAM_READ_DATA_READY =>
					-- We are in a state where the host is reading data from the SRAM
					-- and the data is current being presented on the SRAM data bus.
					-- If we at cycle 0 we can return the state back to idle as the
					-- read is complete.
					if Cycle0 = '1' then
						hostSramOperationsRegister := HOST_SRAM_IDLE;
					else
						hostSramOperationsRegister := hostSramOperationsRegister;
					end if;
				when HOST_SRAM_READING =>
					-- We are in a state where we are waiting to read host data from
					-- the SRAM.  If we are at cycle 3 then change the state to
					-- indicate the data is ready.
					if Cycle3 = '1' then
						hostSramOperationsRegister := HOST_SRAM_READ_DATA_READY;
					else
						hostSramOperationsRegister := hostSramOperationsRegister;
					end if;
				when others =>
					-- We are in an idle state.  Check if we got a host sync pulse
					-- which means the host is interfacing with the chip and is
					-- writting information.
					if HostSyncPulse = '1' then
						-- The host is writting information.  If this is meant to start
						-- an SRAM operation then set the correct state.
						if HostAddress = VIDEO_RAM_WRITE_ADDRESS then
							hostSramOperationsRegister := HOST_SRAM_WRITTING;
						elsif HostAddress = VIDEO_RAM_READ_ADDRESS then
							hostSramOperationsRegister := HOST_SRAM_READING;
						else
							hostSramOperationsRegister := hostSramOperationsRegister;
						end if;
					else
						hostSramOperationsRegister := hostSramOperationsRegister;
					end if;
			end case;
		end if;
		
		-- The value in the least siginificant register is to drive the SRAM write
		-- enable pin.
		SramWriteEnableOutput <= hostSramOperationsRegister(0);
		
		-- Create a signal that goes high during cycle 0 and both registers are
		-- logic low which indicates a write is in progress.  This signal will
		-- enable the output drivers of the SRAM data pins and the SRAM write
		-- enable pin.
		SramOutEnable <= Cycle0 and not hostSramOperationsRegister(0) and not hostSramOperationsRegister(1);

		-- Output the content of the host SRAM operations register to be used by
		-- other modules on the chip.
		HostSramOpRegisterContents <= hostSramOperationsRegister;
	end process HostSramOperations;
end architecture Behavioral;
