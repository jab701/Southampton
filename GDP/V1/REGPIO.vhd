


library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGPIO is
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

end entity REGPIO;

architecture RTL of REGPIO is
    
   type regtran is (idle, check_iordy, write_address, assert_diorw, check_iordy2,
	                 data_setup, checkt2_len, negate_dior, negate_diow, release_bus,
	                 checkt2i_len, checkt0_len, return_function);
	signal regstate_current, regstate_next, nextstate_self : regtran;
	  
	  
	signal regDD: std_logic_vector(15 downto 0);
   signal regCS: std_logic_vector(1 downto 0);
   signal regDA: std_logic_vector(2 downto 0);
   signal regDMACK, regdiorhdmardyhstrobe, regDIOWSTOP: std_logic;

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
	
	signal regpioselect : std_logic;
	signal flagdb : std_logic;
	
	signal busy : std_logic;
	signal lba_level : std_logic_vector(1 downto 0);

	type pio is (mode0, mode1, mode2, mode3, mode4);	
	signal REGMode : pio; -- External
	signal PIOMode : pio; -- External	
	signal REGmodet0, REGmodet1, REGmodet2, REGmodet2i, REGmodet3, REGmodet4, REGmodet5, REGmodet9 : std_logic_vector(11 downto 0);
	signal PIOmodet0, PIOmodet1, PIOmodet2, PIOmodet2i, PIOmodet3, PIOmodet4, PIOmodet5, PIOmodet9 : std_logic_vector(11 downto 0);
	signal modet0, modet1, modet2, modet2i, modet3, modet4, modet5, modet9 : std_logic_vector(8 downto 0);	

begin

REGMODES: process(REGmode) is
   begin
      case REGMode is 
      
         when mode0 =>
             REGmodet0  <= x"03C";
             REGmodet1  <= x"007";
             REGmodet2  <= x"01D";
             REGmodet2i <= x"000";
             REGmodet3  <= x"006";
             REGmodet4  <= x"003";
             REGmodet5  <= x"005";
             REGmodet9  <= x"002";
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
             REGmodet0  <= "000010010";
             REGmodet1  <= "000000011";
             REGmodet2  <= "000001000";
             REGmodet2i <= "000000111";
             REGmodet3  <= "000000000";
             REGmodet4  <= "000000000";
             REGmodet5  <= "000000000";
             REGmodet9  <= "000000000";
         when mode4 =>
             REGmodet0  <= "000001100";
             REGmodet1  <= "000000011";
             REGmodet2  <= "000000111";
             REGmodet2i <= "000000011";
             REGmodet3  <= "000000010";
             REGmodet4  <= "000000000";
             REGmodet5  <= "000000010";
             REGmodet9  <= "000000000";
        end case;   
   end process REGMODES;

PIOMODES: process(PIOmode) is
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
             PIOmodet0  <= "000111100";
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
         when mode4 =>
             PIOmodet0  <= "000111100";
             PIOmodet1  <= "000000111";
             PIOmodet2  <= "000011101";
             PIOmodet2i <= "000000000";
             PIOmodet3  <= "000000110";
             PIOmodet4  <= "000000011";
             PIOmodet5  <= "000000101";
             PIOmodet9  <= "000000010";
        end case;   
   end process PIOMODES;
reginput: process(regrst, regbegin) is

   begin
       
       if (regrst = '1') then
           regstate_next <= idle;
       elsif (regbegin = '1') then
           regstate_next <= check_iordy;
       else
           regstate_next <= nextstate_self;
       end if;
       
   end process reginput;
       
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
    