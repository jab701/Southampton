
----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  26th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  
-- Description:  
--
-- Dependencies: None
--
-- Revision: 1.00 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.std_logic_textio.ALL; -- Include synopsys textIO functions

use std.textio.ALL;

library PNA_LibNeuron_com;

entity TB_Load_Enables  is
  generic (Address_Width : natural := 1;
           NumNeurons : integer := 1);
           
  port(Clock : in std_logic;
       Load : in std_logic;
       
       Loading : out std_logic;
       
       Enable_In  : in std_logic_vector((NumNeurons-1) downto 0);
       Enable_Addr: out std_logic_vector((Address_Width - 1) downto 0);
       Enable_Out : out std_logic;
       Enable_we  : out std_logic);
       
end entity TB_Load_Enables;

architecture Behavioural of TB_Load_Enables is
begin

Load_Enables: process is
begin
  Loading <= '0';
  Enable_we <= '0';
  
  wait until rising_edge(Load);
  Loading <= '1';  
  
  for i in 0 to (NumNeurons-1) loop
    Enable_Addr <= std_logic_vector(to_unsigned(i, Address_Width));
    Enable_Out <= Enable_In(i);
    Enable_we <= '1';
    wait until rising_edge(Clock);
    Enable_we <= '0';
  end loop;
 
  Loading <= '0'; 
end process;

end architecture Behavioural;



