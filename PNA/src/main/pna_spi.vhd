library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_spi_if is
   port (-- System Control Signals
         clk   : in std_logic;
         rst_n : in std_logic;
         -- SPI Configuration
         --cpol  : in std_logic;
         --cpha  : in std_logic;
         -- Internal Bus Interface Signals
         din   : in std_logic_vector(7 downto 0);
         drdy  : out std_logic;
         dout  : out std_logic_vector(7 downto 0);
         -- External SPI Bus Signals
         sck   : in std_logic;
         cs_n  : in std_logic;
         sdi   : in std_logic;
         sdo   : out std_logic);
end entity pna_spi_if;

architecture rtl of pna_spi_if is


type STATES is (ST_IDLE, ST_SAMPLE, ST_SHIFT);

signal state   : STATES;
signal n_state : STATES;

signal sck_last : std_logic;

signal sck_rise : std_logic;
signal sck_fall : std_logic;

signal sample_tick : std_logic;
signal shift_tick : std_logic;

signal bitcnt   : std_logic_vector(2 downto 0);
signal n_bitcnt : std_logic_vector(2 downto 0);

signal shift   : std_logic_vector(8 downto 0);
signal n_shift : std_logic_vector(8 downto 0);

signal n_drdy : std_logic;

begin
   sdo  <= shift(8);
   dout <= shift(8 downto 1);

   -- sck rise & fall signals
   sck_rise <= sck AND NOT(sck_last);
   sck_fall <= NOT(sck) AND sck_last;

   -- Tick Signals
   sample_tick <= sck_rise;
   -- We only tick on the falling edge if we ticked on the rising edge
   shift_tick <= sck_fall;

   p_reg: process(clk, rst_n)
   begin
      if rst_n = '0' then
         sck_last <= '0';
         bitcnt   <= (others => '0');
         shift    <= (others => '0');
         drdy     <= '0';
         state    <= ST_IDLE;
      elsif clk'event AND clk = '1' then
         sck_last <= sck;
         bitcnt   <= n_bitcnt;
         shift    <= n_shift;
         drdy     <= n_drdy;
         state    <= n_state;
      end if;
   end process p_reg;

   p_states: process(shift, bitcnt, cs_n, state, sample_tick, shift_tick, sdi, din)
   begin

      case state is
      when ST_IDLE =>
         n_shift(0)          <= '0';
         n_shift(8 downto 1) <= din;
         n_bitcnt            <= (others => '0');
         n_drdy                <= '0';

         if cs_n = '0' then
            n_state <= ST_SAMPLE;
         else
            n_state <= ST_IDLE;
         end if;

      when ST_SAMPLE =>
         n_shift(8 downto 1) <= shift(8 downto 1);
         n_shift(0)          <= sdi;
         n_bitcnt            <= bitcnt;
         n_drdy              <= '0';

         if cs_n = '1' then
            n_state <= ST_IDLE;
         elsif sample_tick = '1' then
            n_state <= ST_SHIFT;
         else
            n_state <= ST_SAMPLE;
         end if;

      when ST_SHIFT =>
         if cs_n = '1' then
            n_shift  <= shift;
            n_bitcnt <= bitcnt;
            n_drdy   <= '0';
            n_state  <= ST_IDLE;
         elsif shift_tick = '1' then
            n_shift(0)          <= '0';
            n_shift(8 downto 1) <= shift(7 downto 0);

            if bitcnt = "111" then
               n_bitcnt <= "000";
               n_drdy   <= '1';
               n_state  <= ST_IDLE;
            else
               n_bitcnt <= bitcnt + 1;
               n_drdy   <= '0';
               n_state  <= ST_SAMPLE;
            end if;
         else
            n_shift  <= shift;
            n_bitcnt <= bitcnt;
            n_drdy   <= '0';
            n_state  <= ST_SHIFT;
         end if;
      end case;
   end process p_states;
end architecture rtl;
