library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_comp_oscillator is
    generic (RESOLUTION : natural := 32);
    port (-- Global Input Signals
          clk           : in std_logic;
          rst_n          : in std_logic;
          tick          : in std_logic;
          phaseoffseten : in std_logic;
          -- Module Specific Parameters
          period        : in std_logic_vector((RESOLUTION - 1) downto 0);
          phase         : in std_logic_vector((RESOLUTION - 1) downto 0);
          -- Module Specific Output Signals
          oscout        : out std_logic
          );
end entity pna_comp_oscillator;

architecture rtl of pna_comp_oscillator is

-- COMPONENT DEFINITIONS
   component pna_comp_timer
   generic( RESOLUTION : natural);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        tick   : in std_logic;
        start    : in std_logic;
        period   : in std_logic_vector((RESOLUTION - 1) downto 0);
        finished : out std_logic);
   end pna_comp_timer;

-- TYPE DEFINITIONS
   type STATES is (STATE_RST, STATE_PHASE, STATE_ON, STATE_OFF);

-- SIGNAL DEFINITIONS
   -- State Machine Signals
   signal state   : STATES;
   signal n_state : STATES;

   -- Timer Signals
   signal timerstart : std_logic;
   signal timerfinish : std_logic;
   signal timerperiod : std_logic_vector((RESOLUTION - 1) downto 0);
begin

i_timer: pna_comp_timer(rtl)
   generic map (RESOLUTION => RESOLUTION)
   port map(clk      => clk,
            rst_n     => rst_n,
            tick     => tick,
            start    => timerstart,
            period   => timerperiod,
            finished => timerfinish);

p_seq: process (clk, rst_n) is
begin
   if (rst_n = '0') then
      state <= STATE_RST;
   elsif (clk'event and ckl = '1') then
      state <= n_state;
   end if
end process p_seq;

p_com: process (state, phaseoffseten, period, phase) is
begin

   case state is
   when STATE_RST =>
      oscout <= '0';
      timerstart <= '1';

      if (phaseoffseten = '1') then
         timerperiod <= phase;
         n_state <= STATE_PHASE;
      else
         timerperiod <= period;
         n_state <= STATE_ON;
      end if;

   when STATE_PHASE =>
      oscout <= '0';
      timerstart <= '0';
      timerperiod <= period;

      if (timerfinish = '1') then
         n_state <= STATE_ON;
      else
         n_state <= STATE_PHASE;
      end if;

   when STATE_ON =>
      oscout <= '1';
      timerstart <= '1';
      timerperiod <= period;
      n_state <= STATE_OFF;

   when STATE_OFF =>
      oscout <= '0';
      timerstart <= '0';
      timerperiod <= period;

      if (timerfinish = '1') then
         n_state <= STATE_ON;
      else
         n_state <= STATE_OFF;
      end if;
   end case;
end process p_com;

end architecture rtl;


