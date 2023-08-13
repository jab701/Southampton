library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library LibNeuron;
use LibNeuron.ALL;
USE LibNeuron.TYPEDEFINITIONS.ALL;


entity Threshold is
	generic
	(
	    -- Module Specific Configuration Parameters
	      NumberSynapses : Positive := 1;
	      MaxSynapses    : Positive := 1;    
	      THe : signed(15 downto 0) := x"0001";
	      THi : signed(15 downto 0) := x"FFFF"
	);
	
	port 
	(
	    -- Global Input Signals
        signal Clock : in std_logic;
        signal  CKE : in std_logic;
        signal nReset : in std_logic;
	    -- Module Specific Input Signals
	      signal SynWeights : in signed_vector((NumberSynapses-1) downto 0);
	    -- Module Specific Output Signals
	      signal AbvExThld : out std_logic;
	      signal BelInThld : out std_logic
	);
      
end Threshold;

architecture Parallel of Threshold is
  
signal WSum : signed(15 downto 0);

begin

SumSynapses: process(SynWeights) is

	Variable WSumTmp : signed(15 downto 0);
begin
	WSumTmp := (Others => '0');

	for i in 0 to (NumberSynapses-1) loop
		WSumTmp := WSumTmp + SynWeights(i);
	end loop;

	WSum <= WSumTmp;

end process SumSynapses;

DecisionEx: process(WSum) is
begin
  if WSum >= THe then
    AbvExThld <= '1';
  else
    AbvExThld <= '0';
  end if;
end process DecisionEx;

DecisionIn: process(WSum) is
begin
  if THi >= WSum then
    BelInThld <= '1';
  else
    BelInThld <= '0';
  end if;
end process DecisionIn;
      
end architecture Parallel;


architecture Sequential of Threshold is
   
signal WSumClkEn : std_logic;
signal WSum : signed(15 downto 0);
signal isumD, isumQ : signed(15 downto 0);

signal addressD, addressQ : Integer range 0 to NumberSynapses - 1;
signal SyncCyclesD, SyncCyclesQ : Integer range 0 to MaxSynapses - 1;


type States is (Initial, Adding, Waiting);
signal StatesD, StatesQ : States;

begin

SynapsesSeq: process(Clock)
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      StatesQ <= Initial;
      AddressQ  <= 0;
      SyncCyclesQ <= 0;
      isumQ <= (Others => '0');
      WSum <= (Others => '0');    
    elsif (CKE = '1') then
      StatesQ <= StatesD;
      AddressQ <= AddressD;
	    SyncCyclesQ <= SyncCyclesD;
	    iSumQ <= iSumD;
	    
	    if (WSumClkEn = '1') then
	      WSum <= isumD;
	    end if;
	    
    end if;  
  end if;
end process SynapsesSeq;

States_Com: Process (StatesQ, SyncCyclesQ, AddressQ, isumQ, SynWeights) is
begin
  
  case StatesQ is
  when Initial =>
    SyncCyclesD <= 0;
    AddressD <= 0;
    iSumD <= (others => '0');
    WSumClkEn <= '0';
    StatesD <= Adding;
    
  when Adding =>
    iSumD <= iSumQ + SynWeights(AddressQ);
    
    if ((SyncCyclesQ = (MaxSynapses - 1)) AND (AddressQ = (NumberSynapses - 1))) then
       SyncCyclesD <= SyncCyclesQ;
       AddressD <= AddressQ;
       WSumClkEn <= '1'; 
       StatesD <= Initial;
    elsif (AddressQ = (NumberSynapses - 1)) then
       SyncCyclesD <= SyncCyclesQ + 1;
       AddressD <= AddressQ;
       WSumClkEn <= '0'; 
       StatesD <= Waiting;
    else
      AddressD <= AddressQ + 1;
      SyncCyclesD <= SyncCyclesQ + 1;
      WSumClkEn <= '0'; 
      StatesD <= Adding;     
    end if;

  when Waiting =>
    AddressD <= AddressQ;
    iSumD <= iSumQ;
    
    if (SyncCyclesQ >= (MaxSynapses - 1)) then
      StatesD <= Initial;
      WSumClkEn <= '1'; 
      SyncCyclesD <= SyncCyclesQ;
    else
      StatesD <= Waiting;
      WSumClkEn <= '0'; 
      SyncCyclesD <= SyncCyclesQ + 1;
    end if;    
 end case;end process States_Com;

DecisionEx: process(WSum) is
begin
  
  if (WSum >= THe) then
    AbvExThld <= '1';    
  else
    AbvExThld <= '0';
  end if;
end process DecisionEx;

DecisionIn: process(WSum) is
begin
  
  if (WSum <= THi) then
    BelInThld <= '1';    
  else
    BelInThld <= '0';
  end if;
end process DecisionIn;
      
end architecture Sequential;

