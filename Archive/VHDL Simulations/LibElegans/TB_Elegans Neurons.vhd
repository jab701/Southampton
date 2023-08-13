----------------------------------------------------------------------------------
-- TestBench Name: TestBenchNeuron
-- Project Name:   TestBenches
--
-- Dependent On: 
-- [FORMAT: TYPE: NAME]  
--          Library: LibNeuron
--          Library: LibNeuronNS
--
-- Designers:
-- [FORMAT: Number: Name (Initials) (E-mail)]
--   1: Julian Bailey (JAB) (Julian.A.Bailey@gmail.com)
--
-- File Revisions: 
-- [FORMAT: Initials - Date (DD/MM/YYYY) - Description]
-- (JAB) - 17/03/2008 - Tested LibNeuron.BurstBlock and LibNeuronNS.BurstBlock.
--                      1Mhz Clock, 1 ms APTime, 2 ms Ref Time, BurstLength = 5.
--                      Behaviour Verfied Sucessfully. 
--
-- Description:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;
USE LibNeuron.TYPEDEFINITIONS.ALL;

library LibElegans;
use LibElegans.ALL;


entity TestBenchElegansNeurons is

end TestBenchElegansNeurons;

architecture Testbench of TestBenchElegansNeurons is

-- Define Clock Period
constant CLKPERIOD : time := 500 ns;
constant NumberSynapses : natural := 2;


signal Clock  : std_logic := '1';
signal nReset : std_logic := '0';

signal Dendrites : signed_vector ((NumberSynapses - 1) downto 0);

signal M_Axon   : std_logic;
signal AB_Axon  : std_logic;
signal D_Axon   : std_logic;
signal AV_Axon  : std_logic;
signal NTD_Axon : std_logic;
signal NTV_Axon : std_logic;

begin

CLSM: entity LibElegans.ElegansNeuron(MSC)
             generic map(2)
             port map(Clock,nReset,'1','0',Dendrites,M_Axon);

CLSAB: entity LibElegans.ElegansNeuron(CLSAB)
             generic map(2)
             port map(Clock,nReset,'1','0',Dendrites,AB_Axon);
             
CLSD: entity LibElegans.ElegansNeuron(CLSD)
             generic map(2)
             port map(Clock,nReset,'1','0',Dendrites,D_Axon);

CLSAV: entity LibElegans.ElegansNeuron(CLSAV)
             generic map(2)
             port map(Clock,nReset,'1','0',Dendrites,AV_Axon);
             
CLSNTD: entity LibElegans.ElegansNeuron(NTDORSAL)
             generic map(2)
             port map(Clock,nReset,'1','0',Dendrites,NTD_Axon);
             
CLSNTV: entity LibElegans.ElegansNeuron(NTVENTRAL)
             generic map(2)
             port map(Clock,nReset,'1','1',Dendrites,NTV_Axon);
                                                                        
-- Clock Generation
Clock <= NOT(Clock) after CLKPERIOD;
-- nReset Control
nReset <= '0', '1' after 1000 ns;

Dendrites <= (x"0000",x"0000"),
             (x"0001",x"0000") after 5 ms,
             (x"0001",x"0001") after 6 ms,
             (x"0000",x"0000") after 6.1 ms,
             (x"0010",x"0000") after 30 ms,
             (x"0010",x"FF00") after 33 ms,
             (x"0000",x"0000") after 34 ms;             

end architecture TestBench;








