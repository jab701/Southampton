----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  26th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  
-- Description:  
--
-- Dependencies: None
--
-- Revision: 1.00 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pu_controller  is
  port 
  (
     signal clock   : in  std_logic;
     signal nreset  : in std_logic;
     signal ce : in std_logic;
     
     signal Trigger : in std_logic;
     signal AddrUnit_Running : in std_logic;
     
     signal Running : out std_logic;
     signal nReset_Ex   : out std_logic;
     signal AddrUnit_Go : out std_logic
   ); 
end entity pu_controller;

architecture Behavioural of pu_controller is

type STATE_TYPE is (rst1,rst2,idle,run);
 
signal StateQ : STATE_TYPE;
signal StateD : STATE_TYPE;
  
begin

seq: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      StateQ <= rst1;  
    elsif (ce = '1') then
      StateQ <= StateD;    
    end if;
  end if;  
end process seq;

com: process (StateQ, addrunit_running, trigger) is
begin
  case (StateQ) is
  when rst1 =>
    nReset_ex <= '0';
    AddrUnit_Go <= '1';
    StateD <= rst2;
    Running <= '1';
    
  when rst2 =>
    nReset_ex <= '0';
    AddrUnit_Go <= '0';
    Running <= '1';
    
    if (AddrUnit_Running = '1') then
      StateD <= rst2;  
    else
      StateD <= idle;
    end if; 
    
  when idle =>
    nReset_ex <= '1';
    Running <= '0';
                
    if (Trigger = '1') then
      StateD <= run;
      AddrUnit_Go <= '1';  
    else
      StateD <= idle;
      AddrUnit_Go <= '0';
    end if;
        
  when run =>
    nReset_ex <= '1';
    AddrUnit_Go <= '0';
    Running <= '1';
    
    if (AddrUnit_Running = '1') then
      StateD <= run;  
    else
      StateD <= idle;
    end if; 
  end case;  
end process com;  
end architecture Behavioural;





