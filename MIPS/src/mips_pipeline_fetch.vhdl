library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library MIPS_Common;

entity mips_pipeline_fetch is
  port(-- Control Signals
       clk           : in std_logic;
       reset_n       : in std_logic;
       -- Stage Control
       enable        : in std_logic;
       ready         : out std_logic;

       -- Memory Controls
       mem_addr      : out std_logic_vector(29 downto 0);
       mem_rd        : out std_logic;
       mem_data      : in std_logic;
       
       -- Stage Inputs
       pc_src        : in std_logic;
       ext_pc        : in std_logic_vector(31 downto 0);
       
       -- Stage Outputs
       instruct      : out std_logic_vector(31 downto 0);
       pc_out        : out std_logic_vector(31 downto 0));
end entity mips_pipeline_fetch;

architecture rtl of mips_pipeline_fetch is

signal pc      : std_logic_vector(29 downto 0);
signal n_pc    : std_logic_vector(29 downto 0);

begin

mem_rd   <= enable;
instruct <= mem_data;
pc_out(1 downto 0)  <= "00";
pc_out(31 downto 2) <= unsigned(pc + 1);

p_pc_reg: process(clk, reset_n)
begin
   if reset_n = '0' then
      pc    <= (others => '0');
      ready <= '0';
   elsif clk'event AND clk = '1' then
      pc    <= n_pc;
      ready <= '1';
   end if;
end process p_pc_reg;

p_pc_com: process(pc, pc_src, ext_pc)
begin
   if enable = '0' then
      n_pc <= pc;
   elsif pc_src = '1' then
      n_pc <= ext_pc(31 downto 2);
   else
      n_pc <= unsigned(pc + 1);
   end if;
end process p_pc_com;

end architecture rtl;