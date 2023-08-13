----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    26/02/2007 
-- Design Name: 
-- Module Name:    C Elegans Neuron Types
-- Project Name:   C Elegans Locomotion
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: Library - MBED_Claverol
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
use LibNeuron.ALL;
use LibNeuron.TYPEDEFINITIONS.ALL;

entity ElegansDriverNeuron is
    generic(NumberSynapses   : Positive);
    port (signal Clock       : std_logic;
          signal CKE         : std_logic;
          signal nReset      : std_logic;
          signal CountPhase  : std_logic;
          -- Output Signal
          Signal Axon        : out std_logic
          ); 
end ElegansDriverNeuron;

architecture CLSAV of ElegansDriverNeuron is
begin
CLSAV: entity LibNeuron.Neuron2(Behavioural) -- Double Check these figures!
                 generic map(20,x"05",12)
                 port map(Clock, CKE, nReset,CountPhase,x"57E40",x"00000",x"3E8",x"7D0",Axon);       
end architecture CLSAV;

architecture NRTS of ElegansDriverNeuron is
begin
NRTS: entity LibNeuron.Neuron2(Behavioural) -- Double Check these figures!
                 generic map(24,x"01",12)
                 port map(Clock, CKE, nReset,CountPhase,x"249F00",x"124F80",x"3E8",x"3E8",Axon);    
end architecture NRTS;


