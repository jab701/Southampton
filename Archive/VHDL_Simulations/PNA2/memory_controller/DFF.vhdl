library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DFF is
  generic (width : natural := 8);
  port 
  (
     signal clk  : in std_logic;
     signal nrst : in std_logic;
     signal cke  : in std_logic;
     signal D    : in std_logic_vector(width-1 downto 0);
     signal Q    : out std_logic_vector(width-1 downto 0)
   ); 
end entity DFF;

architecture Behavioural of DFF is

begin
  
process (clk, nrst) is
begin
  if (nrst = '0') then
    Q <= (others => '0');
  elsif rising_edge(clk) then
    if (cke = '1') then
      Q <= D;  
    end if;
  end if;   
    
end process;

end architecture Behavioural;
