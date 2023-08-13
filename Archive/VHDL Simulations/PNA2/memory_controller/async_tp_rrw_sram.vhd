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

entity async_tp_rrw_sram  is
	generic 
	(
	   -- Module Specific Configuration Parameters
	   address_width : natural := 8;
	   data_width : natural := 32
	);
	port 
	(  signal rclock1    : in std_logic;
	   signal rd1        : in std_logic;
	   signal addr_read1 : in std_logic_vector((address_width-1) downto 0);
	   signal data_read1 : out std_logic_vector((data_width-1) downto 0);

	   signal rclock2    : in std_logic;
	   signal rd2        : in std_logic;
	   signal addr_read2 : in std_logic_vector((address_width-1) downto 0);
	   signal data_read2 : out std_logic_vector((data_width-1) downto 0);
	   	   
	   signal wclock     : in std_logic;
	   signal we         : in std_logic;
	   signal addr_write : in std_logic_vector((address_width-1) downto 0);	   
	   signal data_write : in std_logic_vector((data_width-1) downto 0)); 
end entity async_tp_rrw_sram;

architecture Behavioural of async_tp_rrw_sram is
  type ram_type is array (((2**address_width) - 1) downto 0) of std_logic_vector((data_width-1) downto 0);
  signal ram : ram_type;
begin

ram_rd1: process (rclock1) is
begin
  if rising_edge(rclock1) then
    if (rd1 = '1') then
      data_read1 <= ram(to_integer(unsigned(addr_read1)));
    else
      data_read1 <= (others => 'Z');
    end if;  
  end if;  
end process ram_rd1;

ram_rd2: process (rclock2) is
begin
  if rising_edge(rclock2) then
    if (rd2 = '1') then
      data_read2 <= ram(to_integer(unsigned(addr_read2)));
    else
      data_read2 <= (others => 'Z');
    end if;  
  end if;  
end process ram_rd2;

ram_wr: process (wclock) is
begin
  if rising_edge(wclock) then
    if (we = '1') then
      ram(to_integer(unsigned(addr_write))) <= data_write;
    end if;
  end if;  
end process ram_wr;
end architecture Behavioural;








