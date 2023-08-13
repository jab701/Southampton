library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipeline_execute_alu_shift is
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

end entity pipeline_execute_alu_shift;

architecture rtl of pipeline_execute_alu_shift is

signal rev_1 : std_logic_vector(31 downto 0);
signal shft_16 : std_logic_vector(31 downto 0);
signal shft_8  : std_logic_vector(31 downto 0);
signal shft_4  : std_logic_vector(31 downto 0);
signal shft_2  : std_logic_vector(31 downto 0);
signal shft_1  : std_logic_vector(31 downto 0);
begin

p_rev_1: process (a, left) is
   variable Reversed : std_logic_vector(31 downto 0);
begin
   for i in 0 to 31 loop
      Reversed(i) <= a(31-i);
   end loop;

   if (left = '1') then
      rev_1 <= Reversed;
   else
      rev_1 <= a;
   end if;
end process p_rev_1;

p_shft_16: process (rev_1, amnt(4), arith) is
   variable signext : std_logic_vector(15 downto 0);
begin
   for i in 0 to 15 loop
      signext(i) <= rev_1(31);
   end loop;

   if ((amnt(4) = '1') AND (arith = '1')) then
      shft_16(15 downto 0)  <= rev_1(31 downto 16);
      shft_16(31 downto 16) <= signext;
   elsif (amnt(4) = '1') then
      shft_16(15 downto 0)  <= rev_1(31 downto 16);
      shft_16(31 downto 16) <= (others => '0');
   else
      shft_16 <= rev_1;
   end if;
end process p_shft_16;

p_shft_8: process (shft_16, amnt(3), arith) is
   variable signext : std_logic_vector(7 downto 0);
begin
   for i in 0 to 7 loop
      signext(i) <= shft_16(31);
   end loop;

   if ((amnt(3) = '1') AND (arith = '1')) then
      shft_8(23 downto 0)  <= shft_16(31 downto 8);
      shft_8(31 downto 24) <= signext;
   elsif (amnt(3) = '1') then
      shft_8(23 downto 0)  <= shft_16(31 downto 8);
      shft_8(31 downto 24) <= (others => '0');
   else
      shft_8 <= shft_16;
   end if;
end process p_shft_8;

p_shft_4: process (shft_8, amnt(2), arith) is
   variable signext : std_logic_vector(3 downto 0);
begin
   for i in 0 to 3 loop
      signext(i) <= shft_8(31);
   end loop;

   if ((amnt(2) = '1') AND (arith = '1')) then
      shft_4(27 downto 0)  <= shft_8(31 downto 4);
      shft_4(31 downto 28) <= signext;
   elsif (amnt(2) = '1') then
      shft_4(27 downto 0)  <= shft_8(31 downto 4);
      shft_4(31 downto 28) <= (others => '0');
   else
      shft_4 <= shft_8;
   end if;
end process p_shft_4;

p_shft_2: process (shft_4, amnt(1), arith) is
   variable signext : std_logic_vector(1 downto 0);
begin
   for i in 0 to 1 loop
      signext(i) <= shft_4(31);
   end loop;

   if ((amnt(1) = '1') AND (arith = '1')) then
      shft_2(29 downto 0)  <= shft_4(31 downto 2);
      shft_2(31 downto 30) <= signext;
   elsif (amnt(1) = '1') then
      shft_2(29 downto 0)  <= shft_4(31 downto 2);
      shft_2(31 downto 30) <= (others => '0');
   else
      shft_2 <= shft_4;
   end if;
end process p_shft_2;

p_shft_1: process (shft_2, amnt(0), arith) is
   variable signext : std_logic_vector(0 downto 0);
begin
   for i in 0 to 0 loop
      signext(i) <= shft_2(31);
   end loop;

   if ((amnt(0) = '1') AND (arith = '1')) then
      shft_1(30 downto 0)  <= shft_2(31 downto 1);
      shft_1(31 downto 31) <= signext;
   elsif (amnt(0) = '1') then
      shft_1(30 downto 0)  <= shft_2(31 downto 1);
      shft_1(31 downto 31) <= (others => '0');
   else
      shft_1 <= shft_2;
   end if;
end process p_shft_1;

p_rev_2: process (shft_1, left) is
begin
   variable Reversed : std_logic_vector(31 downto 0);
begin
   for i in 0 to 31 loop
      Reversed(i) <= shft_1(31-i);
   end loop;

   if (left = '1') then
      q <= Reversed;
   else
      q <= shft_1;
   end if;
end process p_rev_2;

end architecture rtl;