

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATA_controller is
 	port (clock, resetc : in std_logic; 
		   DASP, DMARQ, INTRQ, IORDYDDMARDYDSTROBE, PDIAGCBLID : in std_logic;
	      DMACK, DIORHDMARDYHSTROBE, DIOWSTOP, RESETD: out std_logic;
         DD: inout std_logic_vector(15 downto 0);
         CS: out std_logic_vector(1 downto 0);
         DA: out std_logic_vector(2 downto 0);
         -- Controller Signals
         busyout: out std_logic;
         cdrdy: out std_logic;
         error: out std_logic;
         ERRORREG: out std_logic_vector(7 downto 0);
         
         cdstrobe: in std_logic;
         pause : in std_logic;
         databus : inout std_logic_vector(15 downto 0);
         devsel, fortyeightbit, rw, resets, MUDMA: in std_logic;
         selectreg : in std_logic_vector(3 downto 0);
         hs_dasp, hs_cblid : out std_logic);
end entity ATA_controller;

architecture RTL of ATA_controller is
	type state is (-- Reset States
	               HHRassert_reset, HHRnegate_wait, HHRHSRcheck_status, HSRset_SRST, HSRclear_wait,
	               HHRHSRregaccesswait,
	               HHRHSRcheck_status2, HSRset_SRST_wait, HSRclear_wait_wait,
	               -- Host Idle States
	               HIhost_idle, HIcheck_status, HIcheck_status_wait, HIcheck_status2, HIdevice_select, HIdevice_select2,
	               HIwrite_features, HIwrite_features_wait,HIwrite_lba_low, HIwrite_lba_low_wait, HIwrite_lba_mid, 
	               HIwrite_lba_mid_wait, HIwrite_lba_high, HIwrite_lba_high_wait, HIwrite_sector_cnt, HIwrite_sector_cnt_wait,
	               HIwrite_command, HIwrite_command_wait, HIbranch_select, hiwrite_lba_low48, HIwrite_LBA_low48_wait,
	               hiwrite_lba_mid48, hiwrite_lba_mid48_wait, hiwrite_lba_high48, hiwrite_lba_high48_wait, hiwrite_sector_cnt48,
	               hiwrite_sector_cnt48_wait,     
	               -- PIO Out States
	               HPIOOtransfer_data, HPIOOintrq_wait, HPIOOcheck_status_wait, HPIOOcheck_status2, HPIOOtransfer_data2,
	               HPIOOget_data,
	               -- PIO In States
	               HPIOIintrq_wait, HPIOIcheck_status, HPIOItransfer_data, HPIOOcheck_status, HPIOIcheck_status_wait, 
	               HPIOIcheck_status2, HPIOItransfer_data2, 
	               -- Non Data Command States
	               HNDintrq_wait, HNDcheck_status, HNDcheck_status_wait, HNDcheck_status2,
	               -- Execute Device Diagnostic States 
	               HEDwait_state, HEDcheck_status, HEDcheck_status_wait, HEDcheck_status2, 
	               -- DMA Common States
	               HDMAcheck_status, HDMAcheck_status_wait, HDMAcheck_status2, HDMAintrq_wait, 
	               -- MDMA Command States
	               HDMApreparedmatransfer, HDMAtransfer_data_first, HDMAtransfer_data_first2, HDMAtransfer_data, 
	               HDMAtransfer_data_waitth, HDMAtransfer_data_waittk, HDMAhost_terminate, HDMAdevice_pause,
	               HDMAget_data, HDMAwrite_data, HDMAtransfer_get_data_first,
	               -- UDMA Data Out Command States
	               UDMAout_initialize, UDMAout_initialize2, UDMAout_initialize3, UDMAout_first_strobe, UDMAout_transfer,
	               UDMAout_transfer2, UDMAout_transfer3, UDMAout_devicepause, UDMAout_terminate,
	               UDMAout_terminate2, UDMAout_terminate3, UDMAout_terminate4, UDMAout_terminatecomplete,
	               UDMAout_initialize_getdata,
	               -- Controller Error Handling States
	               Error_check, Error_check_wait, Error_check2);
	               
	signal current_state, next_state, previous_state : state;
	type regtran is (idle, check_iordy, write_address, assert_diorw, check_iordy2,
	                 data_setup, checkt2_len, negate_dior, negate_diow, release_bus,
	                 checkt2i_len, checkt0_len, return_function);
	signal regstate_current, regstate_next, nextstate_self, regstate_last : regtran;

	type pio is (mode0, mode1, mode2, mode3, mode4);
	type MDMA is (mode0, mode1, mode2);
	type UDMA is (mode0, mode1, mode2, mode3);
		
	signal sectorcounter: std_logic_vector(16 downto 0);
	signal wordcounter: std_logic_vector(7 downto 0);
	signal REGMode : pio; -- External
	signal PIOMode : pio; -- External
	signal MDMAMode : MDMA;   -- External
	signal UDMAMode : UDMA;   -- External
	signal REGmodet0, REGmodet1, REGmodet2, REGmodet2i, REGmodet3, REGmodet4, REGmodet5, REGmodet9 : std_logic_vector(8 downto 0);
	signal PIOmodet0, PIOmodet1, PIOmodet2, PIOmodet2i, PIOmodet3, PIOmodet4, PIOmodet5, PIOmodet9 : std_logic_vector(8 downto 0);
	signal modet0, modet1, modet2, modet2i, modet3, modet4, modet5, modet9 : std_logic_vector(8 downto 0);
	signal MDMAt0, MDMAtd, MDMAtg, MDMAth, MDMAtj, MDMAtkr, MDMAtkw, MDMAtm, MDMAtn : std_logic_vector(8 downto 0);
	signal UDMAtenvmin, UDMAtzah, UDMAtdvs, UDMAtack, UDMAtcvh, UDMAtui, UDMAtdvh, UDMAtcyc, UDMAt2cychalf : std_logic_vector(8 downto 0); 
	signal UDMAtss, UDMAtmli : std_logic_vector(8 downto 0);
	
	signal regpioselect : std_logic;
	signal flagdb : std_logic;
	
	signal busy : std_logic;
	signal lba_level : std_logic_vector(1 downto 0);
	
	type statedriver is (ATAD, REG);
	signal driver : statedriver;
   signal regCS: std_logic_vector(1 downto 0);
   signal regDA: std_logic_vector(2 downto 0);
   signal regDMACK, intDMACK, intdiorhdmardyhstrobe, regdiorhdmardyhstrobe, intDIOWSTOP,regDIOWSTOP: std_logic;
	
	-- ATA Timers
	signal ctimer, ctimerv : std_logic_vector(8 downto 0);
	signal ltimer, ltimerv : std_logic_vector(19 downto 0);
	signal stimer, stimerv : std_logic_vector(8 downto 0);
	signal mtimer, mtimerv : std_logic_vector(19 downto 0);
	signal ctimerf, loadctimer, creset : std_logic;
	signal ltimerf, loadltimer, lreset : std_logic;
	signal stimerf, loadstimer, sreset : std_logic;
	signal mtimerf, loadmtimer, mreset : std_logic;
	
	-- REG Timers
	signal ptimer, ptimerv : std_logic_vector(8 downto 0);
	signal qtimer, qtimerv : std_logic_vector(19 downto 0);
	signal ttimer, ttimerv : std_logic_vector(8 downto 0);
	signal rtimer, rtimerv : std_logic_vector(19 downto 0);
	signal ptimerf, loadptimer, preset : std_logic;
	signal qtimerf, loadqtimer, qreset : std_logic;
	signal ttimerf, loadttimer, treset : std_logic;
	signal rtimerf, loadrtimer, rreset : std_logic;
		
	signal register_read: std_logic_vector(7 downto 0);
	signal regrst, regbegin: std_logic; 
	signal intcs: std_logic_vector(1 downto 0);
	signal intda: std_logic_vector(2 downto 0);

	signal flag, HOB, daspen, inthsdasp : std_logic;
	
   -- Internal Databus control
   signal hddata : std_logic;
   signal intddwe, ata_intddwe, reg_intddwe, atadirectdd : std_logic;
   signal intrw: std_logic; -- '0' for read, '1' for write
	signal intdd, atadd: std_logic_vector(15 downto 0);
		
	-- CRC Signals
	signal CRCOUT: std_logic_vector(15 downto 0);
	signal CRCEN, crcDIORHDMARDYHSTROBE : std_logic;
	signal CRCIN : std_logic_vector(15 downto 0);
   signal f : std_logic_vector(15 downto 0);
	signal interror : std_logic;
	-- Command Registers
	signal commandreg, devicereg, devicecont, features, LBAHIGH0, LBAHIGH1, LBAMID0, LBAMID1, LBALOW0, LBALOW1: std_logic_vector(7 downto 0);
   signal sectorcount0, sectorcount1 : std_logic_vector(7 downto 0);
   signal cmodes : std_logic_vector(7 downto 0);
   signal PIOmodet0cus, REGmodet0cus, MDMAmodet0cus : std_logic_vector(8 downto 0);
	

begin
seq: process(clock, resetc, resets) is

	begin
		if (resetc =  '1' )  then
		   previous_state <= HHRassert_reset;
			current_state <= HHRassert_reset;		 -- When reset always go to Hardware Reset level
			regstate_current <= idle;
			regstate_last <= idle;
		elsif (resets = '1') then
		   previous_state <= HSRset_SRST;
			current_state <= HSRset_SRST;		 -- When reset always go to Hardware Reset level
			regstate_current <= idle;
			regstate_last <= idle;   
		elsif rising_edge(clock) then
		   previous_state <= current_state;
			current_state <= next_state;
			regstate_last <= regstate_current;
			regstate_current <= regstate_next;
      end if;
			
	end process seq;

daspcblid: process(clock, resetc, daspen, DASP, PDIAGCBLID, inthsdasp) is 
   begin
      hs_cblid <= PDIAGCBLID;
      hs_dasp <= inthsdasp;
      
      if (resetc = '1') then
          inthsdasp <= '0';
      elsif rising_edge(CLOCK) then
         if (daspen = '1') then
             inthsdasp <= DASP;
         else
             inthsdasp <= inthsdasp;
         end if;
     else
        inthsdasp <= inthsdasp;       
     end if;
   end process daspcblid;
    
busysigerrsig: process(current_state, interror, intdd) is

   begin
      if (current_state = HIhost_idle) then   -- If host is not in idle
         busyout <= '0';                      -- state then lower busy flag
      else
         busyout <= '1';
      end if;
      
      if (current_state = ERROR_check2) then   -- If error detected then flah
         interror <= '1';
         error <= interror;
         ERRORREG <= intdd(7 downto 0);
      elsif (current_state = HHRassert_reset) then
         interror <= '0';  
         error <= interror;
         ERRORREG <= (others => '0');
      elsif (current_state = HSRset_SRST) then
         interror <= '0'; 
         error <= interror;
         ERRORREG <= (others => '0'); 
      elsif (current_state = HIcheck_status) then -- Continue to flag error until new command issued
         interror <= '0';
         error <= interror;
         ERRORREG <= (others => '0');
      else
         interror <= interror;
         error <= interror;
         ERRORREG <= intdd(7 downto 0);
      end if;    
   end process busysigerrsig;	
   
reginput: process(regrst, regbegin, nextstate_self) is

   begin
       
       if (regrst = '1') then
           regstate_next <= idle;
       elsif (regbegin = '1') then
           regstate_next <= check_iordy;
       else
           regstate_next <= nextstate_self;
       end if;
       
   end process reginput;

commandwrite: process(resetc, cdstrobe) is
    begin
        
        if (resetc = '1') then             -- Zero all registers
           commandreg <= (others => '0');
           devicecont <= (others => '0');
           devicereg <= (others => '0');
           features <= (others => '0');
           LBAHIGH0 <= (others => '0');
           LBAHIGH1 <= (others => '0');
           LBAMID0 <= (others => '0');
           LBAMID1 <= (others => '0');
           LBALOW0 <= (others => '0');
           LBALOW1 <= (others => '0');
           sectorcount0 <= (others => '0');
           sectorcount1 <= (others => '0');
           cmodes <= (others => '0');      -- reset registers to normal values
           piomodet0cus <= "000111100"; 
           regmodet0cus <= "000111100";
           MDMAmodet0cus <= "000110000"; 
            
        elsif falling_edge(cdstrobe) then
            
           if (selectreg = "0001") then
               commandreg <= databus(7 downto 0);
           else
               commandreg <= commandreg;
           end if;
           
           if (selectreg = "0010") then
               devicereg <= databus(7 downto 0);
           else
               devicereg <= devicereg;
           end if;
           
           if (selectreg = "0011") then
               devicecont <= databus(7 downto 0);
           else
               devicecont <= devicecont;
           end if;
           
           if (selectreg = "0100") then
               features <= databus(7 downto 0);
           else
               features <= features;
           end if;
           
           if (selectreg = "0101") then
               LBAHIGH0 <= databus(7 downto 0);
           else
               LBAHIGH0 <= LBAHIGH0;
           end if;
           
           if (selectreg = "0110") then
               LBAHIGH1 <= databus(7 downto 0);
           else
               LBAHIGH1 <= LBAHIGH1;
           end if;
           
           if (selectreg = "0111") then
               LBAMID0 <= databus(7 downto 0);
           else
               LBAMID0 <= LBAMID0;
           end if;
           
           if (selectreg = "1000") then
               LBAMID1 <= databus(7 downto 0);
           else
               LBAMID1 <= LBAMID1;
           end if;
           
           if (selectreg = "1001") then
               LBALOW0 <= databus(7 downto 0);
           else
               LBALOW0 <= LBALOW0;
           end if;
           
           if (selectreg = "1010") then
               LBALOW1 <= databus(7 downto 0);
           else
               LBALOW1 <= LBALOW1;
           end if;
           
           if (selectreg = "1011") then
               sectorcount0 <= databus(7 downto 0);
           else
               sectorcount0 <= sectorcount0;
           end if;
           
           if (selectreg = "1100") then
               sectorcount1 <= databus(7 downto 0);
           else
               sectorcount1 <= sectorcount1;
           end if;
           
           if (selectreg = "1101") then           -- Current DMA modes
               cmodes <= databus(7 downto 0);     -- UUUMMPPP - where U - UDMA mode
           else                                   --                  M - MDMA mode
               cmodes <= cmodes;                  --                  P - PIO mode
           end if;
           
           if (selectreg = "1110") then
              regmodet0cus <= databus(8 downto 0);
              piomodet0cus <= databus(8 downto 0);
           else
              regmodet0cus <= regmodet0cus;
              piomodet0cus <= piomodet0cus;
           end if;
           
           if (selectreg = "1111") then
              MDMAmodet0cus <= databus(8 downto 0);
           else
              MDMAmodet0cus <= MDMAmodet0cus;
           end if;          
      end if;
    end process commandwrite;
    
