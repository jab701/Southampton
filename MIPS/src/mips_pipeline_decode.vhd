library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mips_sys_isa_pack.ALL;

entity pipeline_decode is
   port(
      -- Input
      clock       : in std_logic;
      instruction : in std_logic_vector(31 downto 0);
      pcplus4     : in std_logic_vector(31 downto 0);

      write_regnum : in std_logic_vector(4 downto 0);
      write_regdat : in std_logic_vector(31 downto 0);
      write_regen  : in std_logic;

      next_pc    : out std_logic_vector(31 downto 0);

      inst_ctrl  : out instruction_ctrl;
      ex_ctrl    : out execute_ctrl;
      mem_ctrl   : out memory_ctrl;
      wb_ctrl    : out writeback_ctrl;
      -- Exception
      except_badfunct   : out std_logic);
end entity pipeline_decode;

architecture rtl of pipeline_decode is

-- Component Declarations
component pipeline_decode_regfile
   port(
      -- core clock
      clock     : in std_logic;
      -- read select
      readsel1  : in std_logic_vector(4 downto 0);
      readsel2  : in std_logic_vector(4 downto 0);
      -- write select & enable
      writesel  : in std_logic_vector(4 downto 0);
      writeen   : in std_logic;
      -- write data input
      writedat  : in std_logic_vector(31 downto 0);
      -- read data outputs
      readdat1  : out std_logic_vector(31 downto 0);
      readdat2  : out std_logic_vector(31 downto 0));
end component pipeline_decode_regfile;

-- Signal Declarations
signal opcode : std_logic_vector(5 downto 0);

signal source_register1 : std_logic_vector(31 downto 0);
signal source_register2 : std_logic_vector(31 downto 0);

signal target_register : std_logic_vector(4 downto 0);

signal se_immed : std_logic_vector(31 downto 0);
signal zero_immed : std_logic;

signal bad_function : std_logic;
signal bad_opcode   : std_logic;

begin

opcode <= instruction(31 downto 26);

i_regfile: entity pipeline_decode_regfile
   port map(-- core clock
            clock     => clock,
            -- read select
            readsel1  => instruction(25 downto 21),
            readsel2  => instruction(20 downto 16),
            -- write select & enable
            writesel  => write_regnum,
            writeen   => write_regen,
            -- write data input
            writedat  => write_regdat,
            -- read data outputs
            readdat1  => source_register1,
            readdat2  => source_register2);
end architecture rtl;