----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey - PhD Research Student 
-- 
-- Create Date:    14:14:51 01/17/2007 
-- Design Name: 
-- Module Name:    C Elegans Locomotion Circuit
-- Project Name:   
-- Target Devices: 
-- Tool versions:  ModelSim SE 6.2F
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;
use LibNeuron.TYPEDEFINITIONS.ALL;

library LibElegans;
use LibElegans.ALL;


entity Elegans_Loco is
    port (-- Control Signals
          signal Clock  : in std_logic;
          signal CKE    : in std_logic;
          signal nReset : in std_logic; -- Active Low
          signal Interrupt : out std_logic;
          -- Parallel Bus Interface
          signal nRD : std_logic;
          signal WR : std_logic;
          signal Address : in std_logic_vector(3 downto 0);
          signal Data : inout std_logic_vector(7 downto 0) 
          );
end Elegans_Loco;

architecture Behavioural of Elegans_Loco is

-- Axon Signals (AxonChannel) 
-- For Network Drivers
signal NRD_Ax: std_logic;
signal NRV_Ax: std_logic;
signal TSD_Ax: std_logic;
signal TSV_Ax: std_logic;
signal AVA_Ax: std_logic;
signal AVB_Ax: std_logic;

type DataArray is array(9 downto 0) of std_logic_vector(7 downto 0);
signal Neuron_Ax : DataArray;
signal Neuron_En : DataArray;

signal DriverNeuron_Ax : std_logic_vector(7 downto 0);
signal Driver_Enable : std_logic_vector(7 downto 0);

signal ReadMuxOutput : std_logic_vector(7 downto 0);
signal NeuronControlCE : std_logic_vector(10 downto 0);

signal NRD_nReset : std_logic;
signal NRV_nReset : std_logic;
signal AVB_nReset : std_logic;
signal AVA_nReset : std_logic;
signal TSD_nReset : std_logic;
signal TSV_nReset : std_logic;
  
begin

Interrupt1: entity LibElegans.InterruptTimer
  port map(Clock, nReset, Interrupt);


BusMode: process (nRD, ReadMuxOutput) is
begin
  if (nRD = '1') then -- Bus Writes Enabled
    Data <= (others => 'Z');
  else  -- Bus Read Mode
    Data <= ReadMuxOutput;
  end if;
end process BusMode; 
    
NeuronDataAddress: process (Address, DriverNeuron_Ax, Neuron_Ax) is
begin
  if (Address = x"0") then
    ReadMuxOutput <= DriverNeuron_Ax;  
  elsif (Address = x"1") then
    ReadMuxOutput <= Neuron_Ax(0);     
  elsif (Address = x"2") then
    ReadMuxOutput <= Neuron_Ax(1);     
  elsif (Address = x"3") then
    ReadMuxOutput <= Neuron_Ax(2);       
  elsif (Address = x"4") then
    ReadMuxOutput <= Neuron_Ax(3);     
  elsif (Address = x"5") then 
    ReadMuxOutput <= Neuron_Ax(4);      
  elsif (Address = x"6") then
    ReadMuxOutput <= Neuron_Ax(5);       
  elsif (Address = x"7") then 
    ReadMuxOutput <= Neuron_Ax(6);      
  elsif (Address = x"8") then
    ReadMuxOutput <= Neuron_Ax(7);       
  elsif (Address = x"9") then
    ReadMuxOutput <= Neuron_Ax(8);
  elsif (Address = x"A") then
    ReadMuxOutput <= Neuron_Ax(9);         
  else
    ReadMuxOutput <= (others => '0'); 
  end if;    
end process NeuronDataAddress;  
 
NeuronControlAddress: process (nRD, Address) is
begin
  NeuronControlCE <= (others => '0');
  if (nRD = '1') then
    if (Address = x"0") then
      NeuronControlCE(0) <= '1'; 
    elsif (Address = x"1") then
      NeuronControlCE(1) <= '1';     
    elsif (Address = x"2") then
      NeuronControlCE(2) <= '1';     
    elsif (Address = x"3") then
      NeuronControlCE(3) <= '1';        
    elsif (Address = x"4") then
      NeuronControlCE(4) <= '1';     
    elsif (Address = x"5") then 
      NeuronControlCE(5) <= '1';       
    elsif (Address = x"6") then
      NeuronControlCE(6) <= '1';        
    elsif (Address = x"7") then 
      NeuronControlCE(7) <= '1';       
    elsif (Address = x"8") then
      NeuronControlCE(8) <= '1';      
    elsif (Address = x"9") then
      NeuronControlCE(9) <= '1'; 
    elsif (Address = x"A") then
      NeuronControlCE(10) <= '1';         
    end if;
  end if;     
