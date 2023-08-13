-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    26/02/2007 
-- Design Name: 
-- Module Name:    C Elegans Neuron Types
-- Project Name:   C Elegans Locomotion
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: Library - MBED_Claverol
--sim:/celegans_body
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

entity CElegansTestbench is

end CElegansTestbench;

architecture Behavioural of CElegansTestbench is

signal Clock : std_logic := '0';
signal ClockOut : std_logic;
Signal nRESET : std_logic; -- Active Low
signal NR_ON  : std_logic; -- Forward Low, Backward High
signal TS_ON  : std_logic; -- Forward Low, Backward High
signal COIL_ON :std_logic;

-- Nerve Ring Outputs
signal NRD  : std_logic;
signal NRV  : std_logic;
-- Class AV Outputs
signal AVA  : std_logic;
signal AVB  : std_logic;
-- Tail Section Outputs 
signal TSD  : std_logic;
signal TSV  : std_logic; 
-- Dorsal Motor Neuron Output
Signal MSCD0 : std_logic;
Signal MSCD1 : std_logic;
Signal MSCD2 : std_logic;
Signal MSCD3 : std_logic;
Signal MSCD4 : std_logic;
Signal MSCD5 : std_logic;
Signal MSCD6 : std_logic;
Signal MSCD7 : std_logic;
Signal MSCD8 : std_logic;
Signal MSCD9 : std_logic;
-- Ventral Motor Neuron Output
Signal MSCV0 : std_logic;
Signal MSCV1 : std_logic;
Signal MSCV2 : std_logic;
Signal MSCV3 : std_logic;
Signal MSCV4 : std_logic;
Signal MSCV5 : std_logic;
Signal MSCV6 : std_logic;
Signal MSCV7 : std_logic;
Signal MSCV8 : std_logic;
Signal MSCV9 : std_logic;

begin

Clock <= NOT(Clock) after 500 ns; -- Clock with 1Mhz Frequency, 50% Duty Cycle


    
nRESET <= '0', '1' after 1 us;
--NR_ON <= '1', '0' after 5000 ms, '1' after 14000 ms;
--TS_ON <= '0', '1' after 7000 ms, '0' after 12000 ms;
NR_ON <= '0';
TS_ON <= '0';
COIL_ON <= '1';

CElegans_Loco: entity LogicElegans.LogicCElegans
                      Port map(Clock, ClockOut, nRESET,NR_ON,TS_ON, COIL_ON,NRD,NRV,AVA,AVB,
                               MSCD0,MSCD1,MSCD2,MSCD3,MSCD4,MSCD5,MSCD6,MSCD7,MSCD8,
                               MSCD9,MSCV0,MSCV1,MSCV2,MSCV3,MSCV4,MSCV5,MSCV6,MSCV7,
                               MSCV8,MSCV9,TSD,TSV);
end architecture Behavioural;

