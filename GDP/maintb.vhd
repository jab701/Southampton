library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATA6TB is -- No ports defined for a testbench
end entity ATA6TB;

architecture testbench of ATA6TB is 
   
   signal clock : std_logic := '0';
   signal resetc: std_logic := '0';
   signal testtimer : std_logic_vector (19 downto 0);
	signal	loadltimerext : std_logic; 
	signal ltimervext : std_logic_vector (19 downto 0);
   begin
       TB0: entity work.timertest port map (clock => clock, resetc => resetc, testtimer => testtimer,
                                            loadltimerext => loadltimerext, ltimervext => ltimervext);
  
   -- Clock generation
   clock <= NOT clock after 5 ns;
   
   -- Test Reset Protocol
   resetc <= '1', '0' after 5 ns;

   
   -- Simulate Drive Response          
       

end architecture testbench;
