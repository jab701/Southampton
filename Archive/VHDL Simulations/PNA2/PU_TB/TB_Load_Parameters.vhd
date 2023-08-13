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

entity TB_Load_Parameters  is
  generic (Address_Width : natural := 1;
           NumNeurons : integer;
           Param_Width : natural := 104;
           FileName : string);
           
  port(Clock : in std_logic;
       Program : in std_logic;
       
       Programming : out std_logic;
       
       Parameter_Addr: out std_logic_vector((Address_Width - 1) downto 0);
       Parameter_Out : out std_logic_vector((Param_Width - 1) downto 0);
       Parameter_we  : out std_logic);
       
end entity TB_Load_Parameters;

architecture Behavioural of TB_Load_Parameters is
FILE Param_File : text;
begin

Load_Config: process is
  variable read_line : Line; -- Line buffers
  variable Neuron_Num : integer;
  variable Param_line : std_logic_vector((Param_Width - 1) downto 0);
  variable good: boolean;   -- Status of the read operations
begin
  Programming <= '0';
  Parameter_we <= '0';
  Neuron_Num := 0;
  
  file_open(Param_File,FileName,READ_MODE);
  wait until rising_edge(Program);
  Programming <= '1';  
  
  while NOT(endfile(Param_File)) loop
      readline(Param_File, read_line);
      next when read_line'length = 0;  -- Skip empty lines
      next when read_line(1) = '#';    -- Skip Comment lines (Check first character)
      
      hread(read_line,Param_line,good);
      assert good
        report "TextIO Error, Failed to readline from parameter file"
        severity error;
     
      Parameter_Addr <= std_logic_vector(to_unsigned(Neuron_Num, Address_Width));
      Parameter_Out <= param_line;
      Parameter_we <= '1';
      wait until rising_edge(Clock);
      Parameter_we <= '0';
      
      Neuron_Num := Neuron_Num + 1; 
       
      assert (NumNeurons >= Neuron_Num)
        report "Parameter File Too long, expecting " & integer'image(NumNeurons) & " neuron parameter sets"
        severity failure;      
  end loop;
  
  assert (NumNeurons = Neuron_Num) 
    report "Parameter File Too Short, expected " & integer'image(NumNeurons) & " neuron parameter sets, only read " & integer'image(Neuron_Num) & " neuron parameter sets!"
    severity failure;

  file_close(Param_File); 
  Programming <= '0'; 
end process;

end architecture Behavioural;


