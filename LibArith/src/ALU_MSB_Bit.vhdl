library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity ALU_MSB_Bit is
  port( a : in std_logic;
        b : in std_logic;
        less : in std_logic;
        cin    : in std_logic;

        ctrl : in std_logic_vector(2 downto 0);
        
        Adder_Bypass : out std_logic;
        q : out std_logic;
        g : out std_logic;
        p : out std_logic);
  
end entity ALU_MSB_Bit;

architecture Behavioural of ALU_MSB_Bit is

signal Add_Sum : std_logic;
signal Mux_b : std_logic;
begin

Adder_Bypass <= Add_Sum;

SUBMUX : process (b, ctrl) is
begin
  if ((ctrl = ALU_OP_SUB) OR (ctrl = ALU_OP_LES)) then
    Mux_b <= NOT(b);
  else
    Mux_b <= b;
  end if;
end process SUBMUX;

FULLADDER_0: entity MIPS_Common.FullAdder
             port map(a => a,
                      b => Mux_b,
                      cin => cin,
                      q => Add_Sum,
                      g => g,
                      p => p);
  
MUX: process(Ctrl, Add_Sum, a, b, Less) is
begin
  case Ctrl is
  when ALU_OP_NOP =>
    q <= a;
  when ALU_OP_ADD =>
    q <= Add_Sum;    
  when ALU_OP_AND =>
    q <= a AND b;  
  when ALU_OP_NOR =>
    q <= a NOR b;
  when ALU_OP_OR =>
    q <= a OR b;
  when ALU_OP_XOR =>
    q <= a XOR b;
  when ALU_OP_LES =>
    q <= less;
    
  when others =>
    q <= '0';             
  end case;

end process MUX;
  
end architecture Behavioural;