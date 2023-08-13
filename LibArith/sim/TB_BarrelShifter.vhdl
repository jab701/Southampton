library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity TB_BarrelShifter is
  
end entity TB_BarrelShifter;

architecture Testbench of TB_BarrelShifter is

signal a : std_logic_vector(31 downto 0);

signal ShiftAmnt : std_logic_vector(4 downto 0);

signal OP : std_logic_vector(1 downto 0);

signal q : std_logic_vector(31 downto 0);


type TestVectorType is 
Record
  InputA     : std_logic_vector(31 downto 0);
  ShiftAmnt  : std_logic_vector(4 downto 0);
  OP         : std_logic_vector(1 downto 0);
  q          : std_logic_vector(31 downto 0);
end Record;

type TestVectorArray is array (natural range <>) of TestVectorType;

signal TestVector : TestVectorArray(127 downto 0);

signal StartTest : std_logic;

begin
  
BARSHIFT_1: entity work.BarrelShifter
            port map(a => a,
                     ShiftAmnt  => ShiftAmnt,
                     OP         => OP,
                     q => q);
                     
-- a          , ShiftAmnt, LS , SA , q          ;
-- x"00000000", "00000"  , '0', '0', x"00000000";
   
StartTest <= '0', '1' after 1 ns;

process is
  variable ExpQ : integer;
  variable ActualQ : integer;
