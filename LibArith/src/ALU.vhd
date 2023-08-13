library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity ALU is
  port( a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        
        ctrl : in std_logic_vector(2 downto 0);

        q : out std_logic_vector(31 downto 0);
        Overflow : out std_logic;
        Zero : out std_logic);
  
end entity ALU;

architecture Behavioural of ALU is

signal carry : std_logic_vector(31 downto 0);
signal SuperGroup1Carry : std_logic;
signal SuperGroup2Carry : std_logic;

signal i_q : std_logic_vector(31 downto 0);
signal g : std_logic_vector(31 downto 0);
signal p : std_logic_vector(31 downto 0);

signal MSB_Adder_Bypass : std_logic;

signal Carry_In : std_logic;
begin
  
overflow <=  SuperGroup2Carry xor carry(31); 
q <= i_q;

ZEROFLAG: process (i_q) is
  variable zero_q : std_logic_vector(31 downto 0);
begin
  zero_q := (others => '0');
  
  if (i_q = zero_q) then
    Zero <= '1';
  else
    Zero <= '0';
  end if;    
end process ZEROFLAG;

SUBMUX : process (ctrl) is
begin
  if ((ctrl = ALU_OP_SUB) OR (ctrl = ALU_OP_LES)) then
    Carry_In <= '1';
  else
    Carry_In <= '0';
  end if;
end process SUBMUX;

ALU_BIT0: entity work.ALU_Bit
     port map(a => a(0),
              b => b(0),
              less => MSB_Adder_Bypass,
              cin => carry(0),
              ctrl => ctrl,
              q => i_q(0),
              g => g(0),
              p => p(0));

ALUS_GEN : for n in 1 to 30 generate

ALU: entity work.ALU_Bit
     port map(a => a(n),
              b => b(n),
              less => '0',
              cin => carry(n),
              ctrl => ctrl,
              q => i_q(n),
              g => g(n),
              p => p(n));
end generate ALUS_GEN;

ALU_MSB: entity work.ALU_MSB_Bit
     port map(a => a(31),
              b => b(31),
              less => '0',
              cin => carry(31),
              ctrl => ctrl,
              Adder_Bypass => MSB_Adder_Bypass,
              q => i_q(31),
              g => g(31),
              p => p(31));
              
CarryLookAhead1_15: entity MIPS_Common.CarryLookAhead_16b
                    port map(c_in => Carry_In,
                             p => p(15 downto 0),
                             g => g(15 downto 0),
                             c_out => carry(15 downto 0),
                             SuperGroup_c => SuperGroup1Carry); 
                             
                             
CarryLookAhead16_31: entity MIPS_Common.CarryLookAhead_16b
                    port map(c_in => SuperGroup1Carry,
                             p => p(31 downto 16),
                             g => g(31 downto 16),
                             c_out => carry(31 downto 16),
                             SuperGroup_c => SuperGroup2Carry);                                           
end architecture Behavioural;
