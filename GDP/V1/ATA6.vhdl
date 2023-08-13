

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ATA_controller is
 	port (clock, resetc: in std_logic; 
		   DASP, DMARQ, INTRQ, IORDYDDMARDYDSTROBE, PDIAGCBLID : in std_logic;
	      DMACK, DIORHDMARDYHSTROBE, DIOWSTOP, RESET: out std_logic;
         DD: inout std_logic_vector(15 downto 0);
         CS: out std_logic_vector(1 downto 0);
         DA: out std_logic_vector(2 downto 0);
         -- Controller Signals
         cdrdy: out std_logic;
         error: out std_logic;
         cdstrobe: in std_logic;
         pause : in std_logic;
         databus : inout std_logic_vector(15 downto 0);
         devsel, fortyeightbit, rw: in std_logic);

end entity ATA_controller;

architecture RTL of ATA_controller is
	type state is (-- Reset States
	               HHRassert_reset, HHRnegate_wait, HHRHSRcheck_status, HSRset_SRST, HSRclear_wait, HHRHSRregaccesswait,
	               HHRHSRcheck_status2, HSRset_SRST_wait, HSRclear_wait_wait,
	               -- Host Idle States
	               HIhost_idle, HIcheck_status, HIcheck_status_wait, HIcheck_status2, HIdevice_select, HIdevice_select2,
	               HIwrite_features, HIwrite_features_wait,HIwrite_lba_low, HIwrite_lba_low_wait, HIwrite_lba_mid, 
	               HIwrite_lba_mid_wait, HIwrite_lba_high, HIwrite_lba_high_wait, HIwrite_sector_cnt, HIwrite_sector_cnt_wait,
	               HIwrite_command, HIwrite_command_wait, HIbranch_select,  
	               -- PIO Out States
	               HPIOOtransfer_data, HPIOOintrq_wait, HPIOOcheck_status_wait, HPIOOcheck_status2, HPIOOtransfer_data2,
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
	               -- UDMA Data In Command States 
	               UDMAin_initialize ,UDMAin_initialize2, UDMAin_initialize3, UDMAinfirst_strobe, UDMAin_transfer,
	               UDMAin_hostpause, UDMAin_terminate, UDMAin_terminate2, UDMAin_terminate3, UDMAin_terminate4, 
                  -- UDMA Data Out Command States
	               UDMAout_initialize, UDMAout_initialize2, UDMAout_initialize3, UDMAout_first_strobe, UDMAout_transfer,
	               UDMAout_transfer2, UDMAout_transfer3, UDMAout_devicepause, UDMAout_terminate,
	               UDMAout_terminate2, UDMAout_terminate3, UDMAout_terminate4, UDMAout_terminatecomplete,   -- 82 states
	               -- Controller Error Handling States
	               Error_check, Error_check_wait, Error_check2);
	               
	signal current_state, next_state, previous_state : state;
	type regtran is (idle, check_iordy, write_address, assert_diorw, check_iordy2,
	                 data_setup, checkt2_len, negate_dior, negate_diow, release_bus,
	                 checkt2i_len, checkt0_len, return_function);
	signal regstate_current, regstate_next, nextstate_self : regtran;

	type pio is (mode0, mode1, mode2, mode3, mode4);
	type MDMA is (mode0, mode1, mode2);
	type UDMA is (mode0, mode1, mode2, mode3);
		
	
	signal REGMode : pio; -- External
	signal PIOMode : pio; -- External
	signal MDMAMode : MDMA;   -- External
	signal UDMAMode : UDMA;   -- External
	signal MUDMA : std_logic; -- External Select MDMA/UDMA
	signal REGmodet0, REGmodet1, REGmodet2, REGmodet2i, REGmodet3, REGmodet4, REGmodet5, REGmodet9 : std_logic_vector(8 downto 0);
	signal PIOmodet0, PIOmodet1, PIOmodet2, PIOmodet2i, PIOmodet3, PIOmodet4, PIOmodet5, PIOmodet9 : std_logic_vector(8 downto 0);
	signal modet0, modet1, modet2, modet2i, modet3, modet4, modet5, modet9 : std_logic_vector(8 downto 0);
	signal MDMAt0, MDMAtd, MDMAth, MDMAtj, MDMAtkr, MDMAtkw, MDMAtm, MDMAtn : std_logic_vector(8 downto 0);
	signal UDMAtenvmin, UDMAtzah, UDMAtdvs, UDMAtack, UDMAtcvh, UDMAtui, UDMAtdvh, UDMAtcyc, UDMAt2cychalf : std_logic_vector(8 downto 0); 
	signal UDMAtss, UDMAtmli : std_logic_vector(8 downto 0);
	
	signal regpioselect : std_logic;
	signal flagdb : std_logic;
	
	signal busy : std_logic;
	signal lba_level : std_logic_vector(1 downto 0);
	
	type statedriver is (ATAD, REG);
	signal driver : statedriver;
	signal regDD: std_logic_vector(15 downto 0);
   signal regCS: std_logic_vector(1 downto 0);
   signal regDA: std_logic_vector(2 downto 0);
   signal regDMACK, intDMACK, intdiorhdmardyhstrobe, regdiorhdmardyhstrobe, intDIOWSTOP,regDIOWSTOP: std_logic;
	signal intCDRDY: std_logic;
	
	signal ctimer, ctimerv : std_logic_vector(8 downto 0);
	signal ltimer, ltimerv : std_logic_vector(19 downto 0);
	signal stimer, stimerv : std_logic_vector(8 downto 0);
	signal mtimer, mtimerv : std_logic_vector(19 downto 0);
	signal ctimerf, loadctimer, creset : std_logic;
	signal ltimerf, loadstimer, lreset : std_logic;
	signal stimerf, loadltimer, sreset : std_logic;
	signal mtimerf, loadmtimer, mreset : std_logic;
		
	signal register_read: std_logic_vector(7 downto 0);
	signal regrst, regbegin: std_logic; 
	signal intcs: std_logic_vector(1 downto 0);
	signal intda: std_logic_vector(2 downto 0);
	signal intrw: std_logic; -- '0' for read, '1' for write
	signal intdd: std_logic_vector(15 downto 0);
	signal flag, HOB : std_logic;
	
	-- Output Data Temporary Registers
	signal datatemp1, datatemp2, datatemp3, datatemp4, datatemp5 :std_logic_vector(15 downto 0);
	signal datatemp1v, datatemp2v, datatemp3v, datatemp4v, datatemp5v :std_logic;
	signal tempenable, temprst : std_logic;
		
	-- CRC Signals
	signal CRCOUT: std_logic_vector(15 downto 0);
	signal CRCEN, crcDIORHDMARDYHSTROBE : std_logic;
	signal CRCIN : std_logic_vector(15 downto 0);
   signal f : std_logic_vector(15 downto 0);
	
	-- Command Registers
	signal selectreg : std_logic_vector(3 downto 0);
	signal commandreg, devicereg, devicecont, features, LBAHIGH0, LBAHIGH1, LBAMID0, LBAMID1, LBALOW0, LBALOW1: std_logic_vector(7 downto 0);
   signal sectorcount0, sectorcount1 : std_logic_vector(7 downto 0);
	

begin
seq: process(clock, resetc) is

	begin
	    
		if (resetc =  '0' )  then
			current_state <= HHRassert_reset;		 -- When reset always go to Hardware Reset level
			previous_state <= HHRassert_reset;

		elsif rising_edge(clock) then
		   previous_state <= current_state;
			current_state <= next_state;
			regstate_current <= regstate_next;
     end if;
			
	end process seq;
	
datatempselect: process(IORDYDDMARDYDSTROBE, DD, tempenable) is     -- Allowing 5 word data buffer if UDMA is paused

   begin
       if (tempenable = '1') then
           datatemp1v <= datatemp1v;
           datatemp2v <= datatemp2v;
           datatemp3v <= datatemp3v;
           
       elsif (temprst = '1') then
              datatemp1v <= '0';
              datatemp2v <= '0';
              datatemp3v <= '0';
       else      
          if rising_edge(IORDYDDMARDYDSTROBE) then  -- For positive going edges
             if (datatemp1v = '0') then
                 datatemp1v <= '1';
                 datatemp2v <= datatemp2v;
                 datatemp3v <= datatemp3v;
             elsif (datatemp2v = '0') then
                 datatemp1v <= datatemp1v;
                 datatemp2v <= '1';
                 datatemp3v <= datatemp3v;
             elsif (datatemp3v = '0') then
                 datatemp1v <= datatemp1v;
                 datatemp2v <= datatemp2v;
                 datatemp3v <= '1';
             else
                 datatemp1v <= datatemp1v;
                 datatemp2v <= datatemp2v;
                 datatemp3v <= datatemp3v;
             end if;
          
         elsif falling_edge(IORDYDDMARDYDSTROBE) then   -- For negative going edges
             if (datatemp1v = '0') then
                 datatemp1v <= '1';
                 datatemp2v <= datatemp2v;
                 datatemp3v <= datatemp3v;
             elsif (datatemp2v = '0') then
                 datatemp1v <= datatemp1v;
                 datatemp2v <= '1';
                 datatemp3v <= datatemp3v;
             elsif (datatemp3v = '0') then
                 datatemp1v <= datatemp1v;
                 datatemp2v <= datatemp2v;
                 datatemp3v <= '1';
             else
                 datatemp1v <= datatemp1v;
                 datatemp2v <= datatemp2v;
                 datatemp3v <= datatemp3v;
             end if;
         end if;
     end if;
   end process datatempselect; 

