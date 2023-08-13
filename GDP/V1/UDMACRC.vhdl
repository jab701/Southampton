----------------------------------------------------------------------------------
-- Design Unit	: ATA 6 Standard UDMA CRC Generation (Entity and Architecture)
--
-- File name	: UDMACRC.vhd
--
-- Description	: Generates the CRC for UDMA transfers
--             : as defined ATA 6 Specification.
--
-- System	: VHDL'93
--
-- Authors	: Julian Bailey
--
-- Revision	: Version 1.0 09/08/05 (FINAL Version)
----------------------------------------------------------------------------------



library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UDMACRC is
 	port (CRCEN : in std_logic; 
		   IORDYDDMARDYDSTROBE, DIORHDMARDYHSTROBE : in std_logic;
		   RW : in std_logic;
         DD: in std_logic_vector(15 downto 0);
   		   xCRCOUT, xCRCIN : out std_logic_vector(15 downto 0));

end entity UDMACRC;

architecture RTL of UDMACRC is

	-- CRC Signals
	signal CRCOUT: std_logic_vector(15 downto 0);
	signal CRCIN : std_logic_vector(15 downto 0);
   signal f : std_logic_vector(15 downto 0);
       
begin
    
CRC: process(CRCEN, RW, DIORHDMARDYHSTROBE, IORDYDDMARDYDSTROBE, DD, f, CRCOUT, CRCIN) is -- CRC Generation for UDMA
   begin
      if (CRCEN = '1') then
         if (RW = '0') then
            if rising_edge(DIORHDMARDYHSTROBE) then
               CRCOUT <= CRCIN;
            elsif falling_edge(DIORHDMARDYHSTROBE) then
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
   
-- CRCIN signal generation equations for UDMA Bursts
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
      
-- f polynomial generation equations for UDMA Bursts
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
      
-- Assign CRCIN/CRCOUT to Output      
      xCRCOUT <= CRCOUT;
      xCRCIN  <= CRCIN;
      
end process CRC;
  
end architecture RTL;
    
