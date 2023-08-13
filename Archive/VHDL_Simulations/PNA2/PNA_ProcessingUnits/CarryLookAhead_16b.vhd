library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CarryLookAhead_16b is
  port( c_in : in std_logic;
        
        p : in std_logic_vector(15 downto 0);
        
        g : in std_logic_vector(15 downto 0);
        
        c_out : out std_logic_vector(15 downto 0);
        
        SuperGroup_C : out std_logic);
  
end entity CarryLookAhead_16b;

architecture Behavioural of CarryLookAhead_16b is

signal Group0_p, Group1_p, Group2_p, Group3_p : std_logic;
signal Group0_g, Group1_g, Group2_g, Group3_g : std_logic;
signal Group0_c, Group1_c, Group2_c, Group3_c : std_logic;
signal SuperGroup_p, SuperGroup_g : std_logic;
       
begin

CLA_GRP0: entity work.CarryLookAhead_4b(behavioural)
          port map(c_in => Group0_C,
                   p_0 => p(0),
                   p_1 => p(1),
                   p_2 => p(2),
                   p_3 => p(3), 
                   g_0 => g(0),
                   g_1 => g(1),
                   g_2 => g(2),
                   g_3 => g(3),
                   c_0 => c_out(0),
                   c_1 => c_out(1),
                   c_2 => c_out(2),
                   c_3 => c_out(3),
                   group_p => Group0_p,
                   group_g => Group0_g);
                   
CLA_GRP1: entity work.CarryLookAhead_4b(behavioural)
          port map(c_in => Group1_c,
                   p_0 => p(4),
                   p_1 => p(5),
                   p_2 => p(6),
                   p_3 => p(7), 
                   g_0 => g(4),
                   g_1 => g(5),
                   g_2 => g(6),
                   g_3 => g(7),
                   c_0 => c_out(4),
                   c_1 => c_out(5),
                   c_2 => c_out(6),
                   c_3 => c_out(7),
                   group_p => Group1_p,
                   group_g => Group1_g); 
                   
CLA_GRP2: entity work.CarryLookAhead_4b(behavioural)
          port map(c_in => Group2_c,
                   p_0 => p(8),
                   p_1 => p(9),
                   p_2 => p(10),
                   p_3 => p(11), 
                   g_0 => g(8),
                   g_1 => g(9),
                   g_2 => g(10),
                   g_3 => g(11),
                   c_0 => c_out(8),
                   c_1 => c_out(9),
                   c_2 => c_out(10),
                   c_3 => c_out(11),
                   group_p => Group2_p,
                   group_g => Group2_g); 
                   
CLA_GRP3: entity work.CarryLookAhead_4b(behavioural)
          port map(c_in => Group3_c,
                   p_0 => p(12),
                   p_1 => p(13),
                   p_2 => p(14),
                   p_3 => p(15), 
                   g_0 => g(12),
                   g_1 => g(13),
                   g_2 => g(14),
                   g_3 => g(15),
                   c_0 => c_out(12),
                   c_1 => c_out(13),
                   c_2 => c_out(14),
                   c_3 => c_out(15),
                   group_p => Group3_p,
                   group_g => Group3_g);                                                                                                                                     

SecondLevel: entity work.CarryLookAhead_4b(behavioural)
          port map(c_in => c_in,
                   p_0 => group0_p,
                   p_1 => group1_p,
                   p_2 => group2_p,
                   p_3 => group3_p, 
                   g_0 => group0_g,
                   g_1 => group1_g,
                   g_2 => group2_g,
                   g_3 => group3_g,
                   c_0 => group0_c,
                   c_1 => group1_c,
                   c_2 => group2_c,
                   c_3 => group3_c,
                   group_p => SuperGroup_p,
                   group_g => SuperGroup_g);
                   
SUPER_CARRY: process (c_in, SuperGroup_p, SuperGroup_g) is
variable tmp1 : std_logic;
begin
  tmp1 := SuperGroup_p AND c_in;
  SuperGroup_C <= tmp1 OR SuperGroup_g;
end process SUPER_CARRY; 
                    
end architecture Behavioural;



