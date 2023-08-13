library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity LeftShiftReversal is
  port( a : in std_logic_vector(31 downto 0);
                
        sel : in std_logic;
        
        q : out std_logic_vector(31 downto 0));  
end entity LeftShiftReversal;

architecture Behavioural of LeftShiftReversal is

signal Reversed : std_logic_vector(31 downto 0);

begin
  
process (a) is
begin
  for i in 0 to 31 loop
    Reversed(i) <= a(31-i); 
  end loop;    
end process;
  
process (a,Reversed,sel) is
begin
  if (sel = '0') then
    q <= a;
  else
    q <= Reversed;
  end if;    
end process;
  
end architecture Behavioural;
