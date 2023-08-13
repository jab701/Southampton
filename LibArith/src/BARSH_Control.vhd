
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity BARSH_Control is
  port(Func_Bits : in std_logic_vector(5 downto 0);
       BARSH_Control : out std_logic_vector(1 downto 0));
end entity BARSH_Control;

architecture Behavioural of BARSH_Control is

begin
  
process (Func_Bits) is
begin
  case Func_Bits is
    when RTYPE_SLL =>
      BARSH_Control <= BRSH_OP_LEFT;
      
    when RTYPE_SRL =>
      BARSH_Control <= BRSH_OP_RIGHT;
      
    when RTYPE_SRA =>
      BARSH_Control <= BRSH_OP_RARTH;
      
    when RTYPE_SLLV =>
      BARSH_Control <= BRSH_OP_LEFT;
       
    when RTYPE_SRLV =>
      BARSH_Control <= BRSH_OP_RIGHT;
     
    when RTYPE_SRAV =>
      BARSH_Control <= BRSH_OP_RARTH;
       
    when others =>
      BARSH_Control <= BRSH_OP_LEFT; 
  end case;
end process;
end architecture Behavioural;


