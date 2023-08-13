library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_pipeline_execute_alu_arith is

end entity tb_pipeline_execute_alu_arith;

architecture tb of tb_pipeline_execute_alu_arith is

-- Input Arguments
signal a : std_logic_vector(31 downto 0) := x"00000000";
signal b : std_logic_vector(31 downto 0) := x"00000000";
-- Input Control Signals        
signal op_add : std_logic := '0';
signal op_and : std_logic := '0';
signal op_sub : std_logic := '0';
signal op_les : std_logic := '0';
signal op_or  : std_logic := '0';
signal op_nor : std_logic := '0';
signal op_xor : std_logic := '0';
-- Output Signals	
signal q : out std_logic_vector(31 downto 0);
signal v : out std_logic

type TestVectorType is 
Record
  A  : std_logic_vector(31 downto 0);
  B  : std_logic_vector(31 downto 0);
  Op : std_logic_vector(6 downto 0);
  Q  : std_logic_vector(31 downto 0);
  V  : std_logic;
end Record;

type TestVectorArray is array (natural range <>) of TestVectorType;

signal TestVector : TestVectorArray(148 downto 0);

signal StartTest : std_logic;
begin

StartTest <= '0', '1' after 1 ns;

process is
   variable ExpOutInt : integer;
   variable Output : integer;
