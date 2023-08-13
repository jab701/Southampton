library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity twos_comp_32b is
  port (a : in std_logic_vector(31 downto 0); 
        
        Convert : in std_logic;
        
        q : out std_logic_vector(31 downto 0));
end entity twos_comp_32b;

architecture Behavioural of twos_comp_32b is
  signal a_inv_mux : std_logic_vector(31 downto 0);
  signal a_inv_plusone : std_logic_vector(31 downto 0);
begin

process (a, Convert) is
begin
  if (Convert = '0') then
    a_inv_mux <= a;  
  else
    a_inv_mux <= NOT(a);  
  end if;
end process;  


AddOne: entity work.PlusOneAdder32b
  port map(a     => a_inv_mux,
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


