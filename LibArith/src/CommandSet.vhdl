library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package COMMANDSET is
-- MIPS R2000A OPCODES
-- ANY OPCODE NAME STARTING OP_UNXX WHERE XX IS A NUMBER ARE UNUSED PLACEHOLDERS  
-- GENERAL OPCODES (0 - 15)
constant OP_ALU   : std_logic_vector(5 downto 0) := "000000";
constant OP_BRNCH : std_logic_vector(5 downto 0) := "000001";
constant OP_JUMP  : std_logic_vector(5 downto 0) := "000010";
constant OP_JAL   : std_logic_vector(5 downto 0) := "000011";
constant OP_BEQ   : std_logic_vector(5 downto 0) := "000100";
constant OP_BNE   : std_logic_vector(5 downto 0) := "000101";
constant OP_BLEZ  : std_logic_vector(5 downto 0) := "000110";
constant OP_BGTZ  : std_logic_vector(5 downto 0) := "000111";
constant OP_ADDI  : std_logic_vector(5 downto 0) := "001000";
constant OP_ADDIU : std_logic_vector(5 downto 0) := "001001";
constant OP_SLTI  : std_logic_vector(5 downto 0) := "001010";
constant OP_SLTIU : std_logic_vector(5 downto 0) := "001011";
constant OP_ANDI  : std_logic_vector(5 downto 0) := "001100";
constant OP_ORI   : std_logic_vector(5 downto 0) := "001101";
constant OP_XORI  : std_logic_vector(5 downto 0) := "001110";
constant OP_LUI   : std_logic_vector(5 downto 0) := "001111";
-- COPROCESSOR OPCODES ( 16 to 19)
constant OP_COP1  : std_logic_vector(5 downto 0) := "010000";
constant OP_COP2  : std_logic_vector(5 downto 0) := "010001";
constant OP_COP3  : std_logic_vector(5 downto 0) := "010010";
constant OP_COP4  : std_logic_vector(5 downto 0) := "010011";
-- OPCODES 20 to 31 are unused
constant OP_UN20  : std_logic_vector(5 downto 0) := "010100";
constant OP_UN21  : std_logic_vector(5 downto 0) := "010101";
constant OP_UN22  : std_logic_vector(5 downto 0) := "010110";
constant OP_UN23  : std_logic_vector(5 downto 0) := "010111";
constant OP_UN24  : std_logic_vector(5 downto 0) := "011000";
constant OP_UN25  : std_logic_vector(5 downto 0) := "011001";
constant OP_UN26  : std_logic_vector(5 downto 0) := "011010";
constant OP_UN27  : std_logic_vector(5 downto 0) := "011011";
constant OP_UN28  : std_logic_vector(5 downto 0) := "011100";
constant OP_UN29  : std_logic_vector(5 downto 0) := "011101";
constant OP_UN30  : std_logic_vector(5 downto 0) := "011110";
constant OP_UN31  : std_logic_vector(5 downto 0) := "011111";
-- MORE GENERAL OPCODES (32 - 63)
constant OP_LB    : std_logic_vector(5 downto 0) := "100000";
constant OP_LH    : std_logic_vector(5 downto 0) := "100001";
constant OP_LWL   : std_logic_vector(5 downto 0) := "100010";
constant OP_LW    : std_logic_vector(5 downto 0) := "100011";
constant OP_LBU   : std_logic_vector(5 downto 0) := "100100";
constant OP_LHU   : std_logic_vector(5 downto 0) := "100101";
constant OP_LWR   : std_logic_vector(5 downto 0) := "100110";
constant OP_UN39  : std_logic_vector(5 downto 0) := "100111";
constant OP_SB    : std_logic_vector(5 downto 0) := "101000";
constant OP_SH    : std_logic_vector(5 downto 0) := "101001";
constant OP_SWL   : std_logic_vector(5 downto 0) := "101010";
constant OP_SW    : std_logic_vector(5 downto 0) := "101011";
constant OP_UN44  : std_logic_vector(5 downto 0) := "101100";
constant OP_UN45  : std_logic_vector(5 downto 0) := "101101";
constant OP_SWR   : std_logic_vector(5 downto 0) := "101110";
constant OP_UN47  : std_logic_vector(5 downto 0) := "101111";
constant OP_LWC0  : std_logic_vector(5 downto 0) := "110000";
constant OP_LWC1  : std_logic_vector(5 downto 0) := "110001";
constant OP_LWC2  : std_logic_vector(5 downto 0) := "110010";
constant OP_LWC3  : std_logic_vector(5 downto 0) := "110011";
constant OP_UN52  : std_logic_vector(5 downto 0) := "110100";
constant OP_UN53  : std_logic_vector(5 downto 0) := "110101";
constant OP_UN54  : std_logic_vector(5 downto 0) := "110110";
constant OP_UN55  : std_logic_vector(5 downto 0) := "110111";
constant OP_SWC0  : std_logic_vector(5 downto 0) := "111000";
constant OP_SWC1  : std_logic_vector(5 downto 0) := "111001";
constant OP_SWC2  : std_logic_vector(5 downto 0) := "111010";
constant OP_SWC3  : std_logic_vector(5 downto 0) := "111011";
constant OP_UN60  : std_logic_vector(5 downto 0) := "111100";
constant OP_UN61  : std_logic_vector(5 downto 0) := "111101";
constant OP_UN62  : std_logic_vector(5 downto 0) := "111110";
constant OP_UN63  : std_logic_vector(5 downto 0) := "111111";

