
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library PNA_LibNeuron;
USE PNA_LibNeuron.ALL;

use std.textio.all;

entity TBPNA is
  generic (NumberNeuron1 : integer := 100;
           NumberNeuron2 : integer := 16;
           NumberSynapse : integer := 200);
end entity TBPNA;

architecture TestBench of TBPNA is

signal Neuron_Clock : std_logic := '0';
signal Neuron_CKE : std_logic := '1';
signal Bus_Clock : std_logic := '0';
signal uCClock : std_logic := '0';

signal nReset : std_logic;



signal nCS : std_logic;
signal SCLK : std_logic;
signal SDI : std_logic;
signal SDO : std_logic;

signal Config_SCLK : std_logic;
signal Config_SDI  : std_logic;
signal Config_SDO  : std_logic;

type CtrlStates is (Initial, Configure, Idle, WriteBit, SetClock, ReadBit, ClearClock, ShiftBits);
signal CtrlStatesD, CtrlStatesQ : CtrlStates;

signal ConfigEnable : std_logic;
signal ConfigComplete : std_logic;

signal MainReset : std_logic;

type NeuronControlArray is array (2 downto 0) of std_logic_vector(255 downto 0);
signal NeuronControlData : NeuronControlArray;
signal NeuronActivityD : std_logic_vector(255 downto 0);
signal NeuronActivityQ : std_logic_vector(255 downto 0);

signal NeuronEnableSetSelect : integer := 0;
signal NeuronActivityAddressQ : integer := 255;
signal NeuronActivityAddressD : integer := 0;

signal Interupt : std_logic := '0';


begin

NeuronControlData(0) <= x"00000000000000000000000000000000000000000013FFFFFFFFFFFFFFFFFFFF";
NeuronControlData(1) <= x"00000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFF";
NeuronControlData(2) <= x"0000000000000000000000000000000000000000002CFFFFFFFFFFFFFFFFFFFF";

PNA1: entity work.PNA_Device 
      generic map(NumberOfNeuron1 => 100,
                  NumberOfNeuron2 => 16,
                  NumberOfSynapses => 200,
                  AddressBusWidth => 8)
      port map(Neuron_Clock => Neuron_Clock ,
               Neuron_CKE => Neuron_CKE,
               Bus_Clock => Bus_Clock,
               nReset => nReset,
               nCS => nCS,
               Config_SCLK => Config_SCLK,
               Config_SDI => Config_SDI,
               Config_SDO => Config_SDO,
               
               SCLK => SCLK,
               SDI => SDI,
               SDO => SDO,
               
               SNC_CHAIN_OUT => open, -- SNC_CHAIN_OUT is not used in this simulation
               SND_CHAIN_IN => '0');

               
Neuron_Clock <= NOT(Neuron_Clock) after 500 ns;
Bus_Clock <= NOT(Bus_Clock) after 5 ns;
uCClock <= NOT(uCClock) after 10 ns;
MainReset <= '0', '1' after 10 ns;

NeuronEnableSetSelect <= 0;
Interupt <= NOT(Interupt) after 500 us;

SDI <= NeuronControlData(NeuronEnableSetSelect)(NeuronActivityAddressQ);

PNA_CONFIGTB: entity work.TBPNA_Config
    port map(Clock    => uCClock,
             nReset   => MainReset,
             Enable   => ConfigEnable,
             Complete => ConfigComplete,
             SCLK     => Config_SCLK,
             SDO      => Config_SDI);
             

              
MAINCTRLSEQ: process (MainReset, uCClock) is
begin
  if (MainReset = '0') then
    CtrlStatesQ <= Initial;
    NeuronActivityAddressQ <= 255;
    NeuronActivityQ <= (others => '0');  
  elsif rising_edge(uCClock) then
    CtrlStatesQ <= CtrlStatesD; 
    NeuronActivityAddressQ <=  NeuronActivityAddressD;
    NeuronActivityQ <= NeuronActivityD;
  end if;
  
end process MAINCTRLSEQ;

MAINCTRLCOM: process (CtrlStatesQ, ConfigComplete, NeuronActivityAddressQ, NeuronActivityQ, Interupt, SDO) is
begin
    NeuronActivityAddressD <= NeuronActivityAddressQ;
    NeuronActivityD <= NeuronActivityQ;
    
  case CtrlStatesQ is
  when Initial =>
    SCLK <= '0';
    nCS <= '1';

    nReset <= '0';
    ConfigEnable <= '0';
         
    if (ConfigComplete = '0') then
      CtrlStatesD <= Configure;  
    else
      CtrlStatesD <= Idle;  
    end if;
    
  when Configure =>
    SCLK <= '0';
    nCS <= '0'; -- Select the chip

    nReset <= '0';
    ConfigEnable <= '1';
            
    if (ConfigComplete = '1') then
      CtrlStatesD <= Idle;
    else
      CtrlStatesD <= Configure;
    end if;
  
  when Idle => 
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '0';
    nCS <= '1'; -- Deselect chip
    
    NeuronActivityAddressD <= 255; 
      
    if rising_edge(Interupt) then
      CtrlStatesD <= WriteBit;
    else
      CtrlStatesD <= Idle;      
    end if;

        
  when WriteBit =>
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '0';
    nCS <= '0'; -- Deselect chip    
    CtrlStatesD <= SetClock;  
          
  when SetClock => 
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '1';
    nCS <= '0'; -- Deselect chip    
    CtrlStatesD <= ReadBit;  
          
  when ReadBit =>
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '0';
    nCS <= '0'; -- Deselect chip 
    NeuronActivityD(NeuronActivityAddressQ) <= SDO;   
    CtrlStatesD <= ClearClock;
            
  when ClearClock => 
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '0';
    nCS <= '0'; -- Deselect chip    
    CtrlStatesD <= ShiftBits; 
           
  when ShiftBits =>
    nReset <= '1';
    ConfigEnable <= '0';

    SCLK <= '0';
    nCS <= '0'; -- Deselect chip

     
    
    
    if (NeuronActivityAddressQ = 0) then
      NeuronActivityAddressD <= NeuronActivityAddressQ;
      CtrlStatesD <= Idle;            
    else
      NeuronActivityAddressD <= NeuronActivityAddressQ - 1;      
      CtrlStatesD <= WriteBit;    
    end if;    
  end case;
  
end process MAINCTRLCOM;




  
end architecture TestBench;
