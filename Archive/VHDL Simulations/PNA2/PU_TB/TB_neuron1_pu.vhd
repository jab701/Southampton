
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

entity TB_neuron1_pu  is
 constant Address_Width : natural := 3;
 constant NumNeurons : std_logic_vector((address_width-1) downto 0):= "011";
 constant FileName : string := "tb_n1_2_pu.dat"; 
end entity TB_neuron1_pu;

architecture Behavioural of TB_neuron1_pu is
signal clock   : std_logic := '0';
signal nreset  : std_logic := '0';
signal ce      : std_logic;
     
signal pu_addr  : std_logic_vector((address_width-1) downto 0);
signal pu_write_addr  : std_logic_vector((address_width-1) downto 0);
signal pu_active : std_logic;
signal pu_we : std_logic;

signal BankSelect : std_logic;
signal Trigger : std_logic;

signal SynSum : std_logic_vector(15 downto 0);
signal Axon : std_logic;

type SynArray is array ((to_integer(unsigned(NumNeurons))-1) downto 0) of std_logic_vector(15 downto 0);
signal SynSums : SynArray;

type BitArray is array ((to_integer(unsigned(NumNeurons))-1) downto 0) of std_logic;
signal Axons   : BitArray;

signal Program : std_logic := '0';
signal Programming : std_logic := '0';

signal Param_Addr : std_logic_vector(Address_Width-1 downto 0);
signal Parameters : std_logic_vector(103 downto 0);
signal Parameter_we : std_logic;

signal Load_Enables : std_logic;
signal Loading_Enables : std_logic;
signal Enables_Addr : std_logic_vector(Address_Width-1 downto 0);
signal Enable_we : std_logic;
signal Enables : std_logic;
signal Enable_Data: std_logic_vector((to_integer(unsigned(NumNeurons))-1) downto 0);

signal Init: std_logic;
signal Load_Enables_1 : std_logic;
signal Load_Enables_2 : std_logic;
begin

Clock <= NOT(Clock) after 5 ns;
ce <= '1';

Init <= '0', '1' after 5 ns, '0' after 10 ns;

Load_Enables <= Load_Enables_1 OR Load_Enables_2;

Load_Enables_2 <= '0';

SynSums(0) <= x"0000", x"000F" after 1 ms, x"0000" after 1.1 ms;
SynSums(1) <= x"0000", x"000F" after 2.5 ms, x"0000" after 2.6 ms;
SynSums(2) <= x"0000", x"000F" after 1 ms, x"0000" after 1.1 ms;
Enable_Data(0) <= '1';
Enable_Data(1) <= '1';
Enable_Data(2) <= '1';

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
    SynSum <= SynSums(to_integer(unsigned(pu_addr)));
    if (pu_we = '1') then
      Axons(to_integer(unsigned(pu_write_addr))) <= Axon;
    end if;
  end if;    
end process;

LoadParams: entity work.TB_Load_Parameters
            generic map(Address_Width => Address_Width,
                        NumNeurons => to_integer(unsigned(NumNeurons)),
                        Param_Width => 104,
                        FileName => FileName)
            port map(Clock => Clock,
                     Program => Program,
                     Programming => Programming,
                     Parameter_Addr => Param_Addr,
                     Parameter_Out => Parameters,
                     Parameter_we => Parameter_we);

LoadEnables: entity work.TB_Load_Enables
             generic map(Address_Width => Address_Width,
                         NumNeurons => to_integer(unsigned(NumNeurons)))
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
                    Neuron1_Pu_Act => pu_active,
                    Neuron2_Pu_Act => '0',
                    Synapse_Pu_Act => '0',                                        
                    BankSelect => BankSelect);
                    
neuron1: entity work.neuron1_pu
         generic map(Address_Width => Address_Width)
         port map(Clock  => Clock,
                  nReset => nReset,
                  ce     => ce,
                  
                  Trigger     => Trigger,
                  Running     => pu_active,
                  BankSelect  => BankSelect,
                  NumNeurons  => NumNeurons,
                  
                  Param_Write      => Parameters,
                  Param_Write_Addr => Param_addr,
                  Param_We         => Parameter_we,
                  
                  Enable_Write      => Enables,
                  Enable_Write_Addr => Enables_addr,
                  Enable_We         => Enable_we,
                  
                  pu_addrunit_out => pu_addr,
                  pu_writeaddr_out => pu_write_addr,
                  pu_we_out       => pu_we,
                  
                  SynSum_In => SynSum,
                  Axon_Out  => Axon);                      
end architecture Behavioural;
