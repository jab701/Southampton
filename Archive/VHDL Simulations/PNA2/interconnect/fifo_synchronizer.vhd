library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo_synchronizer is
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
end entity fifo_synchronizer;

architecture Behavioural of fifo_synchronizer is

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





