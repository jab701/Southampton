library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder32b is
  port( a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        
        sub : in std_logic;

        q : out std_logic_vector(31 downto 0);
        carry_out : out std_logic);
  
end entity Adder32b;

architecture Behavioural of Adder32b is

signal carry : std_logic_vector(31 downto 0);
signal SuperGroup1Carry : std_logic;
signal g : std_logic_vector(31 downto 0);
signal p : std_logic_vector(31 downto 0);

signal mux_b : std_logic_vector(31 downto 0);

begin

process (b, sub) is
begin
  if (sub = '0') then
    mux_b <= b;
  else
    mux_b <= NOT(b);
  end if;    
end process;
  
FADD_GEN : for n in 0 to 31 generate

FADD: entity work.FullAdder
     port map(a => a(n),
              b => mux_b(n),
              cin => carry(n),
              q => q(n),
              g => g(n),
              p => p(n));
end generate FADD_GEN;
              
CarryLookAhead1_15: entity work.CarryLookAhead_16b
                    port map(c_in => sub,
                             p => p(15 downto 0),
                             g => g(15 downto 0),
                             c_out => carry(15 downto 0),
                             SuperGroup_c => SuperGroup1Carry); 
                             
CarryLookAhead16_31: entity work.CarryLookAhead_16b
                    port map(c_in => SuperGroup1Carry,
                             p => p(31 downto 16),
                             g => g(31 downto 16),
                             c_out => carry(31 downto 16),
                             SuperGroup_c => carry_out);                                           
end architecture Behavioural;
