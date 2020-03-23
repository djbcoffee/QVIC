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
-- File: SramAddressRegister.vhd
--
-- Description:
-- Holds the current address for writting/reading data to/from the SRAM.  There
-- are four cycles as described in the CycleCounter.vhd module and each has a
-- unique address:
--	0 - Put the name table address on address lines to read the character number.
--     The address is composed of data from the horizontal and vertical counters:
--     001Y(8)Y(7)Y(6)Y(5)Y(4)X(8)X(7)X(6)X(5)X(4)X(3)
-- 1 - Put the character number read (C(7) through C(0) inclusive) and
--     concatonate with the current pixel row being drawn:
--     000C(7)C(6)C(5)C(4)C(3)C(2)C(1)C(0)Y(3)Y(2)Y(1)
-- 2 - Evaluate the current pixel being drawn from the pattern table (C(0)) and
--     put with the proper color table row and column:
--     01C(0)Y(8)Y(7)Y(6)Y(5)Y(4)X(8)X(7)X(6)X(5)X(4)X(3)
-- 3 - Put host address on address lines for host read/writes to/from the SRAM.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.universal.all;

entity SramAddressRegister is
	port
	(
		Clock : in std_logic;
		HorizontalCount : in std_logic_vector(8 downto 0);
		VerticalCount : in std_logic_vector(8 downto 1); --Bits 0 and 9 of Vertical Count Register are not used.
		SramDataBus : in std_logic_vector(7 downto 0);
		WorkingRegisterContent : in std_logic_vector(13 downto 0);
		CycleCounterContent : in std_logic_vector(1 downto 0);
		SramAddress : out std_logic_vector(13 downto 0)
	);
end entity SramAddressRegister;

architecture Behavioral of SramAddressRegister is
begin
	SramAddressOperation : process (Clock) is
		variable addressRegister : std_logic_vector(13 downto 0) := (others => '0');
	begin
		if Clock'event and Clock = '1' then
			case CycleCounterContent is
				when CYCLE0 =>
					-- Name table address:
					-- 001Y(8)Y(7)Y(6)Y(5)Y(4)X(8)X(7)X(6)X(5)X(4)X(3)
					addressRegister(13 downto 11) := NAME_TABLE_ADDRESS_PREFIX;
					addressRegister(10 downto 6) := VerticalCount(8 downto 4);
					addressRegister(5 downto 0) := HorizontalCount(8 downto 3);
				when CYCLE1 =>
					-- Pattern table address:
					-- 000C(7)C(6)C(5)C(4)C(3)C(2)C(1)C(0)Y(3)Y(2)Y(1)
					addressRegister(13 downto 11) := PATTERN_TABLE_ADDRESS_PREFIX;
					addressRegister(10 downto 3) := SramDataBus;
					addressRegister(2 downto 0) := VerticalCount(3 downto 1);
				when CYCLE2 =>
					-- Color tables address (note that only bit 11 of the address
					-- changes):
					-- 010Y(8)Y(7)Y(6)Y(5)Y(4)X(8)X(7)X(6)X(5)X(4)X(3) for color 0
					-- table
					-- or
					-- 011Y(8)Y(7)Y(6)Y(5)Y(4)X(8)X(7)X(6)X(5)X(4)X(3) for color 1
					-- table
					if (HorizontalCount(2 downto 0) = "000" and SramDataBus(7) = '1') or (HorizontalCount(2 downto 0) = "001" and SramDataBus(6) = '1') or (HorizontalCount(2 downto 0) = "010" and SramDataBus(5) = '1') or (HorizontalCount(2 downto 0) = "011" and SramDataBus(4) = '1') or (HorizontalCount(2 downto 0) = "100" and SramDataBus(3) = '1') or (HorizontalCount(2 downto 0) = "101" and SramDataBus(2) = '1') or (HorizontalCount(2 downto 0) = "110" and SramDataBus(1) = '1') or (HorizontalCount(2 downto 0) = "111" and SramDataBus(0) = '1') then
						addressRegister(13 downto 11) := COLOR_1_TABLE_ADDRESS_PREFIX;
					else
						addressRegister(13 downto 11) := COLOR_0_TABLE_ADDRESS_PREFIX;
					end if;
					addressRegister(10 downto 6) := VerticalCount(8 downto 4);
					addressRegister(5 downto 0) := HorizontalCount(8 downto 3);
				when others =>
					--Host read/write address.
					addressRegister(13 downto 0) := WorkingRegisterContent;
			end case;
		end if;
		
		-- Put the SRAM address onto the SRAM address pins.
		SramAddress <= addressRegister;
	end process SramAddressOperation;
end architecture Behavioral;