-- BRANCH FUNCTION CODES
constant OP_BRNCH_BLTZ    : std_logic_vector(4 downto 0) := "00000";
constant OP_BRNCH_BGEZ    : std_logic_vector(4 downto 0) := "00001";
constant OP_BRNCH_BLTZAL  : std_logic_vector(4 downto 0) := "10000";
constant OP_BRNCH_BGEZAL  : std_logic_vector(4 downto 0) := "10001";

-- R-TYPE INSTRUCTION FUNCTION CODES FOR ALU (MIPS R2000A)
constant RTYPE_SLL     : std_logic_vector(5 downto 0) := "000000";
constant RTYPE_UN01    : std_logic_vector(5 downto 0) := "000001";
constant RTYPE_SRL     : std_logic_vector(5 downto 0) := "000010";
constant RTYPE_SRA     : std_logic_vector(5 downto 0) := "000011";
constant RTYPE_SLLV    : std_logic_vector(5 downto 0) := "000100";
constant RTYPE_UN05    : std_logic_vector(5 downto 0) := "000101";
constant RTYPE_SRLV    : std_logic_vector(5 downto 0) := "000110";
constant RTYPE_SRAV    : std_logic_vector(5 downto 0) := "000111";
constant RTYPE_JR      : std_logic_vector(5 downto 0) := "001000";
constant RTYPE_JALR    : std_logic_vector(5 downto 0) := "001001";
constant RTYPE_UN10    : std_logic_vector(5 downto 0) := "001010";
constant RTYPE_UN11    : std_logic_vector(5 downto 0) := "001011";
constant RTYPE_SYSCALL : std_logic_vector(5 downto 0) := "001100";
constant RTYPE_BREAK   : std_logic_vector(5 downto 0) := "001101";
constant RTYPE_UN14    : std_logic_vector(5 downto 0) := "001110";
constant RTYPE_UN15    : std_logic_vector(5 downto 0) := "001111";
constant RTYPE_MFHI    : std_logic_vector(5 downto 0) := "010000";
constant RTYPE_MTHI    : std_logic_vector(5 downto 0) := "010001";
constant RTYPE_MFLO    : std_logic_vector(5 downto 0) := "010010";
constant RTYPE_MTLO    : std_logic_vector(5 downto 0) := "010011";
constant RTYPE_UN20    : std_logic_vector(5 downto 0) := "010100";
constant RTYPE_UN21    : std_logic_vector(5 downto 0) := "010101";
constant RTYPE_UN22    : std_logic_vector(5 downto 0) := "010110";
constant RTYPE_UN23    : std_logic_vector(5 downto 0) := "010111";
constant RTYPE_MULT    : std_logic_vector(5 downto 0) := "011000";
constant RTYPE_MULTU   : std_logic_vector(5 downto 0) := "011001";
constant RTYPE_DIV     : std_logic_vector(5 downto 0) := "011010";
constant RTYPE_DIVU    : std_logic_vector(5 downto 0) := "011011";
constant RTYPE_UN28    : std_logic_vector(5 downto 0) := "011100";
constant RTYPE_UN29    : std_logic_vector(5 downto 0) := "011101";
constant RTYPE_UN30    : std_logic_vector(5 downto 0) := "011110";
constant RTYPE_UN31    : std_logic_vector(5 downto 0) := "011111";
constant RTYPE_ADD     : std_logic_vector(5 downto 0) := "100000";
constant RTYPE_ADDU    : std_logic_vector(5 downto 0) := "100001";
constant RTYPE_SUB     : std_logic_vector(5 downto 0) := "100010";
constant RTYPE_SUBU    : std_logic_vector(5 downto 0) := "100011";
constant RTYPE_AND     : std_logic_vector(5 downto 0) := "100100";
constant RTYPE_OR      : std_logic_vector(5 downto 0) := "100101";
constant RTYPE_XOR     : std_logic_vector(5 downto 0) := "100110";
constant RTYPE_NOR     : std_logic_vector(5 downto 0) := "100111";
constant RTYPE_UN40    : std_logic_vector(5 downto 0) := "101000";
constant RTYPE_UN41    : std_logic_vector(5 downto 0) := "101001";
constant RTYPE_SLT     : std_logic_vector(5 downto 0) := "101010";
constant RTYPE_SLTU    : std_logic_vector(5 downto 0) := "101011";
constant RTYPE_UN44    : std_logic_vector(5 downto 0) := "101100";
constant RTYPE_UN45    : std_logic_vector(5 downto 0) := "101101";
constant RTYPE_UN46    : std_logic_vector(5 downto 0) := "101110";
constant RTYPE_UN47    : std_logic_vector(5 downto 0) := "101111";
constant RTYPE_UN48    : std_logic_vector(5 downto 0) := "110000";
constant RTYPE_UN49    : std_logic_vector(5 downto 0) := "110001";
constant RTYPE_UN50    : std_logic_vector(5 downto 0) := "110010";
constant RTYPE_UN51    : std_logic_vector(5 downto 0) := "110011";
constant RTYPE_UN52    : std_logic_vector(5 downto 0) := "110100";
constant RTYPE_UN53    : std_logic_vector(5 downto 0) := "110101";
constant RTYPE_UN54    : std_logic_vector(5 downto 0) := "110110";
constant RTYPE_UN55    : std_logic_vector(5 downto 0) := "110111";
constant RTYPE_UN56    : std_logic_vector(5 downto 0) := "111000";
constant RTYPE_UN57    : std_logic_vector(5 downto 0) := "111001";
constant RTYPE_UN58    : std_logic_vector(5 downto 0) := "111010";
constant RTYPE_UN59    : std_logic_vector(5 downto 0) := "111011";
constant RTYPE_UN60    : std_logic_vector(5 downto 0) := "111100";
constant RTYPE_UN61    : std_logic_vector(5 downto 0) := "111101";
constant RTYPE_UN62    : std_logic_vector(5 downto 0) := "111110";
constant RTYPE_UN63    : std_logic_vector(5 downto 0) := "111111";