datatemp: process(datatemp1v,datatemp2v,datatemp3v) is      -- 3 Word data buffer if transfer is paused
   
   begin
       
       if rising_edge(datatemp1v) then
          datatemp1 <= DD;
          datatemp2 <= datatemp2;
          datatemp3 <= datatemp3;
       elsif rising_edge(datatemp2v) then
          datatemp1 <= datatemp1;
          datatemp2 <= DD;
          datatemp3 <= datatemp3;
       elsif rising_edge(datatemp3v) then
          datatemp1 <= datatemp1;
          datatemp2 <= datatemp2;
          datatemp3 <= DD;
       else
          datatemp1 <= datatemp1;
          datatemp2 <= datatemp2;
          datatemp3 <= datatemp3;
       end if;   
   end process datatemp;
        
commandwrite: process(cdstrobe, selectreg) is

    begin
        
        if falling_edge(cdstrobe) then
            
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
        else
           commandreg <= commandreg;
           devicecont <= devicecont;
           devicereg <= devicereg;
           features <= features;
           LBAHIGH0 <= LBAHIGH0;
           LBAHIGH1 <= LBAHIGH1;
           LBAMID0 <= LBAMID0;
           LBAMID1 <= LBAMID1;
           LBALOW0 <= LBALOW0;
           LBALOW1 <= LBALOW1;
           sectorcount0 <= sectorcount0;
           sectorcount1 <= sectorcount1;
       end if;
    end process commandwrite;
    
CRC: process(crcDIORHDMARDYHSTROBE, IORDYDDMARDYDSTROBE, DD, f, CRCOUT, CRCIN) is -- CRC Generation for UDMA
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
       
regpio: process(regpioselect) is

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
   	
timers: process(clock) is

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
                   
       elsif (rising_edge(clock)) then
           -- Timer for Signals timings based on 100Mhz Clock
      	    if (lreset = '1') then
               linttimer := "11111111111111111111";
      	    elsif (linttimer = "00000000000000000000") then
			      linttimer := linttimer;
			      ltimerf <= '1';
			  elsif (loadltimer = '1') then
			      linttimer := unsigned(ltimerv);
			  elsif (linttimer = "11111111111111111111") then
			      linttimer := "11111111111111111111";
			      ltimerf <= '0';
	        else
			      linttimer := linttimer - 1;
			      ltimerf <= '0';
			  end if;
         			 
		     if (sreset = '1') then
               sinttimer := "111111111";
		     elsif (sinttimer = "00000000") then
		         sinttimer := sinttimer;
		         stimerf <= '1';
		     elsif (loadstimer = '1') then
    	          sinttimer := unsigned(stimerv);
			  elsif (sinttimer = "111111111") then
			      sinttimer := "111111111";
			      stimerf <= '0';
		     else
		         sinttimer := sinttimer - 1;
		         stimerf <= '0';
		     end if;
		     
		     if (creset = '1') then
               cinttimer := "111111111";
		     elsif (cinttimer = "0000000000") then
		         cinttimer := cinttimer;
		         ctimerf <= '1';
		     elsif (loadctimer = '1') then
			      cinttimer := unsigned(ctimerv);
			  elsif (cinttimer = "11111111111") then
			      cinttimer := "111111111";
			      ctimerf <= '0';
		     else
		         cinttimer := cinttimer - 1;
		         ctimerf <= '0';
		     end if;
		     
		     if (mreset = '1') then
               minttimer := "11111111111111111111";
		     elsif (minttimer = "000000000000000000") then
		         minttimer := minttimer;
		         mtimerf <= '1';
		     elsif (loadmtimer = '1') then
			      minttimer := unsigned(mtimerv);
			  elsif (minttimer = "11111111111111111111") then
			      minttimer := "11111111111111111111";
			      mtimerf <= '0';
		     else
		         minttimer := minttimer - 1;
		         mtimerf <= '0';
		     end if;
		 end if;
			
		ltimer <= std_logic_vector(linttimer);
		stimer <= std_logic_vector(sinttimer);
      ctimer <= std_logic_vector(cinttimer);
      mtimer <= std_logic_vector(minttimer);
      
   end process timers;
   
DRIVERCONTROL: process(driver) is          -- Control of which state machine controls the output lines
   begin
      case driver is
       
          when ATAD =>
              if (intrw = '0') then
                 DD <= intDD;    
              else
                 intDD <= DD;
              end if;
              CS <= intcs;
			     DA <= intda;
			     DIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			     crcDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE; 
			     DIOWSTOP <= intDIOWSTOP; 
		        DMACK <= intDMACK; 
              
          when REG =>
              if (intrw = '0') then
                 DD <= regDD;
              else
                 regDD <= DD; 
		        end if;
		        CS <= regCS; 
		        DA <= regDA; 
		        DIORHDMARDYHSTROBE <= regDIORHDMARDYHSTROBE;
		        crcDIORHDMARDYHSTROBE <= regDIORHDMARDYHSTROBE; 
		        DIOWSTOP <= regDIOWSTOP; 
		        DMACK <= regDMACK; 
    
      end case;
   end process DRIVERCONTROL;

DATABUSFLOW: process (CDSTROBE, intCDRDY) is
   begin
       
       if (rw = '0') then
          if falling_edge(CDSTROBE) then         -- If receiving end ready 
             databus <= intdd;
          else
             databus <= databus;
          end if;    
       else
          if falling_edge(CDSTROBE) then         -- If receiving end ready 
             intdd <= databus;
          else
             intdd <= intdd;
          end if;    
       end if;
      
   end process DATABUSFLOW;
       	

   
MDMAMODES: process(MDMAMode) is
   begin
       case(MDMAMode) is
           
           when mode0 =>
           when mode1 =>
           when mode2 =>
       end case;
   end process MDMAMODES; 
   
UDMAMODES: process(UDMAMode) is
   begin
       case(UDMAMode) is
           
           when mode0 =>
           when mode1 =>
           when mode2 =>
           when mode3 =>
       end case;
   end process UDMAMODES;    
   
