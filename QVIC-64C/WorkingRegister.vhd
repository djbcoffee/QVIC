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
-- File: WorkingRegister.vhd
--
-- Description:
-- A working register that either holds an address on which to perform a read or
-- write from SRAM, or holds a data byte read from the SRAM.  The lower 8-bits of
-- the working register are tied to tri-state output drivers that will drive the
-- value of the register onto the 8-bit host data bus when a read is requested.
---------------------------------------------------------------------------------
-- DJB 12/31/18 Created.
---------------------------------------------------------------------------------

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use work.universal.all;

entity WorkingRegister is
	port
	(
		Clock, HostSyncPulse, CS, nCS, RnW : in std_logic;
		HostSramOpRegisterContents : in std_logic_vector(1 downto 0);
		HostAddress : in std_logic_vector(1 downto 0);
		SramDataBus : in std_logic_vector(7 downto 0);
		WorkingRegisterContent : out std_logic_vector(13 downto 0);
		HostDataBus, HostDataPins : inout std_logic_vector(7 downto 0)
	);
end entity WorkingRegister;

architecture Behavioral of WorkingRegister is
	signal HostDataOutEnable : std_logic;
	signal HostDataOut : std_logic_vector(7 downto 0);
begin
	-- Uses primitives for the output and input buffers that are specific to the
	-- XC9500XL series CPLD.  The output buffer uses the active low enable.
	HostDataOutBufferBit0 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(0), I => HostDataOut(0), T => HostDataOutEnable);
	HostDataOutBufferBit1 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(1), I => HostDataOut(1), T => HostDataOutEnable);
	HostDataOutBufferBit2 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(2), I => HostDataOut(2), T => HostDataOutEnable);
	HostDataOutBufferBit3 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(3), I => HostDataOut(3), T => HostDataOutEnable);
	HostDataOutBufferBit4 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(4), I => HostDataOut(4), T => HostDataOutEnable);
	HostDataOutBufferBit5 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(5), I => HostDataOut(5), T => HostDataOutEnable);
	HostDataOutBufferBit6 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(6), I => HostDataOut(6), T => HostDataOutEnable);
	HostDataOutBufferBit7 : OBUFT
		generic map (SLEW => "FAST")
		port map (O => HostDataPins(7), I => HostDataOut(7), T => HostDataOutEnable);
		
	DataBusInBufferBit0 : IBUF
		port map (O => HostDataBus(0), I => HostDataPins(0));
	DataBusInBufferBit1 : IBUF
		port map (O => HostDataBus(1), I => HostDataPins(1));
	DataBusInBufferBit2 : IBUF
		port map (O => HostDataBus(2), I => HostDataPins(2));
	DataBusInBufferBit3 : IBUF
		port map (O => HostDataBus(3), I => HostDataPins(3));
	DataBusInBufferBit4 : IBUF
		port map (O => HostDataBus(4), I => HostDataPins(4));
	DataBusInBufferBit5 : IBUF
		port map (O => HostDataBus(5), I => HostDataPins(5));
	DataBusInBufferBit6 : IBUF
		port map (O => HostDataBus(6), I => HostDataPins(6));
	DataBusInBufferBit7 : IBUF
		port map (O => HostDataBus(7), I => HostDataPins(7));

	WorkingReg : process (Clock, CS, nCS, RnW, HostAddress) is
		variable workingRegister : std_logic_vector(13 downto 0) := (others => '0');
	begin
		-- Check on every rising edge of the system clock.
		if Clock'event and Clock = '1' then
			-- The working register is only writable during an idle or read data
			-- ready state of the host SRAM operation register in module
			-- HostSramOpRegister.vhd.  In either state the least significant bit of
			-- the state register is set to logic one.
			if HostSramOpRegisterContents(0) = '1' then
				-- Do lower 8-bits first.
				if HostSramOpRegisterContents(1) = '0' then
					-- The SRAM is being read from a host command and has been
					-- completed so we can store the data on the SRAM data bus in the
					-- lower 8-bits of the working register.  The state
					-- HOST_SRAM_READ_DATA_READY has a a value of "01" and we already
					-- know the least significant bit is set to logic one so we only
					-- needed to check the most significant bit of the state.
					workingRegister(7 downto 0) := SramDataBus;	
				elsif HostSyncPulse = '1' and HostAddress = WORKING_REG_LOW_BYTE_ADDRESS then
					-- We have a host writing pulse and it is the host address that
					-- writes to the working register lower 8-bits so do the write.
					workingRegister(7 downto 0) := HostDataBus;
				else
					workingRegister(7 downto 0) := workingRegister(7 downto 0);
				end if;
			
				-- Do upper 6-bits.
				if HostSyncPulse = '1' and HostAddress = WORKING_REG_HIGH_BYTE_ADDRESS then
					-- We have a host writing pulse and it is the host address that
					-- writes to the working register upper 6-bits so do the write.
					workingRegister(13 downto 8) := HostDataBus(5 downto 0);
				else
					workingRegister(13 downto 8) := workingRegister(13 downto 8);
				end if;
			end if;
		end if;
		
		-- If the chip is selected for a read operation then turn on the output
		-- drivers.
		if CS = '1' and nCS = '0' and RnW = '1' and HostAddress = WORKING_REG_LOW_BYTE_ADDRESS then
			HostDataOutEnable <= '0';
		else
			HostDataOutEnable <= '1';
		end if;
		
		-- Put the data in the least significant 8-bits of the working register
		-- onto the inputs of the output buffer driver.
		HostDataOut <= workingRegister(7 downto 0);

		-- Output the content of the working register for other modules on the chip
		-- to use.
		WorkingRegisterContent <= workingRegister;
	end process WorkingReg;
end architecture Behavioral;
