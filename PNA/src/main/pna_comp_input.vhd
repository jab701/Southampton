library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use pna_config_pack.ALL;
use pna_pack.ALL;

entity pna_comp_input is
   generic(CONFIG_ADDR : integer := 0);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        --
        config_addr     : in  std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
        config_wr       : in  std_logic;
        config_di       : in  std_logic_vector(31 downto 0);
        config_do       : out std_logic_vector(31 downto 0);
        --
        sys_addr        : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
        sys_data_out    : out std_logic_vector(0 downto 0));
end pna_comp_input;

architecture rtl of pna_comp_input is

-- SIGNAL DEFINITIONS
   signal data   : std_logic_vector((2**SYS_ADDR_WIDTH)-1 downto 0);
   signal n_data : std_logic_vector((2**SYS_ADDR_WIDTH)-1 downto 0);
begin
   p_reg: process (clk, rst_n)
   begin
      if rst_n = '0' then
         data <= (others => '0');
      elsif rising_edge(clk) then
         data <= n_data;
      end if;
   end process p_reg;

   p_com: process (data, conf_addr, config_wr, config_di)
      variable num_loops : integer;
      variable base_addr : std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
   begin
      num_loops := ((2**SYS_ADDR_WIDTH)/32) - 1;
      base_addr := std_logic_vector(to_unsigned(CONFIG_ADDR,CONF_ADDR_WIDTH));

      -- Default Assignments
      n_data    <= data;
      config_do <= (others => 'Z');

      loop1: for i in 0 to num_loops loop
         if conf_addr = (base_addr + i) then
            config_do <= data((i*32) + 31 downto (i*32));

            if config_wr = '1' then
               n_data((i*32) + 31 downto (i*32)) <= config_di;
            end if;
         end if;
      end loop loop1;

      n_data(0) <= '0'; -- Data bit 0 is always zero!
   end process p_com;

    p_output: process(sys_addr, data)
       variable addr_i : integer range 0 to (2**SYS_ADDR_WIDTH)-1;
    begin
       addr_i := to_integer(unsigned(sys_addr));

       if addr_i = 0 then
          sys_data_out(0) <= '0';
       else
          sys_data_out(0) <= data(addr_i);
       end if;
    end process p_output;
end architecture rtl;

