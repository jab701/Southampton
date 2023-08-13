library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity alu_controller is
  port(Sys_Control : in std_logic_vector(3 downto 0);
       Func_Bits : in std_logic_vector(5 downto 0);
       ALU_Control : out std_logic_vector(2 downto 0));
end entity alu_controller;

architecture Behavioural of alu_controller is

begin
  
process (Sys_Control, Func_Bits) is
begin
  
  if (Sys_Control(3) = '0') then -- ALU is controlled by system controller
    ALU_Control <= Sys_Control(2 downto 0);
  else -- ALU is controller by Func Bits in Instruction
    case Func_Bits is
    when RTYPE_ADD =>
      ALU_Control <= ALU_OP_ADD;
        
    when RTYPE_ADDU =>
      ALU_Control <= ALU_OP_ADD;
             
    when RTYPE_SUB =>
      ALU_Control <= ALU_OP_SUB;
              
    when RTYPE_SUBU =>
      ALU_Control <= ALU_OP_SUB;
             
    when RTYPE_AND =>
      ALU_Control <= ALU_OP_AND;
             
    when RTYPE_OR =>
      ALU_Control <= ALU_OP_OR;
             
    when RTYPE_XOR =>
      ALU_Control <= ALU_OP_XOR;
             
    when RTYPE_NOR =>
      ALU_Control <= ALU_OP_NOR;
             
    when RTYPE_SLT =>
      ALU_Control <= ALU_OP_LES;
            
    when RTYPE_SLTU =>
      ALU_Control <= ALU_OP_LES;
      
    when others =>
      ALU_Control <= ALU_OP_NOP;
    end case;
  end if;   
end process;

end architecture Behavioural;


