library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity RightShift1Bit is
  port( a : in std_logic_vector(31 downto 0);
        
        Shift_In : in std_logic;
        
        sel : in std_logic;
        
        q : out std_logic_vector(31 downto 0));  
end entity RightShift1Bit;

architecture Behavioural of RightShift1Bit is

signal b : std_logic_vector(31 downto 0);
begin

b(30 downto 0) <= a(31 downto 1);

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