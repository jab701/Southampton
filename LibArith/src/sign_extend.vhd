library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity sign_extend is
  generic( InputLength : natural := 16;
           OutputLength : natural := 32);
  port(a : in std_logic_vector(InputLength-1 downto 0);
       q : out std_logic_vector(OutputLength-1 downto 0));
end entity sign_extend;

architecture Behavioural of sign_extend is
begin
  


process (a) is
begin
  for i in InputLength to OutputLength-1 loop
    q(i) <= a(InputLength-1); 
  end loop;
  q(InputLength-1 downto 0) <= a;
end process;

end architecture Behavioural;
