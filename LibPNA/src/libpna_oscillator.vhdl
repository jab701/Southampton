library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity libpna_oscillator is
    generic (RESOLUTION : natural := 32);
    port (-- Global Input Signals
          signal clk           : in std_logic;
          signal cke           : in std_logic;
          signal rstn          : in std_logic;
          signal phaseoffseten : in std_logic;
          -- Module Specific Parameters
          signal period        : in std_logic_vector((RESOLUTION - 1) downto 0);
          signal phase         : in std_logic_vector((RESOLUTION - 1) downto 0);
          -- Module Specific Output Signals
          signal oscout        : out std_logic
          );
end entity libpna_oscillator;

architecture rtl of libpna_oscillator is

-- COMPONENT DEFINITIONS
   component libpna_timer
   generic
   (   -- Module Specific Configuration Parameters
      RESOLUTION : natural);
   port
   (   -- Global Input Signals
      signal clk    : in std_logic;
      signal cke      : in std_logic;
      signal rstn   : in std_logic;
      -- Module Specific Input Signals
      signal start    : in std_logic;
      -- Module Specific Parameters
      signal period   : in std_logic_vector((RESOLUTION - 1) downto 0);
      -- Module Specific Output Signals
      signal finished : out std_logic);
   end libpna_timer;

-- TYPE DEFINITIONS
   type STATES is (STATE_RST, STATE_PHASE, STATE_ON, STATE_OFF);

-- SIGNAL DEFINITIONS
   -- State Machine Signals
   signal state_d : STATES;
   signal state_q : STATES;

   -- Timer Signals
   signal timerstart : std_logic;
   signal timerfinish : std_logic;
   signal timerperiod : std_logic_vector((RESOLUTION - 1) downto 0);
begin

i_timer: libpna_timer(rtl)
   generic map (RESOLUTION => RESOLUTION)
   port map(clk      => clk,
            cke      => cke,
            rstn     => rstn,
            start    => timerstart,
            period   => timerperiod,
            finished => timerfinish);

p_seq: process (clk, rstn) is
begin
   if (rstn = '0') then
      state_q <= STATE_RST;
   elsif (clk'event and ckl = '1') then
      if (cke = '1') then
         state_q <= state_d;
      end if;
   end if
end process p_seq;

p_com: process (state_q, phaseoffseten, period, phase) is
begin

   case state_q is
   when STATE_RST =>
      oscout <= '0';
      timerstart <= '1';

      if (phaseoffseten = '1') then
         timerperiod <= phase;
         state_d <= STATE_PHASE;
      else
         timerperiod <= period;
         state_d <= STATE_ON;
      end if;

   when STATE_PHASE =>
      oscout <= '0';
      timerstart <= '0';
      timerperiod <= period;

      if (timerfinish = '1') then
         state_d <= STATE_ON;
      else
         state_d <= STATE_PHASE;
      end if;

   when STATE_ON =>
      oscout <= '1';
      timerstart <= '1';
      timerperiod <= period;
      state_d <= STATE_OFF;

   when STATE_OFF =>
      oscout <= '0';
      timerstart <= '0';
      timerperiod <= period;

      if (timerfinish = '1') then
         state_d <= STATE_ON;
      else
         state_d <= STATE_OFF;
      end if;
   end case;
end process p_com;

end architecture rtl;


