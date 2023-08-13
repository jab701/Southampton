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

entity dp_rw_sram  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	   address_width : natural := 8;
	   data_width : natural := 32
	);
	port 
	(
	   signal clock    : in std_logic;
	   signal we       : in std_logic;
	   signal rd       : in std_logic;
	   signal addr_read  : in  std_logic_vector((address_width-1) downto 0);
	   signal addr_write  : in  std_logic_vector((address_width-1) downto 0);	   
	   signal data_write  : in std_logic_vector((data_width-1) downto 0);
	   signal data_read : out std_logic_vector((data_width-1) downto 0)
	 ); 
end entity dp_rw_sram;

architecture Behavioural of dp_rw_sram is
  type ram_type is array (((2**address_width) - 1) downto 0) of std_logic_vector((data_width-1) downto 0);
  signal ram : ram_type;
begin

ram_1: process (clock) is
begin
    if rising_edge(clock) then
      if (we = '1') then
        ram(to_integer(unsigned(addr_write))) <= data_write;
      end if;
      
      if (rd = '1') then
        data_read <= ram(to_integer(unsigned(addr_read)));
      else
        data_read <= (others => 'Z');
      end if;
   
    end if;
end process ram_1;
end architecture Behavioural;




