library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATA6TBMDMA is -- No ports defined for a testbench
end entity ATA6TBMDMA;

architecture testbench of ATA6TBMDMA is 
   
   signal clock : std_logic := '0';
   signal resetc, DASP, DMARQ, INTRQ, IORDYDDMARDYDSTROBE, PDIAGCBLID: std_logic := '0';
   signal DMACK, DIORHDMARDYHSTROBE, DIOWSTOP, RESETD : std_logic := '0';
   signal DD, databus, databus0, databus1 : std_logic_vector(15 downto 0) := (others => '0');
   signal CS : std_logic_vector(1 downto 0) := (others => '0');
   signal DA : std_logic_vector(2 downto 0) := (others => '0');
   signal busyout, cdrdy, error, cdstrobe, cdstrobe0, cdstrobe1, pause, hs_dasp, hs_cblid, devsel, fortyeightbit: std_logic ;
   signal rw, resets, MUDMA : std_logic := '0';
   signal selectreg : std_logic_vector(3 downto 0) := (others => '0');
   signal timertest : std_logic_vector(19 downto 0) := (others => '0');
   signal loadltimerext : std_logic := '0';
   signal ltimervext: std_logic_vector(19 downto 0) := (others => '0');
   signal ERRORREG: std_logic_vector(7 downto 0);
   signal timertime: std_logic;
   type states is (wcommand, wdevicereg, wdevicecont, features, LBAhigh0, LBAhigh1,
                   LBAmid0, LBAmid1, LBAlow0, LBAlow1, sectorcnt0, sectorcnt1, checkstatus,
                   write_intdd);
   
   
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
   clock <= NOT clock after 5 ns; 
   -- Test Reset Protocol
   resetc <= '1', '0' after 5 ns;
   DD <= "0000000000000000", "ZZZZZZZZZZZZZZZZ" after 2400 us, "0000000000000000" after 3 ms, "ZZZZZZZZZZZZZZZZ" after 3000717 ns,
         "0000000000001000" after 3009160 ns, "ZZZZZZZZZZZZZZZZ" after 3010 us;
   databus0 <= "0000000000110101", "0000000001010000" after 25 ns, "0000000000000000" after 50 ns, 
              "0000000000000000" after 75 ns, "0000000000000000" after 100 ns, "0000000000000000" after 125 ns,
              "0000000000000000" after 150 ns, "0000000000000000" after 175 ns, "0000000000000001" after 200 ns,
              "0000000000000000" after 225 ns, "0000000000000001" after 250 ns, "0000000000000000" after 275 ns,
              "ZZZZZZZZZZZZZZZZ" after 300 ns;
   selectreg <= "0001", "0010" after 25 ns, "0011" after 50 ns, "0100" after 75 ns, "0101" after 100 ns,
                "0110" after 125 ns, "0111" after 150 ns, "1000" after 175 ns, "1001" after 200 ns, "1010" after 225 ns,
                "1011" after 250 ns, "1100" after 275 ns, "1111" after 3 ms, "0000" after 3000020 ns;
   cdstrobe0 <= '1', '0' after 20 ns, '1' after 25 ns, '0' after 45 ns, '1' after 50 ns, '0' after 70 ns, '1' after 75 ns,
               '0' after 95 ns, '1' after 100 ns, '0' after 120 ns, '1' after 125 ns, '0' after 145 ns, '1' after 150 ns,
               '0' after 170 ns, '1' after 175 ns, '0' after 195 ns, '1' after 200 ns, '0' after 220 ns, '1' after 225 ns,
               '0' after 245 ns, '1' after 250 ns, '0' after 270 ns, '1' after 275 ns, '0' after 290 ns, '1' after 300 ns;
   timertime <= '0', '1' after 3010 uS;
   -- General Parameters
   rw <= '1';
   fortyeightbit <= '1';
   IORDYDDMARDYDSTROBE <= '1'; -- Device is ready
   DMARQ <= '0', '1' after 3009155 ns;
   
   cdstrobecnt: process (timertime, CDSTROBE0, CDSTROBE1, databus1, databus0, CDRDY) is
   begin
      if (timertime = '1') then
          databus1 <= "0101010101010101";
  
        CDSTROBE <= CDSTROBE1;
         DATABUS <= DATABUS1;    
      else
         CDSTROBE <= CDSTROBE0;
         DATABUS <= DATABUS0;
      end if;
       end process;
      
    cdstrobecnt2: process is
    begin
        CDSTROBE1 <= '1';
        wait until (CDRDY = '1');
        CDSTROBE1 <= '0';
        wait until (rising_edge(clock));   

    end process;
      
  

         
       

end architecture testbench;