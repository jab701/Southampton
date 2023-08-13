library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.mips_sys_isa_pack.ALL;

entity pipeline_decode_regfile is
   port(
      -- core clock
      clock        : in std_logic;
      -- read select
      readsel1     : in std_logic_vector(4 downto 0);
      readsel2     : in std_logic_vector(4 downto 0);
      -- write select & enable
      writesel     : in std_logic_vector(4 downto 0);
      writeen      : in std_logic;
      -- write data input
      writedat     : in std_logic_vector(31 downto 0);
      -- read data outputs
      readdat1     : out std_logic_vector(31 downto 0);
      readdat2     : out std_logic_vector(31 downto 0);
      -- Debug Port
      dbgsel     : in std_logic_vector(4 downto 0);
      dbgwrite   : in std_logic;
      dbgin      : in std_logic_vector(31 downto 0);
      dbgout     : out std_logic_vector(31 downto 0);
      dbgblocked : out std_logic);
end entity pipeline_decode_regfile;

architecture rtl of pipeline_decode_regfile is

-- Type Declarations
type REGTYPE is array(30 downto 0) of std_logic_vector(31 downto 0);

-- Signal Declarations
signal registers : REGTYPE;

begin

p_read: process(readsel1, readsel2, writesel, registers, writedat)
   variable ZEROSEL : std_logic_vector(4 downto 0);
begin
   ZEROSEL := (others => '0');

   -- Read Port 1
   for i in 0 to 31 loop
      -- Register Zero is always read as zero
      if (i = 0) then
         if (readsel1 = ZEROSEL) then
            readdat1 <= (others => '0');
         end if;
      else
         -- if readsel = writesel then forward the write
         if ((readsel1 = writesel) AND (writeen = '1')) then
            readdat1 <= writedat;
         -- if readsel = dbgsel then forward the write
         elsif ((readsel1 = dbgsel) AND (dbgwrite = '1')) then
            readdat1 <= dbgin;
         -- otherwise just read the register
         elsif (readsel1 = std_logic_vector(unsigned(i,5)) then
            readdat1 <= registers(i-1);
         end if;
      end if;
   end loop;

   -- Read Port 2
   for i in 0 to 31 loop
      -- Register Zero is always read as zero
      if (i = 0) then
         if (readsel2 = ZEROSEL) then
            readdat2 <= (others => '0');
         end if;
      else
         -- if readsel = writesel then forward the write
         if ((readsel2 = writesel) AND (writeen = '1')) then
            readdat2 <= writedat;
         -- if readsel = dbgsel then forward the write
         elsif ((readsel2 = dbgsel) AND (dbgwrite = '1')) then
            readdat2 <= dbgin;
         -- otherwise just read the register
         elsif (readsel1 = std_logic_vector(unsigned(i,5)) then
            readdat2 <= registers(i-1);
         end if;
      end if;
   end loop;
end process p_read;

p_write: process (clock, writesel, writeen, writedat,
                  dbgsel, dbgwrite, dbgin)
begin
   if (clock'event AND (clock = '1')) then
      for i in 1 to 31 loop
         -- Pipeline Writes have priority over dbgwrite
         if ((writesel = std_logic_vector(unsigned((i),5)) AND (writeen = '1')) then
            registers(i-1) <= writedat;
         elsif ((dbgsel = std_logic_vector(unsigned((i),5)) AND (dbgwrite = '1')) then
            registers(i-1) <= dbgin;
         end if;
      end loop;
   end if;
end process p_write;

p_debug_read: process (dbgsel, registers)
   variable ZEROSEL : std_logic_vector(4 downto 0);
begin
   ZEROSEL := (others => '0');

   for i in 0 to 31 loop
      if (i = 0) then
         -- Register Zero is always read as zero
         if (dbgsel = ZEROSEL) then
            dbgout <= (others => '0');
         end if
      else
         -- Forward the write to the debug port
         if ((dbgsel = writesel) AND (writeen = '1')) then
            dbgout <= writedat;
         -- otherwise read the register to the dbg port
         elsif (dbgsel = std_logic_vector(unsigned(i,5)) then
            dbgout <= registers(i-1);
         end if;
      end if;
   end loop;
end process p_debug_read;

-- Debug Blocked Signal
-- This signal tells the debugger if the debuggers write has been
-- blocked because the pipeline was writing to the same location.
p_debug_block: process (dbgsel, writesel, dbgwrite, writeen)
begin
   if ((writesel = dbgsel) AND (dbgwrite = '1') AND (writeen = '1')) then
      dbgblocked <= '1';
   else
      dbgblocked <= '0';
   end if;
end process p_debug_block;

end architecture rtl;