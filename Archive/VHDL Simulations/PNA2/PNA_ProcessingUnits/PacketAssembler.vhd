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

entity PacketAssembler is
  port 
  (
     signal clock   : in  std_logic;
     signal BusClock : in std_logic;
     signal nreset  : in std_logic;
     signal ce      : in std_logic;
     
     signal SourceAddress : in std_logic_vector(15 downto 0);
     signal TargetAddress : in std_logic_vector(15 downto 0);
     
     signal AP_ON : in std_logic;
     signal AP_OFF : in std_logic;
     
     signal SynWeight : in std_logic_vector(15 downto 0);
     signal Syn_ON  : in std_logic;
     signal Syn_OFF : in std_logic;
     
     signal Error : out std_logic;
     -- TX Bus
     signal tx   : out std_logic); 
end entity PacketAssembler;

architecture Behavioural of PacketAssembler is

signal FIFO_Full : std_logic;
signal FIFO_WE : std_logic;
signal PacketData : std_logic_vector(55 downto 0);

signal ErrorD, ErrorQ: std_logic;

signal TwoCompSynWeight : std_logic_vector(15 downto 0);

begin
Error <= ErrorQ;

TWOCOMP_1: entity work.twos_comp_16b
          port map(a =>  SynWeight,
                   Convert => '1',
                   q => TwoCompSynWeight);
                   
UART_TX1: entity Interconnect.uart_tx 
          generic map(PacketLength => 56)
          port map(clock => BusClock,
                   nReset => nreset,
                   FIFO_Full => FIFO_Full,
                   FIFO_CLK => clock,
                   FIFO_WE => FIFO_WE,
                   FIFO_Data_IN => PacketData,
                   tx => tx);

process (Clock, nreset) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      ErrorQ <= '0';  
    else
      ErrorQ <= ErrorD;
    end if;
  end if;
end process;
                               
process(AP_ON, AP_OFF, Syn_ON, Syn_OFF, SourceAddress, TargetAddress, SynWeight, ErrorQ) is
begin
  if (ErrorQ = '1') then
    ErrorD <= '1';
    FIFO_WE <= '0';
  else
    ErrorD <= (AP_ON OR AP_OFF OR Syn_ON OR Syn_OFF) AND FIFO_Full;
   
    if (AP_ON = '1') then
      PacketData(7 downto 0) <= TYPE_AP;
      PacketData(23 downto 8) <= SourceAddress;
      PacketData(55 downto 24) <= x"00000001";
      FIFO_WE <= '1';  
    elsif (AP_OFF = '1') then
      PacketData(7 downto 0) <= TYPE_AP;
      PacketData(23 downto 8) <= SourceAddress;
      PacketData(55 downto 24) <= x"00000000";
      FIFO_WE <= '1';        
    elsif (Syn_ON = '1') then
      PacketData(7 downto 0)   <= TYPE_SYN;
      PacketData(23 downto 8)  <= TargetAddress;
      PacketData(39 downto 24) <= SourceAddress;
      PacketData(55 downto 40) <= SynWeight;
      FIFO_WE <= '1';          
    elsif (Syn_OFF = '1') then
      PacketData(7 downto 0)   <= TYPE_SYN;
      PacketData(23 downto 8)  <= TargetAddress;
      PacketData(39 downto 24) <= SourceAddress;
      PacketData(55 downto 40) <= TwoCompSynWeight;
      FIFO_WE <= '1';
    else
      PacketData <= (others => 'X');
      FIFO_WE <= '0';      
    end if;
  end if;
end process;

end architecture Behavioural;




