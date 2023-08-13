----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    26/02/2007 
-- Design Name: 
-- Module Name:    C Elegans Synapse Types
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
use LibNeuron.typedefinitions.ALL;

entity ElegansSynapse is
    port (signal Clock    : std_logic;
          signal CKE      : std_logic;
          signal nReset   : std_logic;
          signal Axon     : in std_logic;   
          signal Dendrite : out signed(15 downto 0)          
          );
end ElegansSynapse;

architecture Type1 of ElegansSynapse is
begin
Type1: entity LibNeuron.Synapse(Behavioural)
                 generic map(20,x"01")
                 port map(Clock => Clock, 
                          CKE => CKE,
                          nReset => nReset, 
                          Axon => Axon,
                          TDel => x"003E8",
                          TDur => x"493E0",
						              SynWeight => Dendrite);    
end architecture Type1;

architecture Type2 of ElegansSynapse is
begin
Type2: entity LibNeuron.Synapse(Behavioural)
                 generic map(20,x"01")
                 port map(Clock => Clock,
                          CKE => CKE,
                          nReset => nReset,
				                  Axon => Axon, 
				                  TDel => x"03A98", 
				                  TDur => x"186A0",
						              SynWeight => Dendrite);
end architecture Type2;

architecture Type3 of ElegansSynapse is
begin
Type3: entity LibNeuron.Synapse(Behavioural)
                 generic map(12,x"01")
                 port map(Clock => Clock,
                          CKE => CKE,
                          nReset => nReset, 
				                  Axon => Axon,
				                  TDel => x"3E8",
				                  TDur => x"44C",
						              SynWeight => Dendrite);
end architecture Type3;

architecture Type4 of ElegansSynapse is
begin
Type4: entity LibNeuron.Synapse(Behavioural)
                 generic map(12,x"FF")
                 port map(Clock => Clock,
                          CKE => CKE,
                          nReset => nReset,
				                  Axon => Axon,
				                  TDel => x"3E8",
				                  TDur => x"3E8",
						              SynWeight => Dendrite);
end architecture Type4;



