----------------------------------------------------------------------------------
-- Company:    ESD Group, School of Electronics, University Of Southampton
-- Engineer:   Julian A Bailey - PhD Research Student
--
-- Create Date:    14:14:51 01/17/2007
-- Design Name:
-- Module Name:    Counter - Behavioral
-- Project Name:   MBED VHDL
-- Target Devices:
-- Tool versions:  ModelSim SE 6.2E
-- Description:
--
-- Dependencies:   EdgeDetector.vhd
--
-- Revision:
-- Revision H:/VHDL Simulations/Synth-VHDL/Counter.vhd1.10 -
--   File Modified  - 27/07/2007 - JAB05R
--   File Validated - 27/07/2007 - JAB05R
--
-- Additional Comments: Revision 1.00 - Synthesizable VHDL
--                      Revision 1.10 - Corrected Registered Signals
--                      Validated Using TestBench-Counter.vhd
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity libpna_timer  is
generic
(   -- Module Specific Configuration Parameters
   RESOLUTION : natural := 32);
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

architecture rtl of libpna_timer is
   signal start_sample : std_logic;

   signal timer_d : std_logic_vector((RESOLUTION - 1) downto 0);
   signal timer_q : std_logic_vector((RESOLUTION - 1) downto 0);

   signal lockedperiod_d : std_logic_vector((RESOLUTION - 1) downto 0);
   signal lockedperiod_q : std_logic_vector((RESOLUTION - 1) downto 0);

   signal timerstate_d : std_logic;
   signal timerstate_q : std_logic;

begin

p_timerseq: process(clk, rstn) is
begin
   if (rstn = '0') then
      start_sample   <= '0';
      timer_q        <= (others => '0');
      lockedperiod_q <= (others => '0');
      timerstate_q   <= '0';
   elsif (clk'event and clk = '1') then
      if (cke = '1') then
         start_sample   <= start;
         timer_q        <= timer_d;
         lockedperiod_q <= lockedperiod_d;
         timerstate_q   <= timerstate_d;
      end if;
   end if;
end process p_timerseq;


p_timercom: process(start, period, start_sample, timer_q, lockedperiod_q, timerstate_q) is

begin
   -- Timer is running
   if (timerstate_q = '1') then
      timer_d        <= timer_q + 1;
      lockedperiod_d <= lockedperiod_q;

      -- The counter has reached the target value
      if (timer_q = lockedperiod_q) then
         timerstate_d   <= '0';
         finished       <= '1';
      -- The counter has not reached the target value
      else
         timerstate_d   <= '1';
         finished       <= '0';
      end if;
   -- Timer is not running
   else
      timer_d        <= (others => '0');
      lockedperiod_d <= period;
      finished       <= '0';

      -- There a rising edge on start
      if ((start = '1') and (start_sample = '0')) then
         timerstate_d   <= '1';
      -- No rising edge and timer is not running
      else
         timerstate_d   <= '0';
      end if;
   end if;
end process p_timercom;

end architecture rtl;

