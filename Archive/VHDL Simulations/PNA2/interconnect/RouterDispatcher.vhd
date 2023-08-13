library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RouterDispatcher is
  port 
  (
     signal clk  : in std_logic;
     signal cke  : in std_logic;
     signal nrst : in std_logic;
     
     -- Router FIFO Signals
     signal Port_Empty : in  std_logic_vector(15 downto 0);
     signal Port_RD    : out std_logic_vector(15 downto 0);
     
     -- Next Stage Pipeline Control
     signal Valid : out std_logic);
     
end entity RouterDispatcher;

architecture Behavioural of RouterDispatcher is

type State_Type is (Idle, Run1, Run2, Run3, Run4, Run5, Run6, Run7, Run8, Run9, Run10, Run11, Run12, Run13, Run14, Run15, Run16);

signal StateD, StateQ : State_Type;

signal PortEmptyD, PortEmptyQ : std_logic_vector(15 downto 0);

begin
  
SEQ: process (Clk) is
begin
  if rising_edge(Clk) then
    if (nrst = '0') then
      StateQ <= Idle;
      PortEmptyQ <= X"FFFF";
    elsif (cke = '1') then
      StateQ <= StateD;
      PortEmptyQ <= PortEmptyD;
    end if;
  end if;
end process SEQ;

COM: process (StateQ, PortEmptyQ, Port_Empty) is
begin
  case StateQ is
  when Idle =>
    Valid <= '0';
    PortEmptyD <= Port_Empty;
      
    if (Port_Empty(0) = '0') then      
      Port_RD <= x"0001";
      StateD <= Run1;        
    elsif (Port_Empty(1) = '0') then      
      Port_RD <= x"0002";
      StateD <= Run2;        
    elsif (Port_Empty(2) = '0') then      
      Port_RD <= x"0004";
      StateD <= Run3;        
    elsif (Port_Empty(3) = '0') then      
      Port_RD <= x"0008";
      StateD <= Run4;        
    elsif (Port_Empty(4) = '0') then      
      Port_RD <= x"0010";
      StateD <= Run5;        
    elsif (Port_Empty(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (Port_Empty(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (Port_Empty(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (Port_Empty(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (Port_Empty(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (Port_Empty(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (Port_Empty(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (Port_Empty(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (Port_Empty(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (Port_Empty(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (Port_Empty(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
       
  when Run1 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(1) = '0') then      
      Port_RD <= x"0002";
      StateD <= Run2;        
    elsif (PortEmptyQ(2) = '0') then      
      Port_RD <= x"0004";
      StateD <= Run3;        
    elsif (PortEmptyQ(3) = '0') then      
      Port_RD <= x"0008";
      StateD <= Run4;        
    elsif (PortEmptyQ(4) = '0') then      
      Port_RD <= x"0010";
      StateD <= Run5;        
    elsif (PortEmptyQ(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run2 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(2) = '0') then      
      Port_RD <= x"0004";
      StateD <= Run3;        
    elsif (PortEmptyQ(3) = '0') then      
      Port_RD <= x"0008";
      StateD <= Run4;        
    elsif (PortEmptyQ(4) = '0') then      
      Port_RD <= x"0010";
      StateD <= Run5;        
    elsif (PortEmptyQ(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
    
  when Run3 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(3) = '0') then      
      Port_RD <= x"0008";
      StateD <= Run4;        
    elsif (PortEmptyQ(4) = '0') then      
      Port_RD <= x"0010";
      StateD <= Run5;        
    elsif (PortEmptyQ(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run4 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(4) = '0') then      
      Port_RD <= x"0010";
      StateD <= Run5;        
    elsif (PortEmptyQ(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run5 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(5) = '0') then      
      Port_RD <= x"0020";
      StateD <= Run6;        
    elsif (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run6 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(6) = '0') then      
      Port_RD <= x"0040";
      StateD <= Run7;        
    elsif (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run7 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(7) = '0') then      
      Port_RD <= x"0080";
      StateD <= Run8;        
    elsif (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run8 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(8) = '0') then      
      Port_RD <= x"0100";
      StateD <= Run9;        
    elsif (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if;     
        
  when Run9 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(9) = '0') then      
      Port_RD <= x"0200";
      StateD <= Run10;        
    elsif (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run10 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(10) = '0') then      
      Port_RD <= x"0400";
      StateD <= Run11;        
    elsif (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run11 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(11) = '0') then      
      Port_RD <= x"0800";
      StateD <= Run12;        
    elsif (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run12 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(12) = '0') then      
      Port_RD <= x"1000";
      StateD <= Run13;        
    elsif (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run13 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(13) = '0') then      
      Port_RD <= x"2000";
      StateD <= Run14;        
    elsif (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run14 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(14) = '0') then      
      Port_RD <= x"4000";
      StateD <= Run15;        
    elsif (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run15 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    
    if (PortEmptyQ(15) = '0') then       
      Port_RD <= x"8000";
      StateD <= Run16;        
    else
      StateD <= Idle;
      Port_RD <= x"0000";
    end if; 
        
  when Run16 =>
    Valid <= '1';
    PortEmptyD <= PortEmptyQ;
    Port_RD <= x"0000";
    StateD <= Idle;
        
  end case;

end process COM; 
end architecture Behavioural;




