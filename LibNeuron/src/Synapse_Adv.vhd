----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    Synapse Block - Behavioral 
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
use LibNeuron.ALL;
use LibNeuron.TYPEDEFINITIONS.ALL;

entity AdvSynapse is
    generic(TimeResolution : natural := 32;
            StackDepth    : natural := 1000;
            SynWeighting  : signed(7 downto 0) := x"01"
            );
    port (-- Input Signals
          signal Clock     : in std_logic;
          signal CKE       : in std_logic;
          signal nReset    : in std_logic;  -- Global Reset Signal
          -- Input Signals       
          signal Axon      : in std_logic;  -- Alpha Channel -- Pre-Syn Axon
          -- Configuration Signals
          signal TDel      : unsigned((TimeResolution - 1) downto 0);
          signal TDur   : unsigned((TimeResolution - 1) downto 0);
          -- Output Signals
          signal SynWeight : out signed(15 downto 0)     -- Synapse Weight -- Gamma Channel
          ); 
end AdvSynapse;

architecture Behavioural of AdvSynapse is

signal AxonSample1, AxonSample2 : std_logic;
signal AxonPulse : std_logic;

type StackStates is (Idle, Push);
signal Current_State, Next_State : StackStates;

signal SynStart : std_logic_vector(StackDepth - 1 downto 0);
signal nSynIdle : std_logic_vector(StackDepth - 1 downto 0);
signal SynWeights : signed_vector(StackDepth - 1 downto 0);
signal AdjTDel : unsigned(TimeResolution-1 downto 0);


begin

AdjTDel <= TDel - 2;
AxonPulse <= AxonSample1 AND (NOT AxonSample2);
                         
 
Synapses : For i in 0 to (StackDepth-1) generate
   Synapse : entity LibNeuron.Synapse(Behavioural)
             generic map(TimeResolution,SynWeighting)
             port map(Clock => Clock, CKE => CKE, nReset => nReset,
                      Axon => SynStart(i), Tdel => AdjTDel, Tdur => TDur,
                      nIdle => nSynIdle(i), SynWeight => SynWeights(i)); 
end generate Synapses;

SynapseStartSeq : process(Clock) is
begin
   if rising_edge(Clock) then
     if (nReset = '0') then
      Current_State <= Idle;
      AxonSample1 <= '0';
      AxonSample2 <= '0';       
     elsif (CKE = '1') then
      Current_State <= Next_State;	  
      AxonSample1 <= Axon;
      AxonSample2 <= AxonSample1;     
     end if;
  end if;
end process SynapseStartSeq;

SynapseStartCom : process(Current_State, AxonPulse, nSynIdle) is
   variable SynStartTmp : std_logic_vector(StackDepth-1 downto 0);
   variable SynStartZero : std_logic_vector(StackDepth-1 downto 0);
begin
   SynStart <= (Others => '0');      
   SynStartTmp := (Others => '0');
   SynStartZero := (Others => '0');
     
   case Current_State is

      when Idle =>
	       if (AxonPulse = '1') then
            Next_State <= Push;    
         else
            Next_State <= Idle;
         end if;
         
      when Push =>
          
         Next_State <= Idle;
        
         StartSignals: FOR i IN 0 to StackDepth-1 Loop
   		     if ((nSynIdle(i) = '0')AND(SynStartTmp = SynStartZero)) then
   		        SynStartTmp(i) := '1';
   		     end if;   
         End Loop StartSignals;
         
         SynStart <= SynStartTmp;
   end case;
   
end process SynapseStartCom;

SynOutput: process(SynWeights)
	Variable SynWeightTmp : signed(15 downto 0);
begin
	SynWeightTmp := x"0000";

	for i in 0 to (StackDepth-1) loop
		SynWeightTmp := SynWeightTmp + SynWeights(i);
	end loop;

	SynWeight <= SynWeightTmp;

end process SynOutput;

end architecture Behavioural;

