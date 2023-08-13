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
package PNA_Types is
  constant Address_Width : natural := 8;
  constant N1_Param_Len  : natural := 104;
  constant N2_Param_Len  : natural := 136;
  constant S_Param_Len   : natural := ((2*Address_Width)+81);
end package PNA_Types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.PNA_Types.ALL;

entity PNA_System  is
  
  generic (NumNeuron1   : std_logic_vector((Address_Width-1) downto 0) := x"64";
           NumNeuron2   : std_logic_vector((Address_Width-1) downto 0) := x"10";
           NumSynapse   : std_logic_vector((Address_Width-1) downto 0) := x"C8");
  port 
  (
     signal clock    : in std_logic;
     signal nReset   : in std_logic;
     signal ce       : in std_logic;
     
     signal N1_Select : std_logic;
     signal N2_Select : std_logic;
     signal S_Select  : std_logic;
     
     signal Config_In     : in std_logic_vector(N2_Param_Len-1 downto 0);
     signal Config_Addr   : in std_logic_vector((address_width-1) downto 0);
     signal Parameters_we : in std_logic;
     signal Enable_we     : in std_logic;
     
     signal Ext_Address   : in std_logic_vector((Address_Width-1) downto 0);
     signal Ext_Read_Data : out std_logic_vector(15 downto 0);
     signal Ext_Read_rd   : in std_logic
     
   ); 
end entity PNA_System;

architecture Behavioural of PNA_System is

signal BankSelect : std_logic;
signal Trigger : std_logic;

signal N1_Pu_Act  : std_logic;
signal N1_pu_Addr : std_logic_vector((Address_Width-1) downto 0);
signal N1_pu_we   : std_logic;
signal N1_SynSum  : std_logic_vector(15 downto 0);
signal N1_Axon    : std_logic;

signal N2_Pu_Act      : std_logic;
signal N2_pu_Addr     : std_logic_vector((Address_Width-1) downto 0);
signal N2_pu_we       : std_logic;
signal N2_PhaseEnable : std_logic;
signal N2_Axon        : std_logic;

signal S_Pu_Act : std_logic;
signal S_pu_we   : std_logic;
signal S_PreSynNeuronAddr : std_logic_vector((Address_Width-1) downto 0);
signal N1_SynSum_rd : std_logic;
signal N2_SynSum_rd : std_logic;
signal S_Axon    : std_logic;
signal S_PostSynNeuronAddr : std_logic_vector((Address_Width-1) downto 0);
signal S_SynSum_In  : std_logic_vector(15 downto 0);
signal S_SynSum_Out : std_logic_vector(15 downto 0); 

signal N1_Parameter_we : std_logic;
signal N1_Enable_we    : std_logic;
signal N1_Ext_rd       : std_logic;

signal N2_Parameter_we : std_logic;
signal N2_Enable_we    : std_logic;
signal N2_Ext_rd       : std_logic;

signal S_Parameter_we : std_logic;
signal S_Enable_we    : std_logic;
signal S_Ext_rd       : std_logic;

begin

--------------------------------------
-- CONFIGURATION MUX LOGIC 
--------------------------------------
Config_Mux: process (N1_Select, N2_Select, S_Select, Parameters_we, Enable_we, Ext_Read_rd) is
begin
  N1_Parameter_we <= '0';
  N2_Parameter_we <= '0';    
  S_Parameter_we  <= '0'; 

  N1_Enable_we <= '0';
  N2_Enable_we <= '0';    
  S_Enable_we  <= '0';
  
  N1_Ext_rd <= '0';
  N2_Ext_rd <= '0';
  S_Ext_rd  <= '0'; 
         
  if (N1_Select = '1') then
    N1_Parameter_we <= Parameters_we;
    N1_Enable_we <= Enable_we;
    N1_Ext_rd <= Ext_Read_rd;
  elsif (N2_Select = '1') then
    N2_Parameter_we <= Parameters_we;
    N2_Enable_we <= Enable_we;
    N2_Ext_rd <= Ext_Read_rd;
  elsif (S_Select = '1') then
    S_Parameter_we <= Parameters_we;
    S_Enable_we <= Enable_we;
    S_Ext_rd <= Ext_Read_rd;
  end if;  
end process Config_Mux;

--------------------------------------
-- 1 us System Trigger
--------------------------------------                     
Timer_1: entity work.Timer
         generic map(Timer_Width => 8)
         port map(Clock => Clock,
                  nReset => nReset,
                  Pause => '0',
                  Period => x"63",
                  Q => Trigger);                      

--------------------------------------
-- System Supervisor
-------------------------------------- 
SystemController: entity work.PNA_System_Controller
           port map(Clock => Clock,
                    nReset => nReset,
                    Neuron1_Pu_Act => N1_Pu_Act,
                    Neuron2_Pu_Act => N2_Pu_Act,
                    Synapse_Pu_Act => S_Pu_Act,                                        
                    BankSelect => BankSelect);

--------------------------------------
-- Axon Memory (For N1_Pu & N2_Pu)
--------------------------------------                    

N1_SynSum_rd <= NOT N2_SynSum_rd;

