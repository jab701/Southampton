library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use pna_config_pack.ALL;
use pna_pack.ALL;

entity pna_comp_synapse is
   generic(CONFIG_ADDR : integer := 0);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        tick   : in std_logic;
        --
        config_addr     : in  std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
        config_wr       : in  std_logic;
        config_di       : in  std_logic_vector(31 downto 0);
        config_do       : out std_logic_vector(31 downto 0);
        --
        sys_addr        : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
        sys_data_in     : in  std_logic_vector(BUS_I_S_WIDTH-1  downto 0);
        sys_data_out    : out std_logic_vector(BUS_O_S_WIDTH-1  downto 0);
        --
        syn_i_link_i   : in  std_logic;
        syn_i_link_o   : out std_logic;
        syn_o_link_i   : in  std_logic_vector(BUS_O_S_WIDTH-1 downto 0);
        syn_o_link_o   : out std_logic_vector(BUS_O_S_WIDTH-1 downto 0));
end pna_comp_synapse;

architecture rtl of pna_comp_synapse is

-- COMPONENT DEFINITIONS
   component pna_comp_bus_input is
      generic(ADDRESS_WIDTH  : integer := 8;
              DATA_WIDTH     : integer := 8);
      port (clk       : in  std_logic;
            rst_n      : in  std_logic;
            unit_addr : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            bus_addr  : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data_in   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0));
   end pna_comp_bus_input;

   component pna_comp_bus_output is
      generic(ADDRESS_WIDTH  : integer := 8;
              DATA_WIDTH     : integer := 8);
      port (unit_addr : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            bus_addr  : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data_in   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0));
   end pna_comp_bus_output;

   component pna_comp_configuration is
      generic(CONF_ADDRESS : integer := 0);
      port( clk     : in std_logic;
            rst_n    : in std_logic;
            address : in  std_logic_vector(11 downto 0);
            wr      : in  std_logic;
            di      : in  std_logic_vector(31 downto 0);
            do      : out std_logic_vector(31 downto 0);
            config  : out std_logic_vector(31 downto 0));
   end component pna_comp_configuration;

   component pna_comp_timer
   generic( RESOLUTION : natural);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        tick   : in std_logic;
        start    : in std_logic;
        period   : in std_logic_vector((RESOLUTION - 1) downto 0);
        finished : out std_logic);
   end pna_comp_timer;

-- TYPE DEFINITIONS
   type STATES is (STATE_IDLE, STATE_DELAY, STATE_ACTIVE);

-- SIGNAL DEFINITIONS
   -- Bus input
   signal sampled_din : std_logic_vector(BUS_I_S_WIDTH-1 downto 0);
   -- Configuration Data
   signal config   : std_logic_vector(127 downto 0);

   -- Synapse Specific Signal
   signal idlen       : std_logic;
   signal axon        : std_logic;
   signal delay       : std_logic_vector(SYN_TIMER_WIDTH - 1 downto 0);
   signal duration    : std_logic_vector(SYN_TIMER_WIDTH - 1 downto 0);
   signal synweight_i : std_logic_vector(SYNAPSE_WIDTH - 1 downto 0);
   signal synweight_o : std_logic_vector(SYNAPSE_WIDTH - 1 downto 0);
   signal synweight_s : std_logic_vector(SYNAPSE_WIDTH - 1 downto 0);

   -- State Machine Signals
   signal state : STATES;
   signal n_state : STATES;

   -- Axon Edge Detect Signals
   signal axon_sample : std_logic;

   -- Timer Signals
   signal timerstart : std_logic;
   signal timerfinish : std_logic;
   signal timerperiod : std_logic_vector((TIMERESOLUTION - 1) downto 0);


begin

   i_busin: pna_comp_bus_input
      generic(ADDRESS_WIDTH => SYS_ADDR_WIDTH,
              DATA_WIDTH    => BUS_I_S_WIDTH);
         port (clk       => clk,
               rst_n      => rst_n,
               conf_addr => config(S_CONF_PREADDR_HI downto S_CONF_PREADDR_LO),
               addr_in   => sys_addr,
               data_in   => sys_data_in,
               data_out  => sampled_din);

   i_config: pna_comp_configuration
      generic map(CONF_ADDRESS => CONF_ADDRESS)
      port map(clk     => clk,
               rst_n    => rst_n,
               address => config_addr,
               wr      => config_wr,
               di      => config_di,
               do      => config_do,
               config  => config);

   i_busout: pna_comp_bus_output
      generic map(ADDRESS_WIDTH => SYS_ADDR_WIDTH,
                  DATA_WIDTH    => BUS_O_S_WIDTH);
      port map (conf_addr  => config(S_CONF_POSADDR_HI downto S_CONF_POSADDR_LO),
                addr_in    => sys_addr,
                data_in(0) => synweight_s,
                data_out   => sys_data_out);

   i_timer: pna_comp_timer(rtl)
      generic map (RESOLUTION => TIMERESOLUTION)
      port map(clk      => clk,
               rst_n     => rst_n,
               tick     => tick,
               start    => timerstart,
               period   => timerperiod,
               finished => timerfinish);

   p_input: process(sampled_din, config, idlen, syn_i_link_i)
   begin
      if config(S_CONF_LINK_LO) = '1' then
         axon         <= syn_i_link_i;
         syn_i_link_o <= idlen AND syn_i_link_i;
      else
         axon <= sampled_din(0);
      end if;
   end process p_input;

   p_output: process (synweight_o, config, syn_o_link_i)
      variable sum : unsigned(synweight_o'range);
   begin
      if config(S_CONF_LINK_HI) = '1' then
         sum := synweight_o + syn_o_link_i;
      else
         sum := synweight_o;
      end if;

      synweight_s  <= sum;
      syn_o_link_o <= sum;
   end process p_output;

   delay       <= config(S_CONF_DELAY_HI downto S_CONF_DELAY_LO);
   duration    <= config(S_CONF_DURAT_HI downto S_CONF_DURAT_LO);
   synweight_i <= config(S_CONF_WEIGHT_HI downto S_CONF_WEIGHT_LO);

   p_seq: process (clk, rst_n) is
   begin
      if (rst_n = '0') then
         axon_sample <= '0';
         state <= STATE_IDLE;
      elsif (clk'event AND clk = '1') then
         axon_sample <= axon;
         state <= n_state;
      end if;
   end process p_seq;

   p_com: process(state, delay, duration, synweight_i, axon, axon_sample, timerfinish) is
   begin
      case state is
      when STATE_IDLE =>
         idlen <= '0';
         timerperiod <= delay;
         synweight_o <= (others => '0');

         if ((axon = '1') and (axon_sample = '0')) then
            timerstart <= '1';
            n_state <= STATE_DELAY;
         else
            timerstart <= '0';
            n_state <= STATE_IDLE;
         end if

      when STATE_DELAY =>
         idlen <= '1';
         timerperiod <= duration;
         synweight_o <= (others => '0');

         if (timerfinished = '1') then
            timerstart = '1';
            n_state <= STATE_DURATION;
         else
            timerstart <= '0';
            n_state <= STATE_DELAY;
         end if;

      when STATE_ACTIVE =>
         idlen <= '1';
         timerperiod <= delay;
         synweight_o <= synweight_i;
         timerstart <= '0';

         if (timerfinished = '1') then
            n_state <= STATE_IDLE;
         else
            n_state <= STATE_DURATION;
         end if;
      end case;
   end process p_com;

end architecture rtl;

