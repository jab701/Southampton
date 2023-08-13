library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity HalfAdder is
  port( a : in std_logic;
        b : in std_logic;

        q : out std_logic;
        g : out std_logic;
        p : out std_logic);
  
end entity HalfAdder;

architecture Behavioural of HalfAdder is

begin

HALFADDER: process (a, b) is
begin
  p <= a;
  g <= a and b;
  q <= a xor b;
  
end process HALFADDER;
  

  
end architecture Behavioural;