ATA: process(current_state) is
	variable wrdcnt : unsigned(7 downto 0);
	variable sectorcnt : unsigned(16 downto 0);
	begin
		   
		RESET <= '1';

		case current_state is
		    
         ---------------------------------------------------------------------------------------------------    
         --------------------------------Hardware/Software Protocol-----------------------------------------
         ---------------------------------------------------------------------------------------------------
			when HHRassert_reset =>			-- Hardware Reset States
			    driver <= ATAD;
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
			    RESET <= '1';
			    regrst <= '1';
			    regbegin <= '0';
			    -- Timer Resets
			    creset <= '1';
			    sreset <= '1';
			    mreset <= '1';
			    loadctimer <= '0';
			    loadstimer <= '0';
			    loadmtimer <= '0';
             
             if (ltimer = "11111111111111111111") then
                ltimerv <= "00000000100111000100";
                loadltimer <= '1';
                lreset <= '0';
             elsif (ltimerf = '1') then     -- Wait 25 Microseconds
			        next_state <= HHRnegate_wait;
			        loadltimer <= '0';
			        lreset <= '1';
			    else
			        next_state <= HHRassert_reset;
			        loadltimer <= '0';
			        lreset <= '0';
			    end if;

 
			when HHRnegate_wait =>              -- Wait 2 Milliseconds
			    driver <= ATAD;
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
             RESET <= '0';
     			    regrst <= '1';
			    regbegin <= '0';
			    -- Timer Resets
			    creset <= '1';
             sreset <= '1';
             mreset <= '1';
             loadctimer <= '0';
             loadstimer <= '0';
             loadmtimer <= '0';
             
             if (ltimer = "11111111111111111111") then
                 ltimerv <= "00110000110101000000";
                 loadltimer <= '1';
                 lreset <= '0';
             elsif (ltimerf = '1') then
			        next_state <= HHRHSRcheck_status;
			        loadltimer <= '0';
			        lreset <= '1';
			    else
			        next_state <= HHRnegate_wait;
			        loadltimer <= '0';
			        lreset <= '0';
			    end if;
			    
			when HHRHSRcheck_status =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';

             next_state <= HHRHSRregaccesswait;
         
     			when HHRHSRregaccesswait =>
     			    driver <= REG;
     			    intDMACK <= '0';
  			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';

	          if (busy = '1') then
                next_state <= HHRHSRregaccesswait;
             else
                next_state <= HHRHSRcheck_status2;
             end if;
             
         when HHRHSRcheck_status2 =>
             driver <= ATAD;
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '1';
             if (intdd = "XXXXXXXX1XXXXXXX") then
                 next_state <= HHRHSRcheck_status;
             else
                 next_state <= HIhost_idle;
             end if;
             
                        
			when HSRset_SRST =>	   -- Software Reset States
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    intdd <= "ZZZZZZZZ00000100";
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= HSRset_SRST_wait;
			    
			when HSRset_SRST_wait =>
			    driver <= REG;
			    intDMACK <= '0';
             intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    intdd <= "ZZZZZZZZ00000100";
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    
			    if (mtimer = "11111111111111111111") then
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
			        mreset <= '1';
			    else
			        next_state <= HSRset_SRST_wait;
			        loadmtimer <= '0';
			        mreset <= '0';
			    end if;
			    
             
         when HSRclear_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    intdd <= "ZZZZZZZZ00000000";
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= HSRclear_wait_wait;
			    
			when HSRclear_wait_wait =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "10";
			    intda <= "110";
			    intrw <= '1';
			    intdd <= "ZZZZZZZZ00000000";
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    
			    if (mtimer = "11111111111111111111") then
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
			        mreset <= '1';
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
             intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    if (selectreg = "1111") then         -- If the register select lines = "1111"
			        next_state <= HIcheck_status;    -- then start the writing to device process
			    else
			        next_state <= HIhost_idle;
			    end if;
			    
			when HIcheck_status =>      -- Check device state
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= HIcheck_status_wait;
             
         when HIcheck_status_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
             if (busy = '1') then
                next_state <= HIcheck_status_wait;
             else
                next_state <= HIcheck_status2;
             end if;
             
         when HIcheck_status2 =>
             driver <= ATAD;
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
             if (intdd = "XXXXXXXX1XXXXXXX") then    -- Check BSY bit
                                
                if (intdd = "XXXXXXXXXXXX1XXX") then -- Check DRQ bit
                    next_state <= HIcheck_status;
                else                 
                    next_state <= HIdevice_select;
                end if;
                
             else
             
                if (intdd = "XXXXXXXXXXXX1XXX") then -- Check DRQ bit
                    next_state <= HIcheck_status;
                else                 
                    next_state <= HIdevice_select;
                end if;
                
             end if;

      			-- write device parameters   
             
			when HIdevice_select =>      -- Change selected device & write device reg
             driver <= REG;
             intDMACK <= '0';
			    intcs <= "01";
			    intda <= "110";
			    intrw <= '1';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    next_state <= HIdevice_select2;
			    intdd <= ("00000000" & (devicereg));
			    
			when HIdevice_select2 =>      -- Change selected device & write device reg (II)
             driver <= REG;
             intDMACK <= '0';
			    intcs <= "01";
			    intda <= "110";
			    intrw <= '1';
	          RESET <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    if (busy = '1') then
			       regrst <= '0';
                next_state <= HIdevice_select2;
                intdd <= ("00000000" & (devicereg));
             else
 	             regrst <= '1';
                next_state <= HIcheck_status;
                intdd <= ("00000000" & (devicereg));
             end if;
             
			
			when HIwrite_features =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    intdd <= ("00000000" & (features));
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    HOB <= '0';
             next_state <= HIwrite_features_wait;
			
			when HIwrite_features_wait =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    intdd <= ("00000000" & (features));
			    intrw <= '0';
	          RESET <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    HOB <= '0';
			    if (busy = '1') then
			       regrst <= '0'; 
                next_state <= HIwrite_features_wait;
             else
                if (fortyeightbit = '1') then
                   HOB <= '1';                   -- Write HOB of registers first
                else
                   HOB <= '0';
                end if;
 	             regrst <= '1';
                next_state <= HIwrite_LBA_low;
             end if;

			when HIwrite_LBA_low =>
			     driver <= REG;
			     intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBALOW0));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_low_wait;
			     else
			     -- LBA HB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBALOW1));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_low_wait;
			     end if;
			     
			     LBA_level <= "00";
			     HOB <= HOB;
			
			when HIwrite_LBA_low_wait =>
              driver <= REG;
              intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB Low
              intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBALOW0));
	           RESET <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB Low
			     intcs <= "01";
			     intda <= "011";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBALOW1));
	           RESET <= '0';
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
              
              HOB <= HOB;
			          
			when HIwrite_LBA_mid =>
			     driver <= REG;
			     intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB Mid    
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAMID0));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_mid_wait;    

			     else
			     -- LBA HB Mid
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAMID1));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_mid_wait; 
			     end if;
			     
			     HOB <= HOB;
						
			 when HIwrite_LBA_mid_wait =>
              driver <= REG;
              intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB Mid
              intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAMID0));
	           RESET <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB Mid
			     intcs <= "01";
			     intda <= "100";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAMID1));
	           RESET <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     end if;
			    
			     HOB <= HOB;
		     
			     if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_LBA_mid_wait;
              else
 	             regrst <= '1';             
                next_state <= HIwrite_LBA_high;
              end if; 
                  
			when HIwrite_LBA_high =>
			     driver <= REG;
			     intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB High    
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAHIGH0));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
              next_state <= HIwrite_LBA_high_wait;    

			     else
			     -- LBA HB High
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAHIGH1));
	           RESET <= '0';
	           regrst <= '0';
			     regbegin <= '1';
			     regpioselect <= '0';
			     
              next_state <= HIwrite_LBA_high_wait; 
			     end if;
			     HOB <= HOB;
						
			 when HIwrite_LBA_high_wait =>
              driver <= REG;
              intDMACK <= '0';
			     if (HOB = '0') then
			     -- LBA LB High
              intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAHIGH0));
	           RESET <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     else
			     -- LBA HB High
			     intcs <= "01";
			     intda <= "101";
			     intrw <= '1';
			     intdd <= ("00000000" & (LBAHIGH1));
	           RESET <= '0';
			     regbegin <= '0';
			     regpioselect <= '0';
			     end if;
			     
			     if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_LBA_high_wait;
              else
 	             regrst <= '1';
 	             
 	             if (fortyeightbit = '1') then         -- If using 48bit addressing then loop around
 	                if (HOB = '1') then                -- and write the LOB of addresses
 	                   HOB <= '0';
 	                   next_state <= HIwrite_LBA_low;
 	                else
 	                   HOB <= '1';
 	                   next_state <= HIwrite_sector_cnt;	                
 	                end if;   
 	             else
 	                   HOB <= '0';
 	                   next_state <= HIwrite_sector_cnt;
 	             end if;
 	   
              end if;
	    
			
			when HIwrite_sector_cnt =>
			    driver <= REG;
			    intDMACK <= '0';
			    if (HOB = '0') then
			       -- Sector Count
			       intcs <= "01";
			       intda <= "010";
			       intrw <= '1';
	             RESET <= '0';
	             regrst <= '0';
			       regbegin <= '1';
			       regpioselect <= '0';
			       intdd <= ("00000000" & (sectorcount0)); -- Where data coming from
			       HOB <= '0';
                next_state <= HIwrite_sector_cnt_wait;
			    else
			        -- Sector Count
			       intcs <= "01";
			       intda <= "010";
			       intrw <= '1';
	             RESET <= '0';
	             regrst <= '0';
			       regbegin <= '1';
			       regpioselect <= '0';
			       intdd <= ("00000000" & (sectorcount1)); -- Where data coming from
			       HOB <= '0';
                next_state <= HIwrite_sector_cnt_wait;
			   end if;
			   
			     HOB <= HOB;
			    
                
			     
			when HIwrite_sector_cnt_wait =>
			    driver <= REG;
             intDMACK <= '0';
             if (HOB = '0') then
                -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESET <= '0';
                regrst <= '0';
                regbegin <= '1';
                regpioselect <= '0';
                intdd <= ("00000000" & (sectorcount0)); -- Where data coming from
                HOB <= '0';
             else
                 -- Sector Count
                intcs <= "01";
                intda <= "010";
                intrw <= '1';
                RESET <= '0';
                regrst <= '0';
                regbegin <= '1';
                regpioselect <= '0';
                intdd <= ("00000000" & (sectorcount1)); -- Where data coming from
                HOB <= '0';
            end if;
            
            if (busy = '1') then
	             regrst <= '0';			   
                next_state <= HIwrite_sector_cnt_wait;
            else
 	             regrst <= '1';
 	             
 	           if (fortyeightbit = '1') then         -- If using 48bit addressing then loop around
 	             if (HOB = '1') then                 -- and write the LOB of addresses
 	                 HOB <= '0';
 	                 next_state <= HIwrite_sector_cnt;
 	             else
 	                 HOB <= '0';
 	                 next_state <= HIwrite_command;	                
 	             end if;
 	             
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
 	                 HOB <= '0';
 	                 next_state <= HIwrite_command;
 	           end if;
 	         end if;
 	         -- Sort out internal counters
 	         
			    
			when HIwrite_command =>
			    driver <= REG;
			    intDMACK <= '0';
			     -- Command Register
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '1';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    intdd <= ("00000000" & (commandreg)); -- Where data coming from
			    regpioselect <= '0';
			    HOB <= '0';
			    sectorcnt := sectorcnt;
			    next_state <= HIwrite_command_wait;
			     
			when HIwrite_command_wait =>
			    driver <= REG;	
			    intDMACK <= '0';		    
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '1';
	          RESET <= '0';
			    regbegin <= '0';
			    intdd <= ("00000000" & (commandreg)); -- Where data coming from
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
			    driver <= REG;	
			    intDMACK <= '0';		    
			    -- Pick correct states to go into
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '1';
	          RESET <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    HOB <= '0';
			    sectorcnt := sectorcnt;
			    
			    if (stimerf = '1') then
			       sreset <= '1';
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
 	             sreset <= '1';
			       loadstimer <= '0';
			       next_state <= HIbranch_select;
             end if; 
			
			---------------------------------------------------------------------------------------------------    
         -------------------------------------Non Data Protocol---------------------------------------------
         ---------------------------------------------------------------------------------------------------
			    
			when HNDintrq_wait =>			-- Non Data Command States
			    driver <= ATAD;
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HNDcheck_status_wait;
			    
			when HNDcheck_status_wait =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd = "XXXXXXXX1XXXXXXX") then
                 next_state <= HNDcheck_status2;
             elsif (intdd = "XXXXXXXXXXXXXXX1") then
                 next_state <= Error_check;
             else                 
                 next_state <= HIhost_idle; 
             end if;
             
         ---------------------------------------------------------------------------------------------------    
         -----------------------------------PIO Data In Protocol--------------------------------------------
         ---------------------------------------------------------------------------------------------------    
			    
			when HPIOIintrq_wait =>			-- PIO Data-in States
			    driver <= ATAD;
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HPIOIcheck_status_wait;
             
         when HPIOIcheck_status_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
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
             intDMACK <= '0';
             intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd = "XXXXXXXX1XXXXXXX") then
                 next_state <= HPIOIcheck_status;
             elsif (intdd = "XXXXXXXXXXXX1XXX") then
                 next_state <= HPIOItransfer_data;
             else                 
                 next_state <= ERROR_check; -- Check Error!
             end if;
             
			when HPIOItransfer_data =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
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
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             next_state <= HPIOOcheck_status_wait;
             
         when HPIOOcheck_status_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
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
             intDMACK <= '0';
             intcs <= "00";
             intda <= "000";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
             if (intdd = "XXXXXXXX1XXXXXXX") then
                 next_state <= HPIOOcheck_status;
             elsif (intdd = "XXXXXXXXXXXX1XXX") then
                 next_state <= HPIOOtransfer_data;
             elsif (intdd = "XXXXXXXXXXXXXXX1") then
                 next_state <= ERROR_check;
             else                 
                 next_state <= HIhost_idle; 
             end if;
             
			when HPIOOtransfer_data =>
			    driver <= REG;
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
	          regrst <= '0';
	          
	          if (cdstrobe = '0') then
	              cdrdy <= '0';
	              intcdrdy <= '0';
			        regbegin <= '1';
			        regpioselect <= '1';
			        sectorcnt := sectorcnt;
			        if (previous_state = HPIOOcheck_status2) then
			           wrdcnt := "11111111";
			        else
			           wrdcnt := wrdcnt;
			        end if;
			        next_state <= HPIOOtransfer_data2;
			    else
	             cdrdy <= '1';
			       regbegin <= '1';
			       regpioselect <= '1';
			       sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt;
			       next_state <= HPIOOtransfer_data;
			    end if;
         
         when HPIOOtransfer_data2 =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '0';
			    regpioselect <= '1';
             if (busy = '1') then
                cdrdy <= '0';
                intcdrdy <= '0';
                next_state <= HPIOOtransfer_data2;
                regrst <= '0'; 
             else
                 regrst <= '1';
                 cdrdy <= '0';
                 intcdrdy <= '0'; 
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
                               
             end if; -- Where to get data to be written?
                     
         when HPIOOintrq_wait =>
             driver <= ATAD;
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
			    
			    if (cdstrobe = '1') then
	             cdrdy <= '0';
	             intcdrdy <= '0';
                if(INTRQ = '1') then
			           next_state <= HPIOIcheck_status;
			       else
			           next_state <= HPIOIintrq_wait;
			       end if;
			    else
			       next_state <= HPIOOintrq_wait;
			    end if;
             
			---------------------------------------------------------------------------------------------------    
         -----------------------------Execute Device Diagnostic Protocol------------------------------------
         ---------------------------------------------------------------------------------------------------
         			    
			when HEDwait_state =>			-- Execute Device Diagnostic States
			    driver <= ATAD;
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             next_state <= HEDcheck_status_wait;
             
         when HEDcheck_status_wait =>
             driver <= REG;
             intDMACK <= '0';
			    intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
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
			    intDMACK <= '0';
			    intcs <= "00";
			    intda <= "000";
			    intrw <= 'Z';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if (intdd = "XXXXXXXX1XXXXXXX") then
                 next_state <= HEDcheck_status;
             elsif (intdd = "XXXXXXXXXXXXXXX1") then
                 next_state <= ERROR_check;
             else
                 next_state <= HIhost_idle; -- FOR THE MOMENT GO TO HOST IDLE, ADD CODE TO CHECK RESULT
             end if; 
             
         ---------------------------------------------------------------------------------------------------    
         -----------------------------Multi-Word DMA Transfer Protocol--------------------------------------
         ---------------------------------------------------------------------------------------------------
             
         when HDMAcheck_status =>		-- DMA Command Protocol States
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "111";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := "00000000";
             next_state <= HDMAcheck_status_wait;
             
         when HDMAcheck_status_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
             intda <= "111";
             intrw <= '0';
             RESET <= '0';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := sectorcnt;
			    wrdcnt := "00000000";
             if (busy = '1') then
                regrst <= '0';  
                next_state <= HDMAcheck_status_wait;
             else
                regrst <= '1'; 
                next_state <= HDMAcheck_status2;
             end if;
             
         when HDMAcheck_status2 =>
             driver <= ATAD;
             intDMACK <= '0';
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := "00000000";
			    
			    if (sectorcnt = "00000000000000000") then -- Then DMA burst has completed, Check BSY, DRQ & ERR
			       if (intdd = "XXXXXXXX1XXXXXXX") then   -- If bsy then wait
			          next_state <= HDMAcheck_status2;    
			       elsif (intdd = "XXXXXXXXXXXX1XXX") then   -- if not busy but DRQ then check for error
			          if (intdd = "XXXXXXXXXXXXXXX1") then   -- if no error then ?!?!?!
			             next_state <= ERROR_check;
			          else
			             next_state <= HIhost_idle;
			          end if;     
			       else
			          if (intdd = "XXXXXXXXXXXXXXX1") then   -- If not Bsy and not DRQ then check for error
			             next_state <= ERROR_check;
			          else
			             next_state <= HIhost_idle;
			          end if;
			       end if;
			    else
                if (intdd = "XXXXXXXX1XXXXXXX") then
                    next_state <= HDMAcheck_status;
                elsif (intdd = "XXXXXXXXXXXX1XXX") then  -- Device data ready
                    if (DMARQ = '1') then -- Device is ready
                       if (MUDMA = '1') then
                          if (rw = '0') then
                             next_state <= UDMAin_initialize;    
                          else
                             next_state <= UDMAout_initialize;
                          end if;
                       else
                          next_state <= HDMAprepareDMAtransfer;
                       end if;
                    else
                       next_state <= HDMAcheck_status2; -- Wait until DMARQ is asserted
                    end if;
                else
                   next_state <= HDMAcheck_status; -- Device not ready
                end if;
             end if;    
             
             
         when HDMAprepareDMAtransfer =>
             driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    creset <= '1';
			    lreset <= '1';
			    mreset <= '1';
			    loadctimer <= '0';
			    loadltimer <= '0';
			    loadmtimer <= '0';
			    intDMACK <= '1';               -- DMACK = '1'
			    sectorcnt := sectorcnt;
			    wrdcnt := "11111111";
			    
			    if (stimer = "111111111") then      -- Wait tm before moving on
			        stimerv <= MDMAtm;
			        loadstimer <= '1';
			        next_state <= HDMAprepareDMAtransfer;
			    elsif (stimerf = '1') then
			        sreset <= '1';
			        next_state <= HDMAtransfer_data_first; -- DMARQ should be asserted so should go straight through
             else
                 sreset <= '0';
                 loadstimer <= '0';
                 next_state <= HDMAprepareDMAtransfer;
			    end if;
			    
 
			when HDMAtransfer_data_first =>
			    driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    creset <= '1';
			    lreset <= '1';
			    sreset <= '1';
       		    loadctimer <= '0';
			    loadstimer <= '0';
 			    intDMACK <= '1';
 			    loadmtimer <= '0';
		       mreset <= '1'; 
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt - 1;
			    if (rw = '0') then                  -- Select Read or Write. '0' = Read  '1' = Write
			        intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		           intDIOWSTOP <= '0';
		       else
		           intDIORHDMARDYHSTROBE <= '0';
		           intDIOWSTOP <= '1';
		           
		           if (CDSTROBE = '0') then
		               cdrdy <= '0';
		               intcdrdy <= '0';
		               next_state <= HDMAtransfer_data_first2;
		           else
		               cdrdy <= '1';
		               intcdrdy <= '1';
		               next_state <= HDMAtransfer_data_first;
		           end if;
		       end if;
		       
		       -- Start td timer
		       loadltimer <= '1';
		       ltimerv <= ("00000000000" & (MDMAtd));
		       lreset <= '0';



			    
			when HDMAtransfer_data_first2 =>
			    driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
			    intDMACK <= '1'; 
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
 			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    
			    
			    if (ltimerf = '1') then
			        if (rw = '0') then
		             if(cdstrobe = '0') then          -- Controller ready
		               cdrdy <= '0';
		               intcdrdy <= '0';
		               loadltimer <= '0';
			            lreset <= '1';
			            intDIORHDMARDYHSTROBE <= '0';   
		               intDIOWSTOP <= '0';
		               loadctimer <= '1'; 		          -- Start To
		               creset <= '0';
		               ctimerv <= MDMAt0;
		               loadstimer <= '1';             -- Start Tk
		               sreset <= '0';
		               loadmtimer <= '1';		           -- Start Th              
		               mreset <= '0';
		               mtimerv <= ("00000000000" & (MDMAth));
		               stimerv <= MDMAtkr;
		               next_state <= HDMAtransfer_data_waitth;
		             else
		               cdrdy <= '1';                        -- Controller not ready and writing
		               intcdrdy <= '1';
		               loadltimer <= '0';
		               lreset <= '0';
		               creset <= '1';
			            mreset <= '1';
			            sreset <= '1';
       		            loadctimer <= '0';
			            loadstimer <= '0';   
			            loadmtimer <= '0';
			            intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		               intDIOWSTOP <= '0';
                   end if; 
		           else
		             intdd <= intdd; -- Data has been written
		             cdrdy <= '0';
		             intcdrdy <= '0';
		             loadltimer <= '0';
			          lreset <= '1';
			          intDIORHDMARDYHSTROBE <= '0';   
		             intDIOWSTOP <= '0';
		             loadctimer <= '1'; 		          -- Start To
		             creset <= '0';
		             ctimerv <= MDMAt0;
		             loadstimer <= '1';             -- Start Tk
		             sreset <= '0';
		             loadmtimer <= '1';		           -- Start Th              
		             mreset <= '0';
		             mtimerv <= ("00000000000" & (MDMAth));
		             stimerv <= MDMAtkw;
		             next_state <= HDMAtransfer_data_waitth;
		           end if; 
			   else
		          loadltimer <= '0';
		          lreset <= '0';
		          creset <= '1';
			       mreset <= '1';
			       sreset <= '1';
       		       loadctimer <= '0';
			       loadstimer <= '0';   
			       loadmtimer <= '0';
			       
		          if (rw = '0') then                  -- Select Read or Write. '0' = Read  '1' = Write
			           intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		              intDIOWSTOP <= '0';
		              cdrdy <= '1';
		              intcdrdy <= '1';
		          else
		              intDIORHDMARDYHSTROBE <= '0';
		              intDIOWSTOP <= '1';
		              intdd <= intdd; -- Data has been written
		              cdrdy <= '0';
		              intcdrdy <= '0';
		          end if;
		          
		          next_state <= HDMAtransfer_data_first2;
		       end if;
		       
		               
			    			       
         when HDMAtransfer_data_waitth =>
 			    driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    creset <= '0';
			    lreset <= '1';
			    sreset <= '0';
       		    loadltimer <= '0';
			    loadstimer <= '0';
			    loadctimer <= '0';
 			    intDMACK <= '1';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		       intDIOWSTOP <= '0';
		       sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    CDRDY <= '0';
			    
			    if (rw = '0') then
			       loadmtimer <= '0';
			       mreset <= '1';
			       next_state <= HDMAtransfer_data_waittk;
			        
			    elsif (mtimerf = '1') then
			        loadmtimer <= '0';
			        mreset <= '1';
			        if (rw = '1') then
			            intdd <= (others => '0');
			        end if;
			        next_state <= HDMAtransfer_data_waittk;
			    else
			        loadmtimer <= '0';
			        mreset <= '0';
			        if (rw = '1') then
			            intdd <= intdd;
			        end if;
			        next_state <= HDMAtransfer_data_waitth;
			    end if;
			    
         when HDMAtransfer_data_waittk =>
             driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    RESET <= '0';
			    regrst <= '1';
			    lreset <= '1';
			    loadltimer <= '0';
			    creset <= '0';
			    loadctimer <= '0';
 			    intDMACK <= '1';
 			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    
			    if (stimerf = '1') then
			        
			        
			        if (rw = '0') then
			            intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		               intDIOWSTOP <= '0';
		               mreset <= '0';                    -- Td timer
			            loadmtimer <= '1';
			            mtimerv <= ("00000000000" & (MDMAtd));
			            loadstimer <= '0';
			            sreset <= '1';
			            CDRDY <= '0';		       
			            next_state <= HDMAtransfer_data;
		           else
		               	               
		               if (CDSTROBE = '0') then
		                  intDIORHDMARDYHSTROBE <= '0';   -- assert DIOR/DIOW
		                  intDIOWSTOP <= '1'; 
		                  cdrdy <= '0';
		                  intcdrdy <= '0';
		                  mreset <= '0';                    -- Td timer
			               loadmtimer <= '1';
			               loadstimer <= '0';
			               sreset <= '1';
			               mtimerv <= ("00000000000" & (MDMAtd));		       
			               next_state <= HDMAtransfer_data;
		               else
		                  mreset <= '1';
			               loadmtimer <= '0';
			               loadstimer <= '0';
			               sreset <= '0';
			               intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		                  intDIOWSTOP <= '0';
			               
		                  cdrdy <= '1';
		                  intcdrdy <= '1';
		                  next_state <= HDMAtransfer_data_waittk;
		               end if;
		           end if;
		           
			    else
			        mreset <= '1';
			        loadmtimer <= '0';
			        loadstimer <= '0';
			        sreset <= '0';
			        intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		           intDIOWSTOP <= '0';
		           if (rw = '0') then
		               cdrdy <= '0';
		           else
		               cdrdy <= '1';
		           end if;
			        next_state <= HDMAtransfer_data_waittk;
			    end if;  
			    
			    
         when HDMAtransfer_data =>
         
             driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
         
 			    intDMACK <= '1';

			    if (mtimerf = '1') then
			        
			        if (ctimerf = '1') then

			            intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		               intDIOWSTOP <= '0';

		             if (wrdcnt = "00000000") then                 -- All Words transferred
		                
		                if (sectorcnt = "00000000000000000")then   -- All Sectors transferred
		                     if (rw = '0') then
		                         if (cdstrobe = '0') then      -- If controller ready transfer data
		                             cdrdy <= '0';
		                             intcdrdy <= '0';
		                             loadmtimer <= '1';	        -- Start Th              
		                             mreset <= '0';
		                             mtimerv <= "00000000000000000000";
		                             wrdcnt := wrdcnt;
		                             sectorcnt := sectorcnt;
		                             next_state <= HDMAhost_terminate;
		                             
		                         else                           -- If controller not ready then 
		                             loadmtimer <= '0';	                    
		                             mreset <= '0';
		                             wrdcnt := wrdcnt;
		                             sectorcnt := sectorcnt;
		                             cdrdy <= '1';
		                             intcdrdy <= '1';
		                             next_state <= HDMAtransfer_data;
		                         end if;
		                     else
		                         loadmtimer <= '1';	        -- Start Th              
		                         mreset <= '0';
		                         mtimerv <= ("00000000000" & (MDMAtd));
		                         next_state <= HDMAhost_terminate;
		                     end if;
		                     
		                     loadstimer <= '1';
		                     sreset <= '0';
		                     stimerv <= MDMAtj;

		                else
		                    	sectorcnt := sectorcnt - 1; 
		                     wrdcnt := "11111111";
		                     loadctimer <= '1'; 		          -- Start To
		                     creset <= '0';
		                     ctimerv <= MDMAt0;
		           
		                     loadstimer <= '1';             -- Start Tk
		                     sreset <= '0';
		                     if (rw = '0') then
		                        stimerv <= MDMAtkr;
		                     else
		                        stimerv <= MDMAtkw;
		                     end if;
		               
		                            
		                     if (rw = '0') then
		                         databus <= intdd; -- Where to put data?
		                     else
		                         loadmtimer <= '1';	        -- Start Th              
		                         mreset <= '0';
		                         mtimerv <= ("00000000000" & (MDMAtd));
		                     end if;
		               
		                     if (DMARQ = '0') then
		                         next_state <= HDMAdevice_pause;
		                         lreset <= '0';
			                      loadltimer <= '1';
			                      ltimerv <= ("00000000000" & (MDMAtj));   
		                     else
		                         next_state <= HDMAtransfer_data_waitth; -- Loop back around to transfer more data
		                         lreset <= '1';
			                      loadltimer <= '0';
		                     end if;
		               end if;
		             else                                         -- Data Transfer not complete
		                  wrdcnt := wrdcnt - 1;
		                  sectorcnt := sectorcnt;  
		                  loadctimer <= '1'; 		          -- Start To
		                  creset <= '0';
		                  ctimerv <= MDMAt0;
		           
		                  loadstimer <= '1';             -- Start Tk
		                  sreset <= '0';
		                  if (rw = '0') then
		                     stimerv <= MDMAtkr;
		                  else
		                     stimerv <= MDMAtkw;
		                  end if;
		               
		                            
		                  if (rw = '0') then
		                      databus <= intdd; -- Where to put data?
		                  else
		                      loadmtimer <= '1';	        -- Start Th              
		                      mreset <= '0';
		                      mtimerv <= ("00000000000" & (MDMAtd));
		                  end if;
		               
		                  if (DMARQ = '0') then
		                      next_state <= HDMAdevice_pause;
		                      lreset <= '0';
			                   loadltimer <= '1';
			                   ltimerv <= ("00000000000" & (MDMAtj));   
		                  else
		                      next_state <= HDMAtransfer_data_waitth; -- Loop back around to transfer more data
		                      lreset <= '1';
			                   loadltimer <= '0';
		                  end if;
		              end if;
		               
		           else
		               wrdcnt := wrdcnt;
		               sectorcnt := sectorcnt;
			            creset <= '0';
			            loadctimer <= '0';
			            if (rw = '0') then
			               intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		                  intDIOWSTOP <= '0';
		               else
		                  intDIORHDMARDYHSTROBE <= '0';   -- assert DIOR/DIOW
		                  intDIOWSTOP <= '1';
		               end if;
		               next_state <= HDMAtransfer_data;
			        end if;
			        
			    else
			        loadmtimer <= '0';
			        mreset <= '0';
			        lreset <= '1';
			        loadltimer <= '0';
			        if (rw = '0') then
			            intDIORHDMARDYHSTROBE <= '1';   -- assert DIOR/DIOW
		               intDIOWSTOP <= '0';
		           else
		               intDIORHDMARDYHSTROBE <= '0';   -- assert DIOR/DIOW
		               intDIOWSTOP <= '1';
		           end if;
			        next_state <= HDMAtransfer_data;
			    end if;  			    
			    
		       
		  
             -- At the end of burst then goto HMDAintrq_wait
         
         when HDMAhost_terminate =>
             driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "ZZZ";
			    intrw <= '0';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    
			    lreset <= '0';
 			    loadltimer <= '0';
 			    creset <= '0';
 			    loadctimer <= '0';

 			    intDIOWSTOP <= '0';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
             
             if (mtimerf = '1') then
                if (stimerf = '1') then
                    mreset <= '1';
                    sreset <= '1';
                    loadstimer <= '0';
                    loadmtimer <= '0';
                    intdd <= (others => 'Z');
                    intDMACK <= '0';
                    next_state <= HDMAintrq_wait;
                else
                    next_state <= HDMAhost_terminate;  -- Wait till timer ends
                    intDMACK <= '1';
                    intdd <= (others => 'Z');
                    sreset <= '0';
                    loadstimer <= '0';
                    mreset <= '0';
                    loadmtimer <= '0';
                end if;
                 
             else
                intDMACK <= '1';
                if (rw = '0') then
                    intdd <= (others => 'Z');
                    loadmtimer <= '0';	                   
		              mreset <= '0';
		              sreset <= '0';
                    loadstimer <= '0';
                else
                    loadmtimer <= '0';	                   
		              mreset <= '0';
		              sreset <= '0';
                    loadstimer <= '0';
                end if;
                next_state <= HDMAhost_terminate;   
             end if;
             
             
         when HDMAdevice_pause =>
         
             driver <= ATAD; -- ATA State Driving Outputs
             intcs <= "00";
			    intda <= "ZZZ";
			    intrw <= 'Z';
	          RESET <= '0';
             regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';

 			    intDMACK <= '1';
 			    intDIORHDMARDYHSTROBE <= '0';   -- negate DIOR/DIOW
		       intDIOWSTOP <= '0';
 			    
 			    lreset <= '0';
 			    loadltimer <= '0';
 			    mreset <= '0';
 			    loadmtimer <= '0';
 			    sreset <= '0';
 			    loadstimer <= '0';
 			    creset <= '0';
 			    loadctimer <= '0';
 			     
 			    if (ltimerf = '1') then
 			        
 			       if (mtimerf = '1') then
 			          intdd <= (others => 'Z');
 			       else
 			          intdd <= databus; -- Where coming from?
 			       end if;
 			       
 			       if (DMARQ = '1') then
 			           intDMACK <= '1';
 			           next_state <= HDMAtransfer_data_waitth;
 			       else
 			           intDMACK <= '0';
 			           next_state <= HDMAdevice_pause;
 			       end if;    
 			    else
 			       next_state <= HDMAdevice_pause;
 			       intDMACK <= '0';
 			    end if;
 			                
			when HDMAintrq_wait =>
			    driver <= ATAD;
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
			    intdd <= (others => '0');
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
			    sectorcnt := (others => '0');
			    wrdcnt := "00000000";
             if(INTRQ = '1') then
			        next_state <= HDMAintrq_wait;
			    else
			        next_state <= HDMAcheck_status;
			    end if;
			    
			---------------------------------------------------------------------------------------------------    
         -------------------------------Ultra DMA In Transfer Protocol--------------------------------------
         ---------------------------------------------------------------------------------------------------					
			when UDMAin_initialize =>
			    driver <= ATAD;
			    intcs <= "ZZ";
			    intda <= "ZZZ";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDMACK <= '0';
			    intdd <= (others => '0');
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    			    
			    if (DMARQ = '1') then
			        intDIOWSTOP <= '1';
			        intDIORHDMARDYHSTROBE <= '0';
			        stimerv <= "000000010";
			        loadstimer <= '1';
			        sreset <= '0';
			        next_state <= UDMAin_initialize2;
			    else
			        loadstimer <= '0';
			        sreset <= '1';
			        intDIOWSTOP <= '0';
			        intDIORHDMARDYHSTROBE <= '1';
			        next_state <= UDMAin_initialize;
			    end if;
			   
			when UDMAin_initialize2 =>
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
			    lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
 			    creset <= '1';
 			    loadctimer <= '0';
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDIORHDMARDYHSTROBE <= '0';
			    
			    if (stimerf = '1') then -- Wait 20nS minimum
			        intDMACK <= '1';
			        sreset <= '0';
			        loadstimer <= '1';
			        stimerv <= UDMAtenvmin;
			        next_state <= UDMAin_initialize3;
			    else
			        intDMACK <= '0';
			        sreset <= '0';
			        loadstimer <= '0';
			        next_state <= UDMAin_initialize2;
			    end if;
			    
			when UDMAin_initialize3 =>
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
			    intDMACK <= '1';
	          RESET <= '0';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
 			    creset <= '1';
 			    loadctimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    
			    if (stimerf = '1') then   -- Wait tenv minimum
			       intDIOWSTOP <= '0';
			       intDIORHDMARDYHSTROBE <= '1';
			       sreset <= '1';
 			       loadstimer <= '0';
			       next_state <= UDMAinfirst_strobe;
			    else
			       intDIOWSTOP <= '1';
			       intDIORHDMARDYHSTROBE <= '0';
			       sreset <= '0';
 			       loadstimer <= '0';
			       next_state <= UDMAin_initialize3;
			    end if;
			
			       
			when UDMAinfirst_strobe =>  -- CRCEN = '1', wait for strobe
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
 			    creset <= '1';
 			    loadctimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDIORHDMARDYHSTROBE <= '1';
			    intDMACK <= '1';
			    CRCEN <= '1';      -- Enable CRC Calculation
			    
			    if falling_edge(IORDYDDMARDYDSTROBE) then         
			       sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt - 1;
			       databus <= DD;
			       next_state <= UDMAin_transfer;
			    else
			       sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt;
			       next_state <= UDMAinfirst_strobe;
			    end if;   
			    
			    
			when UDMAin_transfer =>
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
	          loadstimer <= '0';
             sreset <= '1';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDMACK <= '1';
			    CRCEN <= '1';      -- Enable CRC Calculation
			    
			   
			    if (DMARQ = '0') then
			        ctimerv <= UDMAtzah;
			        loadctimer <= '1';
			        creset <= '0';
			        wrdcnt := wrdcnt;
			        sectorcnt := sectorcnt;
			        intDIORHDMARDYHSTROBE <= '1';
			        next_state <= UDMAin_terminate;
			        
			    elsif (pause = '1') then          -- Check for pause etc. -- Prepare for 5 data words
			        loadctimer <= '0';
                 creset <= '1';                      
			        intDIORHDMARDYHSTROBE <= '0';         -- To pause the Transfer negate HDMARDY    
			        next_state <= UDMAin_terminate;                                
			                                        
			    
			    elsif  rising_edge(IORDYDDMARDYDSTROBE) then
			        loadctimer <= '0';
                 creset <= '1';
                 intDIORHDMARDYHSTROBE <= '1';         
			        if (wrdcnt = "00000000") then
			          sectorcnt := sectorcnt - 1;
			          if (sectorcnt = "00000000000000000") then
			              sectorcnt := (others => '0');
			              wrdcnt := "00000000";
			              next_state <= UDMAin_terminate;   -- Get ready to terminate the transfer, all data transfered
			          else
			              wrdcnt := "11111111";         -- Get ready for next sector
			              databus <= DD;
			              next_state <= UDMAin_transfer;
			          end if;
			       else
			          wrdcnt := wrdcnt - 1;
			          databus <= DD;
			          next_state <= UDMAin_transfer;
			       end if;
			       
			    elsif falling_edge(IORDYDDMARDYDSTROBE) then
			        loadctimer <= '0';
                 creset <= '1';
                 intDIORHDMARDYHSTROBE <= '1';
			       if (wrdcnt = "00000000") then
			          sectorcnt := sectorcnt - 1;
			          if (sectorcnt = "000000000") then
			              sectorcnt := (others => '0');
			              wrdcnt := "00000000";
			              next_state <= UDMAin_terminate;   -- Get ready to terminate the transfer, all data transfered
			          else
			              wrdcnt := "11111111";         -- Get ready for next sector
			              databus <= DD;
			              next_state <= UDMAin_transfer;
			          end if;
			       else
			          wrdcnt := wrdcnt - 1;
			          sectorcnt := sectorcnt;
			          databus <= DD;
			          next_state <= UDMAin_transfer;
			       end if;
			        
			    else
			       intDIORHDMARDYHSTROBE <= '1';
			       loadctimer <= '0';
                creset <= '1';
			       sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt;
			       next_state <= UDMAin_transfer;
			    end if;   
			    
			when UDMAin_hostpause =>               -- To pause the DMA transfer state
			    driver <= ATAD;                    -- This state does not drive data on to GDP hardware bus, data is
			    intcs <= "00";                     -- buffered until it can be read, then circuit is paused.
			    intda <= "000";                     
			    intrw <= '0';
	          RESET <= '0';
	          loadctimer <= '0';
             creset <= '1';
             loadstimer <= '0';
             sreset <= '1';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDIORHDMARDYHSTROBE <= '0';             -- Host DMA Ready Flag Low
			    intDMACK <= '1';
			    CRCEN <= '1'; 
			    tempenable <= '1';                 -- Enable temporary data registers
			    temprst <= '0';
			    
			    -- Wait 1111000 (1200nS) before leaving this state, reason is to allow for at least 3 data words
			    
			    if  rising_edge(IORDYDDMARDYDSTROBE) then
			        loadctimer <= '0';
                 creset <= '1';
                 if (wrdcnt = "00000000") then
			          sectorcnt := sectorcnt - 1;
			          if (sectorcnt = "000000000") then
			              sectorcnt := (others => '0');
			              wrdcnt := "00000000";
			              next_state <= UDMAin_terminate;   -- Get ready to terminate the transfer, all data transfered
			          else
			              wrdcnt := "11111111";         -- Get ready for next sector
			              next_state <= UDMAin_hostpause;
			          end if;
			       else
			          wrdcnt := wrdcnt - 1;
			          next_state <= UDMAin_hostpause;
			       end if;
			       
			    elsif falling_edge(IORDYDDMARDYDSTROBE) then
			        loadctimer <= '0';
                 creset <= '1';
                if (wrdcnt = "00000000") then
			          sectorcnt := sectorcnt - 1;
			          if (sectorcnt = "000000000") then
			              sectorcnt := (others => '0');
			              wrdcnt := "00000000";
			              next_state <= UDMAin_terminate;   -- Get ready to terminate the transfer, all data transfered
			          else
			              wrdcnt := "11111111";         -- Get ready for next sector
			              next_state <= UDMAin_hostpause;
			          end if;
			       else
			          wrdcnt := wrdcnt - 1;
			          sectorcnt := sectorcnt;
			          next_state <= UDMAin_hostpause;
			       end if;
			        
			    else
			       loadctimer <= '0';
                creset <= '1';
			       sectorcnt := sectorcnt;
			       wrdcnt := wrdcnt;
			       next_state <= UDMAin_hostpause;
			    end if;   
			    
			when UDMAin_terminate =>               -- Terminating the DMA transfer state
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '0';
	          RESET <= '0';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDMACK <= '1';
			    CRCEN <= '0';      -- Disable CRC Calculation
			    DIOWSTOP <= '1'; -- Assert STOP
             intDIORHDMARDYHSTROBE <= '0'; -- Negate DMARDY
			    
			    if (ctimerf = '1') then -- Wait of tzah Has been satisfied
			       loadctimer <= '0';
                creset <= '1';
                intDD <= CRCOUT;     -- Drive CRC Result onto the Bus
                loadstimer <= '1';
                sreset <= '0';
                stimerv <= UDMAtdvs;
                next_state <= UDMAin_terminate2;
             else
                creset <= '0';
                loadctimer <= '0';
                next_state <= UDMAin_terminate;
             end if;
             
          when UDMAin_terminate2 =>               -- Terminating the DMA transfer state
             driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                  -- Write Mode

	          RESET <= '0';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDMACK <= '1';
			    CRCEN <= '0';         -- Disable CRC Calculation
			    DIOWSTOP <= '1';      -- Assert STOP
             intDIORHDMARDYHSTROBE <= '0'; -- Negate DMARDY
             
			    
			    if (IORDYDDMARDYDSTROBE = '1') then -- Wait of DMASTROBE Has been asserted
			       loadctimer <= '1';               -- Start Tmil Timer
                creset <= '0';                   -- Start Tdvs timer                  
                ctimerv <= "000000010";
                loadstimer <= '1';               
                sreset <= '0';                                    
                stimerv <= UDMAtdvs;
                intDD <= CRCOUT;                  -- Drive CRC result onto bus
                next_state <= UDMAin_terminate3;
             else
                intDD <= (others => 'Z');
                creset <= '1';
                loadctimer <= '0';
                next_state <= UDMAin_terminate2;
             end if;
             
             
             
           when UDMAin_terminate3 =>               -- Terminating the DMA transfer state
             driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
	          RESET <= '0';
	          loadstimer <= '0';
             sreset <= '0';
	          lreset <= '1';
 			    loadltimer <= '0';
 			    mreset <= '1';
 			    loadmtimer <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    CRCEN <= '0';         -- Disable CRC Calculation
			    DIOWSTOP <= '1';      -- Assert STOP
             intDIORHDMARDYHSTROBE <= '0'; -- Negate DMARDY
             intDD <= CRCOUT;
			    
			    if (ctimerf = '1') then -- Wait of tmli Has been asserted
                if(stimerf = '1') then   -- Wait of tdvs has been satisfied
      			         loadctimer <= '1';
                  creset <= '0';
                  ctimerv <= UDMAtack;
                  loadstimer <= '1';
                  sreset <= '0';
                  stimerv <= UDMAtcvh;
         			      intDMACK <= '0';         -- Negate DMACK, Time Tack & Tcvh
                  next_state <= UDMAin_terminate4;
                else
                  creset <= '0';
                  loadctimer <= '0';
                  sreset <= '0';
                  loadstimer <= '0';
         			      intDMACK <= '1';
                  next_state <= UDMAin_terminate3;
                end if;
             else
                creset <= '0';
                loadctimer <= '0';
                sreset <= '0';
                loadstimer <= '0';
         			    intDMACK <= '1';
                next_state <= UDMAin_terminate3;
             end if;
             
             when UDMAin_terminate4 =>               -- Terminating the DMA transfer state
             driver <= ATAD;                        -- 

			    intrw <= '1';
	          RESET <= '0';
	          loadctimer <= '0';
	          loadltimer <= '0';
	          loadmtimer <= '0';
             creset <= '1';
	          lreset <= '1';
 			    mreset <= '1';
 			    
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			    intDIOWSTOP <= '0';
			    intDMACK <= '0';
			    CRCEN <= '0';         -- Disable CRC Calculation

			    
			    if (stimerf = '1') then -- Wait of tcvh Has been asserted
                intDD <= (others => 'Z');
                
                if (ctimerf = '1') then -- Wait fo Tack has been satisfied
                   DIOWSTOP <= 'Z';
                   intDIORHDMARDYHSTROBE <= 'Z';
                   intcs <= "00";
			          intda <= "000";
			          sreset <= '1';
                   loadstimer <= '0';
                   creset <= '1';
                   loadctimer <= '0';
                   next_state <= HDMAintrq_wait;      -- Wait for interupt state
                else
                   intDIOWSTOP <= '1';
                   intDIORHDMARDYHSTROBE <= '0';
                   intcs <= "00";
			          intda <= "000";
                   sreset <= '0';
                   loadstimer <= '0';
                   creset <= '0';
                   loadctimer <= '0';
                   next_state <= UDMAin_terminate4;
                end if;
             else
                sreset <= '0';
                loadstimer <= '0';
                creset <= '0';
                loadctimer <= '0';
                intDD <= CRCOUT;
                DIOWSTOP <= '1';
                intDIORHDMARDYHSTROBE <= '0';
                intcs <= "00";
			       intda <= "000";
                next_state <= UDMAin_terminate4;
             end if;
                
                
                
			    
			    
			---------------------------------------------------------------------------------------------------    
         -------------------------------Ultra DMA Out Transfer Protocol-------------------------------------
         ---------------------------------------------------------------------------------------------------
         
         when UDMAout_initialize =>
             driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    intDD <= (others => 'Z');
	          RESET <= '0';
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
			    intdd <= (others => '0');
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
			        intDIOWSTOP <= 'Z';
			        intDIORHDMARDYHSTROBE <= 'Z';
			        next_state <= UDMAout_initialize;
			    end if;

         when UDMAout_initialize2 =>
             driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    intdd <= databus;              -- Drive first word on to bus
	          RESET <= '0';
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    intdd <= databus;              -- Drive first word on to bus
	          RESET <= '0';
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';
			    intdd <= databus;              -- Drive first word on to bus
	          RESET <= '0';
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
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

			       intdd <= (others => '0');        -- Zero the output
		          
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
			       intdd <= databus;                -- Drive first word on to bus
			       next_state <= UDMAout_transfer;
			    end if;
			       
			  when UDMAout_transfer2 => 
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    intdd <= databus;               -- drive next data word onto the bus
	          RESET <= '0';
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
			    intDIOWSTOP <= '0';                               -- Negate STOP
			    next_state <= UDMAout_transfer3; 
 			    			                                        		    
			  when UDMAout_transfer3 => 
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    intdd <= databus;               -- drive next data word onto the bus
	          RESET <= '0';
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
	          
             CRCEN <= '0';                   -- Disable CRC
			    sectorcnt := sectorcnt;
			    wrdcnt := wrdcnt;
			    intDMACK <= '1';
			    intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;   
			    intDIOWSTOP <= '0';             -- Negate STOP
			    
			    intdd <= (others => '0');
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
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
			       intdd <= (others => '0');
			       next_state <= UDMAout_terminate2;    
			    else
			       sreset <= '0';
			       loadstimer <= '0';
			       next_state <= UDMAout_terminate; 
			    end if;
			  
			  when UDMAout_terminate2 =>
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '1';
			     
			    loadltimer <= '0';                    
	          loadmtimer <= '0';
	          loadstimer <= '0';
	          lreset <= '1';
	          mreset <= '1';
	          sreset <= '1';
             
             intdd <= (others => '0'); 
             
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
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
			       intdd <= CRCOUT;
			       creset <= '0';
			       sreset <= '0';
			       loadstimer <= '1';
			       loadctimer <= '1';
			       ctimerv <= UDMAtmli;
			       stimerv <= UDMAtdvs;
			       next_state <= UDMAout_terminate4;    
			    else
			       intDIORHDMARDYHSTROBE <= intDIORHDMARDYHSTROBE;
			       intdd <= (others => '0');
			       creset <= '1';
			       sreset <= '1';
			       loadstimer <= '0';
			       loadctimer <= '0'; 
			       next_state <= UDMAout_terminate3; 
			    end if;
			    
			  when UDMAout_terminate4 =>
			    driver <= ATAD;
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
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
			    intdd <= CRCOUT;
			    
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
			    intcs <= "00";
			    intda <= "000";
			    intrw <= '1';                   -- Write mode
			    
	          RESET <= '0';
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
			    intdd <= CRCOUT;
			    
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
			    intDMACK <= '0';
			    intcs <= "01";
			    intda <= "001";
			    intrw <= '0';
	          RESET <= '0';
	          regrst <= '0';
			    regbegin <= '1';
			    regpioselect <= '0';
             next_state <= ERROR_check_wait;
             
         when ERROR_check_wait =>
             driver <= REG;
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "001";
             intrw <= '0';
             RESET <= '0';
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
             intDMACK <= '0';
             intcs <= "01";
			    intda <= "001";
             intrw <= '0';
             RESET <= '0';
 	          regrst <= '1';
			    regbegin <= '0';
			    regpioselect <= '0';
             if (intdd = "XXXXXXXXXXXXXXX1") then    -- Check BSY bit
                error <= '1';
                next_state <= HIhost_idle;                   
             else
                error <= '0';
                next_state <= HIhost_idle;
             end if; 
			  
		end case;
		
	end process ATA;
	
	
