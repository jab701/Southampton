----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:36:03 04/22/2010 
-- Design Name: 
-- Module Name:    Main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InterruptTimer is
    Port ( Clock : in  STD_LOGIC;
           nReset : in  STD_LOGIC;
           Interrupt : out  STD_LOGIC);
end InterruptTimer;

architecture Behavioral of InterruptTimer is
  
type MachineStates is (Initial, Running, Pulse);
signal StateQ, StateD : MachineStates;    
signal CounterQ, CounterD : unsigned(15 downto 0);
begin

process (Clock, nReset) is
begin
	if (nReset = '0') then
		CounterQ <= (others => '0');
		StateQ <= Initial;
	elsif rising_edge(Clock) then
		CounterQ <= CounterD;
		StateQ <= StateD;
	end if;
end process;

process (CounterQ, StateQ) is
begin
  
  case StateQ is
  when Initial =>
      CounterD <= x"01F4" - 1;
      Interrupt <= '0';
      StateD <= Running;
    
  when Running =>
      CounterD <= CounterQ - 1;
      Interrupt <= '0';
      
      if (CounterQ = x"0000") then
        StateD <= Pulse;  
      else
        StateD <= Running;
      end if;
         
  when Pulse =>
      CounterD <= x"01F4" - 2;
      Interrupt <= '1';
      StateD <= Running; 
         
  end case;  
end process;

end Behavioral;

