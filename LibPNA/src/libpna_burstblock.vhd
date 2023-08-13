----------------------------------------------------------------------------------
-- Company:    ESD Group, School of Electronics, University Of Southampton
-- Engineer:   Julian A Bailey - PhD Research Student
--
-- Create Date:    14:14:51 01/17/2007
-- Design Name:
-- Module Name:    Burst Block - Behavioral
-- Project Name:   MBED VHDL
-- Target Devices:
-- Tool versions:  ModelSim SE 6.2K
--
-- Description:
--
-- Dependencies:   Counter.vhd
--
-- Revision 2.00 -
--   File Modified  - 12/07/2007 - JAB05R
--   File Validated - 12/07/2007 - JAB05R
--
-- Additional Comments: Revision 1.0 - Behavioural VHDL   (JAB05R)
--                      Revision 2.0 - Synthesizable VHDL (JAB05R)
--                      Validated Using TestBench-Burst.vhd (JAB05R)
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity libpna_burstblock  is
    generic(RESOLUTION       : natural := 32);
    port (signal clk         : in  std_logic;
          signal cke         : in  std_logic;
          signal rstn        : in  std_logic;
          signal abvthlde    : in  std_logic;
          signal belthldi    : in  std_logic;
          signal oscin       : in  std_logic;
          signal burstlength : in  std_logic_vector(7 downto 0);
          signal aptime      : in  std_logic_vector((RESOLUTION - 1) downto 0);
          signal reftime     : in  std_logic_vector((RESOLUTION - 1) downto 0);
          signal axon        : out std_logic);
end libpna_burstblock;

architecture rtl of libpna_burstblock is

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
   type STATES is (STATE_OFF, STATE_ON, STATE_DEC, STATE_REF);

-- CONSTANTS
   signal ZERO   : signed(7 downto 0) := (others => '0');
   signal MINUS1 : signed(7 downto 0) := (others => '1');

-- SIGNAL DEFINITIONS
   -- State Machine Signals
   signal state_d : STATES;
   signal state_q : STATES;

   -- Burst Signals
   signal burstcount_d : signed(7 downto 0);
   signal burstcount_q : signed(7 downto 0);

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

p_seq: process(clk, rstn) is
begin
   if (rstn = '0') then
      state_q <= STATE_OFF;
      burstcount_q <= (others => '0');
   elsif (clk'event and ckl = '1') then
      if (cke = '1') then
         state_q <= state_d;
         burstcount_q <= burstcount_d;
      end if;
   end if
end process p_seq;

p_com: process(abvthlde, belthldi, oscin, aptime, reftime, timerfinish, state_q, burstcount_q) is

begin
   burstcount_d <= burstcount_q;

   case state_q is
   when STATE_OFF =>
      axon <= '0';

      timerperiod <= aptime - 1;

      burstcount_d <= burstlength;

      if (abvthlde = '1') then
         state_d <= STATE_ON;
         timerstart <= '1';
      elsif (oscin = '1') then
         state_d <= STATE_ON;
         timerstart <= '1';
      else
         state_d <= STATE_OFF;
         timerstart <= '0';
      end if;

   when STATE_ON =>
      axon <= '1';

      timerstart  <= '0';
      timerperiod <= reftime - 1;

      if (timerfinished = '1') then
         state_d <= STATE_DEC;
      else
         state_d <= STATE_ON;
      end if;

      if (belthldi = '1') then
         burstcount_d <= ZERO;
      else
         burstcount_d <= burstcount_q;
      end if;

   when STATE_DEC =>
      axon <= '0';

      timerstart  <= '1';
      timerperiod <= reftime - 1;

      if (belthldi = '1') then
         burstcount_d <= ZERO;
      elsif (burstcount_q = MINUS1) then
         burstcount_d <= burstcount_q;
      else
         burstcount_d <= burstcount_q - 1;
      end if;

      state_d <= STATE_REF;

   when STATE_REF =>
      axon <= '0';

      timerperiod <= aptime - 1;

      if (belinthld = '1') then
         burstcount_d <= ZERO;
      else
         burstcount_d <= burstcount_q;
      end if;

      if (timerfinished = '1') then
         if (burstcount_q = ZERO) then
            state_d <= STATE_OFF;
            timerstart <= '0';
         else
            state_d <= STATE_ON;
            timerstart <= '1';
         end if;
      else
         state_d <= STATE_REF;
         timerstart <= '0';
      end if;
   end case;

end process p_com;
end architecture rtl;