MODESET: process(cmodes)
   begin
     
         if (cmodes(2 downto 0) = "100") then
             PIOmode <= mode4;
             REGmode <= mode4;
         elsif (cmodes(2 downto 0) = "011") then
             PIOmode <= mode3;
             REGmode <= mode3;
         elsif (cmodes(2 downto 0) = "010") then
             PIOmode <= mode2;
             REGmode <= mode2;
         elsif (cmodes(2 downto 0) = "001") then
             PIOmode <= mode1;
             REGmode <= mode1;
         else
             PIOmode <= mode0;
             REGmode <= mode0;
         end if;
         
         if (cmodes(4 downto 3) = "10") then
             MDMAmode <= mode2;
         elsif (cmodes(4 downto 3) = "01") then
             MDMAmode <= mode1;
         else
             MDMAmode <= mode0;
         end if;
         
         if (cmodes(7 downto 5) = "011") then
              UDMAmode <= mode3;
         elsif (cmodes(7 downto 5) = "010") then
              UDMAmode <= mode2;
          elsif (cmodes(7 downto 5) = "001") then
              UDMAmode <= mode1;
         else
              UDMAmode <= mode0;
         end if;
             

   end process MODESET;  
   
     
CRC: process(crcDIORHDMARDYHSTROBE, IORDYDDMARDYDSTROBE, DD, f, rw, CRCEN, CRCOUT, CRCIN) is -- CRC Generation for UDMA
   begin
      if (CRCEN = '1') then
         if (rw = '0') then
            if rising_edge(crcDIORHDMARDYHSTROBE) then
               CRCOUT <= CRCIN;
            elsif falling_edge(crcDIORHDMARDYHSTROBE) then
               CRCOUT <= CRCIN;
            else
               CRCOUT <= CRCOUT;
            end if;
          else
            if rising_edge(IORDYDDMARDYDSTROBE) then
               CRCOUT <= CRCIN;
            elsif falling_edge(IORDYDDMARDYDSTROBE) then
               CRCOUT <= CRCIN;    
            else
               CRCOUT <= CRCOUT;
            end if;
          end if;
      else
         CRCOUT <= "0100101010111010"; -- Enter Seed Value Here
      end if;
   
-- CRCIN signal generation Equations for UDMA Bursts
      CRCIN(0)  <= f(15);
      CRCIN(1)  <= f(14);
      CRCIN(2)  <= f(13);
      CRCIN(3)  <= f(12);
      CRCIN(4)  <= f(11);
      CRCIN(5)  <= f(10) XOR f(15);
      CRCIN(6)  <= f(9)  XOR f(14);
      CRCIN(7)  <= f(8)  XOR f(13);
      CRCIN(8)  <= f(7)  XOR f(12);
      CRCIN(9)  <= f(6)  XOR f(11);
      CRCIN(10) <= f(5)  XOR f(10);
      CRCIN(11) <= f(4)  XOR f(9);
      CRCIN(12) <= f(3)  XOR f(8) XOR f(15);
      CRCIN(13) <= f(2)  XOR f(7) XOR f(14);
      CRCIN(14) <= f(1)  XOR f(6) XOR f(13);
      CRCIN(15) <= f(0)  XOR f(5) XOR f(12);
-- f polynomial generation   Equations for UDMA Bursts
      f(0)  <= DD(0)  XOR CRCOUT(15);
      f(1)  <= DD(1)  XOR CRCOUT(14);  
      f(2)  <= DD(2)  XOR CRCOUT(13); 
      f(3)  <= DD(3)  XOR CRCOUT(12);
      f(4)  <= DD(4)  XOR CRCOUT(11) XOR f(0);
      f(5)  <= DD(5)  XOR CRCOUT(10) XOR f(1);
      f(6)  <= DD(6)  XOR CRCOUT(9)  XOR f(2);
      f(7)  <= DD(7)  XOR CRCOUT(8)  XOR f(3);
      f(8)  <= DD(8)  XOR CRCOUT(7)  XOR f(4);
      f(9)  <= DD(9)  XOR CRCOUT(6)  XOR f(5);
      f(10) <= DD(10) XOR CRCOUT(5)  XOR f(6);
      f(11) <= DD(11) XOR CRCOUT(4)  XOR f(0) XOR f(7);
      f(12) <= DD(12) XOR CRCOUT(3)  XOR f(1) XOR f(8);
      f(13) <= DD(13) XOR CRCOUT(2)  XOR f(2) XOR f(9);
      f(14) <= DD(14) XOR CRCOUT(1)  XOR f(3) XOR f(10);
      f(15) <= DD(15) XOR CRCOUT(0)  XOR f(4) XOR f(11);
   end process CRC;
       
regpio: process(regpioselect, REGmodet0, REGmodet1, REGmodet2, REGmodet2i, REGmodet3, REGmodet4,
                REGmodet5, REGmodet9, PIOmodet0, PIOmodet1, PIOmodet2, PIOmodet2i, PIOmodet3, 
                PIOmodet4, PIOmodet5, PIOmodet9) is

   begin
        if (regpioselect = '0') then   -- regpioselect = 0 then select register timings
             modet0  <= REGmodet0;  
             modet1  <= REGmodet1;  
             modet2  <= REGmodet2;  
             modet2i <= REGmodet2i; 
             modet3  <= REGmodet3;  
             modet4  <= REGmodet4;  
             modet5  <= REGmodet5;  
             modet9  <= REGmodet9;
        else
             modet0  <= PIOmodet0;  
             modet1  <= PIOmodet1;
             modet2  <= PIOmodet2;  
             modet2i <= PIOmodet2i; 
             modet3  <= PIOmodet3;  
             modet4  <= PIOmodet4;  
             modet5  <= PIOmodet5;  
             modet9  <= PIOmodet9;
        end if;          
           
            
   end process regpio;
   	
timers: process(clock, resetc, ltimerf, lreset, loadltimer, ltimerv, sreset, loadstimer,
                stimerv, creset, loadctimer, ctimerv, mreset, loadmtimer, mtimerv, stimerf,
                ctimerf, mtimerf ) is

   variable linttimer : unsigned(19 downto 0);
   variable sinttimer : unsigned(8 downto 0);
   variable cinttimer : unsigned(8 downto 0);
   variable minttimer : unsigned(19 downto 0);
   begin

       if (resetc = '1') then
           linttimer := "11111111111111111111";
           sinttimer := "111111111";
           cinttimer := "111111111";
           minttimer := "11111111111111111111";
           ltimerf <= '0';
           ctimerf <= '0';
           stimerf <= '0';
           mtimerf <= '0';      
       else
           -- Timer for Signals timings based on 100Mhz Clock
      	    if (lreset = '1') then
               linttimer := "11111111111111111111";
               ltimerf <= ltimerf;
           elsif (loadltimer = '1') then
        	      linttimer := unsigned(ltimerv);
    	          ltimerf <= '0';    
      	    elsif (linttimer = "00000000000000000000") then
			      linttimer := linttimer;
			      ltimerf <= '1';
			  elsif (linttimer = "11111111111111111111") then
			      linttimer := "11111111111111111111";
			      ltimerf <= ltimerf;
	        else
	            if (rising_edge(clock)) then
			         linttimer := linttimer - 1;
			         ltimerf <= '0';
			      else
			         linttimer := linttimer;
			         ltimerf <= ltimerf;
			      end if;
			  end if;
			  
		
			  if (sreset = '1') then
               sinttimer := "111111111";
               stimerf <= stimerf;
           elsif (loadstimer = '1') then
    	          sinttimer := unsigned(stimerv);
    	          stimerf <= '0';    
		     elsif (sinttimer = "00000000") then
		         sinttimer := sinttimer;
		         stimerf <= '1';
		     elsif (sinttimer = "111111111") then
			      sinttimer := "111111111";
			      stimerf <= stimerf;
		     else
		         if (rising_edge(clock)) then
			         sinttimer := sinttimer - 1;
		            stimerf <= '0';
			      else
			         sinttimer := sinttimer;
			         stimerf <= stimerf;
			      end if;
			  end if;
		     
		     if (creset = '1') then
               cinttimer := "111111111";
               ctimerf <= ctimerf;
           elsif (loadctimer = '1') then
                 cinttimer := unsigned(ctimerv);
                 ctimerf <= '0';    
           elsif (cinttimer = "00000000") then
               cinttimer := cinttimer;
               ctimerf <= '1';
           elsif (cinttimer = "111111111") then
               cinttimer := "111111111";
               ctimerf <= ctimerf;
           else
               if (rising_edge(clock)) then
                  cinttimer := cinttimer - 1;
                  ctimerf <= '0';
               else
                  cinttimer := cinttimer;
                  ctimerf <= ctimerf;
               end if;
           end if;
		     
		     if (mreset = '1') then
             minttimer := "11111111111111111111";
             mtimerf <= mtimerf;
           elsif (loadmtimer = '1') then
               minttimer := unsigned(mtimerv);
               mtimerf <= '0';    
           elsif (minttimer = "00000000000000000000") then
             minttimer := minttimer;
             mtimerf <= '1';
           elsif (minttimer = "11111111111111111111") then
             minttimer := "11111111111111111111";
             mtimerf <= mtimerf;
           else
             if (rising_edge(clock)) then
                minttimer := minttimer - 1;
                mtimerf <= '0';
             else
                minttimer := minttimer;
                mtimerf <= mtimerf;
             end if;
           end if;
       end if;
		 
  	   		
	   ltimer <= std_logic_vector(linttimer);
		stimer <= std_logic_vector(sinttimer);
      ctimer <= std_logic_vector(cinttimer);
      mtimer <= std_logic_vector(minttimer);	

      
   end process timers;

regtimers: process(clock, resetc, qtimerf, qreset, loadqtimer, qtimerv, treset, loadttimer,
                ttimerv, preset, loadptimer, ptimerv, ttimerf, ptimerf ) is

   variable qinttimer : unsigned(19 downto 0);
   variable tinttimer : unsigned(8 downto 0);
   variable pinttimer : unsigned(8 downto 0);

   begin

       if (resetc = '1') then
           qinttimer := "11111111111111111111";
           tinttimer := "111111111";
           pinttimer := "111111111";
           qtimerf <= '0';
           ptimerf <= '0';
           ttimerf <= '0';
           rtimerf <= '0';      
       else
           -- Timer for Signals timings based on 100Mhz Clock
      	    if (qreset = '1') then
               qinttimer := "11111111111111111111";
               qtimerf <= qtimerf;
           elsif (loadqtimer = '1') then
                 qinttimer := unsigned(qtimerv);
                 qtimerf <= '0';    
             elsif (qinttimer = "00000000000000000000") then
               qinttimer := qinttimer;
               qtimerf <= '1';
           elsif (qinttimer = "11111111111111111111") then
               qinttimer := "11111111111111111111";
               qtimerf <= qtimerf;
           else
               if (rising_edge(clock)) then
                  qinttimer := qinttimer - 1;
                  qtimerf <= '0';
               else
                  qinttimer := qinttimer;
                  qtimerf <= qtimerf;
               end if;
           end if;
			  
		
			  if (treset = '1') then
               tinttimer := "111111111";
               ttimerf <= ttimerf;
           elsif (loadttimer = '1') then
                 tinttimer := unsigned(ttimerv);
                 ttimerf <= '0';    
           elsif (tinttimer = "00000000") then
               tinttimer := tinttimer;
               ttimerf <= '1';
           elsif (tinttimer = "111111111") then
               tinttimer := "111111111";
               ttimerf <= ttimerf;
           else
               if (rising_edge(clock)) then
                  tinttimer := tinttimer - 1;
                  ttimerf <= '0';
               else
                  tinttimer := tinttimer;
                  ttimerf <= ttimerf;
               end if;
           end if;
		     
		     if (preset = '1') then
               pinttimer := "111111111";
               ptimerf <= ptimerf;
           elsif (loadptimer = '1') then
                 pinttimer := unsigned(ptimerv);
                 ptimerf <= '0';    
           elsif (pinttimer = "00000000") then
               pinttimer := pinttimer;
               ptimerf <= '1';
           elsif (pinttimer = "111111111") then
               pinttimer := "111111111";
               ptimerf <= ptimerf;
           else
               if (rising_edge(clock)) then
                  pinttimer := pinttimer - 1;
                  ptimerf <= '0';
               else
                  pinttimer := pinttimer;
                  ptimerf <= ptimerf;
               end if;
           end if;
		     
		     
       end if;
		 
      --loadltimerext <= loadltimer;
	   qtimer <= std_logic_vector(qinttimer);
		ttimer <= std_logic_vector(tinttimer);
      ptimer <= std_logic_vector(pinttimer);
      

      
   end process regtimers; 
     
