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

entity LogicElegansUnit is
    port (
          signal Clock  : in  std_logic;
          signal nReset : in  std_logic;
          
          signal D_FWD  : in  std_logic;
          signal V_FWD  : in  std_logic;
          
          signal AVB    : in  std_logic;
          signal AVA    : in  std_logic;
          
          signal D_BWD  : in  std_logic;
          signal V_BWD  : in  std_logic;
          
          signal D_OUT  : out std_logic;
          signal V_OUT  : out std_logic
          ); 
end LogicElegansUnit;


architecture HeadEnd of LogicElegansUnit is

signal D_Q : std_logic;
signal D_D : std_logic;
signal V_Q : std_logic;
signal V_D : std_logic;

signal D_BWD_AND_AVA : std_logic;
signal V_BWD_AND_AVA : std_logic;

signal SET_D_SRL : std_logic;
signal SET_V_SRL : std_logic;

begin
DSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_D_SRL, V_D, D_D, D_Q);
VSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_V_SRL, D_D, V_D, V_Q);
          
D_BWD_AND_AVA <= D_BWD and AVA;
V_BWD_AND_AVA <= V_BWD and AVA;

SET_D_SRL <= D_FWD or D_BWD_AND_AVA;
SET_V_SRL <= V_FWD or V_BWD_AND_AVA;          
          

D_OUT <= D_Q;
V_OUT <= V_Q;

end architecture HeadEnd;

architecture TailEnd of LogicElegansUnit is

signal D_Q : std_logic;
signal D_D : std_logic;
signal V_Q : std_logic;
signal V_D : std_logic;

signal D_FWD_AND_AVB : std_logic;
signal V_FWD_AND_AVB : std_logic;

signal SET_D_SRL : std_logic;
signal SET_V_SRL : std_logic;

begin
DSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_D_SRL, V_D, D_D, D_Q);
VSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_V_SRL, D_D, V_D, V_Q);
          
D_FWD_AND_AVB <= D_FWD and AVB;
V_FWD_AND_AVB <= V_FWD and AVB;

SET_D_SRL <= D_FWD_AND_AVB or D_BWD;
SET_V_SRL <= V_FWD_AND_AVB or V_BWD;          
          

D_OUT <= D_Q;
V_OUT <= V_Q;

            
end architecture TailEnd;


architecture Default of LogicElegansUnit is

signal D_Q : std_logic;
signal D_D : std_logic;
signal V_Q : std_logic;
signal V_D : std_logic;

signal D_FWD_AND_AVB : std_logic;
signal V_FWD_AND_AVB : std_logic;

signal D_BWD_AND_AVA : std_logic;
signal V_BWD_AND_AVA : std_logic;

signal SET_D_SRL : std_logic;
signal SET_V_SRL : std_logic;

begin
DSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_D_SRL, V_D, D_D, D_Q);
VSRLatch: entity LogicElegans.SRLatch(Behavioural)
          port map(Clock, nReset, SET_V_SRL, D_D, V_D, V_Q);
          
D_FWD_AND_AVB <= D_FWD and AVB;
V_FWD_AND_AVB <= V_FWD and AVB;

D_BWD_AND_AVA <= D_BWD and AVA;
V_BWD_AND_AVA <= V_BWD and AVA;

SET_D_SRL <= D_FWD_AND_AVB or D_BWD_AND_AVA;
SET_V_SRL <= V_FWD_AND_AVB or V_BWD_AND_AVA;          
          

D_OUT <= D_Q;
V_OUT <= V_Q;

           
end architecture Default;

