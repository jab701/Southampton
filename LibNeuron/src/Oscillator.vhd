library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;

entity Oscillator is
    generic (
    	     -- Module Specific Configuration Parameters
             Resolution : natural := 32
             );
    port (-- Global Input Signals
          signal Clock         : in  std_logic;
          signal CKE           : in  std_logic;
          signal nReset        : in  std_logic;
          signal TimerPhaseEn  : in  std_logic;
          -- Module Specific Parameters
          signal TimerPeriod   : in  unsigned((Resolution -1) downto 0);
          signal TimerPhase : in  unsigned((Resolution -1) downto 0);
          -- Module Specific Output Signals
          signal Output     : out std_logic
          ); 
end Oscillator;

architecture Behavioural of Oscillator is
    
type OscillatorStates is (OscReset, OscPhase, OscOnPeriod, OscOffPeriod);
signal Current_State : OscillatorStates;
signal Next_State    : OscillatorStates;

signal TimerPeriodIn : unsigned((Resolution - 1) downto 0);
signal TimerStart, TimerFinish : std_logic;
begin

Timer: entity LibNeuron.Timer(Behavioural)
                generic map (Resolution)
                port map(Clock => Clock,
                         CKE => CKE,
                         nReset => nReset, 
				                 Start => TimerStart,
						             Period => TimerPeriodIn,
						             Finished => TimerFinish);
                    
Oscillator_Seq: process (Clock) is
begin
   if rising_edge(Clock) then
     if (nReset = '0') then
       Current_State <= OscReset; 
     elsif (CKE = '1') then
       Current_State <= Next_State;     
     end if;
   end if;   
end process Oscillator_Seq;

Oscillator_States: process (Current_State, TimerPeriod, TimerFinish, TimerPhase, TimerPhaseEn) is
variable PeriodZero : unsigned(31 downto 0);                              
begin
   PeriodZero := (Others => '0'); 
   case Current_State is
      when OscReset =>
          Output <= '0';
          TimerStart <= '0';
          
          if (TimerPhaseEn = '0') then
             TimerPeriodIn <= TimerPeriod - 3; 
             Next_State <= OscOnPeriod;              
          else
             TimerPeriodIn <= TimerPhase - 2;
             Next_State <= OscPhase;          
          end if;
  
      when OscPhase =>
          Output <= '0';          
          TimerPeriodIn <= TimerPhase - 2;
                    
          if (TimerFinish = '1') then
            TimerStart <= '0';
            Next_State <= OscOnPeriod;
          else
            TimerStart <= '1';
            Next_State <= OscPhase;
          end if;
          
      when OscOnPeriod =>
          Output <= '1';          
          
          TimerStart <= '0';
          TimerPeriodIn <= TimerPeriod - 3; 
          
          Next_State <= OscOffPeriod;          
           

 
                    
      when OscOffPeriod =>
          Output <= '0';          
          TimerPeriodIn <= TimerPeriod - 3;                    

          if (TimerFinish = '1') then
            TimerStart <= '0';
            Next_State <= OscOnPeriod;
          else
            TimerStart <= '1';
            Next_State <= OscOffPeriod;
          end if;          
   end case;
   
end process Oscillator_States;

end architecture Behavioural;