end process NeuronControlAddress; 
  
DriverNeuronControlUnits : entity LibElegans.DataScan
               port map(Clock   => WR,          
                        CE  => NeuronControlCE(0), Data_In => Data ,
                        Data_Out  => Driver_Enable);   
                        
NeuronControlUnits : FOR i in 1 to 10 generate
  NeuronControlUnits : entity LibElegans.DataScan
               port map(Clock   => WR,        
                        CE  => NeuronControlCE(i), Data_In => Data ,
                        Data_Out  => Neuron_En(i-1));                             
end generate NeuronControlUnits;

DriverNeuron_Ax(0) <= NRD_Ax;
DriverNeuron_Ax(1) <= NRV_Ax;
DriverNeuron_Ax(2) <= AVB_Ax;
DriverNeuron_Ax(3) <= AVA_Ax;
DriverNeuron_Ax(4) <= TSD_Ax;
DriverNeuron_Ax(5) <= TSV_Ax;
DriverNeuron_Ax(6) <= '0';
DriverNeuron_Ax(7) <= '0';

NRD_nReset <= nReset AND Driver_Enable(0);
NRV_nReset <= nReset AND Driver_Enable(1);
AVB_nReset <= nReset AND Driver_Enable(2);
AVA_nReset <= nReset AND Driver_Enable(3);
TSD_nReset <= nReset AND Driver_Enable(4);
TSV_nReset <= nReset AND Driver_Enable(5);
       
-- Network Drivers --     
N_NRD: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, NRD_nReset,'0',NRD_Ax);
                   
N_NRV: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, NRV_nReset,Driver_Enable(6),NRV_Ax);
                      
N_AVB: entity LibElegans.ElegansDriverNeuron(CLSAV)
                  generic map(1)
                  port map (Clock, CKE, AVB_nReset,'0',AVB_Ax);
                      
N_AVA: entity LibElegans.ElegansDriverNeuron(CLSAV)
                  generic map(1)
                  port map (Clock, CKE, AVA_nReset,'0',AVA_Ax); 
                  
N_TSD: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, TSD_nReset,Driver_Enable(7),TSD_Ax); 
                                   
N_TSV:  entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, TSV_nReset,'0',TSV_Ax);
                                    
                  
LOCO_NRV: entity LibElegans.Loco_Unit(NerveRing)
                          port map(Clock   => Clock          , CKE => CKE  , nReset  => nReset, 
                                   AVB_Ax  => AVB_Ax         , AVA_Ax  => AVA_Ax         , 
                                   DM_Fwd  => NRD_Ax         , VM_Fwd  => NRV_Ax         ,
                                   DM_Aft  => Neuron_Ax(1)(0), VM_Aft  => Neuron_Ax(1)(4),
                                   Neuron_En => Neuron_En(0) , Neuron_Ax => Neuron_Ax(0) );

LOCOUNITS : FOR i in 1 to 8 generate
  LOCOUNIT : entity LibElegans.Loco_Unit(Default)
               port map(Clock   => Clock            , CKE => CKE  , nReset  => nReset             ,
                        AVB_Ax  => AVB_Ax           , AVA_Ax  => AVA_Ax             ,
                        DM_Fwd  => Neuron_Ax(i-1)(0), VM_Fwd  => Neuron_Ax(i-1)(4)  ,
                        DM_Aft  => Neuron_Ax(i+1)(0), VM_Aft  => Neuron_Ax(i+1)(4)  ,
                        Neuron_En => Neuron_En(i)   , Neuron_Ax => Neuron_Ax(i)     );                             
end generate LOCOUNITS;

LOCO_TSV: entity LibElegans.Loco_Unit(TailSection)
                          port map(Clock   => Clock            , CKE => CKE  ,  nReset  => nReset         , 
                                   AVB_Ax  => AVB_Ax           , AVA_Ax  => AVA_Ax         , 
                                   DM_Fwd  => Neuron_Ax(8)(0)  , VM_Fwd  => Neuron_Ax(8)(4),
                                   DM_Aft  => TSD_Ax           , VM_Aft  => TSV_Ax         ,
                                   Neuron_En => Neuron_En(9)   , Neuron_Ax => Neuron_Ax(9) );
                                   
                                   
end architecture Behavioural;                