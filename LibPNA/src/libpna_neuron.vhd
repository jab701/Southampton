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

entity libpna_neuron is
   generic(
      BASE_ADDRESS    : natural := 0;
      SYN_RESOLUTION  : natural := 16;
      TIME_RESOLUTION : natural := 32);
   port (
      signal clk    : in std_logic;
      signal cke    : in std_logic;
      signal rstn   : in std_logic;
      -- Threshold Block Signals
      signal thresholde  : in std_logic_vector((SYN_RESOLUTION - 1) downto 0);
      signal thresholdi  : in std_logic_vector((SYN_RESOLUTION - 1) downto 0);
      signal synweights  : in std_logic_vector((SYN_RESOLUTION - 1) downto 0);
      -- Burst Block Signals
      signal burstlength : in std_logic_vector(7 downto 0);
      signal aptime      : in std_logic_vector((TIME_RESOLUTION - 1) downto 0);
      signal reftime     : in std_logic_vector((TIME_RESOLUTION - 1) downto 0);
      -- Axon Action Potential Signal
      signal axon        : out std_logic);
end libpna_neuron;

architecture rtl of libpna_neuron is

-- COMPONENT DEFINITIONS
   -- libpna_threshold
   component libpna_threshold is
      generic(RESOLUTION : natural := 16);
      port(signal thresholde : in std_logic_vector((RESOLUTION - 1) downto 0);
           signal thresholdi : in std_logic_vector((RESOLUTION - 1) downto 0);
      -- Module Specific Input Signals
           signal synweights : in std_logic_vector((RESOLUTION - 1) downto 0);
      -- Module Specific Output Signals
           signal abvthlde : out std_logic;
           signal belthldi : out std_logic);
   end component libpna_threshold;

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
-- Threshold Block Output
   signal abvthlde : std_logic;
   signal belthldi : std_logic;

begin

i_threshold: entity libpna_threshold
   generic map(RESOLUTION => SYN_RESOLUTION)
   port map (thresholde => thresholde,
             thresholdi => thresholdi,
             synweights => synweights,
             abvthlde   => abvthlde,
             belthldi   => belthldi);

i_burst: entity libpna_burstblock
   generic map(RESOLUTION => TIME_RESOLUTION)
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

