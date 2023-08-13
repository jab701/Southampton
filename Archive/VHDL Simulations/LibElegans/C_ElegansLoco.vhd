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
          signal Clock  : in  std_logic;
          signal CKE    : in std_logic;
          signal nReset : in  std_logic; -- Active Low
          signal NR_ON  : in  std_logic; -- If On Model will move forward
          signal TS_ON  : in  std_logic; -- if On and NR_ON is off then model will move backward
          signal COIL_ON : in std_logic;
          -- Nerve Ring Outputs
          signal NRD  : out std_logic;
          signal NRV  : out std_logic;
          -- Class AV Outputs
          signal AVA  : out std_logic;
          signal AVB  : out std_logic;
          -- Dorsal Motor Neurons Outputs
          signal MSCD0: out std_logic;
          signal MSCD1: out std_logic;
          signal MSCD2: out std_logic;
          signal MSCD3: out std_logic;   
          signal MSCD4: out std_logic;
          signal MSCD5: out std_logic;   
          signal MSCD6: out std_logic;
          signal MSCD7: out std_logic;
          signal MSCD8: out std_logic;
          signal MSCD9: out std_logic;   
          -- Ventral Motor Neurons Outputs
          signal MSCV0: out std_logic;
          signal MSCV1: out std_logic;
          signal MSCV2: out std_logic;
          signal MSCV3: out std_logic;   
          signal MSCV4: out std_logic;
          signal MSCV5: out std_logic;   
          signal MSCV6: out std_logic;
          signal MSCV7: out std_logic;
          signal MSCV8: out std_logic;
          signal MSCV9: out std_logic;
          -- Tail Section Outputs 
          signal TSD  : out std_logic;
          signal TSV  : out std_logic                                                             
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

signal DM_Ax : std_logic_vector(9 downto 0);
signal VM_Ax : std_logic_vector(9 downto 0);

signal NRD_nReset : std_logic;
signal NRV_nReset : std_logic;
signal AVB_nReset : std_logic;
signal AVA_nReset : std_logic;
signal TSD_nReset : std_logic;
signal PHASE_ENABLE : std_logic;
signal TSV_nReset : std_logic;


begin
-- Output Signal Assignments
NRD <= NRD_Ax;
NRV <= NRV_Ax;
AVA <= AVA_Ax;
AVB <= AVB_Ax;
TSD <= TSD_Ax;
TSV <= TSV_Ax;
-- Dorsal Motor Neurons Outputs 
MSCD0 <= DM_Ax(0);
MSCD1 <= DM_Ax(1);
MSCD2 <= DM_Ax(2);
MSCD3 <= DM_Ax(3);
MSCD4 <= DM_Ax(4);
MSCD5 <= DM_Ax(5);
MSCD6 <= DM_Ax(6);
MSCD7 <= DM_Ax(7);
MSCD8 <= DM_Ax(8);
MSCD9 <= DM_Ax(9);
-- Ventral Motor Neurons Outputs          
MSCV0 <= VM_Ax(0);
MSCV1 <= VM_Ax(1);
MSCV2 <= VM_Ax(2);
MSCV3 <= VM_Ax(3);
MSCV4 <= VM_Ax(4);
MSCV5 <= VM_Ax(5);   
MSCV6 <= VM_Ax(6);
MSCV7 <= VM_Ax(7);
MSCV8 <= VM_Ax(8);
MSCV9 <= VM_Ax(9);
                    

