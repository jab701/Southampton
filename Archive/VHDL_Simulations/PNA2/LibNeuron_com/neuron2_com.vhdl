----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  14th March 2011
-- Project Name: LibNeuron 2.0
-- Module Name:  Neuron2 Combinatorial (Com)
-- Description:  Combinatorial logic for Next State Signals in Neuron2 State Machine.
--
-- Dependencies: osc_com.vhd burst_com.vhd timer_com.vhd
--
-- Revision: 2.00 
--
-- Additional Comments: 14/03/2011 - Validated using testbench - JAB
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Neuron2_Com  is
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
       signal Reg_In : in std_logic_vector((TimerBits*4)+27 downto 0);
     -- Register Outputs  
       signal Reg_Out : out std_logic_vector((TimerBits*4)+27 downto 0);
     -- Static Parameters
       signal Parameters  : in std_logic_vector(135 downto 0);
       signal Phase_Enable : in std_logic;
     -- Combinatorial Output Signals
       signal AP_ON       : out std_logic;
       signal AP_OFF      : out std_logic
  ); 
end Neuron2_Com;

architecture Behavioural of Neuron2_Com is

signal Osc_Reg_In : std_logic_vector((TimerBits*2)+8 downto 0);
signal Burst_Reg_In : std_logic_vector((TimerBits*2)+18 downto 0);

signal Osc_Reg_Out : std_logic_vector((TimerBits*2)+8 downto 0);
signal Burst_Reg_Out: std_logic_vector((TimerBits*2)+18 downto 0);

signal OscOutput : std_logic;

constant Osc_Low : natural := 0;
constant Osc_Top : natural := (TimerBits*2)+8;
constant Burst_Low : natural := (TimerBits*2)+9;
constant Burst_Top : natural := (TimerBits*4)+27;


begin
Osc_Reg_In   <= Reg_In(Osc_Top downto Osc_Low);
Burst_Reg_In <= Reg_In(Burst_Top downto Burst_Low);  

Reg_Out(Osc_Top downto Osc_Low)     <= Osc_Reg_Out;
Reg_Out(Burst_Top downto Burst_Low) <= Burst_Reg_Out;  
                     
Osc1: entity work.Osc_Com
  generic map(TimerBits)
  port map(-- System Control Input Signals
           nReset => nReset,
           -- Register Inputs
           Reg_In => Osc_Reg_In,
           -- Register Outputs  
           Reg_Out => Osc_Reg_Out,
           -- Static Input Signals
           PhaseDelay => Parameters(31 downto 0),
           PeriodTime => Parameters(63 downto 32),   
           Phase_En => Phase_Enable,
           -- Combinatorial Output Signals
           Output => OscOutput);
        
Burst1: entity work.Burst_Com
  generic map(TimerBits)
  port map(-- System Control Input Signals
           nReset => nReset,
           -- Register Inputs
           Reg_In => Burst_Reg_In,
           -- Register Outputs  
           Reg_Out => Burst_Reg_Out,             
           -- Static Input Signals
           APTime => Parameters(95 downto 64), 
           RefTime => Parameters(127 downto 96),       
           NBurst => Parameters(135 downto 128),           
           -- Combinatorial Input Signals
           Ex => OscOutput,    
           Inh => '0',            
           -- Combinatorial Output Signals
           AP_ON => AP_ON,
           AP_OFF => AP_OFF);   
end architecture Behavioural;