library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity mips_decode_branch is
  port(-- Inputs
       -- Data in
       pc_in      : in std_logic_vector(29 downto 0);
       immediate  : in std_logic_vector(29 downto 0);
       reg1       : in std_logic_vector(31 downto 0);
       reg2       : in std_logic_vector(31 downto 0);
       -- Operation
       control    : in branch_ctrl;
       -- Outputs
       takebranch : out std_logic;
       pc_out     : out std_logic_vector(29 downto 0));
end entity mips_decode_branch;

architecture rtl of mips_decode_branch is

-- Operation
signal eq      : std_logic;
signal neq     : std_logic;
signal ltez    : std_logic;
signal ltz     : std_logic;
signal gtz     : std_logic;
signal gtez    : std_logic;
       
signal iszero  : std_logic;
signal isequal : std_logic;

begin

eq   <= control.eq;
neq  <= control.neq;
ltez <= control.ltez;
ltz  <= control.ltz;
gtz  <= control.gtz;
gtez <= control.gtez;

p_branchcalc: process(pc_in, immediate)
   variable op1 : signed(30 downto 0);
   variable op2 : signed(30 downto 0);
   variable op3 : signed(30 downto 0);
begin
   -- sign extend both input operands
   op1 := '0' & pc_in;
   op2 := immediate(29) & immediate;
   -- signed add
   op3 := op1 + op2;
   -- assign back to output, truncate
   pc_out <= op3(29 downto 0);   
end process p_branchcalc;

p_iszero: process(reg1)
   variable ZERO_VALUE : std_logic_vector(31 downto 0);
begin
  ZERO_VALUE := (others => '0');
  
  if (reg1 = ZERO_VALUE) then
     iszero <= '1';
  else
     iszero <= '0';
  end if;
end process p_iszero;

p_isequal: process(reg1, reg2)
begin
   if reg1 = reg2 then
      isequal <= '1';
   else
      isequal <= '0';
   end if;
end process p_isequal;

p_branch: process(eq, neq, ltez, ltz, gtz,
                  gtez, reg1, isequal, iszero)
   variable takebranch_v : std_logic;
   variable msb          : std_logic;
   variable notmsb       : std_logic;
   variable notisequal   : std_logic;
   variable notiszero    : std_logic;
begin
   -- Save the msb, makes the equations look tidy
   msb        := reg1(reg1'high);
   notmsb     := NOT(msb);
   notisequal := NOT(isequal);
   notiszero  := NOT(iszero);
   
   -- We should branch if one of the following six conditions is true
   -- Save into temporary variable
   takebranch_v := (eq   AND  isequal)             OR  -- reg1  = reg2
                   (neq  AND  notisequal)          OR  -- reg1 != reg2
                   (ltez AND (msb OR iszero))      OR  -- reg1 =< 0
                   (ltz  AND  msb)                 OR  -- reg1  < 0
                   (gtz  AND notmsb AND notiszero) OR  -- reg1  > 0
                   (gtez AND (notmsb OR iszero));      -- reg1 >= 0
                   
   -- We check to make sure only one control signal was asserted
   -- otherwise we do not branch.
   takebranch <= takebranch_v AND (eq  XOR neq XOR ltez XOR
                                   ltz XOR gtz XOR gtez);                
end process p_branch;

end architecture rtl;

