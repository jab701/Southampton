----------------------------------------------------------------------------------
-- Design Unit	: Timer Based on Central Clock (Entity and Architecture)
--
-- File name	: timer.vhd
--
-- Description	: Timer is loaded with value in timerv when loadtimer
--             : is raised. When number of clock cycles in timerv have
--             : passed timerfin goes high.
--
-- System	: VHDL'93
--
-- Authors	: Julian Bailey
--
-- Revision	: Version 1.4 09/08/05 (FINAL Version)
----------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
   generic (n: natural := 19); 
 	port (clock             : in  std_logic;
 	      reset             : in  std_logic;
 	      loadtimer         : in  std_logic;
 	      timerv            : in  std_logic_vector(n downto 0);
 	      timerfin          : out std_logic);
end entity Timer;


architecture RTL of Timer is
	-- Timer Signals 
	signal timerf : std_logic;
		
begin
    
timer: process(clock, loadtimer, reset, timerv, timerf) is  -- Timer Control
	variable timervar : unsigned (n downto 0);
	begin
      
		if (reset = '1') then
          timervar := (others => '1');
          timerf <= '0';
      elsif (loadtimer = '1') then
   	      timervar := unsigned(timerv);
          timerf <= '0';    
      elsif (timervar = "00000000000000000000") then
	       timervar := timervar;
	       timerf <= '1';
		elsif (timervar = "11111111111111111111") then
	      timervar := (others => '1');
	      timerf <= timerf;
	   else
	      if (rising_edge(clock)) then
	         timervar := timervar - 1;
	         timerf <= '0';
	      else
	         timervar := timervar;
	         timerf <= timerf;
	      end if;
	   end if;
	   
      timerfin <= timerf;
      
   end process timer;
end architecture RTL;
