library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

entity tb_routerdispatcher is
  generic 
  (clock_period : time := 1 ns);
end entity tb_routerdispatcher;

architecture Behavioural of tb_routerdispatcher is

signal clock   : std_logic := '1';
signal nReset  : std_logic := '0';
signal Port_Empty : std_logic_vector(15 downto 0);
signal Port_RD    : std_logic_vector(15 downto 0);
signal Valid : std_logic;

begin
  
ROUTER_DISPATCHER_1:  entity work.RouterDispatcher
                      port map(clk => clock,
                               nrst => nReset,
                               cke => '1',
                               Port_Empty => Port_Empty,
                               Port_RD => Port_RD,
                               Valid => Valid);
                                                      
clock <= NOT clock after clock_period/2;
nReset <= '0', '1' after clock_period*10;

Port_Empty <= x"FFFF",
              x"0000" after clock_period*20,
              x"FFFF" after clock_period*21,
              x"EEEE" after clock_period*40,
              x"FFFF" after clock_period*41;
end architecture Behavioural;









