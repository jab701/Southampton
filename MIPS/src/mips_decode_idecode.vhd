library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mips_sys_isa_pack.ALL;

entity mips_decode_idecode is
   port(
      -- Input
      instruction : in std_logic_vector(31 downto 0);
      -- Outputs
      bad_instruct : out std_logic;
      
      -- Pipeline Control
      inst_ctrl   : out instruction_ctrl;
      brnch_ctrl  : out branch_control;
      ex_ctrl     : out execute_ctrl;
      mem_ctrl    : out memory_ctrl;
      wb_ctrl     : out writeback_ctrl;
      
      -- Pipeline Data
      sourcereg1   : out std_logic_vector(4 downto 0);
      sourcereg2   : out std_logic_vector(4 downto 0);
      targetreg    : out std_logic_vector(4 downto 0);
      immediate    : out std_logic_vector(31 downto 0);
      
      takejump     : out std_logic;
      jumplink     : out std_logic;
      jumpreg      : out std_logic;
      jumpimmed    : out std_logic_vector(25 downto 0));
end entity mips_decode_idecode;

architecture rtl of mips_decode_idecode is

-- Component Declarations
-- Signal Declarations
signal opcode : std_logic_vector(5 downto 0);

signal source_register1 : std_logic_vector(31 downto 0);
signal source_register2 : std_logic_vector(31 downto 0);

signal target_register : std_logic_vector(4 downto 0);

signal se_immed : std_logic_vector(31 downto 0);
signal zero_immed : std_logic;

signal bad_function : std_logic;
signal bad_opcode   : std_logic;

begin

sourcereg1 <= instruction(25 downto 21);
sourcereg2 <= instruction(20 downto 16);

p_targetreg: process (instruction, takejump) 
begin
   if instruction(31 downto 26) = ALU_OP then
      targetreg <= instruction(15 downto 11);
   elsif takejump = '1' then
      targetreg <= (others => '1'); 
   else
      targetreg <= instruction(20 downto 16);
   end if;
end process p_targetreg;

p_signextend: process(instruction) is
begin
   immediate(15 downto 0) <= instruction(15 downto 0);
   for i in 16 to 31 loop
      immediate(i) <= instruction(15);
   end loop;
end process p_signextend;

p_decode: process (instruction) is
begin
   -- Default values
   -- Execute Control
   -- By default we shift by immediate = zero (NOP)
   ex_ctrl.arithn_shift  <= '1';
   ex_ctrl.arith_op      <= (others => '0');
   ex_ctrl.shiftamnt     <= instruction(10 downto 6);
   ex_ctrl.shift_left    <= '0';
   ex_ctrl.shift_arth    <= '0';
   ex_ctrl.use_immediate <= '0';

   -- Memory Control
   mem_ctrl.rd   <= '0';
   mem_ctrl.wr   <= '0';
   mem_ctrl.byte <= '0';
   mem_ctrl.half <= '0';
   mem_ctrl.bls0 <= '0';
   mem_ctrl.bls1 <= '0';
   mem_ctrl.bls2 <= '0';
   mem_ctrl.bls3 <= '0';

   -- Writeback Control
   wb_ctrl.regwr     <= '0';
   wb_ctrl.memregmux <= '0';
   
   -- Jump Control
   takejump  <= '0';
   jumplink  <= '0';
   jumpreg   <= '0';   
   jumpimmed <= instruction(25 downto 0);

   -- Instruction decode
   case instruction(31 downto 26) is
   when OP_ALU   =>
      -- Registers
      
      case instruction(5 downto 0) is
      when RTYPE_SLL     =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '1';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '1';

      when RTYPE_SRL     =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '1';

      when RTYPE_SRA     =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '1';
         ex_ctrl.use_immediate <= '1';

      when RTYPE_SLLV    =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '1';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SRLV    =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SRAV    =>
         ex_ctrl.arithn_shift  <= '1';
         ex_ctrl.arith_op      <= (others => '0');
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '1';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_JR      =>
         takejump <= '1';
         jumplink <= '0';
         jumpreg  <= '1';
         
      when RTYPE_JALR    =>
         takejump <= '1';
         jumplink <= '0';
         jumpreg  <= '1';
      
      when RTYPE_SYSCALL =>
      
      when RTYPE_BREAK   =>
      
      when RTYPE_MFHI    =>
         bad_function <= '1';
      when RTYPE_MTHI    =>
         bad_function <= '1';
      when RTYPE_MFLO    =>
         bad_function <= '1';
      when RTYPE_MTLO    =>
         bad_function <= '1';
      when RTYPE_MULT    =>
         bad_function <= '1';
      when RTYPE_MULTU   =>
         bad_function <= '1';
      when RTYPE_DIV     =>
         bad_function <= '1';
      when RTYPE_DIVU    =>
         bad_function <= '1';

      when RTYPE_ADD     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_ADD;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_ADDU    =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_ADD;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SUB     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_SUB;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SUBU    =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_SUB;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_AND     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_AND;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_OR      =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_OR;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_XOR     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_XOR;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_NOR     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_NOR;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SLT     =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_LES;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when RTYPE_SLTU    =>
         ex_ctrl.arithn_shift  <= '0';
         ex_ctrl.arith_op      <= ALU_LES;
         ex_ctrl.shift_left    <= '0';
         ex_ctrl.shift_arth    <= '0';
         ex_ctrl.use_immediate <= '0';

      when others    =>
         -- Use Execute Control Defaults
         -- Use Memory Control Defaults
         -- Use Writeback Control Defaults
         -- Exception!
         -- Bad Instruction Function Code
         bad_instruct <= '1';
      end case;
      
   when OP_BRNCH =>
      case instruction(20 downto 16) is
         when OP_BRNCH_BLTZ =>

         when OP_BRNCH_BGEZ =>

         when OP_BRNCH_BLTZAL =>
 
         when OP_BRNCH_BGEZAL =>
 
         when others =>
            bad_opcode <= '1';  
      end case;

   when OP_JUMP  =>

   when OP_JAL   =>

   when OP_BEQ   =>

   when OP_BNE   =>

   when OP_BLEZ  =>

   when OP_BGTZ  =>

   when OP_ADDI  =>

   when OP_ADDIU =>

   when OP_SLTI  =>

   when OP_SLTIU =>

   when OP_ANDI  =>

   when OP_ORI   =>

   when OP_XORI  =>

   when OP_LUI   =>

   when OP_LB    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';
      
   when OP_LH    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_LWL   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_LW    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_LBU   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_LHU   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_LWR   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_SB    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_SH    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_SWL   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_SW    =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when OP_SWR   =>
      mem_ctrl.rd   <= '0';
      mem_ctrl.wr   <= '0';
      mem_ctrl.byte <= '0';
      mem_ctrl.half <= '0';
      mem_ctrl.bls0 <= '0';
      mem_ctrl.bls1 <= '0';
      mem_ctrl.bls2 <= '0';
      mem_ctrl.bls3 <= '0';

   when others   =>
      bad_instruct <= '1';

   end case;
