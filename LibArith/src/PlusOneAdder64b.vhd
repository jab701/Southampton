library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PlusOneAdder64b is
  port( a     : in std_logic_vector(63 downto 0);
        
        q     : out std_logic_vector(63 downto 0));
  
end entity PlusOneAdder64b;

architecture Behavioural of PlusOneAdder64b is

signal carry : std_logic_vector(63 downto 0);

signal g : std_logic_vector(63 downto 0);
signal p : std_logic_vector(63 downto 0);

signal SuperGroup1Carry : std_logic;
signal SuperGroup2Carry : std_logic;
signal SuperGroup3Carry : std_logic;

begin
  
HADD_GEN : for n in 0 to 63 generate

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
                             SuperGroup_c => SuperGroup2Carry); 

                             
CarryLookAhead32_47: entity work.CarryLookAhead_16b
                    port map(c_in => SuperGroup2Carry,
                             p => p(47 downto 32),
                             g => g(47 downto 32),
                             c_out => carry(47 downto 32),
                             SuperGroup_c => SuperGroup3Carry); 
                             
CarryLookAhead48_63: entity work.CarryLookAhead_16b
                    port map(c_in => SuperGroup3Carry,
                             p => p(63 downto 48),
                             g => g(63 downto 48),
                             c_out => carry(63 downto 48),
                             SuperGroup_c => open);                                                                       
end architecture Behavioural;

