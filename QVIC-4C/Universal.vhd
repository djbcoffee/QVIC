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
-- File: Universal.vhd
--
-- Description:
-- Contains universal information for the project.
---------------------------------------------------------------------------------
-- DJB 11/16/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Universal is
	-- Cycles:
	constant CYCLE0 : std_logic_vector(1 downto 0) := "00";
	constant CYCLE1 : std_logic_vector(1 downto 0) := "01";
	constant CYCLE2 : std_logic_vector(1 downto 0) := "10";

	-- Host Addresses:
	constant WORKING_REG_LOW_BYTE_ADDRESS : std_logic_vector(1 downto 0) := "00";
	constant WORKING_REG_HIGH_BYTE_ADDRESS : std_logic_vector(1 downto 0) := "01";
	constant VIDEO_RAM_WRITE_ADDRESS : std_logic_vector(1 downto 0) := "10";
	constant VIDEO_RAM_READ_ADDRESS : std_logic_vector(1 downto 0) := "11";
	
	-- Host SRAM Operations:
	constant HOST_SRAM_IDLE : std_logic_vector(1 downto 0) := "11";
	constant HOST_SRAM_READING : std_logic_vector(1 downto 0) := "10";
	constant HOST_SRAM_READ_DATA_READY : std_logic_vector(1 downto 0) := "01";
	constant HOST_SRAM_WRITTING : std_logic_vector(1 downto 0) := "00";

	-- SRAM Address Prefixes:
	constant PATTERN_TABLE_ADDRESS_PREFIX : std_logic_vector(1 downto 0) := "00";
	constant NAME_TABLE_ADDRESS_PREFIX : std_logic_vector(2 downto 0) := "010";
	constant COLOR_TABLES_ADDRESS_PREFIX : std_logic := '1';
end package Universal;

package body Universal is

end package body Universal;
