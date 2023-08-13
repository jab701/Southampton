library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity zero_extend is
  generic( InputLength : natural := 16;
           OutputLength : natural := 32);
  port(a : in std_logic_vector(InputLength-1 downto 0);
       q : out std_logic_vector(OutputLength-1 downto 0));
end entity zero_extend;

architecture Behavioural of zero_extend is
begin
  
q(InputLength-1 downto 0) <= a;
q(OutputLength-1 downto InputLength) <= (others => '0');

end architecture Behavioural;