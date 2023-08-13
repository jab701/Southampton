library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mips_sys_isa_pack.ALL;

entity pipeline_execute is
   port(
      -- Input
      inst_ctrl  : in instruction_ctrl;
      ex_ctrl    : in execute_ctrl;
      -- Forwarding
      forwarding : in forward_ctrl;
      -- Result Output
      q          : out std_logic_vector(31 downto 0);
      v          : out std_logic);
end entity pipeline_execute;

architecture rtl of pipeline_execute is

-- Component Declarations
component pipeline_execute_alu
   port(
      -- Input Operands
      a            : in std_logic_vector(31 downto 0);
      b            : in std_logic_vector(31 downto 0);
      -- Unit Select
      arithn_shift : in std_logic;
      -- Arith Control
      arith_op           : in std_logic_vector(6 downto 0);
      -- Shift Control
      shift_left         : in std_logic;
      shift_arith        : in std_logic;
      -- Result Output
      q            : out std_logic_vector(31 downto 0);
      v            : out std_logic);
end component pipeline_execute_alu;

-- Signal Declarations
signal operand1 : std_logic_vector(31 downto 0);
signal operand2 : std_logic_vector(31 downto 0);


begin

p_operand1: process(inst_ctrl, ex_ctrl, forwarding) is
begin
   if (forwarding.ex_rs = '1') then
      operand1 <= forwarding.ex_data;
   elsif (forwarding.mem_rs ='1') then
      operand1 <= forwarding.mem_data;
   else
      operand1 <= inst_ctrl.regdat_rs;
   end if;
end process p_operand1;

p_operand2: process(inst_ctrl, ex_ctrl, forwarding) is
begin
   -- Use sign-extended immediate
   if (ex_ctrl.use_immediate = '1') then
      operand2 <= inst_ctrl.immed_se16;
   elsif (forwarding.ex_rt = '1') then
      operand2 <= forwarding.ex_data;
   elsif (forwarding.mem_rt ='1') then
      operand2 <= forwarding.mem_data;
   else
      operand2 <= inst_ctrl.regdat_rt;
   end if;
end process p_operand2;

i_alu: entity pipeline_execute_alu
   port map(-- Input Operands
            a            => operand1,
            b            => operand2,
            -- Unit Select
            arithn_shift => ex_ctrl.arithn_shift,
            -- Arith Control
            arith_op     => ex_ctrl.arith_op,
            -- Shift Control
            shift_left   => ex_ctrl.shift_left,
            shift_arith  => ex_ctrl.shift_arth,
            -- Result Output
            q            => q,
            v            => v);
end architecture rtl;