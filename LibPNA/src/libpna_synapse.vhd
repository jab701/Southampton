----------------------------------------------------------------------------------
-- Company:    ESD Group, School of Electronics, University Of Southampton
-- Engineer:   Julian A Bailey - PhD Research Student
--
-- Create Date:    14:14:51 01/17/2007
-- Design Name:
-- Module Name:    Synapse Block - Behavioral
-- Project Name:   MBED VHDL
-- Target Devices:
-- Tool versions:  ModelSim SE 6.2E
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library libpna;
use libpna.ALL;

entity libpna_synapse is
    generic(TIMERESOLUTION : natural := 32;
            SYNRESOLUTION  : natural := 16);
   port (-- Input Signals
         signal clk    : in std_logic;
         signal cke    : in std_logic;
         signal rstn   : in std_logic;
         -- Input Signals
         signal axon      : in std_logic;  -- Alpha Channel -- Pre-Syn Axon
         -- Configuration Signals
         signal delay       : std_logic_vector((TIMERESOLUTION - 1) downto 0);
         signal duration    : std_logic_vector((TIMERESOLUTION - 1) downto 0);
         signal synweight_i : std_logic_vector(SYNRESOLUTION-1 downto 0);
         -- Output Signals
         signal idlen       : out std_logic;
         signal synweight_o : out std_logic_vector(SYNRESOLUTION-1 downto 0));     -- Synapse Weight -- Gamma Channel
end libpna_synapse;

architecture rtl of libpna_synapse is

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
   type STATES is (STATE_IDLE, STATE_DELAY, STATE_ACTIVE);

-- SIGNAL DEFINITIONS
   -- State Machine Signals
   signal state_d : STATES;
   signal state_q : STATES;

   -- Axon Edge Detect Signals
   signal axon_sample : std_logic;

   -- Timer Signals
   signal timerstart : std_logic;
   signal timerfinish : std_logic;
   signal timerperiod : std_logic_vector((TIMERESOLUTION - 1) downto 0);


begin

i_timer: libpna_timer(rtl)
   generic map (RESOLUTION => TIMERESOLUTION)
   port map(clk      => clk,
            cke      => cke,
            rstn     => rstn,
            start    => timerstart,
            period   => timerperiod,
            finished => timerfinish);

p_seq: process (clk, rstn) is
begin
   if (rstn = '0') then
      axon_sample <= '0';
      state_q <= STATE_IDLE;
   elsif (clk'event AND clk = '1') then
      axon_sample <= axon;
      state_q <= state_d;
   end if;
end process p_seq;

p_com: process(state_q, delay, duration, synweight_i, axon, axon_sample, timerfinish) is
begin
   case state_q is
   when STATE_IDLE =>
      idlen <= '0';
      timerperiod <= delay;
      synweight_o <= (others => '0');

      if ((axon = '1') and (axon_sample = '0')) then
         timerstart <= '1';
         state_d <= STATE_DELAY;
      else
         timerstart <= '0';
         state_d <= STATE_IDLE;
      end if

   when STATE_DELAY =>
      idlen <= '1';
      timerperiod <= duration;
      synweight_o <= (others => '0');

      if (timerfinished = '1') then
         timerstart = '1';
         state_d <= STATE_DURATION;
      else
         timerstart <= '0';
         state_d <= STATE_DELAY;
      end if;

   when STATE_ACTIVE =>
      idlen <= '1';
      timerperiod <= delay;
      synweight_o <= synweight_i;
      timerstart <= '0';

      if (timerfinished = '1') then
         state_d <= STATE_IDLE;
      else
         state_d <= STATE_DURATION;
      end if;
   end case;
end process p_com;

end architecture rtl;

