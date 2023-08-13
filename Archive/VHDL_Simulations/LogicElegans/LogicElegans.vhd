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

library LogicElegans;
use LogicElegans.ALL;

entity LogicCElegans is
    port (-- Control Signals
          signal Clock  : in  std_logic;
          signal ClockOut : out std_logic;
          signal nReset : in  std_logic; -- Active Low
          --
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
end LogicCElegans;

architecture Behavioural of LogicCElegans is

-- Axon Signals (AxonChannel) 
-- For Network Drivers
signal iNRD: std_logic;
signal iNRV: std_logic;
signal iTSD: std_logic;
signal iTSV: std_logic;
signal iAVA: std_logic;
signal iAVB: std_logic;

signal DM : std_logic_vector(9 downto 0);
signal VM : std_logic_vector(9 downto 0);

signal NRD_Enable : std_logic;
signal NRV_Enable : std_logic;
signal AVB_Enable : std_logic;
signal AVA_Enable : std_logic;
signal TSD_Enable : std_logic;
signal PHASE_ENABLE : std_logic;
signal TSV_Enable : std_logic;

begin
ClockOut <= Clock;
  
NRD <= iNRD;
NRV <= iNRV;
AVB <= iAVB;
AVA <= iAVA;
TSD <= iTSD;
TSV <= iTSV;

MSCD0 <= DM(0);
MSCD1 <= DM(1);
MSCD2 <= DM(2);
MSCD3 <= DM(3);
MSCD4 <= DM(4);
MSCD5 <= DM(5);
MSCD6 <= DM(6);
MSCD7 <= DM(7);
MSCD8 <= DM(8);
MSCD9 <= DM(9);

MSCV0 <= VM(0);
MSCV1 <= VM(1);
MSCV2 <= VM(2);
MSCV3 <= VM(3);
MSCV4 <= VM(4);
MSCV5 <= VM(5);
MSCV6 <= VM(6);
MSCV7 <= VM(7);
MSCV8 <= VM(8);
MSCV9 <= VM(9);

-- Direction Control
DRVCTRL: process(NR_ON, TS_ON, COIL_ON)
begin
    if (NR_ON = '1') then
      NRD_Enable <= '1';
      NRV_Enable <= '1';
      AVB_Enable <= '1';
      AVA_Enable <= '0';
      TSD_Enable <= '0';
      PHASE_ENABLE <= '1';
      TSV_Enable <= '0';
    elsif (TS_ON = '1') then
      NRD_Enable <= '0';
      NRV_Enable <= '0';
      AVB_Enable <= '0';
      AVA_Enable <= '1';
      TSD_Enable <= '1';
      PHASE_ENABLE <= '1';
      TSV_Enable <= '1';
    elsif (COIL_ON = '1') then
      NRD_Enable <= '1';
      NRV_Enable <= '0';
      AVB_Enable <= '1';
      AVA_Enable <= '1';
      TSD_Enable <= '1';
      PHASE_ENABLE <= '0';
      TSV_Enable <= '0';    
    else 
      NRD_Enable <= '0';
      NRV_Enable <= '0';
      AVB_Enable <= '0';
      AVA_Enable <= '0';
      TSD_Enable <= '0';
      PHASE_ENABLE <= '1';
      TSV_Enable <= '0';
    end if;
end process DRVCTRL;

--DM(0)  <= iNRD;
--VM(0)  <= iNRV;
--DM(11) <= iTSD;
--VM(11) <= iTSV;

--NRDLTCH <= DM(1) OR Reset;
--NRVLTCH <= VM(1) OR Reset;
--TSDLTCH <= DM(10) OR Reset;
--TSVLTCH <= VM(10) OR Reset;

--SRLTCH_NRD: entity LogicElegans.SRLatch(Behavioural)
--            port map(S_PAD =>iNRD, R_PAD => NRDLTCH, Q_PAD =>DM(0) );

--SRLTCH_NRV: entity LogicElegans.SRLatch(Behavioural)
--            port map(S_PAD =>iNRV, R_PAD => NRVLTCH, Q_PAD =>VM(0) );
            
--SRLTCH_TSD: entity LogicElegans.SRLatch(Behavioural)
--            port map(S_PAD =>iTSD, R_PAD => TSDLTCH, Q_PAD =>DM(11) );

--SRLTCH_TSV: entity LogicElegans.SRLatch(Behavioural)
--            port map(S_PAD =>iTSV, R_PAD => TSVLTCH, Q_PAD =>VM(11) );
                              
N_NRD: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"000000",x"249F00")
       port map(Clock => Clock, nReset => nReset,
             Enable => NRD_Enable, CountPhase => '0',
			 Q => iNRD); 

N_NRV: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"124F80",x"249F00")
       port map(Clock => Clock, nReset => nReset,
                Enable => NRV_Enable, CountPhase => PHASE_ENABLE,
				Q => iNRV); 
          
N_AVB: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"000000",x"057E40")
       port map(Clock => Clock, nReset => nReset,
                Enable => AVB_Enable, CountPhase => '0',
				Q => iAVB); 
          
N_AVA: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"000000",x"057E40")
       port map(Clock => Clock, nReset => nReset,
                Enable => AVA_Enable, CountPhase => '0',
				Q => iAVA); 
          
N_TSD: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"000000",x"249F00")
       port map(Clock => Clock, nReset => nReset,
                Enable => TSD_Enable, CountPhase => '0',
				Q => iTSD); 
          
N_TSV: entity LogicElegans.LogicElegansDrvr(Behavioural)
       generic map (24,x"124F80",x"249F00")
       port map(Clock => Clock, nReset => nReset,
                Enable => TSV_Enable, CountPhase => PHASE_ENABLE,
				Q => iTSV); 
                
HeadLoco : entity LogicElegans.LogicElegansUnit(HeadEnd)
           port map(Clock => Clock , nReset => nReset,
                    D_FWD => iNRD , V_FWD  => iNRV ,
                    AVB   => iAVB  , AVA    => iAVA  ,
                    D_BWD => DM(1) , V_BWD  => VM(1) ,
                    D_OUT => DM(0) , V_OUT  => VM(0) );
                                                              
LOCOUNITS : FOR i in 1 to 8 generate
  LOCOUNIT : entity LogicElegans.LogicElegansUnit(Default)
              port map(Clock => Clock   , nReset => nReset  ,
                       D_FWD => DM(i-1) , V_FWD  => VM(i-1) ,
                       AVB   => iAVB    , AVA    => iAVA    ,
                       D_BWD => DM(i+1) , V_BWD  => VM(i+1) ,
                       D_OUT => DM(i)   , V_OUT  => VM(i)   );
end generate LOCOUNITS;

TailLoco : entity LogicElegans.LogicElegansUnit(TailEnd)
           port map(Clock => Clock , nReset => nReset ,
                    D_FWD => DM(8) , V_FWD  => VM(8)  ,
                    AVB   => iAVB  , AVA    => iAVA   ,
                    D_BWD => iTSD, V_BWD  => iTSV ,
                    D_OUT => DM(9), V_OUT  => VM(9) );
end architecture Behavioural;