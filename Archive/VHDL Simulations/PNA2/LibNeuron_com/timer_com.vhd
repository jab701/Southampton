----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  13th March 2011
-- Project Name: LibNeuron 2.0
-- Module Name:  Timer Combinatorial (Com)
-- Description:  Combinatorial logic for Next State Signals in Timer State Machine.
--
-- Dependencies: None
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

entity Timer_Com  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	     TimerBits : natural := 32
	);
	port 
	(
	   -- System Control Input Signals
        signal nReset   : in std_logic;
	   -- Register Inputs
	     signal Reg_In  : in  std_logic_vector((TimerBits*2)+3 downto 0);
	   -- Register Outputs  
	     signal Reg_Out : out std_logic_vector((TimerBits*2)+3 downto 0);  
     -- Combinatorial Input Signals
	     signal Start    : in std_logic;
	   -- Static Parameters  
	     signal Period_In   : in std_logic_vector((TimerBits - 1) downto 0);
	   -- Combinatorial Output Signals
	     signal Finish : out std_logic
	); 
end Timer_Com;

architecture Behavioural of Timer_Com is

--state encodings
CONSTANT Idle     : STD_LOGIC_VECTOR := "001";
CONSTANT Running  : STD_LOGIC_VECTOR := "010";
CONSTANT Finished : STD_LOGIC_VECTOR := "100";

-- Positions of signal vectors within Reg vectors
constant Counter_Low : natural := 0;
constant Counter_Top : natural := TimerBits-1;

constant Period_Low : natural := TimerBits;
constant Period_Top : natural := (TimerBits*2)-1;

constant State_Low : natural := TimerBits*2;
constant State_Top : natural := (TimerBits*2)+2;

constant LastStart_Pos: natural := (TimerBits*2)+3;

-- Internal Registered Signals used for the Counter
signal Counter_D : std_logic_vector((TimerBits - 1) downto 0);
signal Counter_Q : std_logic_vector((TimerBits - 1) downto 0);

-- Internal Registered Period Signal
signal Period_Q : std_logic_vector((TimerBits - 1) downto 0);

-- Internal Registered State Signals
signal State_D, State_Q : std_logic_vector(2 downto 0);

-- Internal Combinatorial Signal for Counter Complete
signal CounterEqPeriod : std_logic;

signal LastStart_Q : std_logic;

begin

Counter_Q <= Reg_In(Counter_Top downto Counter_Low);
Period_Q  <= Reg_In(Period_Top  downto Period_Low);
State_Q   <= Reg_In(State_Top   downto State_Low);
LastStart_Q   <= Reg_In(LastStart_Pos);

Reg_Out(Counter_Top downto Counter_Low) <= Counter_D;
Reg_Out(Period_Top  downto Period_Low)  <= Period_In - 1;
Reg_Out(State_Top   downto State_Low)   <= State_D;
Reg_Out(LastStart_Pos) <= Start;

CounterComplete: process (Counter_Q, Period_Q) is
begin
  if (Counter_Q = Period_Q) then
    CounterEqPeriod <= '1';
  else
    CounterEqPeriod <= '0';
  end if; 
end process;

Com: process (nReset, Counter_Q, State_Q, LastStart_Q, Start, CounterEqPeriod) is
begin
  if (nReset = '0') then
    Counter_D <= (others => '0');
    Finish <= '0';      
    State_D <= Idle;    
  else
    case State_Q is
      when Idle =>
        Counter_D <= (others => '0');
        Finish <= '0';  
        
        if ((Start = '1')AND(LastStart_Q = '0')) then
          State_D <= Running;
        else
          State_D <= Idle;
        end if;
      
      when Running =>
        Counter_D <= Counter_Q + 1;
        Finish <= '0';
            
        if (CounterEqPeriod = '1') then
          State_D <= Finished;
        else
          State_D <= Running;
        end if;
    
      when Finished =>
        Counter_D <= (others => '0');
        Finish <= '1';
            
        if ((Start = '1')AND(LastStart_Q = '0')) then
          State_D <= Running;
        else
          State_D <= Idle;
        end if;
            
      when others =>
        Counter_D <= (others => '-');
        Finish <= '-';      
        State_D <= (others => '-');
              
    end case;
  end if;
end process com;
end architecture Behavioural;

