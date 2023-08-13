library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package NETWORKDEFS is
---------------- PACKET FORMAT ----------------
-- ALL SIZES ARE IN BITS
--
--  TYPE |  ADDRESS |  DATA
--   8   |    16    |   32
-----------------------------------------------
constant TYPE_AP     : std_logic_vector(7 downto 0) := x"00";
constant TYPE_SYN    : std_logic_vector(7 downto 0) := x"01";
constant TYPE_EN     : std_logic_vector(7 downto 0) := x"02";
constant TYPE_PROG0  : std_logic_vector(7 downto 0) := x"F0";
constant TYPE_PROG1  : std_logic_vector(7 downto 0) := x"F1";
constant TYPE_PROG2  : std_logic_vector(7 downto 0) := x"F2";
constant TYPE_PROG3  : std_logic_vector(7 downto 0) := x"F3";
constant TYPE_PROG4  : std_logic_vector(7 downto 0) := x"F4";
constant TYPE_PROG5  : std_logic_vector(7 downto 0) := x"F5";
constant TYPE_PROG6  : std_logic_vector(7 downto 0) := x"F6";
constant TYPE_PROG7  : std_logic_vector(7 downto 0) := x"F7";
constant TYPE_PROG8  : std_logic_vector(7 downto 0) := x"F8";
constant TYPE_PROG9  : std_logic_vector(7 downto 0) := x"F9";
constant TYPE_PROG10 : std_logic_vector(7 downto 0) := x"FA";
constant TYPE_PROG11 : std_logic_vector(7 downto 0) := x"FB";
constant TYPE_PROG12 : std_logic_vector(7 downto 0) := x"FC";
constant TYPE_PROG13 : std_logic_vector(7 downto 0) := x"FD";
constant TYPE_PROG14 : std_logic_vector(7 downto 0) := x"FE";
constant TYPE_PROG15 : std_logic_vector(7 downto 0) := x"FF";
  
end package NETWORKDEFS;

