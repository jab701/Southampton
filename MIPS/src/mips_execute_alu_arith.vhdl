library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipeline_execute_alu_arith is
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
end entity pipeline_execute_alu_arith;

architecture rtl of pipeline_execute_alu_arith is

-- Output Mux Input Signals
signal a_as_b : std_logic_vector(31 downto 0);
signal overflow : std_logic;
begin

-- Input Signal Preparation

-- Addition & Subtraction
p_as: process (a, b, op_sub, op_les) is
   variable b_mux  : std_logic_vector(31 downto 0);
   variable se_b   : signed(32 downto 0);
   variable se_a   : signed(32 downto 0);
   variable result : signed(32 downto 0);
begin
   if ((op_sub = '1') or (op_les = '1')) then
      b_mux := not(b) + 1;
   else
      b_mux := b;
   end if;

   se_a := a(31) & a;
   se_b := b_mux(31) & b_mux;
   result := se_a + se_b;

   if (result(32) /= result(31)) then
      overflow <= '1';
   else
      overflow <= '0';
   end if;

   if (op_les = '1') then
      a_as_b(0) <= result(31);
      a_as_b(31 downto 0) <= (others => '0');
   else
      a_as_b <= result(31 downto 0);
   end if;

end process p_as;

-- Output Mux
p_outputmux: process (op_add, op_and, op_sub, op_les, op_or, op_nor, op_xor,
                      a, b, a_as_b, overflow) is
begin
   q <= (others => '0');
   v <= '0';

   if (op_add = '1') then
      q <= a_as_b;
      v <= overflow;
   elsif (op_and = '1') then
      q <= a AND b;
      v <= '0';
   elsif (op_sub = '1') then
      q <= a_as_b;
      v <= overflow;
   elsif (op_les = '1') then
      q <= a_as_b;
      v <= '0';
   elsif (op_or = '1')  then
      q <= a OR b;
      v <= '0';
   elsif (op_nor = '1') then
      q <= NOT(a OR b);
      v <= '0';
   elsif (op_xor = '1') then
      q <= a XOR b;
      v <= '0';
   else
      q <= a;
      v <= '0';
   end if;
end process p_outputmux;

end architecture rtl;