DRIVERCONTROL: process (driver, ata_intddwe, intcs, intda, intDIORHDMARDYHSTROBE,
                        intDIOWSTOP, intDMACK, reg_intddwe, regCS, regDA, regDIORHDMARDYHSTROBE,
                        regDIOWSTOP, regDMACK) is          -- Control of which state machine controls the output lines
   begin
      case driver is
       
          when ATAD =>
              intddwe <= ata_intddwe;
              CS <= intcs;
			     DA <= intda;
			     DIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			     crcDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE; 
			     DIOWSTOP <= intDIOWSTOP; 
		        DMACK <= intDMACK; 
              
          when REG =>
              intddwe <= reg_intddwe;
		        CS <= regCS; 
		        DA <= regDA; 
		        DIORHDMARDYHSTROBE <= regDIORHDMARDYHSTROBE;
		        crcDIORHDMARDYHSTROBE <= regDIORHDMARDYHSTROBE; 
		        DIOWSTOP <= regDIOWSTOP; 
		        DMACK <= regDMACK; 
    
      end case;

   end process DRIVERCONTROL;

DATABUSFLOW: process (CDSTROBE, intrw, hddata, clock, atadirectdd, intddwe, intdd,
                      databus, atadd, DD) is
   begin
       if (atadirectdd = '0') then  
         if (hddata = '0') then               -- if reading from host or device side
            if (intrw = '0') then
              if (intddwe = '1') then          -- If reading from device
                 if (clock = '1') then   -- only read when intddwe is high
                   intdd <= DD;
                   DD <= (others => 'Z');
                   databus <= (others => 'Z');
                 else
                   intdd <= intdd;
                   DD <= (others => 'Z');
                   databus <= (others => 'Z');
                 end if;
              else
                 intdd <= intdd;
                 DD <= (others => 'Z');
                 databus <= (others => 'Z');
              end if;    
            else
               if (intddwe = '1') then      -- if writing to device and intddwe = '0' 
                 DD <= intdd;               -- then DD <= '0';
                 intdd <= intdd;
                 databus <= (others => 'Z');
               else
                 intdd <= intdd;
                 DD <= (others => 'Z');
                 databus <= (others => 'Z');
               end if;
            end if;
         else                                       -- Otherwise intdd control is by HLC
            if (intrw = '0') then
              if falling_edge(CDSTROBE) then         -- If receiving end ready 
                databus <= intdd;
              else
                intdd <= intdd;
              end if;    
            else
              if falling_edge(CDSTROBE) then         -- If receiving end ready 
                intdd <= databus;
                databus <= (others => 'Z');
              else
                intdd <= intdd;
                databus <= (others => 'Z');
              end if;    
            end if;
         end if;
       else
          if (intddwe = '1') then      -- if writing to device and intddwe = '0' 
             DD <= atadd;
             intdd <= intdd;
          else
             intdd <= intdd;
             DD <= DD;
          end if;

       end if;
      
   end process DATABUSFLOW;
       	
REGMODES: process(REGmode, regmodet0cus) is
   begin
      case REGMode is 
      
         when mode0 =>
             REGmodet0  <= "000111100";
             REGmodet1  <= "000000111";
             REGmodet2  <= "000011101";
             REGmodet2i <= "000000000";
             REGmodet3  <= "000000110";
             REGmodet4  <= "000000011";
             REGmodet5  <= "000000101";
             REGmodet9  <= "000000010";
         when mode1 =>
             REGmodet0  <= "000100110";
             REGmodet1  <= "000000101";
             REGmodet2  <= "000011101";
             REGmodet2i <= "000000000";
             REGmodet3  <= "000000101";
             REGmodet4  <= "000000010";
             REGmodet5  <= "000000100";
             REGmodet9  <= "000000010";
         when mode2 =>
             REGmodet0  <= "000100001";
             REGmodet1  <= "000000011";
             REGmodet2  <= "000011101";
             REGmodet2i <= "000000000";
             REGmodet3  <= "000000011";
             REGmodet4  <= "000000010";
             REGmodet5  <= "000000010";
             REGmodet9  <= "000000000";
         when mode3 =>
             REGmodet0  <= REGmodet0cus;
             REGmodet1  <= "000000011";
             REGmodet2  <= "000001000";
             REGmodet2i <= "000000111";
             REGmodet3  <= "000000000";
             REGmodet4  <= "000000000";
             REGmodet5  <= "000000000";
             REGmodet9  <= "000000000";
         when mode4 =>
             REGmodet0  <= REGmodet0cus;
             REGmodet1  <= "000000011";
             REGmodet2  <= "000000111";
             REGmodet2i <= "000000011";
             REGmodet3  <= "000000010";
             REGmodet4  <= "000000000";
             REGmodet5  <= "000000010";
             REGmodet9  <= "000000000";
        end case;   
   end process REGMODES;

PIOMODES: process(PIOmode, piomodet0cus) is
   begin
      case PIOMode is -- REMEMBER TO UPDATE THESE VALUES. SHOULD NOT BE THE SAME AS REG VALUES
      
         when mode0 =>
             PIOmodet0  <= "000111100";
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
         when mode1 =>
             PIOmodet0  <= "000111100";
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
         when mode2 =>
             PIOmodet0  <= "000111100";
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
         when mode3 =>
             PIOmodet0  <= PIOmodet0cus;
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
         when mode4 =>
             PIOmodet0  <= PIOmodet0cus;
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
        end case;   
   end process PIOMODES;
   
MDMAMODES: process(MDMAMode, MDMAmodet0cus) is
   begin
       case(MDMAMode) is
           
           when mode0 =>
               MDMAt0  <= "000110000";
               MDMAtd  <= "000010110";
               MDMAtg  <= "000001010";
               MDMAth  <= "000000010";
               MDMAtj  <= "000000010";
               MDMAtkr <= "000000101";
               MDMAtkw <= "000010110";
               MDMAtm  <= "000000101";
               MDMAtn  <= "000000010";
           when mode1 =>
               MDMAt0 <= MDMAmodet0cus;
               MDMAtd  <= "000001000";
               MDMAtg  <= "000000011";
               MDMAth  <= "000000010";
               MDMAtj  <= "000000001";
               MDMAtkr <= "000000101";
               MDMAtkw <= "000000101";
               MDMAtm  <= "000000011";
               MDMAtn  <= "000000001";
           when mode2 =>
               MDMAt0 <= MDMAmodet0cus;
               MDMAtd  <= "000000111";
               MDMAtg  <= "000000010";
               MDMAth  <= "000000001";
               MDMAtj  <= "000000001";
               MDMAtkr <= "000000011";
               MDMAtkw <= "000000011";
               MDMAtm  <= "000000011";
               MDMAtn  <= "000000001";
       end case;
   end process MDMAMODES; 
   
UDMAMODES: process(UDMAMode) is
   begin
       case(UDMAMode) is
           
           when mode0 =>
               UDMAtcyc      <= "000001100"; 
               UDMAt2cychalf <= "000001100";
               UDMAtdvs      <= "000000111";
               UDMAtdvh      <= "000000001";
               UDMAtcvh      <= "000000001";
               UDMAtmli      <= "000000010";
               UDMAtui       <= "000000000";
               UDMAtzah      <= "000000010"; 
               UDMAtenvmin   <= "000000010";
               UDMAtack      <= "000000010"; 
               UDMAtss       <= "000000101"; 
           when mode1 =>
               UDMAtcyc      <= "000001000"; 
               UDMAt2cychalf <= "000001000";
               UDMAtdvs      <= "000000101";
               UDMAtdvh      <= "000000001";
               UDMAtcvh      <= "000000001";
               UDMAtmli      <= "000000010";
               UDMAtui       <= "000000000";
               UDMAtzah      <= "000000010"; 
               UDMAtenvmin   <= "000000010";
               UDMAtack      <= "000000010"; 
               UDMAtss       <= "000000101";
           when mode2 =>
               UDMAtcyc      <= "000000110"; 
               UDMAt2cychalf <= "000000110";
               UDMAtdvs      <= "000000100";
               UDMAtdvh      <= "000000001";
               UDMAtcvh      <= "000000001";
               UDMAtmli      <= "000000010";
               UDMAtui       <= "000000000";
               UDMAtzah      <= "000000010"; 
               UDMAtenvmin   <= "000000010";
               UDMAtack      <= "000000010"; 
               UDMAtss       <= "000000101";
           when mode3 =>
               UDMAtcyc      <= "000000100"; 
               UDMAt2cychalf <= "000001001";
               UDMAtdvs      <= "000000010";
               UDMAtdvh      <= "000000001";
               UDMAtcvh      <= "000000001";
               UDMAtmli      <= "000000010";
               UDMAtui       <= "000000000";
               UDMAtzah      <= "000000010"; 
               UDMAtenvmin   <= "000000010";
               UDMAtack      <= "000000010"; 
               UDMAtss       <= "000000101";
       end case;
   end process UDMAMODES;    
   
