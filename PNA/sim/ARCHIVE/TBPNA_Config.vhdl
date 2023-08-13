
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use std.textio.all;


entity TBPNA_Config is
           
  port  (Clock : in std_logic;
         nReset : in std_logic;
         Enable : in std_logic;
         Complete : out std_logic;
         SCLK : out std_logic;
         SDO : out std_logic);
           
end entity TBPNA_Config;

architecture TestBench of TBPNA_Config is

type ConfigStates is (Initial, ReadLine, CheckLine, ProcessReadLine, Send0, Send1, CheckLineLimit, Done);

signal ConfigStatesD, ConfigStatesQ : ConfigStates;

signal icounterQ, icounterD : integer;
signal C : character; 
begin

CONFIGSEQ: process (nReset, Clock) is
begin
  if (nReset = '0') then
        ConfigStatesQ <= Initial;
        iCounterQ <= 1;
  elsif rising_edge(Clock) then
     if (Enable = '1') then
        ConfigStatesQ <= ConfigStatesD;
        iCounterQ <= iCounterD;
     end if;
  end if;  
end process CONFIGSEQ;

CONFIGCOM: process (ConfigStatesQ, iCounterQ) is
  file data_file : text;
  variable L : line;
  variable R : real;
  variable C : character;
  variable good_number : boolean;  
begin
  
  case ConfigStatesQ is
  when Initial =>
    SDO <= '0';
    Complete <= '0';
    SCLK  <= '0';
    iCounterD <= 1;
    file_open(data_file,"ConfigData.txt",READ_MODE);
    ConfigStatesD <= ReadLine;
        
  when ReadLine =>
    SDO <= '0';    
    Complete <= '0';
    SCLK  <= '0';    
    iCounterD <= 1;
        
    if endfile(data_file) then
      ConfigStatesD <= Done;      
    else
      readline(data_file, L);
      ConfigStatesD<= CheckLine;
       
    end if;
when CheckLine =>
    SDO <= '0';    
    Complete <= '0';
    SCLK  <= '0';  
    iCounterD <= 1;
 
    if (L'length = 0) then
      ConfigStatesD <= ReadLine;
    elsif (L(1) = '#') then
       ConfigStatesD <= ReadLine;      
    else
        ConfigStatesD <= ProcessReadLine;    
    end if;    
       
  when ProcessReadLine =>
    SDO <= '0';
    SCLK  <= '0';
    Complete <= '0';

    iCounterD <= iCounterQ;

      if (L(iCounterQ) = '0') then
        SDO <= '0';        
        ConfigStatesD <= Send0;        
      elsif (L(iCounterQ) = '1') then
        SDO <= '1';       
        ConfigStatesD <= Send1;
      else
        ConfigStatesD <= CheckLineLimit;                
      end if;  

    
  when Send0 =>
    iCounterD <= iCounterQ;
    SCLK  <= '1';
    Complete <= '0';
    SDO <= '0';
    ConfigStatesD <= CheckLineLimit;
          
  when Send1 =>
    iCounterD <= iCounterQ;      
    SCLK  <= '1';
    Complete <= '0';
    SDO <= '1';
    ConfigStatesD <= CheckLineLimit;
    
  when CheckLineLimit =>
    SDO <= '0';
    SCLK <= '0';
    Complete <= '0';
    iCounterD <= iCounterQ;  
        
    if (iCounterQ = (L'length)) then
      ConfigStatesD <= ReadLine;
    else
      iCounterD <= iCounterQ + 1;
      ConfigStatesD <= ProcessReadLine;    
    end if;    
                      
  when Done =>
    iCounterD <= 0;
    SDO <= '0';
    SCLK <= '0';      
    Complete <= '1';
    ConfigStatesD <= Done;
     
  end case;  
end process CONFIGCOM;
  
end architecture TestBench;
