----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
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

library LibNeuron;
USE LibNeuron.ALL;

entity Neuron2 is
    generic(-- Oscillator Generics
            OscResolution : natural := 32;
            -- Burst Block Generics
            BurstLength    : Signed(7 downto 0) := x"05";
            TimeRes   : natural := 32
            );
    port (signal Clock           : in std_logic;
          signal CKE             : in std_logic;
          signal nReset          : in std_logic;
          signal CountPhase      : in std_logic;
          -- Oscillator Block Parameters
          signal Period     : in unsigned((OscResolution - 1) downto 0);
          signal Phase : in unsigned((OscResolution - 1) downto 0);
          -- Burts Block Parameters
          signal APTime     : unsigned((TimeRes - 1) downto 0);
          signal RefTime    : unsigned((TimeRes - 1) downto 0);
          -- Axon Action Potential Signal
          signal Axon           : out std_logic
          ); 
end Neuron2;

architecture Behavioural of Neuron2 is
  
-- Oscillator Block Output
signal Osc : std_logic;

begin
  
Burst1     : entity LibNeuron.BurstBlock(Behavioural)
            generic map(BurstLength,TimeRes) 
            port map (Clock, CKE, nReset, '0', '0', Osc, APTime , RefTime, Axon);
Osc1       : entity LibNeuron.Oscillator(Behavioural)
            generic map(OscResolution) 
            port map (Clock, CKE, nReset, CountPhase, Period,Phase,Osc);       
end architecture Behavioural;
