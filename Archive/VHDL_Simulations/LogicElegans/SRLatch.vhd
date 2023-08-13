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


entity SRLatch is
    port (signal Clock  : in  std_logic;
          signal nReset : in  std_logic;
          signal S_PAD  : in  std_logic;
          signal R_PAD  : in  std_logic;
          signal DeltaQ : out std_logic;
          signal Q_PAD  : out std_logic
          ); 
end SRLatch;

architecture Behavioural of SRLatch is
signal Q      : std_logic;
signal D      : std_logic;
signal R_MUXD : std_logic;
begin
  
Q_PAD <= Q;
DeltaQ <= D;

SEQ: process (Clock, nReset) is
begin
  if (nReset='0') then
    Q <= '0';      
  elsif rising_edge(Clock) then
    Q <= D;  
  end if;
end process SEQ;

SETMUX: process (S_PAD,R_MUXD) is
begin
  if (S_PAD = '1') then
    D <= '1';
  else
    D <= R_MUXD;
  end if;  
end process SETMUX;

RESETMUX: process (R_PAD,Q) is
begin
  if (R_PAD = '1') then
    R_MUXD <= '0';
  else
    R_MUXD <= Q;
  end if;    
end process RESETMUX;

end architecture Behavioural;

