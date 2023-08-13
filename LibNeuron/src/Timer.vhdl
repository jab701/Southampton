----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    Counter - Behavioral 
-- Project Name:   MBED VHDL
-- Target Devices: 
-- Tool versions:  ModelSim SE 6.2E
-- Description: 
--
-- Dependencies:   EdgeDetector.vhd
--
-- Revision: 
-- Revision H:/VHDL Simulations/Synth-VHDL/Counter.vhd1.10 - 
--   File Modified  - 27/07/2007 - JAB05R
--   File Validated - 27/07/2007 - JAB05R
--
-- Additional Comments: Revision 1.00 - Synthesizable VHDL
--                      Revision 1.10 - Corrected Registered Signals    
--                      Validated Using TestBench-Counter.vhd
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Include LibNeuron Library
library LibNeuron;
use LibNeuron.ALL;

entity Timer  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	     TimerBits : natural := 32
	);
	port 
	(
	   -- Global Input Signals
        signal Clock    : in  std_logic;
        signal CKE      : in  std_logic;
        signal nReset   : in  std_logic;
	   -- Module Specific Input Signals
	     signal Start    : in  std_logic;
	   -- Module Specific Parameters
	     signal Period   : in  unsigned((TimerBits - 1) downto 0);
	   -- Module Specific Output Signals
	     signal Finished : out std_logic
	); 
end Timer;

architecture Behavioural of Timer is
 
  signal Start_CurrentSample : std_logic;
  signal Start_LastSample : std_logic;
  
  signal RunningD : std_logic;
  signal RunningQ : std_logic;
  signal StartPulse : std_logic;

  signal LockedPeriod : unsigned((TimerBits - 1) downto 0);
  
  signal TimerD, TimerQ : unsigned((TimerBits - 1) downto 0);  

begin
  StartPulse <= Start_CurrentSample AND NOT(Start_LastSample);

RegSignals: process(Clock) is
begin
    if rising_edge(Clock) then
      if (nReset = '0') then
         Start_LastSample <= '0';
         Start_CurrentSample <= '0';
         RunningQ <= '0';         
      elsif (CKE = '1') then
         Start_LastSample <= Start_CurrentSample;
         Start_CurrentSample <= Start;
         RunningQ <= RunningD;
       end if; 
    end if;
end process RegSignals;

PeriodLocking: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      LockedPeriod <= (Others => '0');       
    elsif (CKE = '1') then
      if (StartPulse = '1') then
        LockedPeriod <= Period;        
      end if;
    end if;
  end if;
end process;

TimerSeq: process (Clock) is 
begin
    if rising_edge(Clock) then
      if (nReset = '0') then
         TimerQ <= (others => '0');
      elsif (CKE = '1') then
         TimerQ <= TimerD;
      end if; 
    end if;  
end process TimerSeq;


TimerCom: process(TimerQ, LockedPeriod, StartPulse, RunningQ) is
begin
  if (RunningQ = '1') AND (TimerQ = LockedPeriod) then 
    TimerD <= (others => '0');
    TimerD(0) <= '1';
    RunningD <= '0';
    Finished <= '1';    
  elsif (RunningQ = '1') then
    TimerD <= TimerQ + 1;
    RunningD <= '1';
    Finished <= '0';     
  elsif (StartPulse = '1') then
    RunningD <= '1';
    TimerD <= (others => '0');
    TimerD(0) <= '1';
    Finished <= '0';    
  else 
    RunningD <= '0';
    TimerD <= (others => '0');
    TimerD(0) <= '1';
    Finished <= '0';            
  end if;
end process TimerCom;

end architecture Behavioural;

