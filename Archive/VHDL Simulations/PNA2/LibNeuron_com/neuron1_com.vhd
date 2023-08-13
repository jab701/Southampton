----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  14th March 2011
-- Project Name: LibNeuron 2.0
-- Module Name:  Neuron1 Combinatorial (Com)
-- Description:  Combinatorial logic for Next State Signals in Neuron1 State Machine.
--
-- Dependencies: threshold_com.vhd burst_com.vhd timer_com.vhd
--
-- Revision: 2.00 
--
-- Additional Comments: 14/03/2011 - Validated using testbench - JAB
--
-------------.---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Neuron1_Com  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	     TimerBits : natural := 32
	);
  port 
  (
     -- System Control Input Signals
       signal nReset : in std_logic;
     -- Register Inputs
       signal Reg_In : in std_logic_vector(((TimerBits*2)+18) downto 0);
     -- Register Outputs  
       signal Reg_Out : out std_logic_vector(((TimerBits*2)+18) downto 0);
     -- Combinatorial Input Signals
       signal SynSum      : in std_logic_vector(15 downto 0);
     -- Static Parameters
       signal Parameters  : in std_logic_vector(103 downto 0); 
     -- Combinatorial Output Signals
       signal AP_ON       : out std_logic;
       signal AP_OFF      : out std_logic
  ); 
end Neuron1_Com;

architecture Behavioural of Neuron1_Com is
  signal Ex  : std_logic;
  signal Inh : std_logic;
begin

Threshold1: entity work.threshold_com
  port map(-- Register Inputs
           SynSum => SynSum,
           -- Static Input Signals
           ExThreshold => Parameters(15 downto 0), 
           InThreshold => Parameters(31 downto 16),      
           -- Combinatorial Output Signals
           Ex => Ex, 
           Inh => Inh);
           
Burst1: entity work.Burst_Com
  generic map(TimerBits)
  port map(-- System Control Input Signals
           nReset => nReset,
           -- Register Inputs
           Reg_In => Reg_In,
           -- Register Outputs  
           Reg_Out => Reg_Out,
           -- Static Input Signals
           APTime => Parameters(63 downto 32), 
           RefTime => Parameters(95 downto 64),       
           NBurst => Parameters(103 downto 96),           
           -- Combinatorial Input Signals
           Ex => Ex,    
           Inh => Inh,            
           -- Combinatorial Output Signals
           AP_ON => AP_ON,
           AP_OFF => AP_OFF);             
end architecture Behavioural;