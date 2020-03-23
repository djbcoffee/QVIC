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
-- File: SramDataRegister.vhd
--
-- Description:
-- Holds data from the host to be written to the SRAM and also routes the data
-- read from the SRAM to other modules on the chip.
---------------------------------------------------------------------------------
-- DJB 12/31/18 Created.
---------------------------------------------------------------------------------

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use work.universal.all;

entity SramDataRegister is
	port
	(
		Clock, HostSyncPulse, SramOutEnable : in std_logic;
		HostAddress : in std_logic_vector(1 downto 0);
		HostDataBus : in std_logic_vector(7 downto 0);
		SramDataBus : out std_logic_vector(7 downto 0);
		SramDataPins : inout std_logic_vector(7 downto 0)
	);
end SramDataRegister;

architecture Behavioral of SramDataRegister is
	signal SramWriteDataBus : std_logic_vector(7 downto 0);
begin
	-- Uses primitives for the output and input buffers that are specific to the
	-- XC9500XL series CPLD.  The output buffer uses the active high enable.
	SramDataOutBufferBit0 : OBUFE
		port map (O => SramDataPins(0), I => SramWriteDataBus(0), E => SramOutEnable);
	SramDataOutBufferBit1 : OBUFE
		port map (O => SramDataPins(1), I => SramWriteDataBus(1), E => SramOutEnable);
	SramDataOutBufferBit2 : OBUFE
		port map (O => SramDataPins(2), I => SramWriteDataBus(2), E => SramOutEnable);
	SramDataOutBufferBit3 : OBUFE
		port map (O => SramDataPins(3), I => SramWriteDataBus(3), E => SramOutEnable);
	SramDataOutBufferBit4 : OBUFE
		port map (O => SramDataPins(4), I => SramWriteDataBus(4), E => SramOutEnable);
	SramDataOutBufferBit5 : OBUFE
		port map (O => SramDataPins(5), I => SramWriteDataBus(5), E => SramOutEnable);
	SramDataOutBufferBit6 : OBUFE
		port map (O => SramDataPins(6), I => SramWriteDataBus(6), E => SramOutEnable);
	SramDataOutBufferBit7 : OBUFE
		port map (O => SramDataPins(7), I => SramWriteDataBus(7), E => SramOutEnable);
		
	DataBusInBufferBit0 : IBUF
		port map (O => SramDataBus(0), I => SramDataPins(0));
	DataBusInBufferBit1 : IBUF
		port map (O => SramDataBus(1), I => SramDataPins(1));
	DataBusInBufferBit2 : IBUF
		port map (O => SramDataBus(2), I => SramDataPins(2));
	DataBusInBufferBit3 : IBUF
		port map (O => SramDataBus(3), I => SramDataPins(3));
	DataBusInBufferBit4 : IBUF
		port map (O => SramDataBus(4), I => SramDataPins(4));
	DataBusInBufferBit5 : IBUF
		port map (O => SramDataBus(5), I => SramDataPins(5));
	DataBusInBufferBit6 : IBUF
		port map (O => SramDataBus(6), I => SramDataPins(6));
	DataBusInBufferBit7 : IBUF
		port map (O => SramDataBus(7), I => SramDataPins(7));

	SramDataRegisterOperation : process (Clock) is
		variable sramDataRegister : std_logic_vector(7 downto 0) := (others => '0');
	begin
		-- On every rising edge of the system clock check if we have a host write.
		if Clock'event and Clock = '1' then
			if HostSyncPulse = '1' then
				-- We have a host write pulse.  Check if it is the host address that
				-- writes to the SRAM data register and so write the data.
				if HostAddress = VIDEO_RAM_WRITE_ADDRESS then
					sramDataRegister := HostDataBus;
				else
					sramDataRegister := sramDataRegister;
				end if;
			else
				sramDataRegister := sramDataRegister;
			end if;
		end if;
		
		-- Put the data in the SRAM data registers onto the inputs of the output
		-- buffer driver.
		SramWriteDataBus <= sramDataRegister;
	end process SramDataRegisterOperation;
end Behavioral;
