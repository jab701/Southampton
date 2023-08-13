library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_spi_control is
   port (-- System Control Signals
         clk         : in std_logic;
         rst_n       : in std_logic;
         -- System Interface Signals
         sys_status  : in  std_logic_vector(7 downto 0);
         sys_ctrl_i  : in  std_logic_vector(7 downto 0);
         sys_ctrl_o  : out std_logic_vector(7 downto 0);
         sys_ctrl_wr : out std_logic;
         sys_addr    : out std_logic_vector(11 downto 0);
         sys_wr      : out std_logic;
         sys_din     : in  std_logic_vector(31 downto 0);
         sys_dout    : out std_logic_vector(31 downto 0);
         -- SPI IF Signals
         spi_cs_n    : in std_logic;
         spi_drdy    : in std_logic;
         spi_din     : in std_logic_vector(7 downto 0);
         spi_dout    : out std_logic_vector(7 downto 0));
end entity pna_spi_control;

architecture rtl of pna_spi_control is

constant CMD_STAT : std_logic_vector(1 downto 0) := "00";
constant CMD_CTRL : std_logic_vector(1 downto 0) := "01";
constant CMD_PROG : std_logic_vector(1 downto 0) := "10";
constant CMD_FREE : std_logic_vector(1 downto 0) := "11";

type STATES is (ST_IDLE , ST_ADDR  , ST_FETCH, ST_DATA1,
                ST_DATA2, ST_DATA3 , ST_DATA4, ST_COMMIT);

signal state   : STATES;
signal n_state : STATES;

signal cmd   : std_logic_vector(1 downto 0);
signal n_cmd : std_logic_vector(1 downto 0);

signal ainc   : std_logic;
signal n_ainc : std_logic;

signal rw_n   : std_logic;
signal n_rw_n : std_logic;

signal addr   : std_logic_vector(11 downto 0);
signal n_addr : std_logic_vector(11 downto 0);

signal data   : std_logic_vector(31 downto 0);
signal n_data : std_logic_vector(31 downto 0);
begin

-- Inputs Assignments
-- Output Assignments
sys_ctrl_o <= spi_din;
sys_addr   <= addr;
sys_dout   <= data;


-- Resettable registers
p_regrst: process (clk, rst_n) is
begin
   if (rst_n = '0') then
      state <= ST_IDLE;
   elsif (clk'event and clk = '1') then
      state <= n_state;
   end if;
end process p_regrst;

-- Non-Resettable Registers
p_regnorst: process (clk) is
begin
   if (clk'event AND clk = '1') then
      cmd  <= n_cmd;
      ainc <= n_ainc;
      rw_n <= n_rw_n;
      addr <= n_addr;
      data <= n_data;
   end if;
end process p_regnorst;


p_com: process(state     , cmd       , ainc   ,
               rw_n      , addr      , data   ,
               sys_status, sys_ctrl_i, sys_din,
               spi_rst   , spi_drdy  , spi_din)

begin
   -- Default Assignments
   n_state    <= state;
   n_cmd      <= cmd;
   n_ainc     <= ainc;
   n_rw_n     <= rw_n;
   n_addr     <= addr;
   n_data     <= data;

   if spi_rst = '1' then
      n_state <= ST_IDLE;
      n_cmd   <= (others => '0');
      n_ainc  <= '0';
      n_rw_n  <= '0';
      n_addr  <= (others => '0');
      n_data  <= (others => '0');
   else
      case state is
      when ST_IDLE =>
         spi_dout <= sys_status;

         if spi_drdy = '1' then
            if spi_din(7 downto 6) = CMD_CTRL then
               n_state <= ST_FETCH
            else
               n_state <= ST_ADDR;
            end if;

            n_cmd               <= spi_din(7 downto 6);
            n_rw_n              <= spi_din(5);
            n_ainc              <= spi_din(4);
            n_addr(12 downto 8) <= spi_din(3 downto 0);
         end if;

      when ST_ADDR  =>
         spi_dout <= sys_status;

         if cmd = CMD_STAT then
            n_state            <= ST_IDLE;
         elsif spi_drdy = '1' then
            n_addr             <= spi_din;

            if cmd = CMD_CTRL then
               if rw_n = '1' then
                  n_state <= ST_FETCH;
               else
                  n_state <= ST_COMMIT;
               end if;
            else


            end if;
         elsif cmd = CMD_CTRL then
            if rw_n <= '1' then
               n_state <= ST_FETCH;
            else
               n_state <= ST_COMMIT;
            end if;
         elsif spi_drdy = '1' then
            addr_valid         <= '1';
            n_state            <= ST_FETCH;
            n_addr(7 downto 0) <= spi_din;
         end if;

      when ST_DATA1 =>
         if cmd = CMD_CTRL then
            spi_dout <= sys_ctrl_i;
         else
            spi_dout <= sys_din(7 downto 0);
         end if;

         if spi_drdy = '1' then
            n_data(7 downto 0) <= spi_din;

            if cmd = CMD_CTRL then
               if rw_n = '0' then
                  sys_ctrl_wr <= '1';
               end if;

               n_state <= ST_IDLE;
            else
               n_state <= ST_DATA2;
            end if;
         end if;

      when ST_DATA2 =>
         spi_dout  <= sys_din(15 downto 0);

         if spi_drdy = '1' then
            n_data(15 downto 8) <= spi_din;
            n_state <= ST_DATA3;
         end if;

      when ST_DATA3 =>
         spi_dout   <= sys_din(23 downto 16);

         if spi_drdy = '1' then
            n_data(23 downto 16) <= spi_din;
            n_state <= ST_DATA4;
         end if;

      when ST_DATA4 =>
         spi_dout   <= sys_din(31 downto 24);

         if spi_drdy = '1' then
            n_data(31 downto 24) <= spi_din;

            if (rw_n = '0') then
               n_state <= ST_COMMIT;
            else
               n_state <= ST_DATA1;

               if ainc = '1' then -- autoincrement address
                  n_addr <= addr + 1;
               end if;
            end if;
         end if;

      when ST_COMMIT =>
         sys_wr      <= '1';

         if ainc = '1' then
            n_addr <= addr + 1;
         end if;

         n_state <= ST_DATA1;
      end case;
   end if;
end process p_com;


end architecture rtl;
