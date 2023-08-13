----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  13th March 2011
-- Project Name: LibNeuron 2.0
-- Module Name:  Burst Combinatorial (Com)
-- Description:  Combinatorial logic for Next State Signals in Burst State Machine.
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

entity Burst_Com  is
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
     -- Static Parameters
       signal APTime  : in std_logic_vector((TimerBits-1) downto 0);
       signal RefTime : in std_logic_vector((TimerBits-1) downto 0);       
       signal NBurst  : in std_logic_vector(7 downto 0);             
     -- Combinatorial Input Signals
       signal Ex        : in std_logic; 
       signal Inh       : in std_logic;        
     -- Combinatorial Output Signals
       signal AP_ON     : out std_logic;
       signal AP_OFF    : out std_logic
  ); 
end Burst_Com;

architecture Behavioural of Burst_Com is
  
signal Timer_Start  : std_logic;
signal TimerPeriod  : std_logic_vector((TimerBits-1) downto 0);

signal State_D : std_logic_vector(4 downto 0);
signal State_Q : std_logic_vector(4 downto 0);

constant Timer_Low    : natural := 0;
constant Timer_Top    : natural := (TimerBits*2)+3;
constant Finished_Pos : natural := (TimerBits*2)+4;
constant Burst_Low    : natural := (TimerBits*2)+5;
constant Burst_Top    : natural := (TimerBits*2)+12;
constant State_Low    : natural := (TimerBits*2)+13;
constant State_Top    : natural := (TimerBits*2)+17;
constant Prev_Axon_Pos    : natural := (TimerBits*2)+18;


constant Idle          : std_logic_vector(4 downto 0) := "00001";
constant AP            : std_logic_vector(4 downto 0) := "00010";
constant Ref           : std_logic_vector(4 downto 0) := "00100";
constant Ref_BurstZero : std_logic_vector(4 downto 0) := "01000";
constant Ref_BurstInf  : std_logic_vector(4 downto 0) := "10000";

signal Burst_D : std_logic_vector(7 downto 0);
signal Finished_D : std_logic;

signal Burst_Q : std_logic_vector(7 downto 0);
signal Finished_Q : std_logic;

signal Axon : std_logic;
signal Prev_Axon : std_logic;
begin
  
Finished_Q <= Reg_In(Finished_Pos);
Burst_Q <= Reg_In(Burst_Top downto Burst_Low);
State_Q <= Reg_In(State_Top downto State_Low);
Prev_Axon <= Reg_In(Prev_Axon_Pos);

Reg_Out(Finished_Pos) <= Finished_D;
Reg_Out(Burst_Top downto Burst_Low) <= Burst_D;
Reg_Out(State_Top downto State_Low) <= State_D;
Reg_Out(Prev_Axon_Pos) <= Axon;

Timer1: entity work.Timer_Com
  generic map(TimerBits)
  port map(nReset   => nReset,
           Reg_In   => Reg_In(Timer_Top downto Timer_Low),
           Reg_Out  => Reg_Out(Timer_Top downto Timer_Low),
           Start    => Timer_Start,
           Period_In => TimerPeriod,
           Finish    => Finished_D);
           
com: process (nReset, APTime, RefTime, State_Q, Finished_Q, Burst_Q, Ex, Inh, NBurst) is
begin
    
  if (nReset = '0') then
    Axon <= '0';
    State_D     <= Idle;
    Timer_Start <= '0';
    TimerPeriod <= (others => '-');
    Burst_D     <= (others => '0');  
  else
    case State_Q is
     when Idle =>
       Axon <= '0';
       TimerPeriod <= APTime - 3;
       Burst_D <= NBurst - 1;
       Timer_Start <= '0'; 
                      
       if (Ex = '1') then
         State_D <= AP;
       else
         State_D <= Idle;
       end if;

     when AP =>
       Axon <= '1';
       TimerPeriod <= APTime - 3;
       
       if (Inh = '1') then
         Burst_D <= (others => '0');  
       else
         Burst_D <= Burst_Q;
       end if;
        
       if (Finished_Q = '1') then
         Timer_Start <= '0';
         
         if (Inh = '1') then
           State_D <= Ref_BurstZero;
         elsif (Burst_Q = x"00") then
           State_D <= Ref_BurstZero;  
         elsif (Burst_Q(7) = '1') then
           State_D <= Ref_BurstInf;        
         else
           State_D <= Ref;
         end if; 
       else
         Timer_Start <= '1';
         State_D <= AP;
       end if;
      
      when Ref =>
        Axon <= '0';
        TimerPeriod <= RefTime - 3;
        
        if (Finished_Q = '1') then
          Timer_Start <= '0';
          if (Inh = '1') then
            Burst_D <= NBurst - 1;
            State_D <= Idle;        
          else
            Burst_D <= Burst_Q - 1;
            State_D <= AP;        
          end if;
        else
          Timer_Start <= '1';
          if (Inh = '1') then
            Burst_D <= (others => '0');
            State_D <= Ref_BurstZero;        
          else
            Burst_D <= Burst_Q;
            State_D <= Ref;        
          end if;
        end if;
          
      when Ref_BurstZero =>
        Axon <= '0';
        TimerPeriod <= RefTime - 3;
        Burst_D <= NBurst - 1;
        
        if (Finished_Q = '1') then
          Timer_Start <= '0';
          State_D <= Idle;        
        else
          Timer_Start <= '1';
          State_D <= Ref_BurstZero;        
        end if;
            
      when Ref_BurstInf =>
        Axon <= '0';
        TimerPeriod <= RefTime - 3;
        
        if (Finished_Q = '1') then
          Timer_Start <= '0';
          if (Inh = '1') then
            Burst_D <= (others => '0');
            State_D <= Idle;        
          else
            Burst_D <= x"FF";
            State_D <= AP;        
          end if;
        else
          Timer_Start <= '1';
          if (Inh = '1') then
            Burst_D <= (others => '0');
            State_D <= Ref_BurstZero;        
          else
            Burst_D <= x"FF";
            State_D <= Ref;        
          end if;
        end if;
                
      when others =>
        State_D     <= (others => '-');
        Timer_Start <= '-';
        TimerPeriod <= (others => '-');
        Burst_D     <= (others => '-'); 
    end case;
  end if;  
end process com;

AP_ON_OFF: process (Axon, Prev_Axon) is
begin
  if ((Axon = '1')AND(Prev_Axon = '0')) then
    AP_ON  <= '1';
    AP_OFF <= '0';  
  elsif ((Axon = '0') AND (Prev_Axon = '1')) then
    AP_ON  <= '0';
    AP_OFF <= '1';     
  else
    AP_ON  <= '0';
    AP_OFF <= '0';    
  end if;    
end process AP_ON_OFF;

end architecture Behavioural;