end process p_decode;

p_execute: process (instruction) is
begin
   case instruction(31 downto 26) is
   when OP_ALU =>
      case instruction(5 downto 0) is
      when RTYPE_SLL | RTYPE_SRL | RTYPE_SRA => -- Shift Operation: Shift by amount specified in instruction
      when RTYPE_SLLV | RTYPE_SRLV | RTYPE_SRAV => -- Shift Operation: Shift by amount specified in register
      when others => -- ALU Operation
      end case;
   when OP_ADDI =>
   when OP_ADDIU =>
   when OP_SLTI =>
   when OP_SLTIU =>
   when OP_ANDI =>
   when OP_ORI =>
   when OP_XORI =>
   when OP_LUI =>
   when others =>
   end case;
end process p_execute;

p_memory: process (instruction) is
begin
  case instruction(31 downto 26) is
  when OP_LB => -- sign extended
  when OP_LH => -- sign extended
  when OP_LWL => -- Preserve Upper word of reg
  when OP_LW => -- load word
  when OP_LBU => -- Zero Extended
  when OP_LHU => -- Zero Extended
  when OP_LWR => -- Preserve Lower word of reg
  when OP_SB => -- store low byte
  when OP_SH => -- store low halfword
  when OP_SWL => -- store low halfword at address (preserve high halfword)
  when OP_SW => -- store word
  when OP_SWR => -- store high halfword at address (preserve low halfword)
  when others =>
  end case;
end process p_memory;

p_writeback: process () is
begin
  case instruction(31 downto 26) is
  when OP_ALU =>
     case instruction(5 downto 0) is
     when RTYPE_SLL | RTYPE_SRL | RTYPE_SRA | RTYPE_SLLV | RTYPE_SRLV | RTYPE_SRAV =>
     when RTYPE_JALR =>
     when RTYPE_MFHI | RTYPE_MFLO =>
     when RTYPE_ADD | RTYPE_ADDU | RTYPE_SUB | RTYPE_SUBU =>
     when RTYPE_AND | RTYPE_OR | RTYPE_XOR | RTYPE_NOR =>
     when RTYPE_SLT | RTYPE_SLTU =>
     when others =>
     end case;
  when OP_LB =>
  when OP_LH =>
  when OP_LWL =>
  when OP_LW =>
  when OP_LBU =>
  when OP_LHU =>
  when OP_LWR =>
  when others =>
  end case;
end process p_writeback;

-- Next PC Address
inst_ctrl.pcplus4    <= pcplus4;
-- Register Numbers
inst_ctrl.regnum_rs  <= instruction(25 downto 21);
inst_ctrl.regnum_rt  <= instruction(20 downto 16);
inst_ctrl.regnum_rd  <= target_register;
-- Register Data
inst_ctrl.regdat_rs  <= source_register1;
inst_ctrl.regdat_rt  <= source_register2;
-- Sign-Extended 16-bit Immediate
inst_ctrl.immed_se16 <= se_immed;
end architecture rtl;