begin
    wait until StartTest = '1';
    for i in 0 to (TestVector'length-1) loop
      a <= TestVector(i).InputA;
      ShiftAmnt <= TestVector(i).ShiftAmnt;
      OP <= TestVector(i).OP;
      wait for 1 ns;
      ExpQ := to_integer(signed(TestVector(i).q));
      ActualQ := to_integer(signed(q));
      
      assert (TestVector(i).Q = q)
        report "Error Test Vector: " & integer'image(i) & " failed. Output Should have been: " & integer'image(ExpQ) & " but was instead: " & integer'image(ActualQ) & " "  
        severity error;
    end loop;
    
    report "TestBench Complete";  
end process;

  
-- a          , ShiftAmnt, OP , SA , q          ;
-- x"00000000", "00000"  , '0', '0', x"00000000";

-- Check 0 to 31 Bit Right Shift
TestVector(0) <= (x"FFFF000F", "00000", "00", x"FFFF000F");
TestVector(1) <= (x"FFFF000F", "00001", "00", x"7FFF8007");
TestVector(2) <= (x"FFFF000F", "00010", "00", x"3FFFC003");
TestVector(3) <= (x"FFFF000F", "00011", "00", x"1FFFE001");
TestVector(4) <= (x"FFFF000F", "00100", "00", x"0FFFF000");
TestVector(5) <= (x"FFFF000F", "00101", "00", x"07FFF800");
TestVector(6) <= (x"FFFF000F", "00110", "00", x"03FFFC00");
TestVector(7) <= (x"FFFF000F", "00111", "00", x"01FFFE00");
TestVector(8) <= (x"FFFF000F", "01000", "00", x"00FFFF00");
TestVector(9) <= (x"FFFF000F", "01001", "00", x"007FFF80");
TestVector(10) <= (x"FFFF000F", "01010", "00", x"003FFFC0");
TestVector(11) <= (x"FFFF000F", "01011", "00", x"001FFFE0");
TestVector(12) <= (x"FFFF000F", "01100", "00", x"000FFFF0");
TestVector(13) <= (x"FFFF000F", "01101", "00", x"0007FFF8");
TestVector(14) <= (x"FFFF000F", "01110", "00", x"0003FFFC");
TestVector(15) <= (x"FFFF000F", "01111", "00", x"0001FFFE");
TestVector(16) <= (x"FFFF000F", "10000", "00", x"0000FFFF");
TestVector(17) <= (x"FFFF000F", "10001", "00", x"00007FFF");
TestVector(18) <= (x"FFFF000F", "10010", "00", x"00003FFF");
TestVector(19) <= (x"FFFF000F", "10011", "00", x"00001FFF");
TestVector(20) <= (x"FFFF000F", "10100", "00", x"00000FFF");
TestVector(21) <= (x"FFFF000F", "10101", "00", x"000007FF");
TestVector(22) <= (x"FFFF000F", "10110", "00", x"000003FF");
TestVector(23) <= (x"FFFF000F", "10111", "00", x"000001FF");
TestVector(24) <= (x"FFFF000F", "11000", "00", x"000000FF");
TestVector(25) <= (x"FFFF000F", "11001", "00", x"0000007F");
TestVector(26) <= (x"FFFF000F", "11010", "00", x"0000003F");
TestVector(27) <= (x"FFFF000F", "11011", "00", x"0000001F");
TestVector(28) <= (x"FFFF000F", "11100", "00", x"0000000F");
TestVector(29) <= (x"FFFF000F", "11101", "00", x"00000007");
TestVector(30) <= (x"FFFF000F", "11110", "00", x"00000003");
TestVector(31) <= (x"FFFF000F", "11111", "00", x"00000001");
-- Check 0 to 31 Bit Right Arith Shift with Sign bit = '0'
TestVector(32) <= (x"40000000", "00000", "10", x"40000000");
TestVector(33) <= (x"40000000", "00001", "10", x"20000000");
TestVector(34) <= (x"40000000", "00010", "10", x"10000000");
TestVector(35) <= (x"40000000", "00011", "10", x"08000000");
TestVector(36) <= (x"40000000", "00100", "10", x"04000000");
TestVector(37) <= (x"40000000", "00101", "10", x"02000000");
TestVector(38) <= (x"40000000", "00110", "10", x"01000000");
TestVector(39) <= (x"40000000", "00111", "10", x"00800000");
TestVector(40) <= (x"40000000", "01000", "10", x"00400000");
TestVector(41) <= (x"40000000", "01001", "10", x"00200000");
TestVector(42) <= (x"40000000", "01010", "10", x"00100000");
TestVector(43) <= (x"40000000", "01011", "10", x"00080000");
TestVector(44) <= (x"40000000", "01100", "10", x"00040000");
TestVector(45) <= (x"40000000", "01101", "10", x"00020000");
TestVector(46) <= (x"40000000", "01110", "10", x"00010000");
TestVector(47) <= (x"40000000", "01111", "10", x"00008000");
TestVector(48) <= (x"40000000", "10000", "10", x"00004000");
TestVector(49) <= (x"40000000", "10001", "10", x"00002000");
TestVector(50) <= (x"40000000", "10010", "10", x"00001000");
TestVector(51) <= (x"40000000", "10011", "10", x"00000800");
TestVector(52) <= (x"40000000", "10100", "10", x"00000400");
TestVector(53) <= (x"40000000", "10101", "10", x"00000200");
TestVector(54) <= (x"40000000", "10110", "10", x"00000100");
TestVector(55) <= (x"40000000", "10111", "10", x"00000080");
TestVector(56) <= (x"40000000", "11000", "10", x"00000040");
TestVector(57) <= (x"40000000", "11001", "10", x"00000020");
TestVector(58) <= (x"40000000", "11010", "10", x"00000010");
TestVector(59) <= (x"40000000", "11011", "10", x"00000008");
TestVector(60) <= (x"40000000", "11100", "10", x"00000004");
TestVector(61) <= (x"40000000", "11101", "10", x"00000002");
TestVector(62) <= (x"40000000", "11110", "10", x"00000001");
TestVector(63) <= (x"40000000", "11111", "10", x"00000000");
-- Check 0 to 31 Bit Right Arith Shift with Sign bit = '1'
TestVector(64) <= (x"FFFF000F", "00000", "10", x"FFFF000F");
TestVector(65) <= (x"80000000", "00001", "10", x"C0000000");
TestVector(66) <= (x"80000000", "00010", "10", x"E0000000");
TestVector(67) <= (x"80000000", "00011", "10", x"F0000000");
TestVector(68) <= (x"80000000", "00100", "10", x"F8000000");
TestVector(69) <= (x"80000000", "00101", "10", x"FC000000");
TestVector(70) <= (x"80000000", "00110", "10", x"FE000000");
TestVector(71) <= (x"80000000", "00111", "10", x"FF000000");
TestVector(72) <= (x"80000000", "01000", "10", x"FF800000");
TestVector(73) <= (x"80000000", "01001", "10", x"FFC00000");
TestVector(74) <= (x"80000000", "01010", "10", x"FFE00000");
TestVector(75) <= (x"80000000", "01011", "10", x"FFF00000");
TestVector(76) <= (x"80000000", "01100", "10", x"FFF80000");
TestVector(77) <= (x"80000000", "01101", "10", x"FFFC0000");
TestVector(78) <= (x"80000000", "01110", "10", x"FFFE0000");
TestVector(79) <= (x"80000000", "01111", "10", x"FFFF0000");
TestVector(80) <= (x"80000000", "10000", "10", x"FFFF8000");
TestVector(81) <= (x"80000000", "10001", "10", x"FFFFC000");
TestVector(82) <= (x"80000000", "10010", "10", x"FFFFE000");
TestVector(83) <= (x"80000000", "10011", "10", x"FFFFF000");
TestVector(84) <= (x"80000000", "10100", "10", x"FFFFF800");
TestVector(85) <= (x"80000000", "10101", "10", x"FFFFFC00");
TestVector(86) <= (x"80000000", "10110", "10", x"FFFFFE00");
TestVector(87) <= (x"80000000", "10111", "10", x"FFFFFF00");
TestVector(88) <= (x"80000000", "11000", "10", x"FFFFFF80");
TestVector(89) <= (x"80000000", "11001", "10", x"FFFFFFC0");
TestVector(90) <= (x"80000000", "11010", "10", x"FFFFFFE0");
TestVector(91) <= (x"80000000", "11011", "10", x"FFFFFFF0");
TestVector(92) <= (x"80000000", "11100", "10", x"FFFFFFF8");
TestVector(93) <= (x"80000000", "11101", "10", x"FFFFFFFC");
TestVector(94) <= (x"80000000", "11110", "10", x"FFFFFFFE");
TestVector(95) <= (x"80000000", "11111", "10", x"FFFFFFFF");
-- Check 0 to 31 Bit Left Shift
TestVector(96) <= (x"00000001", "00000", "01", x"00000001");
TestVector(97) <= (x"00000001", "00001", "01", x"00000002");
TestVector(98) <= (x"00000001", "00010", "01", x"00000004");
TestVector(99) <= (x"00000001", "00011", "01", x"00000008");
TestVector(100) <= (x"00000001", "00100", "01", x"00000010");
TestVector(101) <= (x"00000001", "00101", "01", x"00000020");
TestVector(102) <= (x"00000001", "00110", "01", x"00000040");
TestVector(103) <= (x"00000001", "00111", "01", x"00000080");
TestVector(104) <= (x"00000001", "01000", "01", x"00000100");
TestVector(105) <= (x"00000001", "01001", "01", x"00000200");
TestVector(106) <= (x"00000001", "01010", "01", x"00000400");
TestVector(107) <= (x"00000001", "01011", "01", x"00000800");
TestVector(108) <= (x"00000001", "01100", "01", x"00001000");
TestVector(109) <= (x"00000001", "01101", "01", x"00002000");
TestVector(110) <= (x"00000001", "01110", "01", x"00004000");
TestVector(111) <= (x"00000001", "01111", "01", x"00008000");
TestVector(112) <= (x"00000001", "10000", "01", x"00010000");
TestVector(113) <= (x"00000001", "10001", "01", x"00020000");
TestVector(114) <= (x"00000001", "10010", "01", x"00040000");
TestVector(115) <= (x"00000001", "10011", "01", x"00080000");
TestVector(116) <= (x"00000001", "10100", "01", x"00100000");
TestVector(117) <= (x"00000001", "10101", "01", x"00200000");
TestVector(118) <= (x"00000001", "10110", "01", x"00400000");
TestVector(119) <= (x"00000001", "10111", "01", x"00800000");
TestVector(120) <= (x"00000001", "11000", "01", x"01000000");
TestVector(121) <= (x"00000001", "11001", "01", x"02000000");
TestVector(122) <= (x"00000001", "11010", "01", x"04000000");
TestVector(123) <= (x"00000001", "11011", "01", x"08000000");
TestVector(124) <= (x"00000001", "11100", "01", x"10000000");
TestVector(125) <= (x"00000001", "11101", "01", x"20000000");
TestVector(126) <= (x"00000001", "11110", "01", x"40000000");
TestVector(127) <= (x"00000001", "11111", "01", x"80000000");
                                                          
end architecture Testbench;




