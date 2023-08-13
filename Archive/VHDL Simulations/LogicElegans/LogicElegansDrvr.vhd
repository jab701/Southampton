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

library LogicElegans;
use LogicElegans.ALL;


entity LogicElegansDrvr is
    generic (Resolution : natural := 32;
             Phase : unsigned := x"00000000";
             Period : unsigned := x"00000000");
    port (signal Clock    : in  std_logic;
          signal nReset   : in  std_logic;
          signal Enable : in std_logic;
		  signal CountPhase : in std_logic;
          signal Q : out std_logic
          ); 
end LogicElegansDrvr;

architecture Behavioural of LogicElegansDrvr is

type CountStates is (Idle, Counting);
type OscStates is (Reset, PhaseState, OnState, OffState);

signal CounterStateQ, CounterStateD : CountStates;
signal OscStatesQ, OscStatesD : OscStates;

signal CountQ, CountD, CounterPeriod : unsigned((Resolution - 1) downto 0);
signal CountStart, CountFinish : std_logic;

begin
  
SEQ: process (Clock, nReset) is
begin
  if (nReset = '0') then
    CounterStateQ <= Idle;
    OscStatesQ <= Reset;
    CountQ <= (Others => '0');
  elsif rising_edge(Clock) then
    if (Enable = '0') then
      CounterStateQ <= Idle;
      OscStatesQ <= Reset;
      CountQ <= (Others => '0');            
    else
      CounterStateQ <= CounterStateD;
      OscStatesQ <= OscStatesD;
      CountQ <= CountD;                 
    end if;
  end if;
end process SEQ;

COMOSC: Process (OscStatesQ, CountPhase, CountFinish ) is
variable PeriodZero : unsigned((Resolution - 1) downto 0);
begin
  PeriodZero := (Others => '0');
  
  case OscStatesQ is
    
  when Reset =>
          Q <= '0';
          CountStart <= '0';
          
          if (CountPhase = '0') then
             CounterPeriod <= Period - 2; 
             OscStatesD <= OnState;              
          else
             CounterPeriod <= Phase - 1;
             OscStatesD <= PhaseState;          
          end if; 
             
  when PhaseState =>
          Q <= '0'; 
          
          CounterPeriod <= Phase - 1;
                    
          if (CountFinish = '1') then
            CountStart <= '0';
            OscStatesD <= OnState;
          else
            CountStart <= '1';
            OscStatesD <= PhaseState;
          end if;
                      
  when OnState =>
          Q <= '1'; 
          CounterPeriod <= Period - 2; 
          OscStatesD    <= OffState;    
                          
  when OffState =>
          Q <= '0'; 
          CounterPeriod <= Period - 2;
                    
          if (CountFinish = '1') then
            CountStart <= '0';
            OscStatesD <= OnState;
          else
            CountStart <= '1';
            OscStatesD <= OffState;
          end if;            
  end case;
end process COMOSC;

COMCNT: process (CounterStateQ, CountQ, CountStart, CounterPeriod) is
begin
 
  case CounterStateQ is
  
  when Idle =>
         CountFinish <= '0';
         CountD <= (others => '0');
         
         if CountStart = '1' then
            CounterStateD <= Counting;
         else
            CounterStateD <= Idle;
         end if;    
  when Counting =>
         
         CountD <= CountQ + 1;

         if (CountQ = (CounterPeriod - 1)) then
            CountFinish <= '1'; 
            CounterStateD <= Idle;    
         else
            CountFinish <= '0';
            CounterStateD <= Counting;
         end if;

  end case;  
  
end process COMCNT;

 
end architecture Behavioural;


