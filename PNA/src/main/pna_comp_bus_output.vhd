library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pna_config_pack;

entity pna_comp_bus_output is
   generic(DATA_WIDTH : integer := 8);
   port (unit_addr    : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
         bus_addr     : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
         data_in      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
         data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0));
end pna_comp_bus_output;

architecture rtl of pna_comp_bus_output is
begin
   p_com: process (data_in, unit_addr, bus_addr)
      variable ZERO : std_logic_vector(unit_addr'range);
   begin
      ZERO := (others => '0');

      if unit_addr = bus_addr AND unit addr /= ZERO then
         data_out <= data_in;
      else
         data_out <= (others => 'Z');
      end if;
   end process p_com;
end architecture rtl;