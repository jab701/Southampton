library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibElegans;
use LibElegans.ALL;

entity TB_ElegansLoco_BusRead is
  port (uC_Clock : in std_logic;
        nReset : in std_logic;
        Interrupt : in std_logic;
        BusWriteInProgress : in std_logic;
        BusReadInProgress : out std_logic;
        BusAddress : out std_logic_vector(3 downto 0);
        BusData : in std_logic_vector(7 downto 0));
end TB_ElegansLoco_BusRead;

architecture Testbench of TB_ElegansLoco_BusRead is
type DSStates is (Initial, Save);
signal DSStateD, DSStateQ : DSStates;

type Data is array (10 downto 0) of std_logic_vector(7 downto 0);
signal DSDataD, DSDataQ : Data; 

signal BusAddressD, BusAddressQ : std_logic_vector(3 downto 0);
signal Interrupt1, Interrupt2 : std_logic;
begin
BusAddress <= BusAddressQ;

seq: process (uC_Clock, nReset) is
begin
  if (nReset = '0') then
    DSStateQ <= Initial;
    BusAddressQ <= (others => '0');
    DSDataQ <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00"); 
    Interrupt1 <= '0';
    Interrupt2 <= '0';
  elsif rising_edge(uC_Clock) then
    DSStateQ <= DSStateD;
    BusAddressQ <= BusAddressD;
    DSDataQ <= DSDataD;
    Interrupt2 <= Interrupt1;
    Interrupt1 <= Interrupt;    
  end if;  
end process seq;

com: process (DSStateQ, DSDataQ, BusAddressQ, BusData, BusWriteInProgress, Interrupt1, Interrupt2) is
begin
  case DSStateQ is
    when Initial =>
      
      BusAddressD <= (others => '0');
      DSDataD <= DSDataQ;
      BusReadInProgress <= '0';
      
      if ((Interrupt1 = '1') AND (Interrupt2 = '0') AND (BusWriteInProgress = '0')) then
        DSStateD <= Save;  
      else
        DSStateD <= Initial;
      end if;  
        
    when Save =>
      DSDataD <= DSDataQ;
      DSDataD(to_integer(unsigned(BusAddressQ))) <= BusData;      
      
      BusAddressD <= BusAddressQ + 1;
      BusReadInProgress <= '1';
     
      if (BusAddressQ = x"A") then
        DSStateD <= Initial;
      else
        DSStateD <= Save;
      end if;
  end case;    
end process com;

end architecture Testbench;