ATA: process(current_state, ltimer, ltimerf, busy, intdd, mtimerf, 
             selectreg, devicereg, features, fortyeightbit, lbalow0, lbalow1,
             lbamid0, lbamid1, lbahigh0, lbahigh1, sectorcount0, sectorcount1, 
             commandreg, intrq, previous_state, cdstrobe, mudma, stimerf,
             mdmatd, mdmatg, ctimerf, mdmath, dmarq, mdmatm, mdmatkw,
             mdmatj, udmatdvs, iordyddmardydstrobe, pause, udmatcyc, udmat2cychalf,
             udmatdvh, udmatss, mdmat0, udmatui, intdiorhdmardyhstrobe,
             crcout, udmatmli, udmatack) is

	variable wrdcnt : unsigned(7 downto 0);
	variable sectorcnt : unsigned(16 downto 0);
	begin
		   
      wordcounter <= std_logic_vector(wrdcnt);
      sectorcounter <= std_logic_vector(sectorcnt);
		case (current_state) is
				       
         ---------------------------------------------------------------------------------------------------    
         --------------------------------Hardware/Software Protocol-----------------------------------------
         ---------------------------------------------------------------------------------------------------
			when HHRassert_reset =>			-- Hardware Reset States
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             cdrdy <= '0';
             error <= '0';
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
			    RESETD <= '1';
			    regrst <= '1';
			    regbegin <= '0';
			    intDIORHDMARDYHSTROBE <= '0';
			    intDIOWSTOP <= '0';
			    -- Timer Resets
			    creset <= '1';
			    sreset <= '1';
			    mreset <= '1';
			    loadctimer <= '0';
			    loadstimer <= '0';
			    loadmtimer <= '0';
             ctimerv <= (others => '0');
             stimerv <= (others => '0');
             mtimerv <= (others => '0'); 
             if (ltimer = "11111111111111111111") then
                loadltimer <= '1';
                lreset <= '0';
                ltimerv <= "00000000100111000100";
                next_state <= HHRassert_reset;    
             elsif (ltimerf = '1') then
                loadltimer <= '0';
                lreset <= '0';
                next_state <= HHRnegate_wait;    
             else
                loadltimer <= '0';
                lreset <= '0';
                next_state <= HHRassert_reset;
             end if;
		
          
			when HHRnegate_wait =>              -- Wait 2 Milliseconds
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
             RESETD <= '0';
     			    regrst <= '1';
			    regbegin <= '0';
			    -- Timer Resets
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             ctimerv <= (others => '0');
             stimerv <= (others => '0');
             mtimerv <= (others => '0');
             
             if (previous_state = HHRassert_reset) then
                 ltimerv <= "00110000110101000000";
                 loadltimer <= '1';
                 lreset <= '0';
                 next_state <= HHRnegate_wait;
             elsif (ltimerf = '1') then
			        next_state <= HHRHSRcheck_status;
			        loadltimer <= '0';
			        lreset <= '0';
			    else
			        next_state <= HHRnegate_wait;
			        loadltimer <= '0';
			        lreset <= '0';
			    end if;
			    
			when HHRHSRcheck_status =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '1';   -- Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             ctimerv <= (others => '0');
             stimerv <= (others => '0');
             mtimerv <= (others => '0');
             ltimerv <= (others => '0');
             next_state <= HHRHSRregaccesswait;
         
     			when HHRHSRregaccesswait =>
     			    driver <= REG;
     			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '1';   -- Sample dasp
     			    intDMACK <= '0';
  			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
             creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             ctimerv <= (others => '0');
             stimerv <= (others => '0');
             mtimerv <= (others => '0');
             
	          if (busy = '1') then
                next_state <= HHRHSRregaccesswait;
             else
                next_state <= HHRHSRcheck_status2;
             end if;
             
         when HHRHSRcheck_status2 =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '1';   -- Sample dasp
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             if (intdd(7) = '1') then
                 next_state <= HHRHSRcheck_status;
             else
                 next_state <= HIhost_idle; -----
             end if;
             
                        
			when HSRset_SRST =>	   -- Software Reset States
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp;
			    intDMACK <= '0';
			    intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    atadd <= "0000000000000100";
	          RESETD <= '0';
	          creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= HSRset_SRST_wait;
			    
			when HSRset_SRST_wait =>
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
             intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    atadd <= "0000000000000100";
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadltimer <= '0';
			    
			    if (previous_state = HSRset_SRST) then
                mtimerv <= "00000000000111110100";
                loadmtimer <= '1';
                mreset <= '0';
                next_state <= HSRset_SRST_wait;
             elsif (mtimerf = '1') then     -- Wait 5 microseconds
			        if (busy = '1') then
                   next_state <= HSRset_SRST_wait;
                else
                   next_state <= HSRclear_wait;
                end if;
			        loadmtimer <= '0';
			        mreset <= '0';
			    else
			        next_state <= HSRset_SRST_wait;
			        loadmtimer <= '0';
			        mreset <= '0';
			    end if;
			    
             
         when HSRclear_wait =>
             driver <= REG;
             atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp;
             intDMACK <= '0';
             intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    atadd <= "0000000000000000";
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             next_state <= HSRclear_wait_wait;
			    
			when HSRclear_wait_wait =>
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    atadd <= "0000000000000000";
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadltimer <= '0';
             
			    if (previous_state = HSRclear_wait) then
                mtimerv <= "00110011010001010000";
                loadmtimer <= '1';
                mreset <= '0';
                next_state <= HSRclear_wait_wait;
             elsif (mtimerf = '1') then     -- Wait 2.1 milliseconds
			        if (busy = '1') then
                   next_state <= HSRclear_wait_wait;
                else
                   next_state <= HHRHSRcheck_status;
                end if;
			        loadmtimer <= '0';
			        mreset <= '0';
			    else
			        next_state <= HSRclear_wait_wait;
			        loadmtimer <= '0';
			        mreset <= '0';
			    end if;
			    
 
         ---------------------------------------------------------------------------------------------------    
         ------------------------------------Host Idle Protocol---------------------------------------------
         ---------------------------------------------------------------------------------------------------
			when HIhost_idle =>		 	-- Bus Idle States -- When to go
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';

			    if (selectreg = "1111") then         -- If the register select lines = "1111"
			        next_state <= HIcheck_status;    -- then start the writing to device process
			    else
			        next_state <= HIhost_idle;
			    end if;
			    
			when HIcheck_status =>      -- Check device state
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             next_state <= HIcheck_status_wait;
             
         when HIcheck_status_wait =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             if (busy = '1') then
                next_state <= HIcheck_status_wait;
             else
                next_state <= HIcheck_status2;
             end if;
             
         when HIcheck_status2 =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             lreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             loadltimer <= '0';
             if (intdd(7) = '1') then    -- Check BSY bit
                                
                if (intdd(4) = '1') then -- Check DRQ bit
                    next_state <= HIcheck_status;
                else                 
                    next_state <= HIdevice_select;
                end if;
                
             else
             
                if (intdd(4) = '1') then -- Check DRQ bit
                    next_state <= HIcheck_status;
                else                 
                    next_state <= HIdevice_select;
                end if;
                
             end if;

      			-- write device parameters   
             
			when HIdevice_select =>      -- Change selected device & write device reg
             driver <= REG;
             atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
			    intcs <= "01";
			    intda <= "110";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    next_state <= HIdevice_select2;
			    atadd <= ("00000000" & (devicereg));
			    
			when HIdevice_select2 =>      -- Change selected device & write device reg (II)
             driver <= REG;
             atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
			    intcs <= "01";
			    intda <= "110";
			    intrw <= '1';
	          RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    if (busy = '1') then
			       regrst <= '0';
                next_state <= HIdevice_select2;
                atadd <= ("00000000" & (devicereg));
             else
 	             regrst <= '1';
                next_state <= HIwrite_features;
                atadd <= ("00000000" & (devicereg));
             end if;
             
			
			when HIwrite_features =>
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    atadd <= ("00000000" & (features));
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    HOB <= '0';
             next_state <= HIwrite_features_wait;
			
			when HIwrite_features_wait =>
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    atadd <= ("00000000" & (features));
			    intrw <= '1';
	          RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    HOB <= '0';
			    if (busy = '1') then
			       regrst <= '0'; 
                next_state <= HIwrite_features_wait;
             else
                regrst <= '1';
                next_state <= HIwrite_LBA_low;
             end if;

			when HIwrite_LBA_low =>
			     driver <= REG;
			     atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
			     intDMACK <= '0';
			     if (fortyeightbit = '0') then -- Write the low byte, else write the high byte first
			     -- LBA LB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBALOW0));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_low_wait;
			     else
			     -- LBA HB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBALOW1));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_low_wait;
			     end if;
			     


			
			when HIwrite_LBA_low_wait =>
              driver <= REG;
              atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
			     if (fortyeightbit = '0') then
			     -- LBA LB Low
              intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBALOW0));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBALOW1));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     end if;

			     if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_LBA_low_wait;
              else
 	             regrst <= '1';             
                next_state <= HIwrite_LBA_mid;
              end if;
              

			          
			when HIwrite_LBA_mid =>
			     driver <= REG;
			     atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
			     intDMACK <= '0';
			     if (fortyeightbit = '0') then
			     -- LBA LB Mid    
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAMID0));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_mid_wait;    

			     else
			     -- LBA HB Mid
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAMID1));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_mid_wait; 
			     end if;
			     

						
			 when HIwrite_LBA_mid_wait =>
              driver <= REG;
              atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
			     if (fortyeightbit = '0') then
			     -- LBA LB Mid
              intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAMID0));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB Mid
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAMID1));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     end if;
			    
		     
			     if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_LBA_mid_wait;
              else
 	             regrst <= '1';             
                next_state <= HIwrite_LBA_high;
              end if; 
                  
			when HIwrite_LBA_high =>
			     driver <= REG;
			     atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
			     intDMACK <= '0';
			     if (fortyeightbit = '0') then
			     -- LBA LB High    
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAHIGH0));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_high_wait;    

			     else
			     -- LBA HB High
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAHIGH1));
	           RESETD <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
			     
              next_state <= HIwrite_LBA_high_wait; 
			     end if;

						
			 when HIwrite_LBA_high_wait =>
              driver <= REG;
              atadirectdd <= '1';
			     hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
			     if (fortyeightbit = '0') then
			     -- LBA LB High
              intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAHIGH0));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB High
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     atadd <= ("00000000" & (LBAHIGH1));
	           RESETD <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     end if;
			     
			     if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_LBA_high_wait;
              else
 	             regrst <= '1';
 	             
 	             if (fortyeightbit = '1') then
 	                 next_state <= HIwrite_LBA_low48;
 	             else
 	                 next_state <= HIwrite_sector_cnt;
 	             end if;
              end if;
	    
			when HIwrite_LBA_low48 =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
              -- LBA LB Low
              intcs <= "01";
              intda <= "011";
              intrw <= '1';
              atadd <= ("00000000" & (LBALOW0));
              RESETD <= '0';
              regrst <= '0';
              regbegin <= '1';
              regpioselect <= '0';
              next_state <= HIwrite_LBA_low48_wait;

         
         when HIwrite_LBA_low48_wait =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
              -- LBA LB Low
              intcs <= "01";
              intda <= "011";
              intrw <= '1';
              atadd <= ("00000000" & (LBALOW0));
              RESETD <= '0';
              regbegin <= '0';
              regpioselect <= '0';
              
              if (busy = '1') then
                regrst <= '0';			   
                next_state <= HIwrite_LBA_low48_wait;
              else
                 regrst <= '1';             
                next_state <= HIwrite_LBA_mid48;
              end if;
              

                   
         when HIwrite_LBA_mid48 =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
              -- LBA LB Mid    
              intcs <= "01";
              intda <= "100";
              intrw <= '1';
              atadd <= ("00000000" & (LBAMID0));
              RESETD <= '0';
              regrst <= '0';
              regbegin <= '1';
              regpioselect <= '0';
              next_state <= HIwrite_LBA_mid48_wait;    

			         
          when HIwrite_LBA_mid48_wait =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
             
              -- LBA LB Mid
              intcs <= "01";
              intda <= "100";
              intrw <= '1';
              atadd <= ("00000000" & (LBAMID0));
              RESETD <= '0';
              regbegin <= '0';
              regpioselect <= '0';
        
           
              if (busy = '1') then
                regrst <= '0';			   
                next_state <= HIwrite_LBA_mid48_wait;
              else
                 regrst <= '1';             
                next_state <= HIwrite_LBA_high48;
              end if; 
                  
         when HIwrite_LBA_high48 =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';

              -- LBA LB High    
              intcs <= "01";
              intda <= "101";
              intrw <= '1';
              atadd <= ("00000000" & (LBAHIGH0));
              RESETD <= '0';
              regrst <= '0';
              regbegin <= '1';
              regpioselect <= '0';
  

              next_state <= HIwrite_LBA_high48_wait; 
 

			         
          when HIwrite_LBA_high48_wait =>
              driver <= REG;
              atadirectdd <= '1';
              hddata <= '0';
              ata_intddwe <= '0';
              daspen <= '0';   -- Don't Sample dasp
              intDMACK <= '0';
              -- LBA LB High
              intcs <= "01";
              intda <= "101";
              intrw <= '1';
              atadd <= ("00000000" & (LBAHIGH0));
              RESETD <= '0';
              regbegin <= '0';
              regpioselect <= '0';
                            
              if (busy = '1') then
                regrst <= '0';			   
                next_state <= HIwrite_LBA_high48_wait;
              else
                 regrst <= '1';
                 next_state <= HIwrite_sector_cnt;
              end if;   
              
			when HIwrite_sector_cnt =>
			    driver <= REG;
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    if (fortyeightbit = '0') then
			       -- Sector Count
			       intcs <= "01";
			       intda <= "010";
			       intrw <= '1';
	             RESETD <= '0';
	             regrst <= '0';
			       regbegin <= '1';
			       regpioselect <= '0';
			       atadd <= ("00000000" & (sectorcount0)); -- Where data coming from
                next_state <= HIwrite_sector_cnt_wait;
			    else
			        -- Sector Count
			       intcs <= "01";
			       intda <= "010";
			       intrw <= '1';
	             RESETD <= '0';
	             regrst <= '0';
			       regbegin <= '1';
			       regpioselect <= '0';
			       atadd <= ("00000000" & (sectorcount1)); -- Where data coming from
                next_state <= HIwrite_sector_cnt_wait;
			   end if;

			    
                
			     
			when HIwrite_sector_cnt_wait =>
			    driver <= REG;
             intDMACK <= '0';
             atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             if (fortyeightbit = '0') then
                -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESETD <= '0';
                regrst <= '0';
                regbegin <= '0';
                regpioselect <= '0';
                atadd <= ("00000000" & (sectorcount0)); -- Where data coming from
             else
                 -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESETD <= '0';
                regrst <= '0';
                regbegin <= '0';
                regpioselect <= '0';
                atadd <= ("00000000" & (sectorcount1)); -- Where data coming from

            end if;
            
            if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_sector_cnt_wait;
            else
 	             regrst <= '1';
 	             
 	           if (fortyeightbit = '1') then
 	              
 	             next_state <= HIwrite_sector_cnt48;
 	                        
 	             if (sectorcount1 = "00000000")   then
 	                if (sectorcount0 = "00000000")   then
 	                    sectorcnt := ('1' & "0000000000000000");
 	                else
 	                    sectorcnt := unsigned('0' & sectorcount1 & sectorcount0);
 	                end if;
 	             else
 	                sectorcnt := unsigned('0' & sectorcount1 & sectorcount0);
 	             end if;   
 	           else
 	                 if (sectorcount0 = "00000000")   then
 	                    sectorcnt := "00000000100000000";
 	                 else
 	                    sectorcnt := unsigned("000000000" & sectorcount0);
 	                 end if; 
 
 	                 next_state <= HIwrite_command;
 	           end if;
 	         end if;
 	         -- Sort out internal counters
 	         
			when HIwrite_sector_cnt48 =>
             driver <= REG;
             atadirectdd <= '1';
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
  
                -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESETD <= '0';
                regrst <= '0';
                regbegin <= '1';
                regpioselect <= '0';
                atadd <= ("00000000" & (sectorcount0)); -- Where data coming from
                next_state <= HIwrite_sector_cnt48_wait;
           

             
                
              
         when HIwrite_sector_cnt48_wait =>
             driver <= REG;
             intDMACK <= '0';
             atadirectdd <= '1';
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp

                -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESETD <= '0';
                regrst <= '0';
                regbegin <= '0';
                regpioselect <= '0';
                atadd <= ("00000000" & (sectorcount0)); -- Where data coming from
             
            
            if (busy = '1') then
                regrst <= '0';			   
                next_state <= HIwrite_sector_cnt48_wait;
            else
                 regrst <= '1';
                 
                 if (sectorcount1 = "00000000")   then
                    if (sectorcount0 = "00000000")   then
                        sectorcnt := ('1' & "0000000000000000");
                    else
                        sectorcnt := unsigned('0' & sectorcount1 & sectorcount0);
                    end if;
                 else
                    sectorcnt := unsigned('0' & sectorcount1 & sectorcount0);
                 end if;   
                 next_state <= HIwrite_command;
             end if;
             
                 
			when HIwrite_command =>
			    driver <= REG;
			    daspen <= '0';   -- Don't Sample dasp
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';
			    intDMACK <= '0';
			     -- Command Register
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    atadd <= ("00000000" & (commandreg)); -- Where data coming from
			    regpioselect <= '0';
			    HOB <= '0';
			    sectorcnt := sectorcnt;
			    next_state <= HIwrite_command_wait;
			     
			when HIwrite_command_wait =>
			    driver <= REG;
			    daspen <= '0';   -- Don't Sample dasp
			    atadirectdd <= '1';
			    hddata <= '0';
             ata_intddwe <= '0';	
			    intDMACK <= '0';		    
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '1';
	          RESETD <= '0';
			    regbegin <= '0';
			    atadd <= ("00000000" & (commandreg)); -- Where data coming from
			    regpioselect <= '0';
			    HOB <= '0';
			    sectorcnt := sectorcnt;
			    if (busy = '1') then
			       regrst <= '0'; 
                next_state <= HIwrite_command_wait;
             else
 	             regrst <= '1';
 	             loadstimer <= '1';
 	             sreset <= '0';
 	             stimerv <= "000101000";   -- 400nS
 	             next_state <= HIbranch_select;
 	          end if;
 	          
 	       when HIbranch_select =>
			    driver <= ATAD;
			    daspen <= '0';   -- Don't Sample dasp
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';	
			    intDMACK <= '0';		    
			    -- Pick correct states to go into
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    HOB <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := "11111111";
			    if (stimerf = '1') then
			       sreset <= '0';
			       loadstimer <= '0';
 	             if (commandreg = "10010000") then -- Execute Device diag
 	                next_state <= HEDwait_state;     
 	             elsif (commandreg = "11101100") then -- Identify Device
 	                next_state <= HPIOIintrq_wait;
 	             elsif (commandreg = "11101111") then   -- Set Features
 	                next_state <= HNDintrq_wait;
 	             elsif (commandreg = "00100000") then   -- Read Sectors
 	                next_state <= HPIOIintrq_wait; 
 	             elsif (commandreg = "00100100") then   -- Read Sectors LBA48
 	                next_state <= HPIOIintrq_wait;
 	             elsif (commandreg = "00110000") then   -- Write Sectors
 	                next_state <= HPIOOcheck_status;    
 	             elsif (commandreg = "00110100") then   -- Write Sectors LBA48
 	                next_state <= HPIOOcheck_status;
 	             elsif (commandreg = "11001010") then   -- Write DMA
 	                next_state <= HDMAcheck_status; 
 	             elsif (commandreg = "00110101") then   -- Write DMA LBA48
 	                next_state <= HDMAcheck_status; 
 	             else
 	                next_state <= HIhost_idle;   -- Written Command not currently supported 
 	             end if;
 	          else
 	             sreset <= '0';
			       loadstimer <= '0';
			       next_state <= HIbranch_select;
             end if; 
			
			---------------------------------------------------------------------------------------------------    
         -------------------------------------Non Data Protocol---------------------------------------------
         ---------------------------------------------------------------------------------------------------
			    
			when HNDintrq_wait =>			-- Non Data Command States
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
			    if(INTRQ = '1') then
			        next_state <= HNDcheck_status;
			    else
			        next_state <= HNDintrq_wait;
			    end if;
			    
			when HNDcheck_status =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HNDcheck_status_wait;
			    
			when HNDcheck_status_wait =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (busy = '1') then
 	             regrst <= '0'; 
                next_state <= HNDcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HNDcheck_status2;
             end if;
			    
			when HNDcheck_status2 =>
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd(7) = '1')then
                 next_state <= HNDcheck_status2;
             elsif (intdd(0) = '1') then
                 next_state <= Error_check;
             else                 
                 next_state <= HIhost_idle; 
             end if;
             
         ---------------------------------------------------------------------------------------------------    
         -----------------------------------PIO Data In Protocol--------------------------------------------
         ---------------------------------------------------------------------------------------------------    
			    
			when HPIOIintrq_wait =>			-- PIO Data-in States
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '1';
			    sectorcnt := sectorcnt;
			    if (previous_state = HIhost_idle) then
			        wrdcnt := "11111111";
			    else
			        wrdcnt := wrdcnt;
			    end if;
			    
			    if(INTRQ = '1') then
			        next_state <= HPIOIcheck_status;
			    else
			        next_state <= HPIOIintrq_wait;
			    end if;

			    			    
			when HPIOIcheck_status =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HPIOIcheck_status_wait;
             
         when HPIOIcheck_status_wait =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (busy = '1') then
 	             regrst <= '0'; 
                next_state <= HPIOIcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HPIOIcheck_status2;
             end if;
             
         when HPIOIcheck_status2 =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd(7) = '1') then
                 next_state <= HPIOIcheck_status;
             elsif (intdd(4) = '1') then
                 next_state <= HPIOItransfer_data;
             else                 
                 next_state <= ERROR_check; -- Check Error!
             end if;
             
			when HPIOItransfer_data =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '1';
			    sectorcnt := sectorcnt;
			    cdrdy <= '0';
			    
			    if (previous_state = HPIOIcheck_status2) then
			        wrdcnt := "11111111";
			    else
			        wrdcnt := wrdcnt;
			    end if;
			    
             next_state <= HPIOItransfer_data2;
         
         when HPIOItransfer_data2 =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '1';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '1';
             if (busy = '1') then
                cdrdy <= '0';
                next_state <= HPIOItransfer_data2;
                regrst <= '0'; 
             else

                 if (cdstrobe = '0') then        -- If controller is ready
                    regrst <= '1';
                    cdrdy <= '0';                -- Say ready to send data 
                    if (wrdcnt = "00000000") then
                        sectorcnt := sectorcnt - 1;
                        if (sectorcnt = "00000000000000000") then
                           next_state <= HIhost_idle;
                        else
                           wrdcnt := "11111111";
                           next_state <= HPIOItransfer_data;
                        end if;
                    else
                       wrdcnt := wrdcnt - 1;
                       sectorcnt := sectorcnt;
                       next_state <= HPIOItransfer_data;
                    end if;
                  else                            -- If controller is not ready then loop until ready        
                     cdrdy <= '1';
                     next_state <= HPIOItransfer_data2;
                     regrst <= '0';       
                  end if;
                               
             end if; 
             

         ---------------------------------------------------------------------------------------------------    
         -----------------------------------PIO Data Out Protocol-------------------------------------------
         ---------------------------------------------------------------------------------------------------
             
			when HPIOOcheck_status =>		-- PIO Data-out States
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             cdrdy <= '0';
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HPIOOcheck_status_wait;
             
         when HPIOOcheck_status_wait =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             cdrdy <= '0';
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (busy = '1') then
                regrst <= '0';  
                next_state <= HPIOOcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HPIOOcheck_status2;
             end if;
             
         when HPIOOcheck_status2 =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             cdrdy <= '0';
             intDMACK <= '0';
             intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd(7) = '1') then
                 next_state <= HPIOOcheck_status;
             elsif (intdd(3) = '1') then
                 next_state <= HPIOOtransfer_data;
             elsif (intdd(0) = '1') then
                 next_state <= ERROR_check;
             else                 
                 next_state <= HIhost_idle; 
             end if;
         
         when HPIOOget_data =>      -- Get the data to transfer
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '1';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
			    intcs <= "01";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
	          sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    regbegin <= '0';
			    regpioselect <= '1';
			    	          
	          if (cdstrobe = '0') then
	              cdrdy <= '0';
			        next_state <= HPIOOtransfer_data;
			    else
	              cdrdy <= '1';
			        next_state <= HPIOOget_data;
			    end if; 
                
			when HPIOOtransfer_data =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             cdrdy <= '0';
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
	          
	          cdrdy <= '0';
       		    regbegin <= '1';
			    regpioselect <= '1';
			    sectorcnt := sectorcnt;
			    
			    if (previous_state = HPIOOget_data) then
			        wrdcnt := "11111111";
			    else
			        wrdcnt := wrdcnt;
			    end if;
			    
			    next_state <= HPIOOtransfer_data2;
			    
         
         when HPIOOtransfer_data2 =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '1';
             if (busy = '1') then
                cdrdy <= '0';
                next_state <= HPIOOtransfer_data2;
                regrst <= '0'; 
             else
                 regrst <= '1';
                 cdrdy <= '0';
                 if (wrdcnt = "00000000") then
                       sectorcnt := sectorcnt - 1;
                       if (sectorcnt = "00000000000000000") then
                           next_state <= HPIOOintrq_wait;
                       else
                           next_state <= HPIOOtransfer_data;
                           wrdcnt := "11111111";
                       end if;
                 else
                       wrdcnt := wrdcnt - 1;
                       sectorcnt := sectorcnt;
                       next_state <= HPIOOtransfer_data;
                 end if;
             end if; 
                     
         when HPIOOintrq_wait =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
			    
             if(INTRQ = '1') then
		           next_state <= HPIOIcheck_status;
		       else
		           next_state <= HPIOIintrq_wait;
		       end if;
             
			---------------------------------------------------------------------------------------------------    
         -----------------------------Execute Device Diagnostic Protocol------------------------------------
         ---------------------------------------------------------------------------------------------------
         			    
			when HEDwait_state =>			-- Execute Device Diagnostic States
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if(INTRQ = '1') then
			        next_state <= HEDcheck_status;
			    else
			        next_state <= HEDwait_state;
			    end if;
			    
			when HEDcheck_status =>
			    driver <= REG;
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             next_state <= HEDcheck_status_wait;
             
         when HEDcheck_status_wait =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
			    intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if (busy = '1') then
                regrst <= '0';  
                next_state <= HEDcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HEDcheck_status2;
             end if;
             
         when HEDcheck_status2 =>
			    driver <= ATAD;
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= 'Z';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if (intdd(7) = '1') then
                 next_state <= HEDcheck_status;
             elsif (intdd(0) = '1') then
                 next_state <= ERROR_check;
             else
                 next_state <= HIhost_idle; -- FOR THE MOMENT GO TO HOST IDLE, ADD CODE TO CHECK RESULT
             end if; 
             
         ---------------------------------------------------------------------------------------------------    
         -----------------------------Multi-Word DMA Transfer Protocol Out--------------------------------------
         ---------------------------------------------------------------------------------------------------
             
         when HDMAcheck_status =>		-- DMA Command Protocol States
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             CDRDY <= '0';
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIORHDMARDYHSTROBE <= '0';
			    intDIOWSTOP <= '0';
             next_state <= HDMAcheck_status_wait;
             
         when HDMAcheck_status_wait =>
             driver <= REG;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             CDRDY <= '0';
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESETD <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIORHDMARDYHSTROBE <= '0';
			    intDIOWSTOP <= '0';
             if (busy = '1') then
                regrst <= '0';  
                next_state <= HDMAcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HDMAcheck_status2;
             end if;
             
         when HDMAcheck_status2 =>
             driver <= ATAD;
             atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             CDRDY <= '0';
             intDMACK <= '0';
             intDIORHDMARDYHSTROBE <= '0';
			    intDIOWSTOP <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    
			    if (DMARQ = '1') then
			           if (intdd(7) = '1') then -- Check bsy 
			              if (intdd(3) = '1') then -- Check DRQ
			                 next_state <= HDMAcheck_status;
			              else
			                 if (MUDMA = '1') then
                             next_state <= UDMAout_initialize;
                          else
                             next_state <= HDMAprepareDMAtransfer;
                          end if;   
			              end if;
			           else
			              if (intdd(3) = '1') then -- Check DRQ
			                 if (MUDMA = '1') then
                             next_state <= UDMAout_initialize;
                          else
                             next_state <= HDMAprepareDMAtransfer;
                          end if;
			              else
			                 if (intdd(0) = '1') then
			                    next_state <= ERROR_check;
			                 else
			                    next_state <= HIhost_idle;
			                 end if;      
			              end if;   
                    end if;
			       else
			          if (intdd(7) = '1') then   -- If bsy then wait
			             next_state <= HDMAcheck_status2;    
			          elsif (intdd(3) = '1') then   -- if not busy but DRQ then check for error
			             next_state <= ERROR_check;    
			          else
			             if (intdd(0) = '1') then   -- If not Bsy and not DRQ then check for error
			                next_state <= ERROR_check;
			             else
			                next_state <= HIhost_idle;
			             end if;
			          end if;
			       end if;
			       
             
         when HDMAprepareDMAtransfer =>
             driver <= ATAD;                    -- ATA State Driving Outputs
     			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                      -- Write Data
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
			    creset <= '1';
			    lreset <= '1';
			    mreset <= '1';
			    loadctimer <= '0';
			    loadltimer <= '0';
			    loadmtimer <= '0';
			    intDMACK <= '1';                   -- DMACK = '1'
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    CDRDY <= '0';
			    if (previous_state = HDMAcheck_status2) then      -- Wait tm before moving on
			        stimerv <= MDMAtm;
			        loadstimer <= '1';
			        next_state <= HDMAprepareDMAtransfer;
			    elsif (stimerf = '1') then
			        sreset <= '1';
			        next_state <= HDMAtransfer_get_data_first; -- DMARQ should be asserted so should go straight through
             else
                 sreset <= '0';
                 loadstimer <= '0';
                 next_state <= HDMAprepareDMAtransfer;
			    end if;
			    
         when HDMAtransfer_get_data_first =>
             driver <= ATAD;          -- ATA State Driving Outputs
			    atadirectdd <= '0';
			    hddata <= '1';   
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';            -- Write Data
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
			    lreset <= '1';
		       mreset <= '1';			    
			    loadltimer <= '0';
			    loadmtimer <= '0';

 			    intDMACK <= '1';
 
			    sectorcnt := sectorcnt;

			    intDIORHDMARDYHSTROBE <= '0';
			                
			    -- Raise DIOWSTOP
			    intDIOWSTOP <= '1';
			    
			    -- start td timer
			    if (previous_state = HDMAprepareDMAtransfer) then      
			        stimerv <= MDMAtd;
			        loadstimer <= '1';
			        sreset <= '0';
             else
                 sreset <= '0';
                 loadstimer <= '0';
			    end if;
			    
			    -- Wait for data from controller
			    if (CDSTROBE = '0') then
			         CDRDY <= '0';
			       		wrdcnt := wrdcnt - 1;
			       		creset <= '0';
			       		loadctimer <= '1';
			       		ctimerv <= MDMAtg;
			       		next_state <= HDMAtransfer_data_first;    
			    else
			         CDRDY <= '1';
			         wrdcnt := wrdcnt;
			         creset <= '1';
			         loadctimer <= '0';
			         next_state <= HDMAtransfer_get_data_first;
			    end if;
			                 
			when HDMAtransfer_data_first =>
			    driver <= ATAD;          -- ATA State Driving Outputs
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';            -- Write Data
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
			    lreset <= '1';
		       mreset <= '1';			    
			    loadltimer <= '0';
			    loadmtimer <= '0';
			    

	       		 wrdcnt := wrdcnt;

 			    intDMACK <= '1';
 
			    sectorcnt := sectorcnt;

			    intDIORHDMARDYHSTROBE <= '0';
			                
			    -- Raise DIOWSTOP
			    intDIOWSTOP <= '1';
			    
			    -- start td timer

   	         stimerv <= MDMAtd;
			    loadstimer <= '1';
			    sreset <= '0';
 
             -- start tg timer
	       	 	creset <= '0';
	       	 	loadctimer <= '1';
	       		 ctimerv <= MDMAtg;
	       		
	       		 next_state <= HDMAtransfer_data_first2;    

                              
			    
			    
			    			    
			when HDMAtransfer_data_first2 =>
			    driver <= ATAD; -- ATA State Driving Outputs
			    atadirectdd <= '0';
			    hddata <= '0';   
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    intDMACK <= '1'; 
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';
 			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    lreset <= '1';
			    loadltimer <= '0';
			    CDRDY <= '0';			    
			    intDIORHDMARDYHSTROBE <= '0';
			    
			    if (ctimerf = '1') then
			       if (stimerf = '1') then
			          intDIOWSTOP <= '0';      -- Once both timers have finished, negate DIOW
			          creset <= '0';
			          mreset <= '0';
			          sreset <= '0';    
			          loadstimer <= '0';
			          loadctimer <= '0';
			          loadmtimer <= '0';
			          
			          next_state <= HDMAtransfer_data_waitth;
			       else
			          intDIOWSTOP <= '1';
			          creset <= '0';
			          loadctimer <= '0';
			          sreset <= '0';
			          loadstimer <= '0';
			          mreset <= '1';
			          loadmtimer <= '0';
			          next_state <= HDMAtransfer_data_first2;
			       end if;    
			    else
			       intDIOWSTOP <= '1';
			       creset <= '0';
			       loadctimer <= '0';
			       sreset <= '0';
			       loadstimer <= '0';
			       mreset <= '1';
			       loadmtimer <= '0';
			       next_state <= HDMAtransfer_data_first2;
			    end if;
			    
		   when HDMAtransfer_data_waitth =>
 			    driver <= ATAD;                -- ATA State Driving Outputs
 			    atadirectdd <= '0';
 			    daspen <= '0';   -- Don't Sample dasp
			    hddata <= '0';   
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';

			    lreset <= '1';
             loadltimer <= '0';

 			    intDMACK <= '1';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		       intDIOWSTOP <= '0';
		       sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    CDRDY <= '0';
			    
             
			    
			    if (previous_state = HDMAtransfer_data_first2) then
			       sreset <= '0';
			       mreset <= '0';
			       creset <= '0';
			       loadstimer <= '1';
			       loadctimer <= '1';
			       loadmtimer <= '1';
			       stimerv <= MDMAth;                           -- Timer th
			       ctimerv <= MDMAtkw;                           -- Timer tk
			       mtimerv <= ("00000000000" & (MDMAt0));
			    elsif (previous_state = HDMAtransfer_data) then
			       sreset <= '0';
			       mreset <= '0';
			       creset <= '0';
			       loadstimer <= '1';
			       loadctimer <= '1';
			       loadmtimer <= '1';
			       stimerv <= MDMAth;                           -- Timer th
			       ctimerv <= MDMAtkw;                           -- Timer tk
			       mtimerv <= ("00000000000" & (MDMAt0)); 			    
			    elsif (stimerf = '1') then
                ata_intddwe <= '0';      -- After the has passed then zero databus
                sreset <= '0';
                loadstimer <= '0';
                mreset <= '0';
			       creset <= '0';
			       loadmtimer <= '0';
			       loadctimer <= '0';
                next_state <= HDMAtransfer_data_waittk;			        
			    else
                ata_intddwe <= '1';
                sreset <= '0';
                loadstimer <= '0';
                mreset <= '0';
			       creset <= '0';
			       loadmtimer <= '0';
			       loadctimer <= '0';
                next_state <= HDMAtransfer_data_waitth;			    
			    end if;
			    
			when HDMAtransfer_data_waittk =>	    			    
			    driver <= ATAD;                -- ATA State Driving Outputs
 			    atadirectdd <= '0';
			    hddata <= '0';
             ata_intddwe <= '0';	
             daspen <= '0';   -- Don't Sample dasp		       
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';

			    lreset <= '1';
             sreset <= '1';
             loadltimer <= '0';
             loadstimer <= '0';
             
 			    intDMACK <= '1';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		       
		       sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    CDRDY <= '0';
			    
             mreset <= '0';
			    loadmtimer <= '0';
			    			    
			    if (ctimerf = '1') then
			       intDIOWSTOP <= '1';                  -- Assert DIOW 
                creset <= '1';
                loadctimer <= '0';
                next_state <= HDMAget_data;			        
			    else
			       intDIOWSTOP <= '0';
                creset <= '0';
                loadctimer <= '0';
                next_state <= HDMAtransfer_data_waittk;			    
			    end if;    		    
			    	    
			when HDMAget_data =>
			    driver <= ATAD;                -- ATA State Driving Outputs
 			    atadirectdd <= '0';
			    hddata <= '1';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp			       
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESETD <= '0';
			    regrst <= '1';

			    lreset <= '1';
             sreset <= '1';
             creset <= '1';
             loadltimer <= '0';
             loadstimer <= '0';
             loadctimer <= '0';
             
 			    intDMACK <= '1';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		       intDIOWSTOP <= '1';
		       
		       sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    
             mreset <= '0';
			    loadmtimer <= '0';
			    			    
			    if (CDSTROBE = '0') then
                CDRDY <= '0';
                next_state <= HDMAwrite_data;			        
			    else
                CDRDY <= '1';
                next_state <= HDMAget_data;			    
			    end if;
			    
			when HDMAwrite_data =>
			    driver <= ATAD;                -- ATA State Driving Outputs
             atadirectdd <= '0';
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp			       
             intcs <= "00";
             intda <= "000";
             intrw <= '1';
             RESETD <= '0';
             regrst <= '1';
             regbegin <= '0';
             regpioselect <= '0';
             RESETD <= '0';
             regrst <= '1';

             lreset <= '1';
             sreset <= '1';
             loadltimer <= '0';
             loadstimer <= '0';
             
             intDMACK <= '1';
             intDIORHDMARDYHSTROBE <= '0'; 
             intDIOWSTOP <= '1';
             
             sectorcnt := sectorcnt;
             wrdcnt := wrdcnt;
             
             mreset <= '0';
             creset <= '0';
             loadmtimer <= '0';
             loadctimer <= '1';
             ctimerv <= MDMAtg; -- Load timer with tg;
			    next_state <= HDMAtransfer_data;             

			      
         when HDMAtransfer_data =>
             driver <= ATAD;                -- ATA State Driving Outputs
             atadirectdd <= '0';
             hddata <= '0';
             ata_intddwe <= '1';	
             daspen <= '0';   -- Don't Sample dasp		       
             intcs <= "00";
             intda <= "000";
             intrw <= '1';
             RESETD <= '0';
             regrst <= '1';
             regbegin <= '0';
             regpioselect <= '0';
             RESETD <= '0';
             regrst <= '1';

             lreset <= '1';
             loadltimer <= '0';
             
             intDMACK <= '1';
             intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW

             if (mtimerf = '1') then
                if (ctimerf = '1') then
                   intDIOWSTOP <= '0';
                   mreset <= '0';
                   sreset <= '0';
                   loadctimer <= '0';
                   creset <= '0';
                   loadmtimer <= '0';
                   loadstimer <= '1';
                   stimerv <= MDMAth;
                   
                   if (DMARQ = '0') then          -- Then Pause the DMA burst
                      
                      next_state <= HDMAdevice_pause;
                      if (wrdcnt = "00000000") then
                          if (sectorcnt = "0000000000000000") then
                             wrdcnt := "00000000";
                             sectorcnt := "00000000000000000";
                          else
                             wrdcnt := "11111111";
                             sectorcnt := sectorcnt - 1;
                          end if;
                      else
                         wrdcnt := wrdcnt - 1;
                         sectorcnt := sectorcnt;
                      end if; 
                   else

                      if (wrdcnt = "00000000") then
                          if (sectorcnt = "0000000000000000") then
                             wrdcnt := "00000000";
                             sectorcnt := "00000000000000000";
                             next_state <= HDMAhost_terminate;    
                          else
                             wrdcnt := "11111111";
                             sectorcnt := sectorcnt - 1;
                             next_state <= HDMAtransfer_data_waitth;
                          end if;
                      else
                         wrdcnt := wrdcnt - 1;
                         sectorcnt := sectorcnt;
                         next_state <= HDMAtransfer_data_waitth;
                      end if;
                   end if;
                else
                   sectorcnt := sectorcnt;
                   wrdcnt := wrdcnt;
                   intDIOWSTOP <= '1';
                   mreset <= '0';
                   creset <= '0';
                   sreset <= '0';
                   loadmtimer <= '0';
                   loadctimer <= '0';
                   loadstimer <= '0';
                   next_state <= HDMAtransfer_data;               
                end if;    
             else
                sectorcnt := sectorcnt;
                wrdcnt := wrdcnt;
                intDIOWSTOP <= '1';
                mreset <= '0';
                creset <= '0';
                sreset <= '0';
                loadmtimer <= '0';
                loadctimer <= '0';
                loadstimer <= '0';
                next_state <= HDMAtransfer_data;
             end if;

			    		       
		  
             -- At the end of burst then goto HMDAintrq_wait
         
            
         when HDMAdevice_pause =>
         
             driver <= ATAD; -- ATA State Driving Outputs
             atadirectdd <= '0';
             hddata <= '0';
             ata_intddwe <= '1';	
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    
			    
             
 			    intDIOWSTOP <= '0';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
 			    if (previous_state = HDMAtransfer_data) then
 			        loadctimer <= '1';
                 creset <= '0';
                 ctimerv <= MDMAtj;
                 lreset <= '0';
 			        loadltimer <= '0';
 			        mreset <= '0';
                 loadmtimer <= '0';
                 loadstimer <= '0';
                 sreset <= '0';
 			    elsif (stimerf = '1') then
 			       ata_intddwe <= '0';
 			       if (ctimerf = '1') then
 			          intDMACK <= '0';
 			          if (wrdcnt = "00000000") then
 			             if (sectorcnt = "0000000000000000") then
 			                next_state <= HDMAintrq_wait;   -- Transfer has finished
 			             else
 			                next_state <= HDMAcheck_status;
 			             end if;
 			          else
 			             next_state <= HDMAcheck_status;
 			          end if;        
 			       else
 			          intDMACK <= '1';
 			          next_state <= HDMAdevice_pause;
 			       end if;	    
 			    else
 			       lreset <= '0';
 			       loadltimer <= '0';
 			       creset <= '0';
 			       loadctimer <= '0';
                mreset <= '0';
                loadmtimer <= '0';
                loadstimer <= '0';
                sreset <= '0';
 			       ata_intddwe <= '1';
 			       next_state <= HDMAdevice_pause;	
 			    end if;
 			    
 			    
 			when HDMAhost_terminate =>         -- Needs to be written
             driver <= ATAD; -- ATA State Driving Outputs
             atadirectdd <= '0';
             hddata <= '0';
             ata_intddwe <= '1';	
             daspen <= '0';   -- Don't Sample dasp
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESETD <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    
			    lreset <= '0';
 			    loadltimer <= '0';
 			    creset <= '0';
 			    loadctimer <= '0';
             mreset <= '0';
             loadmtimer <= '0';
             
 			    intDIOWSTOP <= '0';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW

         when HDMAintrq_wait =>
			    driver <= ATAD;
			    atadirectdd <= '0';
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
 			    sreset <= '1';
 			    loadstimer <= '0';
 			    creset <= '1';
 			    loadctimer <= '0';
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if(INTRQ = '1') then
                 next_state <= HDMAcheck_status;
			    else
			        next_state <= HDMAintrq_wait;
			    end if;
			    
   
			---------------------------------------------------------------------------------------------------    
         -------------------------------Ultra DMA Out Transfer Protocol-------------------------------------
         ---------------------------------------------------------------------------------------------------
         
         when UDMAout_initialize =>
             driver <= ATAD;
             atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          loadltimer <= '0';
	          loadmtimer <= '0';
	          loadctimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          creset <= '1';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';

			    intDMACK <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    CRCEN <= '0';                       -- Disable CRC Calculations			    
			    if (DMARQ = '1') then
			        intDIOWSTOP <= '1';             -- Assert STOP
			        intDIORHDMARDYHSTROBE <= '1';   -- Assert HSTROBE
			        stimerv <= "000000010";         -- Load timer Tack
			        loadstimer <= '1';
			        sreset <= '0';
			        next_state <= UDMAout_initialize2;
			    else
			        loadstimer <= '0';
			        sreset <= '1';
			        intDIOWSTOP <= '0';
			        intDIORHDMARDYHSTROBE <= '0';
			        next_state <= UDMAout_initialize;
			    end if;
         
         when UDMAout_initialize_getdata =>
             driver <= ATAD;
             atadirectdd <= '0'; 
             hddata <= '1';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
	          loadltimer <= '0';
	          loadstimer <= '0';
	          loadmtimer <= '0';
	          loadctimer <= '0';
	          lreset <= '1';
	          sreset <= '0';
	          mreset <= '1';
	          creset <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
 			    intDIOWSTOP <= '1';             -- Assert STOP
			    intDIORHDMARDYHSTROBE <= '1';   -- Assert HSTROBE
			    CRCEN <= '0';
			    
			    if (CDSTROBE = '0') then
                CDRDY <= '0';
                next_state <= UDMAout_initialize2;			        
			    else
                CDRDY <= '1';
                next_state <= UDMAout_initialize_getdata;			    
			    end if;
			    
         when UDMAout_initialize2 =>
             driver <= ATAD;
             atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
	          loadltimer <= '0';
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
 			    intDIOWSTOP <= '1';             -- Assert STOP
			    intDIORHDMARDYHSTROBE <= '1';   -- Assert HSTROBE
			    CRCEN <= '0';			    
			    if (stimerf = '1') then             -- Wait until Tack has passed
			        intDMACK <= '1';                -- Assert DMACK
                 stimerv <= "000000010";         -- Load timer Tenv
			        loadstimer <= '1';
			        sreset <= '0';
			        ctimerv <= UDMAtdvs;             -- Load timer Tdvs
			        loadctimer <= '1';
			        creset <= '0'; 
			        next_state <= UDMAout_initialize3;
			    else
			        loadstimer <= '0';
			        sreset <= '0';
                 intDMACK <= '0';
			        next_state <= UDMAout_initialize2;
			    end if; 
			    
			 
			 when UDMAout_initialize3 =>
             driver <= ATAD;
             atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    loadctimer <= '0'; 
			    loadltimer <= '0';
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          creset <= '0';
             CRCEN <= '1';                  -- Enable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1'; 
 			    intDIORHDMARDYHSTROBE <= '1';   -- Assert HSTROBE
			                                        		    
			    if (stimerf = '1') then             -- Wait until Tenv has passed
			        intDIOWSTOP <= '0';             -- Negate STOP
			        
			        if (IORDYDDMARDYDSTROBE = '1') then
			           stimerv <= UDMAtui;         -- Load timer Tui
			           loadstimer <= '0';
			           sreset <= '1';
			           next_state <= UDMAout_first_strobe;    
			        else
			           loadstimer <= '0';
			           sreset <= '0';
			           next_state <= UDMAout_initialize3; 
			        end if;
             else
			        loadstimer <= '0';
			        sreset <= '0';
                 intDIOWSTOP <= '1';
			        next_state <= UDMAout_initialize3;
			    end if;
			    
			 when UDMAout_first_strobe =>
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    loadctimer <= '0'; 
			    loadltimer <= '0';
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          creset <= '0';
             CRCEN <= '1';                   -- Enable CRC
			    sectorcnt := sectorcnt;
			    intDMACK <= '1';
			    intDIOWSTOP <= '0';             -- Negate STOP 
 			    			                                        		    
			    if (stimerf = '1') then             -- Wait until Tui has passed
			       if (ctimerf = '1') then          -- Wait until Tdvs has passed
			          loadctimer <= '0';
			          loadstimer <= '1';            -- Load Tdvh
			          stimerv <= UDMAtdvh;
			          creset <= '1';
			          sreset <= '0';
			          wrdcnt := wrdcnt - 1;
			          intDIORHDMARDYHSTROBE <= '0'; -- Negate HSTROBE
			          next_state <= UDMAout_transfer;   -- Goto transfer state
			       else
			          loadctimer <= '0';
			          loadstimer <= '0';
			          creset <= '0';
			          sreset <= '0';
			          wrdcnt := wrdcnt;
			          intDIORHDMARDYHSTROBE <= '1';   -- Leave Asserted HSTROBE
			          next_state <= UDMAout_first_strobe;   
			       end if;    
			    else
			        loadctimer <= '0';
			        loadstimer <= '0';
			        creset <= '0';
			        sreset <= '0';
			        wrdcnt := wrdcnt;
			        intDIORHDMARDYHSTROBE <= '1';     -- Leave Asserted HSTROBE
			        next_state <= UDMAout_first_strobe;
			    end if;
			    
			 when UDMAout_transfer => 
			    driver <= ATAD;
			    atadirectdd <= '0';
			    daspen <= '0';   -- Don't Sample dasp 
             hddata <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    loadctimer <= '0'; 
	          creset <= '1';
             CRCEN <= '1';                   -- Enable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    intDIOWSTOP <= '0';             -- Negate STOP 
 			    			                                        		    
			    if (stimerf = '1') then             -- Wait until Tdvh has passed
                ata_intddwe <= '0';               -- Stop driving bus
		          if (pause = '1') then                  -- Host pause
		             loadltimer <= '0';                  -- pause state after DD lines are released
	                loadmtimer <= '0';
	                loadstimer <= '0';
	                lreset <= '1';
	                mreset <= '1';
	                sreset <= '0';                        -- Don't reset stimer 
			          next_state <= UDMAout_transfer;
			           
			       elsif (IORDYDDMARDYDSTROBE = '0') then   -- If device wants to pause then goto 
			          loadltimer <= '0';                    -- pause state after DD lines are released
	                loadmtimer <= '0';
	                loadstimer <= '0';
	                lreset <= '1';
	                mreset <= '1';
	                sreset <= '0';                        -- Don't reset stimer 
			          next_state <= UDMAout_devicepause;
			       else
			          loadstimer <= '0';                    -- Reset Stimer           
			          sreset <= '1';
			          loadltimer <= '1';                    -- Start Cycle timer ltimer
			          loadmtimer <= '1';                    -- Start Half 2 Cycle timer mtimer
			          lreset <= '0';
			          mreset <= '0';
			          ltimerv <= ("00000000000" & (UDMAtcyc));
			          mtimerv <= ("00000000000" & (UDMAt2cychalf));    
			          next_state <= UDMAout_transfer2;      -- Otherwise continue the transfer
			       end if;
			    else
                loadstimer <= '0';            
			       sreset <= '0';
			       ata_intddwe <= '1';
			       next_state <= UDMAout_transfer;
			    end if;
			       
			  when UDMAout_transfer2 => 
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '1';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    
			    loadctimer <= '0';
			    loadstimer <= '1';
			    loadmtimer <= '0';
			    loadltimer <= '0'; 
	          creset <= '1';
	          sreset <= '0';
	          mreset <= '0';
	          lreset <= '0';
	          stimerv <= UDMAtdvs;            -- Start Tdvs
             
             CRCEN <= '1';                   -- Enable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    intDIOWSTOP <= '0';
			    
			    if (CDSTROBE = '0') then
                CDRDY <= '0';
                next_state <= UDMAout_transfer3;			        
			    else
                CDRDY <= '1';
                next_state <= UDMAout_transfer2;			    
			    end if;                              
	                                        		    
  
			  when UDMAout_transfer3 => 
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
		             
             CRCEN <= '1';                   -- Enable CRC
			    intDMACK <= '1';
			    intDIOWSTOP <= '0';
			    
     
			    if (stimerf = '1') then
			        if (ltimerf = '1') then
			            if (mtimerf = '1') then
			               if (intDIORHDMARDYHSTROBE = '1') then
			                  intDIORHDMARDYHSTROBE <= '0';
			               else
			                  intDIORHDMARDYHSTROBE <= '1';
			               end if;
			               loadstimer <= '1';
			               sreset <= '0';
			               stimerv <= UDMAtdvh;
			               
			               if (wrdcnt = "0000000") then
			                   if (sectorcnt = "000000000") then
			                       loadctimer <= '1';
			                       creset <= '0';
			                       ctimerv <= UDMAtss;
			                      next_state <= UDMAout_terminate;    
			                   else
			                      loadctimer <= '0';
			                      creset <= '1';
			                      wrdcnt := "11111111";
			                      sectorcnt := sectorcnt - 1;
			                      next_state <= UDMAout_transfer;
			                   end if;
			               else
			                  loadctimer <= '0';
			                  creset <= '1';
			                  wrdcnt := wrdcnt - 1;
			                  sectorcnt := sectorcnt;
			                  next_state <= UDMAout_transfer;
			               end if;
			               
			            else
			               loadctimer <= '0';
			               creset <= '1';
			               intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			               loadstimer <= '0';
			               loadmtimer <= '0';
			               loadltimer <= '0'; 
	                     sreset <= '0';
	                     mreset <= '0';
	                     lreset <= '0';
	                     sectorcnt := sectorcnt;
			               wrdcnt := wrdcnt;
	                     next_state <= UDMAout_transfer3;  
			            end if;
			        else
			           loadctimer <= '0';
			           creset <= '1';
			           intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			           loadstimer <= '0';
			           loadmtimer <= '0';
			           loadltimer <= '0'; 
	                 sreset <= '0';
	                 mreset <= '0';
	                 lreset <= '0';
	                 sectorcnt := sectorcnt;
			           wrdcnt := wrdcnt;
	                 next_state <= UDMAout_transfer3;  
			        end if;    
			        
			    else
			       loadctimer <= '0';
			       creset <= '1';
			       loadstimer <= '0';
			       loadmtimer <= '0';
			       loadltimer <= '0'; 
	             sreset <= '0';
	             mreset <= '0';
	             lreset <= '0';
	             sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt;
	             intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
	             next_state <= UDMAout_transfer3;  
			    end if;
			  
			  when UDMAout_devicepause =>       -- Device pause state
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
	          
             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    intDIOWSTOP <= '0';             -- Negate STOP
			    
			    loadctimer <= '0';
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          loadstimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          sreset <= '0';                  -- Don't reset stimer
	          creset <= '1';
	          
	          if (IORDYDDMARDYDSTROBE = '0') then
	              if (DMARQ = '1') then
	                next_state <= UDMAout_devicepause;
	              else
	                next_state <= UDMAout_terminate3;   -- Jump to Terminate state 3 since DMARQ is negated
	              end if;
	          else
	             next_state <= UDMAout_transfer;
	          end if;     
			  
			  when UDMAout_terminate =>
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
	          loadctimer <= '0';
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          creset <= '0';
	          
             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    intDIOWSTOP <= '0';             -- Negate STOP
			    			    
			    if (stimerf = '1') then
			       sreset <= '1';
			       loadstimer <= '0';
			       ata_intddwe <= '0';
			       next_state <= UDMAout_terminate2;    
			    else
			       ata_intddwe <= '1';
			       sreset <= '0';
			       loadstimer <= '0';
			       next_state <= UDMAout_terminate; 
			    end if;
			  
			  when UDMAout_terminate2 =>
			    driver <= ATAD;
			    atadirectdd <= '0'; 
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          loadstimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          sreset <= '1';

             
             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    			    			    
			    if (ctimerf = '1') then
			       creset <= '1';
			       loadctimer <= '0';
			       intDIOWSTOP <= '1';             -- Assert STOP
			       next_state <= UDMAout_terminate3;    
			    else
			       creset <= '0';
			       loadctimer <= '0';
			       intDIOWSTOP <= '0';             -- Negate STOP
			       next_state <= UDMAout_terminate2; 
			    end if;
			    
			  when UDMAout_terminate3 =>
			    driver <= ATAD;
			    atadirectdd <= '1'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';

             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIOWSTOP <= '1';             -- Assert STOP
			    intDMACK <= '1';
			    
			    if (DMARQ = '0') then
			       intDIORHDMARDYHSTROBE <= '1';
			       atadd <= CRCOUT;
			       creset <= '0';
			       sreset <= '0';
			       loadstimer <= '1';
			       loadctimer <= '1';
			       ctimerv <= UDMAtmli;
			       stimerv <= UDMAtdvs;
			       next_state <= UDMAout_terminate4;    
			    else
			       intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			       atadd <= (others => '0');
			       creset <= '1';
			       sreset <= '1';
			       loadstimer <= '0';
			       loadctimer <= '0'; 
			       next_state <= UDMAout_terminate3; 
			    end if;
			    
			  when UDMAout_terminate4 =>
			    driver <= ATAD;
			    atadirectdd <= '1'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';

             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIOWSTOP <= '1';             -- Assert STOP
			    
			    intDIORHDMARDYHSTROBE <= '1';
			    atadd <= CRCOUT;
			    
			    if (stimerf = '1') then
			       if (ctimerf = '1') then
			          intDMACK <= '0'; 
			          creset <= '0';
			          sreset <= '1';
			          loadstimer <= '0';
			          loadctimer <= '1';
			          ctimerv <= UDMAtack;
			          next_state <= UDMAout_terminatecomplete;
			       else
			          intDMACK <= '1';
			          creset <= '0';
			          sreset <= '0';
			          loadstimer <= '0';
			          loadctimer <= '0';
			          next_state <= UDMAout_terminate4; 
			       end if;
			    else
			       intDMACK <= '1';
			       creset <= '0';
			       sreset <= '0';
			       loadstimer <= '0';
			       loadctimer <= '0'; 
			       next_state <= UDMAout_terminate4; 
			    end if;
			    
			    
			    when UDMAout_terminatecomplete =>
			    driver <= ATAD;
			    atadirectdd <= '1'; 
             hddata <= '0';
             ata_intddwe <= '1';
             daspen <= '0';   -- Don't Sample dasp
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESETD <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    
			    loadstimer <= '0'; 
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
             sreset <= '1';
             
             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIOWSTOP <= '1';             -- Assert STOP
			    intDMACK <= '0';
			    intDIORHDMARDYHSTROBE <= '1';
			    atadd <= CRCOUT;
			    
			    if (ctimerf = '1') then         -- When Tack has passed
			       creset <= '1';
			       loadctimer <= '0';
			       next_state <= HDMAintrq_wait;   -- DMA has finished wait for interupt
			    else
			       creset <= '0';
			       loadctimer <= '0'; 
			       next_state <= UDMAout_terminatecomplete; 
			    end if;
			    
			---------------------------------------------------------------------------------------------------    
         ------------------------------Controller Error Handling States-------------------------------------
         ---------------------------------------------------------------------------------------------------   
			when ERROR_check =>      -- Check Error Register
			    driver <= REG;
			    hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    intrw <= '0';
	          RESETD <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= ERROR_check_wait;
             
         when ERROR_check_wait =>
             driver <= REG;
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "001";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
             if (busy = '1') then
                next_state <= ERROR_check_wait;
             else
                next_state <= ERROR_check2;
             end if;
             
         when ERROR_check2 =>
             driver <= ATAD;
             hddata <= '0';
             ata_intddwe <= '0';
             daspen <= '0';   -- Don't Sample dasp
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
             intrw <= '0';
             RESETD <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
             next_state <= HIhost_idle;
			  
		end case;
		
	end process ATA;
	
	
