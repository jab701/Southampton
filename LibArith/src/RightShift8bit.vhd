library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RightShift8Bit is
  port( a : in std_logic_vector(31 downto 0);
        
        Shift_In : in std_logic;
        
        sel : in std_logic;
        
        q : out std_logic_vector(31 downto 0));  
end entity RightShift8Bit;

architecture Behavioural of RightShift8Bit is

signal b : std_logic_vector(31 downto 0);
begin

b(23 downto 0) <= a(31 downto 8);

b(24) <= Shift_In;
b(25) <= Shift_In;
b(26) <= Shift_In;
b(27) <= Shift_In;
b(28) <= Shift_In;
b(29) <= Shift_In;
b(30) <= Shift_In;
b(31) <= Shift_In; 

process(a,b,sel) is
begin
  if (sel = '0') then
    q <= a;
  else
    q <= b;
  end if;    
end process;
  
end architecture Behavioural;

