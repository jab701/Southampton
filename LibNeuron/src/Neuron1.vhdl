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
USE LibNeuron.TYPEDEFINITIONS.ALL;

entity Neuron1 is
    generic(-- Threshold Block Generics
            NumberSynapses : Positive := 1;
            MaxSynapses    : Positive := 1;
            THe            : signed(15 downto 0) := x"0001";
            THi            : signed(15 downto 0) := x"FFFF";
            -- Oscillator Generics
               -- Oscillator Has No Generics
            -- Burst Block Generics
            BurstLength    : Signed(7 downto 0) := x"02";
            TimeRes   : natural := 32
            );
    port (signal Clock         : in std_logic;
          signal CKE           : in std_logic;
          signal nReset        : in std_logic;
          -- Threshold Block Signals
          signal SynWeightVector : in signed_vector((NumberSynapses-1) downto 0);
          -- Burst Block Signals
          signal APTime         : unsigned((TimeRes - 1) downto 0);
          signal RefTime        : unsigned((TimeRes - 1) downto 0);
          -- Axon Action Potential Signal
          signal Axon           : out std_logic
          ); 
end Neuron1;

architecture Behavioural1 of Neuron1 is
-- Threshold Block Output

signal AbvExThld : std_logic;
signal BelInThld : std_logic;

begin

Threshold1 : entity LibNeuron.Threshold(Parallel)
            generic map(NumberSynapses, MaxSynapses, THe, THi)
            port map (Clock, CKE, nReset, SynWeightVector, AbvExThld, BelInThld );    
Burst1     : entity LibNeuron.BurstBlock(Behavioural)
            generic map(BurstLength,TimeRes) 
            port map (Clock, CKE, nReset, AbvExThld, BelInThld, '0', APTime, RefTime, Axon);
      
end architecture Behavioural1;

architecture Behavioural2 of Neuron1 is
-- Threshold Block Output
signal AbvExThld : std_logic;
signal BelInThld : std_logic;

begin

Threshold1 : entity LibNeuron.Threshold(Sequential)
            generic map(NumberSynapses, MaxSynapses, THe, THi)
            port map (Clock, CKE, nReset, SynWeightVector, AbvExThld, BelInThld );    
Burst1     : entity LibNeuron.BurstBlock(Behavioural)
            generic map(BurstLength,TimeRes) 
            port map (Clock, CKE, nReset, AbvExThld, BelInThld, '0', APTime, RefTime, Axon);
      
end architecture Behavioural2;
