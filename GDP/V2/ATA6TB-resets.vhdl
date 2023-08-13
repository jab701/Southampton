library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATA6TB is -- No ports defined for a testbench
end entity ATA6TB;

architecture testbench of ATA6TB is 
   
   signal clock : std_logic := '0';
   signal resetc, DASP, DMARQ, INTRQ, IORDYDDMARDYDSTROBE, PDIAGCBLID: std_logic := '0';
   signal DMACK, DIORHDMARDYHSTROBE, DIOWSTOP, RESETD : std_logic := '0';
   signal DD, databus : std_logic_vector(15 downto 0) := (others => '0');
   signal CS : std_logic_vector(1 downto 0) := (others => '0');
   signal DA : std_logic_vector(2 downto 0) := (others => '0');
   signal busyout, cdrdy, error, cdstrobe, pause, hs_dasp, hs_cblid, devsel, fortyeightbit: std_logic := '0';
   signal rw, resets, MUDMA : std_logic := '0';
   signal selectreg : std_logic_vector(3 downto 0) := (others => '0');
   signal timertest : std_logic_vector(19 downto 0) := (others => '0');
   signal loadltimerext : std_logic := '0';
   signal ltimervext: std_logic_vector(19 downto 0) := (others => '0');
   signal ERRORREG: std_logic_vector(7 downto 0);
   begin
       TB0: entity work.ATA_controller port map (clock => clock, resetc => resetc, DASP => DASP, DMARQ => DMARQ, INTRQ => INTRQ,
                                                 IORDYDDMARDYDSTROBE => IORDYDDMARDYDSTROBE, PDIAGCBLID =>PDIAGCBLID,
	                                              DMACK => DMACK, DIORHDMARDYHSTROBE =>DIORHDMARDYHSTROBE, DIOWSTOP => DIOWSTOP,
	                                              RESETD => RESETD, DD => DD, CS => CS, DA => DA, busyout => busyout, 
	                                              cdrdy => cdrdy, error => error, cdstrobe => cdstrobe, pause => pause, databus => databus,
	                                              devsel => devsel, fortyeightbit => fortyeightbit,rw => rw, resets => resets,
	                                              MUDMA => MUDMA, selectreg => selectreg, hs_dasp => hs_dasp, hs_cblid => hs_cblid,
	                                              ERRORREG => ERRORREG);
  
   -- Clock generation
   clock <= NOT clock after 5 ns, '0' after 80 ns;
   -- Test Reset Protocol
   resetc <= '1', '0' after 25 ns;
   --DD <= "0000000000000000",  "0000000010000000" after 80 ns, "0000000000000000" after 2026581 ns, "ZZZZZZZZZZZZZZZZ" after 2400 us;
   -- Test Software Reset Protocol
   resets <= '0', '1' after 2500 uS, '0' after 2500025 ns;
   -- General Parameters
   rw <= '0';
   IORDYDDMARDYDSTROBE <= '1'; -- Device is ready
   

   
         
       

end architecture testbench;