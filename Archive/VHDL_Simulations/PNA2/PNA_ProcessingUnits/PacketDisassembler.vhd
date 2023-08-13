----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  26th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  
-- Description:  
--
-- Dependencies: None
--
-- Revision: 1.00 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library Interconnect;
use Interconnect.NetworkDefs.ALL;

entity PacketDisassembler is
  port 
  (
     signal clock   : in  std_logic;
     signal BusClock : in std_logic;
     signal nreset  : in std_logic;
     signal ce      : in std_logic;
     
     signal ProcessingUnitAddress : in std_logic_vector(7 downto 0);
     
     signal PacketSourceAddress : out std_logic_vector(15 downto 0);
     
     signal MemoryAddress : out std_logic_vector(7 downto 0);
     signal MemoryDataIn  : in std_logic_vector(31 downto 0);
     signal MemoryDataOut : out std_logic_vector(31 downto 0);
     
     signal Variable_RD   : out std_logic;
     
     signal Parameter_WE  : out std_logic_vector(15 downto 0);
     signal Enable_WE     : out std_logic;
     signal Variable_WE   : out std_logic;
     signal MaxAddress_WE : out std_logic;

     -- RX Bus
     signal rx   : in std_logic); 
end entity PacketDisassembler;

architecture Behavioural of PacketDisassembler is

signal FIFO_Empty : std_logic;
signal FIFO_RD : std_logic;
signal PacketData : std_logic_vector(55 downto 0);

signal ErrorD, ErrorQ: std_logic;

type States is (Idle, Read, Decode, Write);
  
signal StateD, StateQ : States;

signal Data_WE : std_logic;
signal ReadData_WE : std_logic;

signal Data : std_logic_vector(31 downto 0);
signal ReadData : std_logic_vector(31 downto 0);
begin
       
UART_RX1: entity Interconnect.uart_rx 
          generic map(PacketLength => 56)
          port map(clock => BusClock,
                   nReset => nreset,
                   rx => rx,
                   Data_Clock => BusClock,
                   Empty => FIFO_Empty,
                   RD => FIFO_RD,
                   Data_Out => PacketData);

REG: process (clock) is
begin
  if rising_edge(Clock) then
    if (Data_WE = '1') then
      Data <= PacketData;  
    end if;
    
    if (ReadData_WE = '1') then
      ReadData <= MemoryDataIn;
    end if;
  end if;    
end process REG;
  
SEQ: process (clock) is
begin
  if rising_edge(clock) then
    if (nreset = '0') then
      StateQ <= Idle;  
    else
      StateQ <= StateD;
    end if;
  end if;
end process SEQ;

COM: process (StateQ) is
begin
  case (StateQ) is
  when Idle =>
    FIFO_RD <= '0';
    Variable_RD <= '0';
    
    Parameter_WE <= (others => '0');
    Enable_WE <= '0';
    Variable_WE <= '0';
    MaxAddress_WE <= '0';
    
    Data_WE <= '0';
    ReadData_WE <= '0';
    
    if (FIFO_Empty = '1') then
      StateD <= Idle;
    else
      StateD <= Read;
    end if;
      
  when Read =>
    FIFO_RD <= '1';
    Variable_RD <= '0';
    
    Parameter_WE <= (others => '0');
    Enable_WE <= '0';
    Variable_WE <= '0';
    MaxAddress_WE <= '0';
    
    Data_WE <= '1';
    ReadData_WE <= '0';
    
    StateD <= Decode;
    
  when Decode =>
    FIFO_RD <= '0';
    Variable_RD <= '0';
    
    Parameter_WE <= (others => '0');
    Enable_WE <= '0';
    Variable_WE <= '0';
    MaxAddress_WE <= '0';
    
    Data_WE <= '0';
    ReadData_WE <= '0';  
    
    StateD <= Write;
    
  when Write =>
    FIFO_RD <= '0';
    Variable_RD <= '0';
    
    Parameter_WE <= (others => '0');
    Enable_WE <= '0';
    Variable_WE <= '0';
    MaxAddress_WE <= '0';
    
    Data_WE <= '0';
    ReadData_WE <= '0';  
    
    StateD <= Idle;
  end case;  
end process COM;

end architecture Behavioural;






