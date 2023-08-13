-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    26/02/2007 
-- Design Name: 
-- Module Name:    C Elegans Neuron Types
-- Project Name:   C Elegans Locomotion
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: Library - MBED_Claverol
--sim:/celegans_body
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibElegans;
use LibElegans.ALL;

entity TB_ElegansLoco is

end TB_ElegansLoco;

architecture Testbench of TB_ElegansLoco is

signal Clock : std_logic := '0';
signal CKE   : std_logic := '1';
signal nReset : std_logic; -- Active Low

signal uC_Clock : std_logic := '0';
signal uC_nReset : std_logic;

signal BusData : std_logic_vector(7 downto 0);
signal BusDataIn : std_logic_vector(7 downto 0);
signal ControlDataBusAddress :std_logic_vector(3 downto 0);
signal NeuronDataBusAddress : std_logic_vector(3 downto 0);

signal Interrupt : std_logic;
signal LoadControlData : std_logic;
signal ControlDataSelect : integer;
signal BusWriteInProgress : std_logic;
signal BusReadInProgress : std_logic;
signal WR : std_logic;
signal nRD : std_logic;
signal BusAddress : std_logic_vector(3 downto 0);

begin
CElegans_Loco: entity LibElegans.Elegans_Loco
                      Port map(Clock => Clock,
                               CKE => CKE,
                               nReset => nReset,
                               Interrupt => Interrupt,
                               -- Data Scan
                               nRD => nRD,
                               WR => WR,
                               Address => BusAddress,
                               Data => BusData);
                               
BusRead: entity LibElegans.TB_ElegansLoco_BusRead
  port map(uC_Clock => uC_Clock,
           nReset => uC_nReset,
           Interrupt => Interrupt,
           BusWriteInProgress => BusWriteInProgress,
           BusReadInProgress => BusreadInProgress,
           BusAddress => NeuronDataBusAddress,
           BusData => BusData);
           
BusWrite: entity LibElegans.TB_ElegansLoco_BusWrite
  port map(uC_Clock => uC_Clock,
           nReset => uC_nReset,
           BusWriteInProgress => BusWriteInProgress,
           BusReadInProgress => BusreadInProgress,
           BusAddress => ControlDataBusAddress,
           LoadControlData => LoadControlData,
           ControlDataSelect => COntrolDataSelect,
           nRD => nRD,
           WR => WR,
           BusData => BusDataIn);           
           
                               
                               
Clock <= NOT(Clock) after 500 ns; -- Clock with 1Mhz Frequency, 50% Duty Cycle
uC_Clock <= NOT(uC_Clock) after 25 ns; -- Clock with 200Mhz Frequency, 50% duty cycle
    
uC_nReset <= '0', '1' after 1 us;
nReset <= '0', '1' after 100 us;

                               
-- (8)NRD, NRV, AVB, AVA, TSD, TSV, NRV_PH, TSV_PH(0)
-- (8)VD, VA, VB, VM, DD, DA, DB, DM(0)

-- Enable Signal Sets
LoadControlData <= '0', '1' after 2 us, '0' after 3 us;
 --       '1' after 5000 ms,  '0' after 5000.001 ms,
 --       '1' after 7000 ms,  '0' after 7000.001 ms,
 --       '1' after 12000 ms, '0' after 12000.001 ms,
 --       '1' after 14000 ms, '0' after 14000.001 ms;                        
        
ControlDataSelect <= 0, 1 after 5000 ms, 2 after 7000 ms, 1 after 12000 ms, 0 after 14000 ms; 

process (BusWriteInProgress, BusDataIn, ControlDataBusAddress, NeuronDataBusAddress) is
  begin
    if (BusWriteInProgress = '1') then -- Write to device
      BusData <= BusDataIn;
      BusAddress <= ControlDataBusAddress;
    else                              -- Read from device
      BusData <= (others => 'Z');
      BusAddress <= NeuronDataBusAddress;
    end if;
end process;
  
 

end architecture Testbench;