-- ALU OPCODES (FOR THIS ARCHITECTURE)
constant ALU_OP_NOP  : std_logic_vector(2 downto 0) := "000";
constant ALU_OP_ADD  : std_logic_vector(2 downto 0) := "001";
constant ALU_OP_SUB  : std_logic_vector(2 downto 0) := "010";
constant ALU_OP_AND  : std_logic_vector(2 downto 0) := "011";
constant ALU_OP_NOR  : std_logic_vector(2 downto 0) := "100";
constant ALU_OP_OR   : std_logic_vector(2 downto 0) := "101";
constant ALU_OP_XOR  : std_logic_vector(2 downto 0) := "110";
constant ALU_OP_LES  : std_logic_vector(2 downto 0) := "111";

-- BARREL SHIFTER OPCODES (FOR THIS ARCHITECTURE)
constant BRSH_OP_RIGHT  : std_logic_vector(1 downto 0) := "00";
constant BRSH_OP_LEFT   : std_logic_vector(1 downto 0) := "01";
constant BRSH_OP_RARTH  : std_logic_vector(1 downto 0) := "10";
constant BRSH_OP_UNUSED : std_logic_vector(1 downto 0) := "11";

-- Branch type codes (FOR THIS ARCHITECTURE)
constant BRANCH_NOP : std_logic_vector(2 downto 0) := "000";
constant BRANCH_EQ  : std_logic_vector(2 downto 0) := "001";
constant BRANCH_NEQ : std_logic_vector(2 downto 0) := "010";
constant BRANCH_LEZ : std_logic_vector(2 downto 0) := "011";
constant BRANCH_GTZ : std_logic_vector(2 downto 0) := "100";
constant BRANCH_LTZ : std_logic_vector(2 downto 0) := "101";
constant BRANCH_GEZ : std_logic_vector(2 downto 0) := "110";

  
end package COMMANDSET;
