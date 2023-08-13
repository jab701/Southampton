library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity FullAdder is
  port( a : in std_logic;
        b : in std_logic;

        cin    : in std_logic;

        q : out std_logic;
        g : out std_logic;
        p : out std_logic);
  
end entity FullAdder;

architecture Behavioural of FullAdder is

begin

ADDER: process (a, b, cin) is
  variable a_xor_b : std_logic;
begin
  a_xor_b := a xor b;
  p <= a_xor_b;
  g <= a and b;
  q <= a_xor_b xor cin;
  
end process ADDER;
  

  
end architecture Behavioural;