----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  14th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  Threshold Combinatorial (Com)
-- Description:  Combinatorial logic for Threshold Decision Machine.
--
-- Dependencies: 
--
-- Revision: 1.00 
--
-- Additional Comments: 14/10/2010 - Validated using testbench - JAB
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Threshold_Com  is
  port 
  (
     -- Combinatorial Inputs
       signal SynSum : in std_logic_vector(15 downto 0);
     -- Static Parameters Signals
       signal ExThreshold : in std_logic_vector(15 downto 0);
       signal InThreshold : in std_logic_vector(15 downto 0);       
     -- Combinatorial Output Signals
       signal Ex  : out std_logic;
       signal Inh : out std_logic
  ); 
end Threshold_Com;

architecture Behavioural of Threshold_Com is
begin
Ex_Com: process (SynSum, ExThreshold) is
variable SignedSynSum : signed(15 downto 0);
variable SignedExThreshold : signed(15 downto 0);
begin
  SignedSynSum := signed(SynSum);
  SignedExThreshold := signed(ExThreshold);
  
  if (SignedSynSum >= SignedExThreshold) then
    Ex <= '1';  
  else
    Ex <= '0';  
  end if;
end process Ex_Com;    

In_Com: process (SynSum, InThreshold) is
variable SignedSynSum : signed(15 downto 0);
variable SignedInThreshold : signed(15 downto 0);
begin
  SignedSynSum := signed(SynSum);
  SignedInThreshold := signed(InThreshold);  
  
  if (SignedSynSum <= SignedInThreshold) then
    Inh <= '1';  
  else
    Inh <= '0';  
  end if;
end process In_Com;
      
end architecture Behavioural;