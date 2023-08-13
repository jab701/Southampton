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

library PNA_LibNeuron_com;

entity TB_PNA_System  is
 constant Address_Width : natural := 1;
 constant NumNeurons : std_logic_vector((address_width-1) downto 0):= "1";
end entity TB_PNA_System;

architecture Behavioural of TB_PNA_System is
signal clock   : std_logic := '0';
signal nreset  : std_logic;
     
signal Address  : std_logic_vector((address_width-1) downto 0);

signal Parameters : std_logic_vector(103 downto 0); 

signal Enable : std_logic;

signal SynSum : std_logic_vector(15 downto 0);

signal Axon : std_logic;

type ParametersArray is array ((to_integer(unsigned(NumNeurons))-1) downto 0) of std_logic_vector(103 downto 0);
signal ParametersROM : ParametersArray;

type SynArray is array ((to_integer(unsigned(NumNeurons))-1) downto 0) of std_logic_vector(15 downto 0);
signal SynSums : SynArray;

type BitArray is array ((to_integer(unsigned(NumNeurons))-1) downto 0) of std_logic;
signal Enables : BitArray;
signal Axons : BitArray;

signal Mem_we : std_logic;
begin

Clock <= NOT(Clock) after 5 ns;
nReset <= '0', '1' after 2 us;

process (Clock) is
begin
  if rising_edge(Clock) then
    Parameters <= ParametersROM(conv_integer(Address));
    SynSum <= SynSums(conv_integer(Address));
    Enable <= Enables(conv_integer(Address));
    if (Mem_we = '1') then
      Axons(conv_integer(Address)) <= Axon;
    end if;
  end if;    
end process;

-- Neuron Parameters
-- Neuron 1
-- Ex Threshold -- In Threshold -- AP Time -- Ref Time -- NBurst
ParametersROM(0)(15  downto  0) <= x"0001";
ParametersROM(0)(31  downto 16) <= x"FFFF";
ParametersROM(0)(63  downto 32) <= x"000003E8";
ParametersROM(0)(95  downto 64) <= x"000007D0";
ParametersROM(0)(103 downto 96) <= x"03";

-- Neuron 2
-- Ex Threshold -- In Threshold -- AP Time -- Ref Time -- NBurst
--ParametersROM(1)(15  downto  0) <= x"0001";
--ParametersROM(1)(31  downto 16) <= x"FFFF";
--ParametersROM(1)(63  downto 32) <= x"000003E8";
--ParametersROM(1)(95  downto 64) <= x"000007D0";
--ParametersROM(1)(103 downto 96) <= x"02";

-- Synaptic Weight Sums
SynSums(0) <= x"0000",
              x"0001" after 1 ms,
              x"0000" after 1.1 ms;
--SynSums(1) <= x"0000";

-- Neuron Enable Inputs
Enables(0) <= '1';
--Enables(1) <= '1';

PNA_System_1: entity work.PNA_System
              generic map(Address_Width => Address_Width)
              port map(clock => clock,
                       nReset => nReset,
                       Address_Out  => Address,                       
                       Mem_we1 => Mem_we,
                       Axon  => Axon,
                       Enable  => Enable,
                       SynSum  => SynSum,
                       Parameters => Parameters,
                       NumNeurons => NumNeurons); 


end architecture Behavioural;
