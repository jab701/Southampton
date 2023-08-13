library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipeline_execute_alu is
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
end entity pipeline_execute_alu;

architecture rtl of pipeline_execute_alu is

-- Component Declarations
component pipeline_execute_alu_arith
   port(
      -- Input Operands
      a      : in std_logic_vector(31 downto 0);
      b      : in std_logic_vector(31 downto 0);
      -- Operation Select
      op_add : in std_logic;
      op_and : in std_logic;
      op_sub : in std_logic;
      op_les : in std_logic;
      op_or  : in std_logic;
      op_nor : in std_logic;
      op_xor : in std_logic;
      -- Result Output
      q      : out std_logic_vector(31 downto 0);
      -- Overflow Output
      v      : out std_logic);
end component pipeline_execute_alu_arith;

component pipeline_execute_alu_shift
   port(
      -- Input Operands
      a     : in std_logic_vector(31 downto 0);
      -- Shift Amount
      amnt  : in std_logic_vector(4 downto 0);
      -- Shift Direction and Mode
      left  : in std_logic;
      arith : in std_logic;
      -- Result
      q     : out std_logic_vector(31 downto 0));
end component pipeline_execute_alu_shift;

-- Signal Declarations
signal arith_result : std_logic_vector(31 downto 0);
signal arith_overflow : std_logic;
signal shift_result : std_logic_vector(31 downto 0);

begin
-- Arithmetic Unit
i_alu_arith: entity pipeline_execute_alu_arith
   port map(-- Input Operands
            a => a,
            b => b,
            -- Operation Select
            op_add => arith_op(0),
            op_and => arith_op(1),
            op_sub => arith_op(2),
            op_les => arith_op(3),
            op_or  => arith_op(4),
            op_nor => arith_op(5),
            op_xor => arith_op(6),
            -- Result Output
            q => arith_result,
            -- Overflow Output
            v => arith_overflow);

-- Barrel Shifter Unit
i_alu_shift: pipeline_execute_alu_shift
   port map(-- Input Operands
            a     => a,
            -- Shift Amount
            amnt  => b(4 downto 0),
            -- Shift Direction and Mode
            left  => shift_left,
            arith => shift_arith,
            -- Result
            q     => shift_result);

p_outputmux: process (arithn_shift, arith_result, arith_overflow,
                      shift_result)
begin
   if (arithn_shift = '0') then
      q <= arith_result;
      v <= arith_overflow;
   else
      q <= shift_result;
      v <= '0';
   end if;
end process p_outputmux;

end architecture rtl;