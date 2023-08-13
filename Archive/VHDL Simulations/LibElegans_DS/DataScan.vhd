----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    C Elegans Locomotion Circuit
-- Project Name:   
-- Target Devices: 
-- Tool versions:  ModelSim SE 6.2F
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

library LibNeuron;
use LibNeuron.ALL;
use LibNeuron.TYPEDEFINITIONS.ALL;

library LibElegans;
use LibElegans.ALL;

entity DataScan is
    generic (Length : natural := 8);
    port (-- Control Signals
          signal Clock  : in  std_logic;
          signal CE : in std_logic;
                  
          signal Data_In : in std_logic_vector((Length - 1) downto 0);
          signal Data_Out : out std_logic_vector((Length - 1) downto 0)       
          );
end DataScan;

architecture Behavioural of DataScan is
begin
  
DataMux: process (Clock) is
begin
  if rising_edge(Clock) then
    if (CE = '1') then
      Data_Out <= Data_In;  
    end if;
  end if;
end process DataMux;



end architecture Behavioural;