N1_Axon_Mem_Ctrl: entity work.Axon_Mem_Ctrl
               generic map(Address_Width => Address_Width)
               Port Map(Clock => Clock,
                        BankSelect => BankSelect,
                        we => N1_pu_we,
                        rd => N1_SynSum_rd,
                        Addr_Read => S_PreSynNeuronAddr,
                        Addr_Write => N1_pu_addr,
                        Data_Read(0)  => S_Axon,
                        Data_Write(0) => N1_Axon,
                        Ext_Addr => Ext_Address,
                        Ext_Data_Read(0) => Ext_Read_Data(0),
                        Ext_rd => N1_Ext_rd);

N2_Axon_Mem_Ctrl: entity work.Axon_Mem_Ctrl
               generic map(Address_Width => Address_Width)
               Port Map(Clock => Clock,
                        BankSelect => BankSelect,
                        we => N2_pu_we,
                        rd => N2_SynSum_rd,
                        Addr_Read => S_PreSynNeuronAddr,
                        Addr_Write => N2_pu_addr,
                        Data_Read(0) => S_Axon,
                        Data_Write(0) => N2_Axon,
                        Ext_Addr => Ext_Address,
                        Ext_Data_Read(0) => Ext_Read_Data(0),
                        Ext_rd => N2_Ext_rd);

 --------------------------------------
-- Synapse Memory
-------------------------------------- 
S_SynSum_Mem: entity work.SynSum_Mem_Ctrl
              generic map(Address_Width => Address_Width)
              port map(Clock => Clock,
                       BankSelect => BankSelect,
                       ActiveBankAddr => N1_pu_addr,
                       ActiveBankRead => N1_SynSum,
                       
                       InactiveBankAddr => S_PostSynNeuronAddr,
                       we => S_pu_we,
                       InactiveBankRead  => S_SynSum_In,
                       InactiveBankWrite => S_SynSum_Out,
                       
                       Ext_Address => Ext_Address,
                       Ext_Data => Ext_Read_Data,
                       Ext_rd => S_Ext_rd);
                       

--------------------------------------
-- Neuron 1 Processing Unit
--------------------------------------                                                                                                                     
neuron1: entity work.neuron1_pu
         generic map(Address_Width => Address_Width)
         port map(Clock  => Clock,
                  nReset => nReset,
                  ce     => ce,
                  
                  Trigger     => Trigger,
                  Running     => N1_Pu_Act,
                  BankSelect  => BankSelect,
                  NumNeurons  => NumNeuron1,
                  
                  Param_Write => Config_In((N1_Param_Len-1) downto 0),
                  Param_Write_Addr => Config_Addr,
                  Param_We         => N1_Parameter_we,
                  
                  Enable_Write      => Config_In(0),
                  Enable_Write_Addr => Config_Addr,
                  Enable_We         => N1_Enable_we,
                  
                  pu_addrunit_out => N1_pu_addr,
                  pu_we_out       => N1_pu_we,
                  
                  SynSum_In => N1_SynSum,
                  Axon_Out  => N1_Axon);

--------------------------------------
-- Neuron 2 Processing Unit
--------------------------------------                  
neuron2: entity work.neuron2_pu
         generic map(Address_Width => Address_Width)
         port map(Clock  => Clock,
                  nReset => nReset,
                  ce     => ce,
                  
                  Trigger     => Trigger,
                  Running     => N2_Pu_Act,
                  BankSelect  => BankSelect,
                  NumNeurons  => NumNeuron2,
                  
                  Param_Write => Config_In,
                  Param_Write_Addr => Config_Addr,
                  Param_We         => N2_Parameter_we,
                  
                  Enable_Write      => Config_In(0),
                  Enable_Write_Addr => Config_Addr,
                  Enable_We         => N2_Enable_we,
                  
                  pu_addrunit_out => N2_pu_addr,
                  pu_we_out       => N2_pu_we,
                  
                  PhaseEnable => N2_PhaseEnable,
                  Axon_Out  => N2_Axon);

--------------------------------------
-- Synapse Processing Unit
--------------------------------------                 
synapse1: entity work.synapse_pu
         generic map(Address_Width => Address_Width,
                     Parameter_Width => ((2*Address_Width)+81))
         port map(Clock  => Clock,
                  nReset => nReset,
                  ce     => ce,
                  
                  Trigger     => Trigger,
                  Running     => S_Pu_Act,
                  BankSelect  => BankSelect,
                  NumSynapses  => NumSynapse,
                  
                  Param_Write => Config_In((S_Param_Len-1) downto 0),
                  Param_Write_Addr => Config_Addr,
                  Param_We         => S_Parameter_we,
                  
                  Enable_Write      => Config_In(0),
                  Enable_Write_Addr => Config_Addr,
                  Enable_We         => S_Enable_we,
                  
                  pu_addrunit_out => open,
                  pu_we_out       => S_pu_we,
                  
                  PreSynNeuronAddr => S_PreSynNeuronAddr,
                  PreSynNeuronType1or2 => N2_SynSum_rd,
                  Axon_In  => S_Axon,
                  
                  PostSynNeuronAddr => S_PostSynNeuronAddr,
                  SynSum_In => S_SynSum_In,
                  SynSum_Out=> S_SynSum_Out);                                                                            
end architecture Behavioural;




