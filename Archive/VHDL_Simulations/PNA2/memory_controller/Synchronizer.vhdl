
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

entity Synchronizer is
  generic 
  (
     -- Module Specific Configuration Parameters
     Stages : natural := 2;
     width : natural := 8
  );
  port 
  (
     signal clock   : in std_logic;
     signal nReset  : in std_logic;
     signal input   : in std_logic_vector(width-1 downto 0);
     signal output  : out std_logic_vector(width-1 downto 0)
   ); 
end entity Synchronizer;

architecture Behavioural of Synchronizer is

type std_logic_array is array (stages downto 0) of std_logic_vector(width-1 downto 0);

signal intermediates : std_logic_array;

begin
  intermediates(0) <= input;
  output <= intermediates(Stages);
  
  Sync: for n in 0 to Stages-1 generate
    DFF: entity work.DFF
         generic map(width => width)
         port map(clk  => clock,
                  nrst => nReset,
                  cke  => '1',
                  D => intermediates(n),
                  Q => intermediates(n+1));  
  end generate Sync;

end architecture Behavioural;