begin
   wait until StartTest = '1';
   for i in 0 to (TestVector'length-1) loop
      VectorNumber <= i;
      op_add <= TestVector(i).Op(0);
      op_and <= TestVector(i).Op(1);
      op_sub <= TestVector(i).Op(2);
      op_les <= TestVector(i).Op(3);
      op_or  <= TestVector(i).Op(4);
      op_nor <= TestVector(i).Op(5);
      op_xor <= TestVector(i).Op(6);
      a <= TestVector(i).A;
      b <= TestVector(i).B;
      wait for 1 ns;
      ExpOutInt := to_integer(signed(TestVector(i).Q));
      Output := to_integer(signed(q));
      
      assert (TestVector(i).Q = q)
         report "Error Test Vector: " & integer'image(i) & " failed. Output Should have been: " & integer'image(Q) & " but was instead: " & integer'image(q) & " "  
         severity error;
      
      if (TestVector(i).V /= 'X') then
         assert (TestVector(i).V = Overflow)
            report "Error Test Vector: " & integer'image(i) & " failed. Output Overflow Should have been: " & std_logic'image(TestVector(i).V) & " but was instead: " & std_logic'image(v)  
            severity error; 
         end if;       
   end loop;
    
   report "TestBench Complete";  
end process;

  
-- a          , b   , Operation       , q          , Overflow;

-- Test NOP
TestVector(0) <= (x"00000000", x"00000000", "000000", x"00000000", '0');
TestVector(1) <= (x"0000FFFF", x"FFFF0000", "0000000", x"0000FFFF", 'X');

-- Testing Add operations!

-- First Test that zero input results in zero output
TestVector(2)   <= (x"00000000", x"00000000", "0000001", x"00000000", '0');

-- Test each bit in Input A propigates to output when added to Input B = 0
TestVector(3)   <= (x"00000001", x"00000000", "0000001", x"00000001", '0');
TestVector(4)   <= (x"00000002", x"00000000", "0000001", x"00000002", '0');
TestVector(5)   <= (x"00000004", x"00000000", "0000001", x"00000004", '0');
TestVector(6)   <= (x"00000008", x"00000000", "0000001", x"00000008", '0');
TestVector(7)   <= (x"00000010", x"00000000", "0000001", x"00000010", '0');
TestVector(8)   <= (x"00000020", x"00000000", "0000001", x"00000020", '0');
TestVector(9)   <= (x"00000040", x"00000000", "0000001", x"00000040", '0');
TestVector(10)  <= (x"00000080", x"00000000", "0000001", x"00000080", '0');
TestVector(11)  <= (x"00000100", x"00000000", "0000001", x"00000100", '0');
TestVector(12)  <= (x"00000200", x"00000000", "0000001", x"00000200", '0');
TestVector(13)  <= (x"00000400", x"00000000", "0000001", x"00000400", '0');
TestVector(14)  <= (x"00000800", x"00000000", "0000001", x"00000800", '0');
TestVector(15)  <= (x"00001000", x"00000000", "0000001", x"00001000", '0');
TestVector(16)  <= (x"00002000", x"00000000", "0000001", x"00002000", '0');
TestVector(17)  <= (x"00004000", x"00000000", "0000001", x"00004000", '0');
TestVector(18)  <= (x"00008000", x"00000000", "0000001", x"00008000", '0');
TestVector(19)  <= (x"00010000", x"00000000", "0000001", x"00010000", '0');
TestVector(20)  <= (x"00020000", x"00000000", "0000001", x"00020000", '0');
TestVector(21)  <= (x"00040000", x"00000000", "0000001", x"00040000", '0');
TestVector(22)  <= (x"00080000", x"00000000", "0000001", x"00080000", '0');
TestVector(23)  <= (x"00100000", x"00000000", "0000001", x"00100000", '0');
TestVector(24)  <= (x"00200000", x"00000000", "0000001", x"00200000", '0');
TestVector(25)  <= (x"00400000", x"00000000", "0000001", x"00400000", '0');
TestVector(26)  <= (x"00800000", x"00000000", "0000001", x"00800000", '0');
TestVector(27)  <= (x"01000000", x"00000000", "0000001", x"01000000", '0');
TestVector(28)  <= (x"02000000", x"00000000", "0000001", x"02000000", '0');
TestVector(29)  <= (x"04000000", x"00000000", "0000001", x"04000000", '0');
TestVector(30)  <= (x"08000000", x"00000000", "0000001", x"08000000", '0');
TestVector(31)  <= (x"10000000", x"00000000", "0000001", x"10000000", '0');
TestVector(32)  <= (x"20000000", x"00000000", "0000001", x"20000000", '0');
TestVector(33)  <= (x"40000000", x"00000000", "0000001", x"40000000", '0');
TestVector(34)  <= (x"80000000", x"00000000", "0000001", x"80000000", '0');
-- Test each bit in Input B propigates to output when added to Input A = 0
TestVector(35)  <= (x"00000000", x"00000001", "0000001", x"00000001", '0');
TestVector(36)  <= (x"00000000", x"00000002", "0000001", x"00000002", '0');
TestVector(37)  <= (x"00000000", x"00000004", "0000001", x"00000004", '0');
TestVector(38)  <= (x"00000000", x"00000008", "0000001", x"00000008", '0');
TestVector(39)  <= (x"00000000", x"00000010", "0000001", x"00000010", '0');
TestVector(40)  <= (x"00000000", x"00000020", "0000001", x"00000020", '0');
TestVector(41)  <= (x"00000000", x"00000040", "0000001", x"00000040", '0');
TestVector(42)  <= (x"00000000", x"00000080", "0000001", x"00000080", '0');
TestVector(43)  <= (x"00000000", x"00000100", "0000001", x"00000100", '0');
TestVector(44)  <= (x"00000000", x"00000200", "0000001", x"00000200", '0');
TestVector(45)  <= (x"00000000", x"00000400", "0000001", x"00000400", '0');
TestVector(46)  <= (x"00000000", x"00000800", "0000001", x"00000800", '0');
TestVector(47)  <= (x"00000000", x"00001000", "0000001", x"00001000", '0');
TestVector(48)  <= (x"00000000", x"00002000", "0000001", x"00002000", '0');
TestVector(49)  <= (x"00000000", x"00004000", "0000001", x"00004000", '0');
TestVector(50)  <= (x"00000000", x"00008000", "0000001", x"00008000", '0');
TestVector(51)  <= (x"00000000", x"00010000", "0000001", x"00010000", '0');
TestVector(52)  <= (x"00000000", x"00020000", "0000001", x"00020000", '0');
TestVector(53)  <= (x"00000000", x"00040000", "0000001", x"00040000", '0');
TestVector(54)  <= (x"00000000", x"00080000", "0000001", x"00080000", '0');
TestVector(55)  <= (x"00000000", x"00100000", "0000001", x"00100000", '0');
TestVector(56)  <= (x"00000000", x"00200000", "0000001", x"00200000", '0');
TestVector(57)  <= (x"00000000", x"00400000", "0000001", x"00400000", '0');
TestVector(58)  <= (x"00000000", x"00800000", "0000001", x"00800000", '0');
TestVector(59)  <= (x"00000000", x"01000000", "0000001", x"01000000", '0');
TestVector(60)  <= (x"00000000", x"02000000", "0000001", x"02000000", '0');
TestVector(61)  <= (x"00000000", x"04000000", "0000001", x"04000000", '0');
TestVector(62)  <= (x"00000000", x"08000000", "0000001", x"08000000", '0');
TestVector(63)  <= (x"00000000", x"10000000", "0000001", x"10000000", '0');
TestVector(64)  <= (x"00000000", x"20000000", "0000001", x"20000000", '0');
TestVector(65)  <= (x"00000000", x"40000000", "0000001", x"40000000", '0');
TestVector(66)  <= (x"00000000", x"80000000", "0000001", x"80000000", '0');
-- Test the carry propigation by adding coressponding bits in A & B
TestVector(67)  <= (x"00000001", x"00000001", "0000001", x"00000002", '0');
TestVector(68)  <= (x"00000002", x"00000002", "0000001", x"00000004", '0');
TestVector(69)  <= (x"00000004", x"00000004", "0000001", x"00000008", '0');
TestVector(70)  <= (x"00000008", x"00000008", "0000001", x"00000010", '0');
TestVector(71)  <= (x"00000010", x"00000010", "0000001", x"00000020", '0');
TestVector(72)  <= (x"00000020", x"00000020", "0000001", x"00000040", '0');
TestVector(73)  <= (x"00000040", x"00000040", "0000001", x"00000080", '0');
TestVector(74)  <= (x"00000080", x"00000080", "0000001", x"00000100", '0');
TestVector(75)  <= (x"00000100", x"00000100", "0000001", x"00000200", '0');
TestVector(76)  <= (x"00000200", x"00000200", "0000001", x"00000400", '0');
TestVector(77)  <= (x"00000400", x"00000400", "0000001", x"00000800", '0');
TestVector(78)  <= (x"00000800", x"00000800", "0000001", x"00001000", '0');
TestVector(79)  <= (x"00001000", x"00001000", "0000001", x"00002000", '0');
TestVector(80)  <= (x"00002000", x"00002000", "0000001", x"00004000", '0');
TestVector(81)  <= (x"00004000", x"00004000", "0000001", x"00008000", '0');
TestVector(82)  <= (x"00008000", x"00008000", "0000001", x"00010000", '0');
TestVector(83)  <= (x"00010000", x"00010000", "0000001", x"00020000", '0');
TestVector(84)  <= (x"00020000", x"00020000", "0000001", x"00040000", '0');
TestVector(85)  <= (x"00040000", x"00040000", "0000001", x"00080000", '0');
TestVector(86)  <= (x"00080000", x"00080000", "0000001", x"00100000", '0');
TestVector(87)  <= (x"00100000", x"00100000", "0000001", x"00200000", '0');
TestVector(88)  <= (x"00200000", x"00200000", "0000001", x"00400000", '0');
TestVector(89)  <= (x"00400000", x"00400000", "0000001", x"00800000", '0');
TestVector(90)  <= (x"00800000", x"00800000", "0000001", x"01000000", '0');
TestVector(91)  <= (x"01000000", x"01000000", "0000001", x"02000000", '0');
TestVector(92)  <= (x"02000000", x"02000000", "0000001", x"04000000", '0');
TestVector(93)  <= (x"04000000", x"04000000", "0000001", x"08000000", '0');
TestVector(94)  <= (x"08000000", x"08000000", "0000001", x"10000000", '0');
TestVector(95)  <= (x"10000000", x"10000000", "0000001", x"20000000", '0');
TestVector(96)  <= (x"20000000", x"20000000", "0000001", x"40000000", '0');
-- Overflow Condition 1 - Two Positive Two complement values
-- are added and set the sign bit.
TestVector(97)  <= (x"40000000", x"40000000", "0000001", x"80000000", '1');
-- Overflow Condition 1 - Two Negative Two complement values
-- are added and unset the sign bit, resulting in Zero.
TestVector(98)  <= (x"80000000", x"80000000", "0000001", x"00000000", '1');
-- Now test that a carried bit can be added to the next bit in the chain.
TestVector(99)  <= (x"00000003", x"00000001", "0000001", x"00000004", '0');
TestVector(100) <= (x"00000006", x"00000002", "0000001", x"00000008", '0');
TestVector(101) <= (x"0000000C", x"00000004", "0000001", x"00000010", '0');
TestVector(102) <= (x"00000018", x"00000008", "0000001", x"00000020", '0');
TestVector(103) <= (x"00000030", x"00000010", "0000001", x"00000040", '0');
TestVector(104) <= (x"00000060", x"00000020", "0000001", x"00000080", '0');
TestVector(105) <= (x"000000C0", x"00000040", "0000001", x"00000100", '0');
TestVector(106) <= (x"00000180", x"00000080", "0000001", x"00000200", '0');
TestVector(107) <= (x"00000300", x"00000100", "0000001", x"00000400", '0');
TestVector(108) <= (x"00000600", x"00000200", "0000001", x"00000800", '0');
TestVector(109) <= (x"00000C00", x"00000400", "0000001", x"00001000", '0');
TestVector(110) <= (x"00001800", x"00000800", "0000001", x"00002000", '0');
TestVector(111) <= (x"00003000", x"00001000", "0000001", x"00004000", '0');
TestVector(112) <= (x"00006000", x"00002000", "0000001", x"00008000", '0');
TestVector(113) <= (x"0000C000", x"00004000", "0000001", x"00010000", '0');
TestVector(114) <= (x"00018000", x"00008000", "0000001", x"00020000", '0');
TestVector(115) <= (x"00030000", x"00010000", "0000001", x"00040000", '0');
TestVector(116) <= (x"00060000", x"00020000", "0000001", x"00080000", '0');
TestVector(117) <= (x"000C0000", x"00040000", "0000001", x"00100000", '0');
TestVector(118) <= (x"00180000", x"00080000", "0000001", x"00200000", '0');
TestVector(119) <= (x"00300000", x"00100000", "0000001", x"00400000", '0');
TestVector(120) <= (x"00600000", x"00200000", "0000001", x"00800000", '0');
TestVector(121) <= (x"00C00000", x"00400000", "0000001", x"01000000", '0');
TestVector(122) <= (x"01800000", x"00800000", "0000001", x"02000000", '0');
TestVector(123) <= (x"03000000", x"01000000", "0000001", x"04000000", '0');
TestVector(124) <= (x"06000000", x"02000000", "0000001", x"08000000", '0');
TestVector(125) <= (x"0C000000", x"04000000", "0000001", x"10000000", '0');
TestVector(126) <= (x"18000000", x"08000000", "0000001", x"20000000", '0');
TestVector(127) <= (x"30000000", x"10000000", "0000001", x"40000000", '0');
TestVector(128) <= (x"60000000", x"20000000", "0000001", x"80000000", '1');
TestVector(129) <= (x"C0000000", x"40000000", "0000001", x"00000000", '0');

-- Testing Subtract Operation
-- This vector is to test that the invert and Carry Input of the Adder Works
TestVector(130) <= (x"00000001", x"00000001", "0000100", x"00000000", '0'); 

-- Testing AND Operation
TestVector(131) <= (x"00000000", x"00000000", "0000010", x"00000000", 'X');
TestVector(132) <= (x"00000000", x"FFFFFFFF", "0000010", x"00000000", 'X');
TestVector(133) <= (x"FFFFFFFF", x"00000000", "0000010", x"00000000", 'X');
TestVector(134) <= (x"FFFFFFFF", x"FFFFFFFF", "0000010", x"FFFFFFFF", 'X');

-- Testing NOR Operation
TestVector(135) <= (x"00000000", x"00000000", "0100000", x"FFFFFFFF", 'X');
TestVector(136) <= (x"00000000", x"FFFFFFFF", "0100000", x"00000000", 'X');
TestVector(137) <= (x"FFFFFFFF", x"00000000", "0100000", x"00000000", 'X');
TestVector(138) <= (x"FFFFFFFF", x"FFFFFFFF", "0100000", x"00000000", 'X');

-- Testing OR Operation
TestVector(139) <= (x"00000000", x"00000000", "0010000", x"00000000", 'X');
TestVector(140) <= (x"00000000", x"FFFFFFFF", "0010000", x"FFFFFFFF", 'X');
TestVector(141) <= (x"FFFFFFFF", x"00000000", "0010000", x"FFFFFFFF", 'X');
TestVector(142) <= (x"FFFFFFFF", x"FFFFFFFF", "0010000", x"FFFFFFFF", 'X');

-- Testing XOR Operation
TestVector(143) <= (x"00000000", x"00000000", "1000000", x"00000000", 'X');
TestVector(144) <= (x"00000000", x"FFFFFFFF", "1000000", x"FFFFFFFF", 'X');
TestVector(145) <= (x"FFFFFFFF", x"00000000", "1000000", x"FFFFFFFF", 'X');
TestVector(146) <= (x"FFFFFFFF", x"FFFFFFFF", "1000000", x"00000000", 'X');

-- Testing Less Than Operation
TestVector(147) <= (x"00000001", x"00000010", "0001000", x"00000001", 'X');
TestVector(148) <= (x"00000010", x"00000001", "0001000", x"00000000", 'X');
end architecture tb;