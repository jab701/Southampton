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

entity SSRAM  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	   address_width : natural := 8;
	   data_width : natural := 32
	);
	port 
	(
	   signal clock    : in  std_logic;
	   signal we       : in  std_logic;
	   signal rd       : in  std_logic;
	   signal address  : in  std_logic_vector((address_width-1) downto 0);
	   signal data_in  : in std_logic_vector((data_width-1) downto 0);
	   signal data_out : out std_logic_vector((data_width-1) downto 0)
	 ); 
end entity SSRAM;

architecture Behavioural of SSRAM is
  type ram_type is array (((2**address_width) - 1) downto 0) of std_logic_vector((data_width-1) downto 0);
  signal ram : ram_type;
begin

ram_1: process (clock) is
begin
    if rising_edge(clock) then
      if (we = '1') then
        ram(to_integer(unsigned(address))) <= data_in;
      end if;
      
      if (rd = '1') then
        data_out <= ram(to_integer(unsigned(address)));
      else
        data_out <= (others => 'Z');
      end if;       
    end if;
end process ram_1;
end architecture Behavioural;