-- Direction Control
-- We control the driving neurons using the nReset Lines
-- this process allows for both the normal nReset behaviour
-- and the control via NR-ON, TS_ON and COIL_ON.
DRVCTRL: process(nReset, NR_ON, TS_ON, COIL_ON)
begin
    if (nReset = '0') then
      NRD_nReset <= '0';
      NRV_nReset <= '0';
      AVB_nReset <= '0';
      AVA_nReset <= '0';
      TSD_nReset <= '0';
      PHASE_ENABLE <= '1';
      TSV_nReset <= '0';      
    elsif (NR_ON = '1') then
      NRD_nReset <= '1';
      NRV_nReset <= '1';
      AVB_nReset <= '1';
      AVA_nReset <= '0';
      TSD_nReset <= '0';
      PHASE_ENABLE <= '1';
      TSV_nReset <= '0';
    elsif (TS_ON = '1') then
      NRD_nReset <= '0';
      NRV_nReset <= '0';
      AVB_nReset <= '0';
      AVA_nReset <= '1';
      TSD_nReset <= '1';
      PHASE_ENABLE <= '1';
      TSV_nReset <= '1';
    elsif (COIL_ON = '1') then
      NRD_nReset <= '1';
      NRV_nReset <= '0';
      AVB_nReset <= '1';
      AVA_nReset <= '1';
      TSD_nReset <= '1';
      PHASE_ENABLE <= '0';
      TSV_nReset <= '0';    
    else 
      NRD_nReset <= '0';
      NRV_nReset <= '0';
      AVB_nReset <= '0';
      AVA_nReset <= '0';
      TSD_nReset <= '0';
      PHASE_ENABLE <= '1';
      TSV_nReset <= '0';
    end if;
end process DRVCTRL;



-- Set Dummy Dendrite to zero


       
-- Network Drivers --     
N_NRD: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, NRD_nReset,'0',NRD_Ax);
                   
N_NRV: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, NRV_nReset,PHASE_ENABLE,NRV_Ax);
                      
N_AVB: entity LibElegans.ElegansDriverNeuron(CLSAV)
                  generic map(1)
                  port map (Clock, CKE, AVB_nReset,'0',AVB_Ax);
                      
N_TSD: entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, TSD_nReset,PHASE_ENABLE,TSD_Ax); 
                                   
N_TSV:  entity LibElegans.ElegansDriverNeuron(NRTS)
                  generic map(1)
                  port map (Clock, CKE, TSV_nReset,'0',TSV_Ax);
                                    
N_AVA: entity LibElegans.ElegansDriverNeuron(CLSAV)
                  generic map(1)
                  port map (Clock, CKE, AVA_nReset,'0',AVA_Ax); 
                                      
                   
LOCO_NRV: entity LibElegans.Loco_Unit(NerveRing)
                          port map(Clock   => Clock    , CKE => CKE         , nReset  => nReset  , 
                                   AVB_Ax  => AVB_Ax   , AVA_Ax  => AVA_Ax  , 
                                   DM_Fwd  => NRD_Ax   , VM_Fwd  => NRV_Ax  ,
                                   DM_Aft  => DM_Ax(1) , VM_Aft  => VM_Ax(1),
                                   DM_Axon => DM_Ax(0) , VM_Axon => VM_Ax(0));

LOCOUNITS : FOR i in 1 to 8 generate
  LOCOUNIT : entity LibElegans.Loco_Unit(Default)
               port map(Clock   => Clock      , CKE => CKE            , nReset  => nReset     ,
                        AVB_Ax  => AVB_Ax     , AVA_Ax  => AVA_Ax     ,
                        DM_Fwd  => DM_AX(i-1) , VM_Fwd  => VM_Ax(i-1) ,
                        DM_Aft  => DM_Ax(i+1) , VM_Aft  => VM_Ax(i+1) ,
                        DM_Axon => DM_Ax(i)   , VM_Axon => VM_Ax(i)  );                              
end generate LOCOUNITS;

LOCO_TSV: entity LibElegans.Loco_Unit(TailSection)
                          port map(Clock   => Clock    , CKE => CKE          , nReset  => nReset   , 
                                   AVB_Ax  => AVB_Ax   , AVA_Ax  => AVA_Ax   , 
                                   DM_Fwd  => DM_Ax(8) , VM_Fwd  => VM_Ax(8) ,
                                   DM_Aft  => TSD_Ax   , VM_Aft  => TSV_Ax   ,
                                   DM_Axon => DM_Ax(9) , VM_Axon => VM_Ax(9));
end architecture Behavioural;                