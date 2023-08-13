library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use pna_config_pack.ALL;
use pna_pack.ALL;

entity pna_comp_configuration is
   generic(CONF_ADDRESS : integer := 0);
   port (
      clk    : in std_logic;
      rst_n   : in std_logic;
      address : in  std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
      wr      : in  std_logic;
      di      : in  std_logic_vector(31 downto 0);
      do      : out std_logic_vector(31 downto 0);
      config  : out std_logic_vector(127 downto 0));
end pna_comp_configuration;

architecture rtl of pna_comp_configuration is
   signal config_0   : std_logic_vector(31 downto 0);
   signal config_1   : std_logic_vector(31 downto 0);
   signal config_2   : std_logic_vector(31 downto 0);
   signal config_3   : std_logic_vector(31 downto 0);

   signal n_config_0   : std_logic_vector(31 downto 0);
   signal n_config_1   : std_logic_vector(31 downto 0);
   signal n_config_2   : std_logic_vector(31 downto 0);
   signal n_config_3   : std_logic_vector(31 downto 0);
begin

   config <= config_3 & config_2 & config_1 & config_0;

   i_conf_reg: process (clk, rst_n)
   begin
      if rst_n = '0' then
         config_0 <= (others => '0');
         config_1 <= (others => '0');
         config_2 <= (others => '0');
         config_3 <= (others => '0');
      elsif rising_edge(clk) then
         config_0 <= n_config_0;
         config_1 <= n_config_1;
         config_2 <= n_config_2;
         config_3 <= n_config_3;
      end if;
   end process i_conf_reg;

   i_conf_com: process(address, wr, di, config_0, config_1, config_2, config_3)
      variable confaddr_0 : std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
      variable confaddr_1 : std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
      variable confaddr_2 : std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
      variable confaddr_3 : std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
   begin
      confaddr_0 := std_logic_vector(to_unsigned(CONF_ADDRESS, CONF_ADDR_WIDTH));
      confaddr_1 := confaddr_0 + 1;
      confaddr_2 := confaddr_1 + 1;
      confaddr_3 := confaddr_2 + 1;

      n_config_0 <= config_0;
      n_config_1 <= config_1;
      n_config_2 <= config_2;
      n_config_3 <= config_3;


      if address(CONF_ADDR_WIDTH-1 downto 2) = CONF_ADDRESS(11 downto 2) then
         case address is
         when confaddr_0 =>
            do <= config_0;

            if wr = '1' then
               n_config_0 <= di;
            end if;

         when confaddr_1 =>
            do <= config_1;

            if wr = '1' then
               n_config_1 <= di;
            end if;

         when confaddr_2 =>
            do <= config_2;

            if wr = '1' then
               n_config_2 <= di;
            end if;

         when confaddr_3 =>
            do <= config_3;

            if wr = '1' then
               n_config_3 <= di;
            end if;

         when others =>
            do  <= (others => 'Z');
         end case;
      end if;
   end process i_conf_com;

end architecture rtl;