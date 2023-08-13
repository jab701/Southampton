library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_pna_spi_if is

end entity tb_pna_spi_if;

architecture tb of tb_pna_spi_if is

-- converts a std_logic_vector into a hex string.
function hstr(slv: std_logic_vector) return string is
  variable hexlen: integer;
  variable longslv : std_logic_vector(67 downto 0) := (others => '0');
  variable hex : string(1 to 16);
  variable fourbit : std_logic_vector(3 downto 0);
begin
  hexlen := (slv'left+1)/4;
  if (slv'left+1) mod 4 /= 0 then
    hexlen := hexlen + 1;
  end if;
  longslv(slv'left downto 0) := slv;
  for i in (hexlen -1) downto 0 loop
    fourbit := longslv(((i*4)+3) downto (i*4));
    case fourbit is
      when "0000" => hex(hexlen -I) := '0';
      when "0001" => hex(hexlen -I) := '1';
      when "0010" => hex(hexlen -I) := '2';
      when "0011" => hex(hexlen -I) := '3';
      when "0100" => hex(hexlen -I) := '4';
      when "0101" => hex(hexlen -I) := '5';
      when "0110" => hex(hexlen -I) := '6';
      when "0111" => hex(hexlen -I) := '7';
      when "1000" => hex(hexlen -I) := '8';
      when "1001" => hex(hexlen -I) := '9';
      when "1010" => hex(hexlen -I) := 'A';
      when "1011" => hex(hexlen -I) := 'B';
      when "1100" => hex(hexlen -I) := 'C';
      when "1101" => hex(hexlen -I) := 'D';
      when "1110" => hex(hexlen -I) := 'E';
      when "1111" => hex(hexlen -I) := 'F';
      when "ZZZZ" => hex(hexlen -I) := 'z';
      when "UUUU" => hex(hexlen -I) := 'u';
      when "XXXX" => hex(hexlen -I) := 'x';
      when others => hex(hexlen -I) := '?';
    end case;
  end loop;
  return hex(1 to hexlen);
end hstr;

   component pna_spi_if
      port (-- System Control Signals
            clk   : in std_logic;
            rst_n : in std_logic;
            -- Internal Bus Interface Signals
            din   : in std_logic_vector(7 downto 0);
            drdy  : out std_logic;
            dout  : out std_logic_vector(7 downto 0);
            -- External SPI Bus Signals
            sck   : in std_logic;
            cs_n  : in std_logic;
            sdi   : in std_logic;
            sdo   : out std_logic);
   end component;

   type STATES is (ST_IDLE, ST_SAMPLE, ST_SHIFT);
   signal state   : STATES;
   signal n_state : STATES;

   signal reg, n_reg : std_logic_vector(8 downto 0);

   signal start_xfer : std_logic;
   signal xfer_done  : std_logic;
   signal xfer_cnt   : std_logic_vector(2 downto 0);
   signal n_xfer_cnt : std_logic_vector(2 downto 0);

   signal tb_clk   : std_logic := '0';
   signal tb_rst_n : std_logic := '0';

   signal sck  : std_logic := '0';
   signal cs_n : std_logic := '0';
   signal sdo  : std_logic;


   signal din    : std_logic_vector(7 downto 0) := x"00";
   signal drdy   : std_logic;
   signal dout   : std_logic_vector(7 downto 0);

   signal tb_start      : std_logic := '0';

   signal tb_di : std_logic_vector(7 downto 0);
   signal tb_si : std_logic_vector(7 downto 0);
   signal tb_so : std_logic_vector(7 downto 0);
   signal tb_do : std_logic_vector(7 downto 0);

begin

   tb_clk   <= NOT(tb_clk) after 5 ns;
   tb_rst_n <= '0', '1' after 20 ns;
   tb_start <= '0', '1' after 30 ns, '0' after 40 ns;

   dut_1: pna_spi_if
      port map(clk   => tb_clk,
               rst_n => tb_rst_n,
               sck   => sck,
               cs_n  => cs_n,
               sdi   => reg(8),
               sdo   => sdo,
               din   => tb_di,
               drdy  => drdy,
               dout  => dout);

   p_ext: process
      variable datai   : std_logic_vector(7 downto 0);
      variable datao   : std_logic_vector(7 downto 0);
      variable compare : std_logic_vector(7 downto 0);

   begin
      start_xfer <= '0';

      cs_n  <= '1';
      tb_di <= (others => '0');
      tb_si <= (others => '0');
      tb_so <= (others => 'U');

      compare := (others => '0');

      wait until tb_start = '1';
      tb_si <= (others => '0');
      tb_di <= (others => '1');
      wait until tb_clk'event AND tb_clk = '1';

      cs_n <= '0';

      for i in 0 to 5 loop
         start_xfer <= '1';
         wait until tb_clk'event AND tb_clk = '1';
         start_xfer <= '0';
         wait until xfer_done = '1';

         wait until tb_clk'event AND tb_clk = '1';
         tb_so <= reg(7 downto 0);
         tb_si <= std_logic_vector(to_unsigned(i+1,8));
         tb_di <= std_logic_vector(to_unsigned(255-i-1,8));
      end loop;

      assert false
         report "TESTBENCH COMPLETE"
         severity failure;

   end process p_ext;

   p_reg: process(tb_clk, tb_rst_n)
   begin
      if tb_rst_n = '0' then
         reg      <= (others => '0');
         xfer_cnt <= (others => '0');
         state    <= ST_IDLE;
      elsif tb_clk'event AND tb_clk = '1' then
         reg      <= n_reg;
         xfer_cnt <= n_xfer_cnt;
         state    <= n_state;
      end if;
   end process p_reg;

   p_xfer: process(state   , tb_si, start_xfer,
                   xfer_cnt, reg    , sdo)
   begin
      case state is
      when ST_IDLE =>
         n_reg      <= tb_si & '0';
         n_xfer_cnt <= "000";
         xfer_done  <= '0';
         sck        <= '0';


         if start_xfer = '1' then
            n_state <= ST_SAMPLE;
         else
            n_state <= ST_IDLE;
         end if;

      when ST_SAMPLE =>
         n_reg      <= reg(8 downto 1) & sdo;
         n_xfer_cnt <= xfer_cnt;
         xfer_done  <= '0';
         sck        <= '1';

         n_state <= ST_SHIFT;

      when ST_SHIFT =>
         n_reg      <= reg(7 downto 0) & '0';
         n_xfer_cnt <= xfer_cnt + 1;
         sck        <= '0';

         if xfer_cnt = "111" then
            n_state   <= ST_IDLE;
            xfer_done <= '1';

         else
            n_state   <= ST_SAMPLE;
            xfer_done <= '0';
         end if;
      end case;
   end process p_xfer;

   -- Loopback the data
   p_int_if: process(tb_clk, tb_rst_n)
   begin
      if tb_rst_n = '0' then
         tb_do <= (others => '0');
      elsif tb_clk'event AND tb_clk = '1' then
         if drdy = '1' then
            tb_do <= dout;
         end if;
      end if;
   end process p_int_if;

end architecture tb;