REGPIOTRANSFER: process(regstate_current)
	
	begin
	    
	   regDD <= (others => 'Z');
		regCS <= "00";
		regDA <= "000";
		regDIORHDMARDYHSTROBE <= '0';
		regDIOWSTOP <= '0';
		regDMACK <= '0';
		
	  case regstate_current is
	      
	    when idle =>
	       busy <= '0';
	       nextstate_self <= idle;
	        
	    when check_iordy =>
	       busy <= '1';
	       -- Timer Resets
			 creset <= '1';
			 lreset <= '1';
			 sreset <= '1';
			 loadctimer <= '0';
			 loadltimer <= '0';
			 loadstimer <= '0';
			 
	       if(IORDYDDMARDYDSTROBE='1') then
	          nextstate_self <= write_address;
	       else
	          nextstate_self <= regstate_current;
	       end if; 
		             
      	when write_address =>
   	    	 busy <= '1';
   	      regCS <= intcs;
   	      regDA <= intda;
			 -- Timer Resets
			 creset <= '1';
			 lreset <= '1';
			 loadctimer <= '0';
			 loadltimer <= '0';
             
          if (stimer = "111111111") then
              stimerv <= modet1;
              loadstimer <= '1';
              sreset <= '0';
              nextstate_self <= write_address;
          elsif (stimerf = '1') then
			        nextstate_self <= assert_diorw;
			        loadstimer <= '0';
			        sreset <= '1';
			 else
			        nextstate_self <= write_address;
			        loadstimer <= '0';
			        sreset <= '0';			    intrw <= 'Z';
			 end if;

		 when assert_diorw =>
	        busy <= '1';
		     regCS <= intcs;
		     regDA <= intda;

		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
           end if;
           
           if (ltimer = "11111111111111111111") then  -- Start T2 timer
              ltimerv <= ("00000000000" & modet2);
              loadltimer <= '1';
              lreset <= '0';
   	       else
   	          loadltimer <= '0';
			     lreset <= '0';
   	       end if;
   	       
   	       if (ctimer = "111111111") then  -- Start T0 timer
              ctimerv <= modet0;
              loadctimer <= '1';
              creset <= '0';
   	       else
   	          loadctimer <= '0';
			     creset <= '0';
   	       end if;
   	       
           if (stimer = "111111111") then  -- Start T1 timer
              stimerv <= modet1;
              loadstimer <= '1';
              sreset <= '0';
           elsif (stimerf = '1') then
   	          nextstate_self <= check_iordy2;
   	          loadstimer <= '0';
			     sreset <= '1';
   	       else
   	          nextstate_self <= assert_diorw;
   	          loadstimer <= '0';
			     sreset <= '0';
   	       end if;
           
       when check_iordy2 =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
   	       loadctimer <= '0';
			  creset <= '0';
           loadltimer <= '0';
           lreset <= '0';
   			  loadstimer <= '0';
			  sreset <= '1';
           
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
              regDD <= intdd;
           end if;
           
           if(IORDYDDMARDYDSTROBE='1') then
              nextstate_self <= data_setup;
              flag <= flag;
           else
              nextstate_self <= regstate_current;
              flag <= '1';
           end if; 
           
       when data_setup =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadctimer <= '0';
			  creset <= '0';
           loadltimer <= '0';
           lreset <= '0';
           
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		        if flag <= '0' then
                 if (stimer = "111111111") then  -- Start T5 timer
                    stimerv <= modet5;
                    loadstimer <= '1';
                    sreset <= '0';
      			           nextstate_self <= data_setup;
 			           flag <= '0'; 
                 elsif (stimerf = '1') then
   	                nextstate_self <= checkt2_len;
   	                flag <= '0';
   	                loadstimer <= '0';
			           sreset <= '1';
   	             else
   	                loadstimer <= '0';
			           sreset <= '0';
			           nextstate_self <= data_setup;
			           flag <= '0';
   	             end if;
              else
                 nextstate_self <= checkt2_len;
                 flag <= '1';
   	             loadstimer <= '0';
			        sreset <= '1';
              end if;
		     else
		        regDD <= intdd;
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
              if flag <= '0' then
                if (stimer = "111111111") then  -- Start T5 timer
                    stimerv <= modet3;
                    loadstimer <= '1';
                    sreset <= '0';
      			           nextstate_self <= data_setup;
 			           flag <= '0'; 
                 elsif (stimerf = '1') then
   	                nextstate_self <= checkt2_len;
   	                flag <= '0';
   	                loadstimer <= '0';
			           sreset <= '1';
   	             else
   	                loadstimer <= '0';
			           sreset <= '0';
			           nextstate_self <= data_setup;
			           flag <= '0';
   	             end if;
              else
                 nextstate_self <= checkt2_len;
                 loadstimer <= '0';
			        sreset <= '1';
                 flag <= '0';
              end if;
           end if;
           
                 
       when checkt2_len =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
   	       loadctimer <= '0';
			  creset <= '0';
			  loadstimer <= '0';
			  sreset <= '1';
           loadltimer <= '0';

		     
		     if(intrw = '0') then
		        regDIORHDMARDYHSTROBE <= '1';
		        regDIOWSTOP <= '0';
		     else
		        regDIORHDMARDYHSTROBE <= '0';  
              regDIOWSTOP <= '1';
           end if;
           
            if (ltimerf = '1') then
                lreset <= '1';
                if(intrw = '0') then
                   nextstate_self <= negate_dior;
                else
                   regDD <= intdd;
                   nextstate_self <= negate_diow;
                end if;
            else
               nextstate_self <= regstate_current;
               lreset <= '0';
            end if;
 
                      
       when negate_dior =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadctimer <= '0';
			  creset <= '0';
			  loadstimer <= '0';
			  sreset <= '1';
     
     	     regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     intdd <= regDD;
		     
		     nextstate_self <= release_bus;
		     
           ltimerv <= ("00000000000" & modet2i);
           loadltimer <= '1';
           lreset <= '0';

		     
       when negate_diow =>
	        busy <= '1';
           regCS <= intcs;
		     regDA <= intda;
		     loadctimer <= '0';
			  creset <= '0';
           
		     regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     intdd <= DD;

		     if (ltimer = "11111111111111111111") then  -- Start T2i timer
              ltimerv <= ("00000000000" & modet2i);
              loadltimer <= '1';
              lreset <= '0';
   	       else
   	          loadltimer <= '0';
			     lreset <= '0';
   	       end if;
   	       
		     if (stimer = "111111111") then  -- Start T4 timer
              stimerv <= modet4;
              loadstimer <= '1';
              sreset <= '0';
 	           nextstate_self <= negate_diow;
           elsif (stimerf = '1') then
   	          nextstate_self <= release_bus;
   	          loadstimer <= '0';
			     sreset <= '1';
   	       else
   	          nextstate_self <= negate_diow;
   	          loadstimer <= '0';
			     sreset <= '0';
   	       end if;
    
       when release_bus =>
	        busy <= '1';
	        
	        loadctimer <= '0';
			  creset <= '0';
			  loadstimer <= '0';
			  sreset <= '1';
           loadltimer <= '0';
           lreset <= '0';
           
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     regDD <= (others => 'Z');

     	    nextstate_self <= checkt2i_len;

           
       when checkt2i_len =>
	        busy <= '1';
	        
	        loadctimer <= '0';
			  creset <= '0';
			  loadstimer <= '0';
			  sreset <= '1';
           
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     regDD <= (others => 'Z');
     		    regCS <= "00";
			  regDA <= "000";
			  
			  if (ltimerf = '1') then
			    regCS <= "00";
			    regDA <= "000";
			    loadltimer <= '0';
             lreset <= '1';
			    nextstate_self <= checkt0_len;
			  else
			    regCS <= intcs;
		       regDA <= intda;
		       loadltimer <= '0';
             lreset <= '0';
			    nextstate_self <= checkt2i_len;
			  end if;

       when checkt0_len =>			    
	        busy <= '1';
	        
	        loadctimer <= '0';
			  loadstimer <= '0';
			  sreset <= '1';
           loadltimer <= '0';
           lreset <= '1';
           
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     regDD <= (others => 'Z');
     		    regCS <= "00";
			  regDA <= "000";
			  
			  if (ctimerf = '1') then
			    regCS <= "00";
			    regDA <= "000";
			    creset <= '1';
			    nextstate_self <= return_function;
			  else
			    regCS <= intcs;
		       regDA <= intda;
		       creset <= '0';
			    nextstate_self <= checkt0_len;
			    intrw <= 'Z';
			   end if;
			   
       when return_function =>
           nextstate_self <= idle;
           busy <= '0';
   	       loadctimer <= '0';
			  creset <= '1';
			  loadstimer <= '0';
			  sreset <= '1';
           loadltimer <= '0';
           lreset <= '1';
           regDIORHDMARDYHSTROBE <= '0';
		     regDIOWSTOP <= '0';
		     regDD <= (others => 'Z');
     		    regCS <= "00";
			  regDA <= "000";
     end case;
 	
	end process REGPIOTRANSFER;
		
		
end architecture RTL;
