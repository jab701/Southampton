----------------------------------------------------------------------------------
-- Company:    ESD Group, School of Electronics, University Of Southampton
-- Engineer:   Julian A Bailey - PhD Research Student
--
-- Create Date:    14:14:51 01/17/2007
-- Design Name:
-- Module Name:    Neuron - Behavioral
-- Project Name:   MBED VHDL
-- Target Devices:
-- Tool versions:  ModelSim SE 6.2E
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity libpna_patterngen is
   generic(-- Oscillator Generics
      OSCTIME_RESOLUTION : natural := 32;
      -- Burst Block Generics
      BURSTTIME_RESOLUTION : natural := 32);
   port (
      signal clk    : in std_logic;
      signal cke    : in std_logic;
      signal rstn   : in std_logic;
      -- Oscillator Block Signals
      signal phaseoffseten : in std_logic;
      signal period        : in std_logic_vector((OSCTIME_RESOLUTION - 1) downto 0);
      signal phase         : in std_logic_vector((OSCTIME_RESOLUTION - 1) downto 0);
      -- Burst Block Signals
      signal burstlength : in std_logic_vector(7 downto 0);
      signal aptime      : in std_logic_vector((BURSTTIME_RESOLUTION - 1) downto 0);
      signal reftime     : in std_logic_vector((BURSTTIME_RESOLUTION - 1) downto 0);
      -- Axon Action Potential Signal
      signal axon        : out std_logic);
end libpna_patterngen;

architecture rtl of libpna_patterngen is

-- COMPONENT DEFINITIONS
   component libpna_oscillator is
      generic (RESOLUTION : natural := 32);
      port (-- Global Input Signals
            signal clk           : in std_logic;
            signal cke           : in std_logic;
            signal rstn          : in std_logic;
            signal phaseoffseten : in std_logic;
            -- Module Specific Parameters
            signal period        : in std_logic_vector((RESOLUTION - 1) downto 0);
            signal phase         : in std_logic_vector((RESOLUTION - 1) downto 0);
            -- Module Specific Output Signals
            signal oscout        : out std_logic);
   end component libpna_oscillator;

   -- libpna_burstblock
   component libpna_burstblock
       generic(RESOLUTION       : natural := 32);
       port (signal clk         : in  std_logic;
             signal cke         : in  std_logic;
             signal rstn        : in  std_logic;
             signal abvthlde    : in  std_logic;
             signal belthldi    : in  std_logic;
             signal oscin       : in  std_logic;
             signal burstlength : in  std_logic_vector(7 downto 0);
             signal aptime      : in  std_logic_vector((RESOLUTION - 1) downto 0);
             signal reftime     : in  std_logic_vector((RESOLUTION - 1) downto 0);
             signal axon        : out std_logic);
   end component libpna_burstblock;

-- SIGNAL DEFINITIONS
-- Oscillator Block Output
signal osc_output : std_logic;
begin

i_osc: entity libpna_oscillator(rtl)
   generic map(RESOLUTION => OSCTIME_RESOLUTION)
   port map(-- Global Input Signals
            clk           => clk,
            cke           => cke,
            rstn          => rstn,
            phaseoffseten => phaseoffseten,
            -- Module Specific Parameters
            period        => period,
            phase         => phase,
            -- Module Specific Output Signals
            oscout        => osc_output);

i_burst: entity libpna_burstblock
   generic map(RESOLUTION => BURSTTIME_RESOLUTION)
   port map (clk         => clk,
             cke         => cke,
             rstn        => rstn,
             abvthlde    => abvthlde,
             belthldi    => belthldi,
             oscin       => '0',
             burstlength => burstlength,
             aptime      => aptime,
             reftime     => reftime,
             axon        => axon);

end architecture rtl;
