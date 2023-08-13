


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CarryLookAhead_4b is
  port( c_in : in std_logic;
        
        p_0 : in std_logic;
        p_1 : in std_logic;
        p_2 : in std_logic;
        p_3 : in std_logic;
                        
        g_0 : in std_logic;
        g_1 : in std_logic;
        g_2 : in std_logic;
        g_3 : in std_logic;

        c_0 : out std_logic;
        c_1 : out std_logic;
        c_2 : out std_logic;
        c_3 : out std_logic;
        
        group_p : out std_logic;
        group_g : out std_logic);
  
end entity CarryLookAhead_4b;

architecture Behavioural of CarryLookAhead_4b is
        
begin

CARRYGEN: process (c_in, p_0, p_1, p_2, p_3, g_0, g_1, g_2, g_3) is

variable C1_tmp : std_logic;

variable C2_tmp1 : std_logic;
variable C2_tmp2 : std_logic;

variable C3_tmp1 : std_logic;
variable C3_tmp2 : std_logic;
variable C3_tmp3 : std_logic;

variable g_0_3_tmp1 :std_logic;
variable g_0_3_tmp2 :std_logic;
variable g_0_3_tmp3 :std_logic;
begin
C1_tmp := p_0 AND c_in;

C2_tmp1 := p_1 AND g_0;
C2_tmp2 := p_1 AND p_0 AND c_in;

C3_tmp1 := p_2 AND g_1;
C3_tmp2 := p_2 AND p_1 AND g_0;
C3_tmp3 := p_2 AND p_1 AND p_0 AND c_in;  

g_0_3_tmp1 := p_3 AND p_2 AND p_1 AND g_0;
g_0_3_tmp2 := p_3 AND p_2 AND g_1;
g_0_3_tmp3 := p_3 AND g_2;
  
c_0 <= c_in;
c_1 <= C1_tmp OR g_0;
c_2 <= C2_tmp1 OR C2_tmp2 OR g_1;
c_3 <= C3_tmp1 OR C3_tmp2 OR C3_tmp3 OR g_2;

group_p <= p_0 AND p_1 AND p_2 AND p_3;
group_g <= g_3 OR g_0_3_tmp1 OR g_0_3_tmp2 OR g_0_3_tmp3;


end process;
  
end architecture Behavioural;


