library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pna_config_pack.ALL;
use work.pna_sys_pack.ALL;

entity pna_sys_timer is
    port (signal clk   : in  std_logic;
          signal rst_n : in  std_logic;
          signal halt      : in std_logic;
          signal restart   : in std_logic;
          signal tick_1us  : out std_logic;
          signal tick_1ms  : out std_logic);
end pna_sys_timer;

architecture rtl of pna_sys_timer is

--{{ Components Section
--}}

--{{ Types Section
--}}

--{{ Constants Section
   constant TIMER_MAX : unsigned(SYS_TIMER_WIDTH-1 downto 0) := to_unsigned(SYS_TIMER_1US - 1, SYS_TIMER_WIDTH);
--}}

--{{ Signals Section
   signal timer   : std_logic_vector(SYS_TIMER_WIDTH-1 downto 0);
   signal n_timer : std_logic_vector(SYS_TIMER_WIDTH-1 downto 0);

   signal us_count   : std_logic_vector(9 downto 0);
   signal n_us_count : std_logic_vector(9 downto 0);

   signal tick_1us_l : std_logic;
--}}

begin
   -- Output Assignments
   tick_1us <= tick_1us_l;

   p_reg: process (clk, rst_n)
   begin
      if rst_n = '0' then
         timer    <= (others => '0';
         us_count <= (others => '0');
      elsif rising_edge(clk) then
         timer    <= n_timer;
         us_count <= n_us_count;
      end if;
   end process p_reg;

   p_uscom: process(timer, halt, restart)
      variable ONE_K : std_logic_vector(9 downto 0);
   begin
      ONE_K := std_logic_vector(to_unsigned(1000-1, 10));

      if halt = '1' then
         n_timer <= timer;
         tick_1us_l <= '0';
      elsif restart = '1' then
         n_timer <= (others => '0');
         tick_1us_l <= '0';
      elsif timer = TIMER_MAX then
         n_timer <= (others => '0');
         tick_1us_l <= '1';
      else
         n_timer <= timer + 1;
         tick_1us_l <= '0';
      end if;
   end process p_uscom;

   p_mscom: process(us_count, tick_1us_l, restart)
   begin
      if restart = '1' then
         tick_1ms <= '0';
         n_us_count <= (others => '0');
      elsif tick_1us_l = '1' then
         if us_count = ONE_K then
            tick_1ms <= '1';
            n_us_count <= (others => '0');
         else
            tick_1ms <= '0';
            n_us_count <= us_count + 1;
         end if;
      else
         tick_1ms <= '0';
         n_us_count <= us_count;
      end if;
   end process p_mscom;

end architecture rtl;
