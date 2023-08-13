library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity twos_comp_64b is
  port (a : in std_logic_vector(63 downto 0); 
        
        Convert : in std_logic;
        
        q : out std_logic_vector(63 downto 0));
end entity twos_comp_64b;

architecture Behavioural of twos_comp_64b is
  signal a_inv : std_logic_vector(63 downto 0);
  signal a_inv_plusone : std_logic_vector(63 downto 0);
begin

a_inv <= NOT(a);  


AddOne: entity work.PlusOneAdder64b
  port map(a     => a_inv,
           q     => a_inv_plusone);

process (a,Convert,a_inv_plusone) is
begin
  if (Convert = '0') then
    q <= a;    
  else
    q <= a_inv_plusone;    
  end if;
end process; 


end architecture Behavioural;

