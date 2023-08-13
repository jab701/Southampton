library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pna_config_pack;

entity pna_comp_bus_input is
   generic(DATA_WIDTH : integer := 8);
   port (clk          : in  std_logic;
         rst_n         : in  std_logic;
         unit_addr    : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
         bus_addr     : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
         data_in      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
         data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0));
end pna_comp_bus_input;

architecture rtl of pna_comp_bus_input is
   signal data    : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal n_data  : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
   data_out <= data;

   p_reg: process (clk, rst_n)
   begin
      if rst_n = '0' then
         data <= (others => '0');
      elsif rising_edge(clk) then
         data <= n_data;
      end if;
   end process p_reg;

   p_com: process (data, data_in, unit_addr, bus_addr)
      variable ZERO : std_logic_vector(unit_addr'range);
   begin
      ZERO := (others => '0');

      if unit_addr = ZERO then
         n_data <= (others => '0');
      elsif unit_addr = bus_addr then
         n_data <= data_in;
      else
         n_data <= data;
      end if;
   end process p_com;
end architecture rtl;