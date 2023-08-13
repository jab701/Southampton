library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibElegans;
use LibElegans.ALL;

entity TB_ElegansLoco_BusWrite is
  port (uC_Clock : in std_logic;
        nReset : in std_logic;
        BusWriteInProgress : out std_logic;
        BusReadInProgress : in std_logic;
        BusAddress : out std_logic_vector(3 downto 0);
        LoadControlData : in std_logic;
        ControlDataSelect : in integer;
        nRD : out std_logic;
        WR : out std_logic;
        BusData : out std_logic_vector(7 downto 0));
end TB_ElegansLoco_BusWrite;

architecture Testbench of TB_ElegansLoco_BusWrite is

type DCSET is array(10 downto 0) of std_logic_vector(7 downto 0);
type DCArray is array(2 downto 0) of DCSET;
signal DCData : DCArray;

type DCStates is (Initial, Waiting, WriteData, Write);
signal DCStateD, DCStateQ : DCStates;

signal BusAddressD, BusAddressQ : std_logic_vector(3 downto 0);
signal LoadControlData1, LoadControlData2 : std_logic; 
begin
DCData(0) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"C7");
DCData(1) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"00");
DCData(2) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"F8");  

BusAddress <= BusAddressQ;

seq: process (uC_Clock, nReset) is
begin
  if (nReset = '0') then
    DCStateQ <= Initial;
    BusAddressQ <= (others => '0');
    LoadControlData1 <= '0';
    LoadControlData2 <= '0';
  elsif rising_edge(uC_Clock) then
    DCStateQ <= DCStateD;
    BusAddressQ <= BusAddressD;
    LoadControlData2 <= LoadControlData1;
    LoadControlData1 <= LoadControlData;
  end if;  
end process seq;

com: process (DCStateQ, DCData, BusAddressQ, ControlDataSelect, BusReadInProgress, LoadControlData1, LoadControlData2) is
begin
  case DCStateQ is
    when Initial =>
      
      BusAddressD <= (others => '0');
      BusWriteInProgress <= '0';
      BusData <= (others => '0');
      nRD <= '0';
      WR <= '0';
      
      
      if (LoadControlData1 = '1' AND LoadControlData2 = '0') then
        DCStateD <= Waiting;
      else
        DCStateD <= Initial;  
      end if; 
      
    when Waiting =>
  
      BusAddressD <= (others => '0');
      BusWriteInProgress <= '0';
      BusData <= (others => '0');
      nRD <= '0';
      WR <= '0';
                  
      if (BusReadInProgress = '1') then
        DCStateD <= Waiting;  
      else
        DCStateD <= WriteData;  
      end if;
     
        
    when WriteData =>
      BusAddressD <= BusAddressQ;
      BusWriteInProgress <= '1';
      BusData <= DCData(ControlDataSelect)(to_integer(unsigned(BusAddressQ)));
      DCStateD <= Write;
      nRD <= '1';
      WR <= '0';
      
    when Write =>
      BusAddressD <= BusAddressQ + 1;
      BusWriteInProgress <= '1';    
      BusData <= DCData(ControlDataSelect)(to_integer(unsigned(BusAddressQ)));
      nRD <= '1';
      WR <= '1';
            
      if (BusAddressQ = x"A") then
        DCStateD <= Initial;
      else
        DCStateD <= WriteData;
      end if;    
      
      
  end case;    
end process com;  
end architecture Testbench;
