library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timertest is
 	port (clock, resetc : in std_logic; 
		   testtimer : out std_logic_vector (19 downto 0);
		   loadltimerext : out std_logic; 
	      ltimervext : out std_logic_vector(19 downto 0));
end entity timertest;

architecture RTL of timertest is
    signal ltimer, ltimerv : std_logic_vector(19 downto 0);
    signal lreset, ltimerf, loadltimer : std_logic;
    type statetype is (s0, s1, s2);
    signal current_state, next_state : statetype;
    
    begin
        
    
seq: process (clock, resetc) is
   begin
      if (resetc = '1') then
         current_state <= s1;
      elsif rising_edge(clock) then
         current_state <= next_state;    
      else
         current_state <= current_state;
      end if;
   end process;
       
timers: process(clock, resetc, ltimer, ltimerf) is

   variable linttimer : unsigned(19 downto 0);
   
   begin
       if (resetc = '1') then
           linttimer := "11111111111111111111";
           ltimerf <= '0';
       else
           -- Timer for Signals timings based on 100Mhz Clock
      	    if (lreset = '1') then
               linttimer := "11111111111111111111";
               ltimerf <= '0';
           elsif (loadltimer = '1') then
        	      linttimer := unsigned(ltimerv);
  	            ltimervext <= ltimerv;
    	          ltimerf <= '0';    
      	    elsif (linttimer = "00000000000000000000") then
			      linttimer := linttimer;
			      ltimerf <= '1';
			  
			  elsif (linttimer = "11111111111111111111") then
			      linttimer := "11111111111111111111";
			      ltimerf <= '0';
	        else
	            if (rising_edge(clock)) then
			         linttimer := linttimer - 1;
			         ltimerf <= '0';
			      else
			         linttimer := linttimer;
			         ltimerf <= ltimerf;
			      end if;
			  end if;
		 end if;
		 
     -- loadltimerext <= loadltimer;
		ltimer <= std_logic_vector(linttimer);
		testtimer <= std_logic_vector(linttimer);
		      
   end process timers;
   
system: process (current_state, clock) is
      begin
          case (current_state) is
              
              when s0 =>
                  lreset <= '0';
                  loadltimer <= '1';
                  ltimerv <= "00000000000000000010";
                  next_state <= s1;
    
              when s1 =>
                  if (ltimer = "11111111111111111111") then
                     lreset <= '0';
                     loadltimer <= '1';
                     ltimerv <= "00000000000000000010";
                     next_state <= s1; 
                      loadltimerext <= '0';   
                  elsif (ltimerf = '1') then
                      loadltimerext <= '0';
                      lreset <= '1';
                      loadltimer <= '1';
                      next_state <= s1;
                  else
                      loadltimerext <= '1';
                      lreset <= '0';
                      loadltimer <= '0';
                      next_state <= s1;
                  end if;
              when s2 =>
                  lreset <= '1';
                  loadltimer <= '0';
                  next_state <= s0;
          end case;    
end process system;
end architecture RTL;
