
library STD;
use STD.textio.all;                     -- basic I/O

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_textio.all;          -- I/O for logic types

library LibNeuron;
USE LibNeuron.ALL;
USE LibNeuron.TYPEDEFINITIONS.ALL;

entity TBLibNeuron is
  constant TimeResolution : natural := 16;
end TBLibNeuron;


architecture NeuronBlocksTB of TBLibNeuron is
  
begin
  
  
end architecture NeuronBlocksTB;

architecture Neuron1TB1 of TBLibNeuron is
signal Clock  : std_logic := '0';
signal CKE    : std_logic := '1';
signal nReset : std_logic := '0';
signal SynWeights : signed_vector(1 downto 0);
signal Axon : std_logic;


begin
Clock <= NOT(Clock) after 500 ns;
nReset <= '0', '1' after 500 ns;

Synweights <= (x"0000",x"0000"),
              (x"0000",x"0003") after 1 ms,
              (x"0000",x"0000") after 2 ms,
              (x"0000",x"0003") after 8 ms,
              (x"0000",x"0000") after 8.5 ms,
              (x"ffff",x"0000") after 9 ms,
              (x"0000",x"0000") after 10 ms;
  
Neuron : entity LibNeuron.Neuron1(Behavioural1)
          generic map(2, 2, x"0003", x"FFFF", x"02", TimeResolution)
          port map (Clock, CKE, nReset, SynWeights, x"03e8", x"03e8", Axon);    

end architecture Neuron1TB1;

architecture Neuron1TB2 of TBLibNeuron is
signal Clock : std_logic := '0';
signal CKE    : std_logic := '1';
signal nReset : std_logic := '0';
signal SynWeights : signed_vector(1 downto 0);
signal Axon : std_logic;


begin
Clock <= NOT(Clock) after 500 ns;
nReset <= '0', '1' after 500 ns;

Synweights <= (x"0000",x"0000"),
              (x"0000",x"0003") after 1 ms,
              (x"0000",x"0000") after 2 ms,
              (x"0000",x"0003") after 8 ms,
              (x"0000",x"0000") after 8.5 ms,
              (x"ffff",x"0000") after 9 ms,
              (x"0000",x"0000") after 10 ms;
  
Neuron : entity LibNeuron.Neuron1(Behavioural1)
          generic map(2, 2, x"0003", x"FFFF", x"02", TimeResolution)
          port map (Clock, CKE, nReset, SynWeights, x"03e8", x"03e8", Axon);    

end architecture Neuron1TB2;

architecture Neuron2TB1 of TBLibNeuron is
signal Clock : std_logic := '0';
signal CKE    : std_logic := '1';
signal nReset : std_logic := '0';
signal Axon1 : std_logic;
signal Axon2 : std_logic;

begin
Clock <= NOT(Clock) after 500 ns;
nReset <= '0', '1' after 500 ns;

Neuron2A : entity LibNeuron.Neuron2
          generic map(32, x"02", TimeResolution)
          port map (Clock, CKE, nReset, '0', x"00003A98", x"00002710", x"03e8", x"03e8", Axon1);    

Neuron2B : entity LibNeuron.Neuron2
          generic map(32, x"02", TimeResolution)
          port map (Clock, CKE, nReset, '1', x"00003A98", x"00002710", x"03e8", x"03e8", Axon2);    
end architecture Neuron2TB1;


architecture SynapsesTB of TBLibNeuron is
signal Clock : std_logic := '0';
signal CKE    : std_logic := '1';
signal nReset : std_logic := '0';
signal Axon : std_logic;  
signal SynOutput1 : signed(15 downto 0);
signal SynOutput2 : signed(15 downto 0);

         
begin
Clock <= NOT(Clock) after 500 ns;
nReset <= '0', '1' after 500 ns;

Axon <= '0',
        '1' after 1 ms,
        '0' after 1.1 ms,
        '1' after 1.2 ms,
        '0' after 1.3 ms,
        '1' after 1.4 ms,
        '0' after 1.5 ms,
        '1' after 1.6 ms,
        '0' after 1.7 ms;

BasicSynapse: entity LibNeuron.Synapse
              generic map(16,x"05")
              port map(Clock, CKE, nReset, Axon, x"03e8", x"07d0", open, SynOutput1);

AdvancedSynapse: entity LibNeuron.AdvSynapse
                 generic map(16, 3, x"05")
                 port map(Clock, CKE, nReset, Axon, x"03e8", x"07d0", SynOutput2);

end architecture SynapsesTB;

--########################### This is the default architecture #########################--
--# It prints a message saying the user should select one of the other architectures   #--
--# Put all testbench architectures before this one, this must be the last in the file #--
--######################################################################################--
architecture Default of TBLibNeuron is
begin
  
process is
  variable my_line : line;  -- type 'line' comes from textio
begin
write(my_line,string'("You have selected the default architecture for simulation!"));
writeline(output,my_line);
write(my_line,string'("This architecture does nothing, please select one of the other testbench architectures for simulation."));
writeline(output,my_line);
wait;
end process;  
end architecture Default;