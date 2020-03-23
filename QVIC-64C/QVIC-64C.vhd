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
-- File: QVIC-64C.vhd
--
-- Description:
-- The internal structure of the QVIC-64C in a Xilinx XC9572XL-5VQG64 CPLD.
--
-- Calculated chip timings:
--				-10		-7			-5
-- Tcoi		 1.0nS	 0.5nS	 0.4nS
-- Tout		 3.0nS	 2.5nS	 2.0nS
-- SRAM		10.0nS	10.0nS	10.0nS
-- Tin		 3.5nS	 2.3nS	 1.5nS
-- Tlogi		 1.8nS	 1.4nS	 1.0nS
-- Tsui		 3.0nS	 2.6nS	 2.3nS
--				------	------	------
-- Totals	22.3nS	19.3nS	17.2nS
--
-- The cycle time is 19.861nS with a 50.35MHz clock.  This would indicate that a
-- -7 chip could handle the timing.  But this only holds true if only the
-- standard 5 product terms are used for any macro cell which receives data from
-- the SRAM.  If extra product terms are needed, and imported from other
-- macrocells, an incremental product term delay will be added.  Because of this
-- the -5 chip was choosen.
--
-- Measured video times from simulation (spec time):
-- Horizontal Front Porch = 0.87384uS (0.94uS) -0.06616uS -7.04%
-- Horizontal Sync = 3.73368uS (3.77uS) -0.03632uS -0.96%
-- Horizontal Back Porch = 1.74768uS (1.89uS) -0.14232uS -7.53%
-- Horizontal Video = 25.4208uS (25.17uS) 0.2508uS 1%
-- Horizontal Line = 31.776uS (31.77uS) 0.006uS 0.02%
-- Vertical Front Porch = 0.41936376mS (0.35mS) 0.06936376mS 19.82%
-- Vertical Sync = 0.063552mS (0.06mS) 0.003552mS 5.92%
-- Vertical Back Porch = 0.95335944mS (1.02mS) -0.06664056mS -6.53%
-- Vertical Video = 15.2461248mS (15.25mS) -0.0038752mS -0.03%
-- Vertical Frame = 16.6824mS (16.68mS) 0.0024mS 0.01%
---------------------------------------------------------------------------------
-- DJB 12/31/18 Created.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity QVIC_64C is
	port
	(
		Clock, CS, nCS, RnW : in std_logic;
		HSync, VSync : out std_logic;
		HostAddress : in std_logic_vector(1 downto 0);
		PixelColor : out std_logic_vector(7 downto 0);
		SramAddress : out std_logic_vector(13 downto 0);
		SramnWE : inout std_logic;
		HostDataPins, SramDataPins : inout std_logic_vector(7 downto 0)
	);
end QVIC_64C;

architecture Struct of QVIC_64C is
	signal Cycle0 : std_logic;
	signal Cycle3 : std_logic;
	signal HostSyncPulse : std_logic;
	signal SramOutEnable : std_logic;
	signal CycleCounterContent : std_logic_vector(1 downto 0);
	signal HorizontalCount : std_logic_vector(8 downto 0);
	signal HostDataBus : std_logic_vector(7 downto 0);
	signal HostSramOpRegisterContents : std_logic_vector(1 downto 0);
	signal SramDataBus : std_logic_vector(7 downto 0);
	signal VerticalCount : std_logic_vector(9 downto 0);
	signal WorkingRegisterContent : std_logic_vector(13 downto 0);
begin
	CycleCounter : entity work.CycleCounter(Behavioral)
		port map (Clock, Cycle0, Cycle3, CycleCounterContent);
	HorizontalCountRegister : entity work.HorizontalCountRegister(Behavioral)
		port map (Clock, Cycle3, HorizontalCount);
	HostSramOpRegister : entity work.HostSramOpRegister(Behavioral)
		port map (Clock, Cycle0, Cycle3, HostSyncPulse, HostAddress, HostSramOpRegisterContents, SramOutEnable, SramnWE);
	HostSync : entity work.HostSync(Behavioral)
		port map (Clock, CS, nCS, RnW, HostSyncPulse);
	PixelColorRegister : entity work.PixelColorRegister(Behavioral)
		port map (Clock, Cycle3, HorizontalCount, VerticalCount, SramDataBus, PixelColor);
	SramAddressRegister : entity work.SramAddressRegister(Behavioral)
		port map (Clock, HorizontalCount, VerticalCount(8 downto 1), SramDataBus, WorkingRegisterContent, CycleCounterContent, SramAddress);
	SramDataRegister : entity work.SramDataRegister(Behavioral)
		port map (Clock, HostSyncPulse, SramOutEnable, HostAddress, HostDataBus, SramDataBus, SramDataPins);
	SyncGenerator : entity work.SyncGenerator(Behavioral)
		port map (Clock, Cycle3, HorizontalCount, VerticalCount, HSync, VSync);
	VerticalCountRegister : entity work.VerticalCountRegister(Behavioral)
		port map (Clock, Cycle3, HorizontalCount, VerticalCount);
	WorkingRegister : entity work.WorkingRegister(Behavioral)
		port map (Clock, HostSyncPulse, CS, nCS, RnW, HostSramOpRegisterContents, HostAddress, SramDataBus, WorkingRegisterContent, HostDataBus, HostDataPins);
end architecture Struct;
