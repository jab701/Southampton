library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_comp_timer  is
generic
( RESOLUTION : natural := 32);
port(clk    : in std_logic;
     rst_n   : in std_logic;
     tick   : in std_logic;
     start    : in std_logic;
     period   : in std_logic_vector((RESOLUTION - 1) downto 0);
     finished : out std_logic);
end pna_comp_timer;

architecture rtl of pna_comp_timer is

   type STATES is (IDLE, RUNNING);

   signal state   : STATES;
   signal n_state : STATES;


   signal timer   : std_logic_vector((RESOLUTION - 1) downto 0);
   signal n_timer : std_logic_vector((RESOLUTION - 1) downto 0);

   signal lockedperiod   : std_logic_vector((RESOLUTION - 1) downto 0);
   signal n_lockedperiod : std_logic_vector((RESOLUTION - 1) downto 0);

   signal timerstate   : std_logic;
   signal n_timerstate : std_logic;

begin

p_timerseq: process(clk, rst_n) is
begin
   if (rst_n = '0') then
      timer  <= (others => '0');
      state  <= IDLE;
   elsif (clk'event and clk = '1') then
      timer  <= n_timer;
      state  <= n_state;
   end if;
end process p_timerseq;


p_timercom: process(tick, state, timer, start, period) is
   variable ZERO : std_logic_vector(RESOLUTION-1 downto 0);
begin
   ZERO := (others => '0');

   if tick = '1' then
      case state is
      when IDLE =>
         finished <= '0';
         n_timer  <= period;

         if start = '1' then
            n_state <= RUNNING;
         else
            n_state <= IDLE;
         end if;

      when RUNNING =>
         n_timer <= timer - 1;

         if timer = ZERO then
            finished <= '1';
            n_state  <= IDLE;
         else
            finished <= '0';
            n_state  <= RUNNING:
         end if;
      end case;
   else
      finished <= '0';
      n_timer  <= timer;
      n_state  <= state;
   end if;
end process p_timercom;

end architecture rtl;

