
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

library LibElegans;
use LibElegans.ALL;

entity TB_InterruptTimer is

end TB_InterruptTimer;

architecture Testbench of TB_InterruptTimer is

signal Clock : std_logic := '0';
signal nReset : std_logic; -- Active Low

signal Interrupt : std_logic;


begin

Clock <= NOT(Clock) after 500 ns; -- Clock with 1Mhz Frequency, 50% Duty Cycle

nRESET <= '0', '1' after 1 us;

InterruptTimer1: entity LibElegans.InterruptTimer
  port map(Clock, nReset, Interrupt);

end architecture Testbench;


