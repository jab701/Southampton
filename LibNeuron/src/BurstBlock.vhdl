----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    Burst Block - Behavioral 
-- Project Name:   MBED VHDL
-- Target Devices: 
-- Tool versions:  ModelSim SE 6.2K
--
-- Description: 
--
-- Dependencies:   Counter.vhd
--
-- Revision 2.00 - 
--   File Modified  - 12/07/2007 - JAB05R
--   File Validated - 12/07/2007 - JAB05R
--
-- Additional Comments: Revision 1.0 - Behavioural VHDL   (JAB05R)
--                      Revision 2.0 - Synthesizable VHDL (JAB05R)
--                      Validated Using TestBench-Burst.vhd (JAB05R)
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;

entity BurstBlock  is
    generic(BurstLength   : signed(7 downto 0) := x"02";
            TimeRes       : natural := 32
            );
    port (signal Clock     : in  std_logic;
          signal CKE       : in std_logic;
          signal nReset    : in  std_logic;
          signal AbvExThld : in  std_logic;
          signal BelInThld : in  std_logic;
          signal OscIn     : in  std_logic;
          signal APTime    : unsigned((TimeRes - 1) downto 0);
          signal RefTime   : unsigned((TimeRes - 1) downto 0);        
          signal Axon     : out std_logic
          ); 
end BurstBlock;

architecture Behavioural of BurstBlock is

type APState is (ap_off, ap_on, ap_ref);
signal eta : APState;
signal eta_next : APState;

signal OscInSample1, OscInSample2 : std_logic;
signal OscInPulse : std_logic;
Signal BurstLengthD, BurstLengthQ : signed(7 downto 0);

signal TimerStart, TimerFinish : std_logic;

signal TimerPeriod : unsigned((TimeRes - 1) downto 0);

begin
OscInPulse <= OscInSample1 AND (NOT OscInSample2);

TIMER: entity LibNeuron.Timer(Behavioural)
       generic map (TimeRes)
       port map(Clock => Clock,
                CKE => CKE,
                nReset => nReset, 
				        Start => TimerStart, 
				        Period => TimerPeriod, 
				        Finished => TimerFinish);
       
			              
REG: process(Clock)is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      OscInSample1 <= '0';
      OscInSample2 <= '0';       
    elsif (CKE = '1') then
      OscInSample2 <= OscInSample1;
      OscInSample1 <= OscIn;        
    end if;
  end if;
end process REG;
                                        
SEQ: process(Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      eta <= ap_off;
      BurstLengthQ <= (Others => '0');       
    elsif (CKE = '1') then
      eta <= eta_next;
      BurstLengthQ <= BurstLengthD;    
    end if;
  end if;  
end process SEQ;
    
    
AP: process(AbvExThld, BelInThld, OscInPulse, Eta, BurstLengthQ, APTime, RefTime, TimerFinish) is
variable ZeroBurst : signed(7 downto 0);
variable InfBurst : signed(7 downto 0);
begin
    
    ZeroBurst := (Others => '0');
    InfBurst := (Others => '1');
    BurstLengthD <= BurstLengthQ; 
       
    case Eta is
    
    when ap_off =>
        Axon <= '0';
        
        TimerStart <= '0';      
        TimerPeriod <= APTime - 2;
            
        BurstLengthD <= (Others => '0');

        if (AbvExThld = '1') then      
           Eta_Next <= ap_on;
        elsif (OscInPulse = '1') then
           Eta_Next <= ap_on;    
        else
           Eta_Next <= ap_off;
        end if;    

        
    when ap_on =>
        Axon <= '1';
        TimerPeriod <= APTime -  2;
        
        if (TimerFinish = '1') then
            TimerStart <= '0';
            Eta_Next <= ap_ref;
        else
            TimerStart <= '1';
            Eta_Next <= ap_on;
        end if;
        
        if (BelInThld = '1') then
           BurstLengthD <= (BurstLength - 1);           
        else
           BurstLengthD <= BurstLengthQ;
        end if;
        
    when ap_ref =>
        Axon <= '0';
        TimerPeriod <= RefTime - 2;
        
       if (TimerFinish = '1') then
            
           TimerStart <= '0';
            
           if (BelInThld = '1') then -- Truncate Burst
               Eta_Next <= ap_off; 
           elsif (BurstLengthQ = (BurstLength - 1)) then
               Eta_Next <= ap_off;
           else
               Eta_Next <= ap_on;
           end if;
           
           if (BurstLength < ZeroBurst) then
              BurstLengthD <= BurstLengthQ;
           else
              BurstLengthD <= BurstLengthQ + 1;
           end if;
        else
           TimerStart <= '1';
           
           if (BelInThld = '1') then --Truncate the burst
              BurstLengthD <= (BurstLength - 1);
           else
              BurstLengthD <= BurstLengthQ;
           end if;
           
           Eta_Next <= ap_ref;
        end if; 
    end case;

end process AP;
 
end architecture Behavioural;



