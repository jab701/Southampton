library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;
use MIPS_Common.COMMANDSET.All;

entity BarrelShifter is
  port( a : in std_logic_vector(31 downto 0);
    
        ShiftAmnt : in std_logic_vector(4 downto 0);
        
        OP : in std_logic_vector(1 downto 0);
        
        q : out std_logic_vector(31 downto 0));  
end entity BarrelShifter;

architecture Behavioural of BarrelShifter is

signal Shift_In : std_logic;

signal a_rev : std_logic_vector(31 downto 0);

signal Shift_16 : std_logic_vector(31 downto 0);
signal Shift_8  : std_logic_vector(31 downto 0);
signal Shift_4  : std_logic_vector(31 downto 0);
signal Shift_2  : std_logic_vector(31 downto 0);
signal Shift_1  : std_logic_vector(31 downto 0);

signal LeftShift : std_logic;
signal ShiftArith : std_logic;
begin
  
Shift_In_Mux: process (OP, a) is
begin
  if (OP = BRSH_OP_LEFT) then -- LEFT SHIFT LOGICAL
    Shift_In <= '0';
    LeftShift <= '1';
    ShiftArith <= '0';
  elsif (OP = BRSH_OP_RARTH) then -- RIGHT SHIFT ARITH
    Shift_In <= a(31);
    LeftShift <= '0';
    ShiftArith <= '1';  
  else -- DEFAULT -- BRSH_OP_RIGHT -- RIGHT SHIFT LOGICAL
    Shift_In <= '0';
    LeftShift <= '0';
    ShiftArith <= '0';  
  end if;
end process Shift_In_Mux;  

DataRev1: entity work.LeftShiftReversal
          port map(a => a,
                   sel => LeftShift,
                   q => a_rev);
               
DataShift16: entity work.RightShift16Bit
             port map(a => a_rev,
                      Shift_In => Shift_In,
                      sel => ShiftAmnt(4),
                      q => Shift_16);
                   
DataShift8: entity work.RightShift8Bit
             port map(a => Shift_16,
                      Shift_In => Shift_In,
                      sel => ShiftAmnt(3),
                      q => Shift_8);
                   
DataShift4: entity work.RightShift4Bit
             port map(a => Shift_8,
                      Shift_In => Shift_In,
                      sel => ShiftAmnt(2),
                      q => Shift_4);
                   
DataShift2: entity work.RightShift2Bit
             port map(a => Shift_4,
                      Shift_In => Shift_In,
                      sel => ShiftAmnt(1),
                      q => Shift_2);
                   
DataShift1: entity work.RightShift1Bit
             port map(a => Shift_2,
                      Shift_In => Shift_In,
                      sel => ShiftAmnt(0),
                      q => Shift_1); 
                   
DataRev2: entity work.LeftShiftReversal
          port map(a => Shift_1,
                   sel => LeftShift,
                   q => q);                                                                                                               
end architecture Behavioural;

