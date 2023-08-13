----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  13th March 2011
-- Project Name: LibNeuron 2.0
-- Module Name:  Oscillator Combinatorial (Com)
-- Description:  Combinatorial logic for Next State Signals in Oscillator State Machine.
--
-- Dependencies: timer_com.vhd
--
-- Revision: 2.00 
--
-- Additional Comments: 13/03/2011 - Validated using testbench - JAB
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Osc_Com  is
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
       signal Reg_In : in std_logic_vector((TimerBits*2)+8 downto 0);
     -- Register Outputs  
       signal Reg_Out : out std_logic_vector((TimerBits*2)+8 downto 0);
     -- Static Parameters
       signal PhaseDelay : in std_logic_vector((TimerBits-1) downto 0);
       signal PeriodTime : in std_logic_vector((TimerBits-1) downto 0);       
       signal Phase_En  : in std_logic;
     -- Combinatorial Output Signals
       signal Output    : out std_logic
  ); 
end Osc_Com;

architecture Behavioural of Osc_Com is
signal Timer_Start  : std_logic;
signal TimerPeriod  : std_logic_vector((TimerBits-1) downto 0); 

-- Register Inputs
signal State_Q : std_logic_vector(3 downto 0);
signal Finished_Q : std_logic;
-- Register Outputs  
signal State_D : std_logic_vector(3 downto 0);     
signal Finished_D : std_logic;

constant Idle  : std_logic_vector(3 downto 0) := "0001";
constant Phase : std_logic_vector(3 downto 0) := "0010";
constant Pulse : std_logic_vector(3 downto 0) := "0100";
constant Off   : std_logic_vector(3 downto 0) := "1000";

constant Timer_Low    : natural := 0;
constant Timer_Top    : natural := (TimerBits*2)+3;
constant Finished_Pos : natural := (TimerBits*2)+4;
constant State_Low    : natural := (TimerBits*2)+5;
constant State_Top    : natural := (TimerBits*2)+8;

begin

Finished_Q <= Reg_In(Finished_Pos);
State_Q    <= Reg_In(State_Top downto State_Low);

Reg_Out(Finished_Pos)               <= Finished_D;
Reg_Out(State_Top downto State_Low) <= State_D;

Timer1: entity work.Timer_Com
  generic map(TimerBits)
  port map(nReset    => nReset,
           Reg_In    => Reg_In(Timer_Top downto Timer_Low),
           Reg_Out   => Reg_Out(Timer_Top downto Timer_Low),
           Start     => Timer_Start,
           Period_In => TimerPeriod,
           Finish    => Finished_D);

com: process (State_Q, nReset, Finished_Q, Phase_En, PhaseDelay, PeriodTime) is
begin
  if (nReset = '0') then
    Output <= '0';
    TimerPeriod <= (others => '-');
    Timer_Start <= '0';        
    State_D <= Idle;  
  else
    case (State_Q) is
      when Idle =>
        Output <= '0';
        TimerPeriod <= (others => '-');
        Timer_Start <= '0';
        
        if (Phase_En = '1') then
          State_D <= Phase; 
        else
          State_D <= Pulse;
        end if;
        
      when Phase =>
        Output <= '0';
        TimerPeriod <= PhaseDelay - 3;
        
        if (Finished_Q = '1') then
          Timer_Start <= '0';
          State_D <= Pulse;        
        else
          Timer_Start <= '1';
          State_D <= Phase;
        end if;
                            
      when Pulse =>
        Output <= '1';
        TimerPeriod <= PeriodTime - 4;
        Timer_Start <= '0';
        State_D <= Off;
                           
      when Off =>
        Output <= '0';
        TimerPeriod <= PeriodTime - 4;
        
        if (Finished_Q = '1') then
          Timer_Start <= '0';
          State_D <= Pulse;        
        else
          Timer_Start <= '1';
          State_D <= Off;
        end if;
                    
      when others =>
        Output <= '-';
        TimerPeriod <= (others => '-');
        Timer_Start <= '-';
        State_D <= (others => '-');
    end case;  
  end if;  
end process com;

end architecture Behavioural;