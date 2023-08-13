library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_comp_threshold is
   generic( RESOLUTION : natural := 16);
   port(thresholde : in std_logic_vector((RESOLUTION - 1) downto 0);
        thresholdi : in std_logic_vector((RESOLUTION - 1) downto 0);
        synweights : in std_logic_vector((RESOLUTION - 1) downto 0);
        abvthlde : out std_logic;
        belthldi : out std_logic);
end entity pna_comp_threshold;

architecture rtl of pna_comp_threshold is

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


