
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PlusOneAdder32b is
  port( a : in std_logic_vector(31 downto 0);
        q : out std_logic_vector(31 downto 0));
  
end entity PlusOneAdder32b;

architecture Behavioural of PlusOneAdder32b is

signal carry : std_logic_vector(31 downto 0);
signal SuperGroup1Carry : std_logic;
signal g : std_logic_vector(31 downto 0);
signal p : std_logic_vector(31 downto 0);

begin
  
HADD_GEN : for n in 0 to 31 generate

HADD: entity work.HalfAdder
     port map(a => a(n),
              b => carry(n),
              q => q(n),
              g => g(n),
              p => p(n));
end generate HADD_GEN;
              
CarryLookAhead1_15: entity work.CarryLookAhead_16b
                    port map(c_in => '1',
                             p => p(15 downto 0),
                             g => g(15 downto 0),
                             c_out => carry(15 downto 0),
                             SuperGroup_c => SuperGroup1Carry); 
                             
CarryLookAhead16_31: entity work.CarryLookAhead_16b
                    port map(c_in => SuperGroup1Carry,
                             p => p(31 downto 16),
                             g => g(31 downto 16),
                             c_out => carry(31 downto 16),
                             SuperGroup_c => open);                                           
end architecture Behavioural;
