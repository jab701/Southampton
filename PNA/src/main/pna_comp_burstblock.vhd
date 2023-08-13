library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pna_comp_burstblock  is
    generic(RESOLUTION       : natural := 32);
    port (clk         : in  std_logic;
          rst_n        : in  std_logic;
          tick        : in  std_logic;
          abvthlde    : in  std_logic;
          belthldi    : in  std_logic;
          oscin       : in  std_logic;
          burstlength : in  std_logic_vector(7 downto 0);
          aptime      : in  std_logic_vector((RESOLUTION - 1) downto 0);
          reftime     : in  std_logic_vector((RESOLUTION - 1) downto 0);
          axon        : out std_logic);
end pna_comp_burstblock;

architecture rtl of pna_comp_burstblock is

-- COMPONENT DEFINITIONS
   component pna_comp_timer
   generic( RESOLUTION : natural);
   port(clk      : in std_logic;
        rst_n     : in std_logic;
        tick     : in std_logic;
        start    : in std_logic;
        period   : in std_logic_vector((RESOLUTION - 1) downto 0);
        finished : out std_logic);
   end pna_comp_timer;

-- TYPE DEFINITIONS
   type STATES is (ST_OFF, ST_ON, ST_DEC, ST_REF);

-- CONSTANTS
   signal ZERO   : signed(7 downto 0) := (others => '0');
   signal MINUS1 : signed(7 downto 0) := (others => '1');

-- SIGNAL DEFINITIONS
   -- State Machine Signals
   signal state   : STATES;
   signal n_state : STATES;

   -- Burst Signals
   signal burstcount   : signed(7 downto 0);
   signal n_burstcount : signed(7 downto 0);

   -- Timer Signals
   signal timerstart : std_logic;
   signal timerfinish : std_logic;
   signal timerperiod : std_logic_vector((RESOLUTION - 1) downto 0);

begin

i_timer: pna_comp_timer(rtl)
   generic map (RESOLUTION => RESOLUTION)
   port map(clk      => clk,
            rst_n     => rst_n,
            tick     => tick,
            start    => timerstart,
            period   => timerperiod,
            finished => timerfinish);

p_seq: process(clk, rst_n) is
begin
   if (rst_n = '0') then
      state      <= STATE_OFF;
      burstcount <= (others => '0');
   elsif (clk'event and clk = '1') then
      state      <= n_state;
      burstcount <= n_burstcount;
   end if
end process p_seq;

p_com: process(abvthlde, belthldi, oscin, aptime, reftime, timerfinish, n_state, n_burstcount) is

begin
  case state is
  when ST_OFF =>
     axon <= '0';
     timerperiod  <= aptime - 1;
     n_burstcount <= burstlength;

     if abvthlde = '1' OR oscin = '1' then
        timerstart <= '1';
        n_state    <= ST_ON;
     else
        timerstart <= '0';
        n_state    <= ST_OFF;
     end if;

  when ST_ON =>
     axon <= '1';
     n_burstcount <= burstcount;

     timerstart  <= '0';
     timerperiod <= reftime - 1;

     if timerfinished = '1' then
        n_state    <= ST_DEC;
     else
        n_state    <= ST_DEC;
     end if;

     if belthldi = '1' then
        n_burstcount  <= ZERO;
     else
        n_bburstcount <= burstcount;
     end if;

  when ST_DEC =>
     axon <= '0';

     timerstart  <= '1'
     timerperiod <= reftime - 1;

     if (belthldi = '1') then
        n_burstcount <= ZERO;
     elsif (burstcount = MINUS1) then
        n_burstcount <= burstcount;
     else
        n_burstcount <= burstcount - 1;
     end if;

     n_state <= ST_REF;

  when ST_REF =>
     axon <= '0';

     timerperiod <= aptime - 1;

     if (belinthld = '1') then
        n_burstcount <= ZERO;
     else
        n_burstcount <= burstcount;
     end if;


     if timerfinished = '1' then
        if burstcount = ZERO then
           n_state    <= ST_OFF;
           timerstart <= '0';
        else
           n_state    <= ST_ON;
           timerstart <= '1';
        end if;
     else
        n_state    <= ST_REF;
        timerstart <= '0';
     end if;
  end case;

end process p_com;
end architecture rtl;



