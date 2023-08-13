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

entity Synapse is
    generic(TimeResolution : natural := 32;
            SynWeighting  : signed(7 downto 0) := x"01"
            );
    port (-- Input Signals
          signal Clock     : in std_logic;
          signal CKE       : in std_logic;
          signal nReset    : in std_logic;  -- Global Reset Signal
          -- Input Signals       
          signal Axon      : in std_logic;  -- Alpha Channel -- Pre-Syn Axon
          -- Configuration Signals
          signal Tdel      : unsigned((TimeResolution - 1) downto 0);
          signal Tdur      : unsigned((TimeResolution - 1) downto 0);
          -- Output Signals
	        signal nIdle     : out std_logic;
          signal SynWeight : out signed(15 downto 0)     -- Synapse Weight -- Gamma Channel
          ); 
end Synapse;

architecture Behavioural of Synapse is

signal AxonSample1, AxonSample2 : std_logic;
signal AxonPulse : std_logic;


signal TimerStart : std_logic;
signal TimerFinish   : std_logic;
signal TimerPeriod  : unsigned((TimeResolution - 1) downto 0);

type States is (Idle, Delay, Active);
signal StateD : States;
signal StateQ : States;

begin
  AxonPulse <= AxonSample1 AND (NOT AxonSample2);
  

  
TIMER: entity LibNeuron.Timer(Behavioural)
       generic map(TimeResolution)
       port map(Clock => Clock,
                CKE => CKE,
                nReset => nReset,
                Start => TimerStart,
                Period => TimerPeriod,
                Finished => TimerFinish);

SEQ: process (Clock) is
begin
   if (rising_edge(Clock)) then
     if (nReset = '0') then
      StateQ <= Idle;   
      AxonSample1 <= '0';
      AxonSample2 <= '0';       
     elsif (CKE = '1') then
      StateQ <= StateD;
      AxonSample2 <= AxonSample1;
      AxonSample1 <= Axon;
     end if;
   end if;
end process SEQ;

COM: process (StateQ, TDel, AxonPulse, TimerFinish, TDur) is
begin
   case StateQ is
      when Idle =>
	      nIdle <= '0';
        TimerPeriod <= TDel - 2;
        SynWeight <= (Others => '0');
      	
       if (AxonPulse = '1') then
      	    TimerStart <= '1';
      	    StateD <= Delay;
      	else
      	    TimerStart <= '0';
      	    StateD <= Idle;
      	end if;
      
      when Delay =>
	      nIdle <= '1';
        TimerPeriod <= TDel - 2;
        SynWeight <= (Others => '0');        
        
        if (TimerFinish = '1') then
            TimerStart <= '1';
            StateD <= Active;
        else
            TimerStart <= '0';
            StateD <= Delay;
        end if;
      
      when Active =>
	      nIdle <= '1';
        TimerPeriod <= TDur - 1;
        TimerStart <= '0';
        SynWeight <= resize(signed(SynWeighting), SynWeight'length);

        if (TimerFinish = '1') then
            StateD <= Idle;
        else
            StateD <= Active;
        end if;
   end case;
end process COM;

end architecture Behavioural;

