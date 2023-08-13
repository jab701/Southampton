library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity libpna_threshold is
   generic
   (
      -- Module Specific Configuration Parameters
      RESOLUTION : natural := 16
   );

   port(
      signal thresholde : in std_logic_vector((RESOLUTION - 1) downto 0);
      signal thresholdi : in std_logic_vector((RESOLUTION - 1) downto 0);
      -- Module Specific Input Signals
      signal synweights : in std_logic_vector((RESOLUTION - 1) downto 0);
      -- Module Specific Output Signals
      signal abvthlde : out std_logic;
      signal belthldi : out std_logic);
end entity libpna_threshold;

architecture rtl of libpna_threshold is

signal thresholde_l : signed((RESOLUTION - 1) downto 0);
signal thresholdi_l : signed((RESOLUTION - 1) downto 0);
signal synweights_l : signed((RESOLUTION - 1) downto 0);

begin
   thresholde_l <= signed(thresholde);
   thresholdi_l <= signed(thresholdi);
   synweights_l <= signed(synweights);

DecisionEx: process(synweights_l) is
begin
   if synweights_l >= thresholde_l then
      abvthlde <= '1';
   else
      abvthlde <= '0';
   end if;
end process DecisionEx;

DecisionIn: process(synweights_l) is
begin
   if thresholdi_l >= synweights_l then
      belthldi <= '1';
   else
      belthldi <= '0';
   end if;
end process DecisionIn;

end architecture rtl;


