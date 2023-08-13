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


entity TestBenchElegansSynapse is

end TestBenchElegansSynapse;

architecture Testbench of TestBenchElegansSynapse is

-- Define Clock Period
constant CLKPERIOD : time := 500 ns;



signal Clock  : std_logic := '1';
signal nReset : std_logic := '0';
signal Axon   : std_logic;
signal T1_Dendrite : signed (15 downto 0);
signal T2_Dendrite : signed (15 downto 0);
signal T3_Dendrite : signed (15 downto 0);
signal T4_Dendrite : signed (15 downto 0);

begin
  

T1: entity LibElegans.ElegansSynapse(Type1)
    port map(Clock,nReset,'1',Axon,T1_Dendrite);
T2: entity LibElegans.ElegansSynapse(Type2)
    port map(Clock,nReset,'1',Axon,T2_Dendrite);
T3: entity LibElegans.ElegansSynapse(Type3)
    port map(Clock,nReset,'1',Axon,T3_Dendrite);
T4: entity LibElegans.ElegansSynapse(Type4)
    port map(Clock,nReset,'1',Axon,T4_Dendrite);	
        
-- Clock Generation
Clock <= NOT(Clock) after CLKPERIOD;
-- nReset Control
nReset <= '0', '1' after 1000 ns;

-- Synapse Vectors
-- 
Axon <= '0', '1' after 1 ms, 
        '0' after 1.1 ms, '1' after 400 ms,
        '0' after 400.1 ms;
         

end architecture TestBench;