REGPIOTRANSFER: process(regstate_current, regstate_last, iordyddmardydstrobe, intcs, intda,
                        modet0, modet1, ttimerf, intrw, modet2, flag, modet5, modet3, qtimerf, modet2i, modet4, ptimerf)
	
	begin
		regCS <= "00";
		regDA <= "000";
		regDIORHDMARDYHSTROBE <= '0';
		regDIOWSTOP <= '0';
		regDMACK <= '0';
		
	  case regstate_current is
	      
	    when idle =>
	       preset <= '1';
			 qreset <= '1';
			 treset <= '1';
			 loadptimer <= '0';
			 loadqtimer <= '0';
			 loadttimer <= '0'; 
	       busy <= '0';
	       nextstate_self <= idle;
	       reg_intddwe <= '0';
	        
	    when check_iordy =>
	       busy <= '1';
	       -- Timer Resets
			 preset <= '1';
			 qreset <= '1';
			 treset <= '1';
			 loadptimer <= '0';
			 loadqtimer <= '0';
			 loadttimer <= '0';
			 reg_intddwe <= '0';
	       if(IORDYDDMARDYDSTROBE='1') then
	          nextstate_self <= write_address;
	       else
	          nextstate_self <= check_iordy;
	       end if; 
		             
      	when write_address =>
   	    	 busy <= '1';
   	      regCS <= intcs;
   	      regDA <= intda;
   	      reg_intddwe <= '0';
			 -- Timer Resets
			 preset <= '1';
			 qreset <= '1';
			 loadptimer <= '0';
			 loadqtimer <= '0';
             
          if (regstate_last = check_iordy) then
              ttimerv <= modet1;
              loadttimer <= '1';
              treset <= '0';
              nextstate_self <= write_address;
          elsif (ttimerf = '1') then
			        nextstate_self <= assert_diorw;
			        loadttimer <= '0';
			        treset <= '0';
			 else
			        nextstate_self <= write_address;
			        loadttimer <= '0';
			        treset <= '0';			    
			 end if;

		 when assert_diorw =>
	        busy <= '1';
		     regCS <= intcs;
		     regDA <= intda;
 		     reg_intddwe <= '0';
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
           end if;
           
           if (regstate_last = write_address) then  -- Start T2 timer
              qtimerv <= ("00000000000" & modet2);
              loadqtimer <= '1';
              qreset <= '0';
   	       else
   	          loadqtimer <= '0';
			     qreset <= '0';
   	       end if;
   	       
   	       if (regstate_last = write_address) then  -- Start T0 timer
              ptimerv <= modet0;
              loadptimer <= '1';
              preset <= '0';
   	       else
   	          loadptimer <= '0';
			     preset <= '0';
   	       end if;
   	       
           if (regstate_last = write_address) then  -- Start T1 timer
              ttimerv <= modet1;
              loadttimer <= '1';
              treset <= '0';
           elsif (ttimerf = '1') then
   	          nextstate_self <= check_iordy2;
   	          loadttimer <= '0';
			     treset <= '0';
   	       else
   	          nextstate_self <= assert_diorw;
   	          loadttimer <= '0';
			     treset <= '0';
   	       end if;
           
       when check_iordy2 =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
   	       loadptimer <= '0';
			  preset <= '0';
           loadqtimer <= '0';
           qreset <= '0';
   			  loadttimer <= '0';
			  treset <= '1';
           
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		        reg_intddwe <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
              reg_intddwe <= '1';
           end if;
           
           if(IORDYDDMARDYDSTROBE='1') then
              nextstate_self <= data_setup;
              flag <= flag;
           else
              nextstate_self <= check_iordy2;
              flag <= '1';
           end if; 
           
       when data_setup =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadptimer <= '0';
			  preset <= '0';
           loadqtimer <= '0';
           qreset <= '0';
           
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		        reg_intddwe <= '0';
		        if flag <= '0' then
                 if (regstate_last = check_iordy2) then  -- Start T5 timer
                    ttimerv <= modet5;
                    loadttimer <= '1';
                    treset <= '0';
      			           nextstate_self <= data_setup;
 			           flag <= '0'; 
                 elsif (ttimerf = '1') then
   	                nextstate_self <= checkt2_len;
   	                flag <= '0';
   	                loadttimer <= '0';
			           treset <= '0';
   	             else
   	                loadttimer <= '0';
			           treset <= '0';
			           nextstate_self <= data_setup;
			           flag <= '0';
   	             end if;
              else
                 nextstate_self <= checkt2_len;
                 flag <= '1';
   	             loadttimer <= '0';
			        treset <= '1';
              end if;
		     else
		        reg_intddwe <= '1';
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
              if flag <= '0' then
                if (regstate_last = check_iordy2) then  -- Start T5 timer
                    ttimerv <= modet3;
                    loadttimer <= '1';
                    treset <= '0';
      			           nextstate_self <= data_setup;
 			           flag <= '0'; 
                 elsif (ttimerf = '1') then
   	                nextstate_self <= checkt2_len;
   	                flag <= '0';
   	                loadttimer <= '0';
			           treset <= '0';
   	             else
   	                loadttimer <= '0';
			           treset <= '0';
			           nextstate_self <= data_setup;
			           flag <= '0';
   	             end if;
              else
                 nextstate_self <= checkt2_len;
                 loadttimer <= '0';
			        treset <= '1';
                 flag <= '0';
              end if;
           end if;
           
                 
       when checkt2_len =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
   	       loadptimer <= '0';
			  preset <= '0';
			  loadttimer <= '0';
			  treset <= '1';
           loadqtimer <= '0';

		     
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		        reg_intddwe <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
  		        reg_intddwe <= '1';
           end if;
           
            if (qtimerf = '1') then
                qreset <= '0';
                if(intrw = '0') then
                   nextstate_self <= negate_dior;
                else
                   nextstate_self <= negate_diow;
                end if;
            else
               nextstate_self <= checkt2_len;
               qreset <= '0';
            end if;
 
                      
       when negate_dior =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadptimer <= '0';
			  preset <= '0';
			  loadttimer <= '0';
			  treset <= '1';
     
     	     regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '1';
		     
		     nextstate_self <= release_bus;
		     
           qtimerv <= ("00000000000" & modet2i);
           loadqtimer <= '1';
           qreset <= '0';

		     
       when negate_diow =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadptimer <= '0';
			  preset <= '0';
           
		     regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '1';

		     if (regstate_last = checkt2_len) then  -- Start T2i timer
              qtimerv <= ("00000000000" & modet2i);
              loadqtimer <= '1';
              qreset <= '0';
   	       else
   	          loadqtimer <= '0';
			     qreset <= '0';
   	       end if;
   	       
		     if (regstate_last = checkt2_len) then  -- Start T4 timer
              ttimerv <= modet4;
              loadttimer <= '1';
              treset <= '0';
 	           nextstate_self <= negate_diow;
           elsif (ttimerf = '1') then
   	          nextstate_self <= release_bus;
   	          loadttimer <= '0';
			     treset <= '1';
   	       else
   	          nextstate_self <= negate_diow;
   	          loadttimer <= '0';
			     treset <= '0';
   	       end if;
    
       when release_bus =>
	        busy <= '1';
	        reg_intddwe <= '1';
	        loadptimer <= '0';
			  preset <= '0';
			  loadttimer <= '0';
			  treset <= '1';
           loadqtimer <= '0';
           qreset <= '0';
           regCS <= intCS;
           regDA <= intDA;
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '0';

     	    nextstate_self <= checkt2i_len;

           
       when checkt2i_len =>
	        busy <= '1';

		     regCS <= "00";

	        loadptimer <= '0';
			  preset <= '0';
			  loadttimer <= '0';
			  treset <= '1';
           
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '0';
     		    regCS <= "00";
			  regDA <= "000";
			  
			  if (qtimerf = '1') then
			    regCS <= intcs;
			    regDA <= intda;
			    loadqtimer <= '0';
             qreset <= '0';
			    nextstate_self <= checkt0_len;
			  else
			    regCS <= intcs;
		       regDA <= intda;
		       loadqtimer <= '0';
             qreset <= '0';
			    nextstate_self <= checkt2i_len;
			  end if;

       when checkt0_len =>			    
	        busy <= '1';
	        
	        loadptimer <= '0';
			  loadttimer <= '0';
			  treset <= '1';
           loadqtimer <= '0';
           qreset <= '1';
           
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '0';
     		    regCS <= "00";
			  regDA <= "000";
			  
			  if (ptimerf = '1') then
			    regCS <= "00";
			    regDA <= "000";
			    preset <= '0';
			    nextstate_self <= return_function;
			  else
			    regCS <= intcs;
		       regDA <= intda;
		       preset <= '0';
			    nextstate_self <= checkt0_len;

			   end if;
			   
       when return_function =>
           nextstate_self <= idle;
           busy <= '0';
   	       loadptimer <= '0';
			  preset <= '1';
			  loadttimer <= '0';
			  treset <= '1';
           loadqtimer <= '0';
           qreset <= '1';
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     reg_intddwe <= '0';
     		    regCS <= "00";
			  regDA <= "000";
     end case;
 	
	end process REGPIOTRANSFER;
		
		
end architecture RTL;
