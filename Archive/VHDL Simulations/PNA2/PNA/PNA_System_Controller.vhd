----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  26th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  
-- Description:  
--
-- Dependencies: None
--
-- Revision: 1.00 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PNA_System_Controller is
  port 
  (
     signal clock   : in  std_logic;
     signal nReset  : in  std_logic;
     signal Neuron1_Pu_Act : in std_logic;
     signal Neuron2_Pu_Act : in std_logic;
     signal Synapse_Pu_Act : in std_logic;
     signal BankSelect : out std_logic); 
end entity PNA_System_Controller;

architecture Behavioural of PNA_System_Controller is
type State is (start, run);
signal StateD, StateQ : State;
signal BankSelect_D, BankSelect_Q : std_logic;
signal Running : std_logic;
begin
BankSelect <= BankSelect_Q;

Running <= Neuron1_Pu_Act OR Neuron2_Pu_Act OR Synapse_Pu_Act;

seq_ctrl: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      StateQ <= start; 
      BankSelect_Q <= '1';     
    else
      StateQ <= StateD;
      BankSelect_Q <= BankSelect_D;      
    end if;
  end if;    
end process seq_ctrl;

com_ctrl: process (StateQ, BankSelect_Q, Running) is
begin
  case StateQ is
  when start =>
    BankSelect_D <= BankSelect_Q;
    
    if (Running = '1') then
      StateD <= run;
    else
      StateD <= Start;
    end if;
            
  when run => 
    
    if (Running = '1') then
      StateD <= run;
      BankSelect_D <= BankSelect_Q;      
    else
      StateD <= start;
      BankSelect_D <= NOT(BankSelect_Q);      
    end if;
  
  end case;  
end process com_ctrl;

end architecture Behavioural;






