
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

use std.textio.ALL;

library PNA_LibNeuron_com;

entity TB_synapse_pu  is
 constant Address_Width : natural := 8;
 constant NumSynapses : std_logic_vector((address_width-1) downto 0):= x"02";
 constant FileName : string := "tb_s_1_pu.dat";
end entity TB_synapse_pu;

architecture Behavioural of TB_synapse_pu is
signal clock   : std_logic := '0';
signal nreset  : std_logic := '0';
signal ce      : std_logic;
     
signal pu_addr  : std_logic_vector((address_width-1) downto 0);
signal pu_active : std_logic;
signal pu_we : std_logic;

signal BankSelect : std_logic;
signal Trigger : std_logic;

signal PreSynNeuronAddr  : std_logic_vector((address_width-1) downto 0);
signal PostSynNeuronAddr : std_logic_vector((address_width-1) downto 0);

signal SynSumRead : std_logic_vector(15 downto 0);
signal SynSumWrite : std_logic_vector(15 downto 0);
signal Axon : std_logic;

type SynArray is array ((to_integer(unsigned(NumSynapses))-1) downto 0) of std_logic_vector(15 downto 0);
signal SynSums : SynArray;

type BitArray is array ((to_integer(unsigned(NumSynapses))-1) downto 0) of std_logic;
signal Axons         : BitArray;

signal Program : std_logic := '0';
signal Programming : std_logic := '0';

signal Param_Addr : std_logic_vector(Address_Width-1 downto 0);
signal Parameters : std_logic_vector((2*Address_Width)+84-1 downto 0);
signal Parameter_we : std_logic;

signal Load_Enables : std_logic;
signal Loading_Enables : std_logic;
signal Enables_Addr : std_logic_vector(Address_Width-1 downto 0);
signal Enable_we : std_logic;
signal Enables : std_logic;
signal Enable_Data: std_logic_vector((to_integer(unsigned(NumSynapses))-1) downto 0);

signal Init: std_logic;
signal Load_Enables_1 : std_logic;
signal Load_Enables_2 : std_logic;
begin

Clock <= NOT(Clock) after 5 ns;
ce <= '1';

Init <= '0', '1' after 5 ns, '0' after 10 ns;

Load_Enables <= Load_Enables_1 OR Load_Enables_2;

Load_Enables_2 <= '0';

Enable_Data(0) <= '1';
Enable_Data(1) <= '1';
--Enable_Data(2) <= '1';

Axons(0) <= '0', '1' after 1 ms, '0' after 1.1 ms;
Axons(1) <= '0';
--Axons(2) <= '0';

process is
begin
  nReset <= '1';
  Program <= '0';
  Load_Enables_1 <= '0';
  wait until rising_edge(Init);
  nReset <= '0';
  Program <= '1';
  wait until Programming = '1';
  Program <= '0';
  wait until Programming = '0';
  Load_Enables_1 <= '1';
  wait until Loading_Enables = '1';
  Load_Enables_1 <= '0';
  wait until Loading_Enables = '0';
  nReset <= '1';   
end process;
  
process (Clock) is
begin
  if rising_edge(Clock) then
    if (pu_we = '1') then
      SynSums(to_integer(unsigned(PostSynNeuronAddr))) <= SynSumWrite;
    end if;
    
    Axon <= Axons(to_integer(unsigned(PreSynNeuronAddr)));
    SynSumRead <= SynSums(to_integer(unsigned(PostSynNeuronAddr)));
  end if;    
end process;

LoadParams: entity work.TB_Load_Parameters
            generic map(Address_Width => Address_Width,
                        NumNeurons => to_integer(unsigned(NumSynapses)),
                        Param_Width => (2*Address_Width+84),
                        FileName => FileName)
            port map(Clock => Clock,
                     Program => Program,
                     Programming => Programming,
                     Parameter_Addr => Param_Addr,
                     Parameter_Out => Parameters,
                     Parameter_we => Parameter_we);

LoadEnables: entity work.TB_Load_Enables
             generic map(Address_Width => Address_Width,
                         NumNeurons => to_integer(unsigned(NumSynapses)))
             port map(Clock => Clock,
                      Load => Load_Enables,
                      Loading => Loading_Enables,
                      Enable_In => Enable_Data,
                      Enable_Addr => Enables_Addr,
                      Enable_Out => Enables,
                      Enable_we => Enable_we);
-- Trigger Timer                      
Timer_1: entity work.Timer
         generic map(Timer_Width => 8)
         port map(Clock => Clock,
                  nReset => nReset,
                  Pause => '0',
                  Period => x"63",
                  Q => Trigger);                      

SystemController: entity work.PNA_System_Controller
           port map(Clock => Clock,
                    nReset => nReset,
                    Neuron1_Pu_Act => '0',
                    Neuron2_Pu_Act => pu_active,
                    Synapse_Pu_Act => '0',                                        
                    BankSelect => BankSelect);
                    
synapse1: entity work.synapse_pu
         generic map(Address_Width => Address_Width,
                     Parameter_Width => ((2*Address_Width)+81))
         port map(Clock  => Clock,
                  nReset => nReset,
                  ce     => ce,
                  
                  Trigger     => Trigger,
                  Running     => pu_active,
                  BankSelect  => BankSelect,
                  NumSynapses  => NumSynapses,
                  
                  Param_Write => Parameters((2*Address_Width+80) downto 0),
                  Param_Write_Addr => Param_addr,
                  Param_We         => Parameter_we,
                  
                  Enable_Write      => Enables,
                  Enable_Write_Addr => Enables_addr,
                  Enable_We         => Enable_we,
                  
                  pu_addrunit_out => pu_addr,
                  pu_we_out       => pu_we,
                  
                  PreSynNeuronAddr => PreSynNeuronAddr,
                  Axon_In  => Axon,
                  
                  PostSynNeuronAddr => PostSynNeuronAddr,
                  SynSum_In => SynSumRead,
                  SynSum_Out=> SynSumWrite);                      
end architecture Behavioural;


