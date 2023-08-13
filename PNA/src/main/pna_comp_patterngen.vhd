library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use pna_config_pack.ALL;
use pna_pack.ALL;

entity pna_comp_patterngen is
   generic(CONFIG_ADDR          : integer := 0);
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
        sys_data_in     : in  std_logic_vector(BUS_I_PG_WIDTH-1 downto 0);
        sys_data_out    : out std_logic_vector(BUS_O_PG_WIDTH-1 downto 0));
end pna_comp_patterngen;

architecture rtl of pna_comp_patterngen is

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

   component pna_comp_oscillator is
      generic (RESOLUTION : natural := 32);
      port (-- Global Input Signals
            clk           : in std_logic;
            rst_n          : in std_logic;
            tick          : in std_logic;
            phaseoffseten : in std_logic;
            -- Module Specific Parameters
            period        : in std_logic_vector((RESOLUTION - 1) downto 0);
            phase         : in std_logic_vector((RESOLUTION - 1) downto 0);
            -- Module Specific Output Signals
            oscout        : out std_logic);
   end component pna_comp_oscillator;

   -- libpna_burstblock
   component pna_comp_burstblock
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
   end component pna_comp_burstblock;

-- SIGNAL DEFINITIONS
   signal sampled_din    : std_logic_vector(0 downto 0);
   -- Reset & Enable Logic
   signal rst_en     : std_logic;
   signal axon       : std_logic;

   -- Configuration Data
   signal config   : std_logic_vector(127 downto 0);

   -- Oscillator Block Output
   signal osc_output : std_logic;
begin
   rst_en <= rst_n AND sampled_din(sampled_din'high);

i_busin: pna_comp_bus_input
   generic(ADDRESS_WIDTH => SYS_ADDR_WIDTH,
           DATA_WIDTH    => BUS_I_PG_WIDTH);
      port (clk       => clk,
            rst_n      => rst_n,
            conf_addr => config(PG_CONF_ADDRESS_HI downto PG_CONF_ADDRESS_LO),
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

i_osc: pna_comp_oscillator
   generic map(RESOLUTION => PG_TIMER_WIDTH)
   port map(-- Global Input Signals
            clk           => clk,
            rst_n          => rst_en,
            tick          => tick,
            phaseoffseten => config(PG_CONF_PHASE_EN),
            -- Module Specific Parameters
            period        => config(PG_CONF_PERIOD_HI downto PG_CONF_PERIOD_LO),
            phase         => config(PG_CONF_PHASE_HI  downto PG_CONF_PHASE_LO),
            -- Module Specific Output Signals
            oscout        => osc_output);

i_burst: pna_comp_burstblock
   generic map(RESOLUTION => N_TIMER_WIDTH)
   port map (clk         => clk,
             rst_n        => rst_en,
             tick        => tick,
             abvthlde    => '0',
             belthldi    => '0',
             oscin       => osc_output,
             burstlength => config(PG_CONF_BURST_HI downto PG_CONF_BURST_LO),
             aptime      => config(PG_CONF_AP_HI    downto PG_CONF_AP_LO),
             reftime     => config(PG_CONF_REF_HI   downto PG_CONF_REF_LO),
             axon        => axon);

i_busout: pna_comp_bus_output
   generic map(ADDRESS_WIDTH => SYS_ADDR_WIDTH,
               DATA_WIDTH    => BUS_O_PG_WIDTH);
   port map (conf_addr  => config(PG_CONF_ADDRESS_HI downto PG_CONF_ADDRESS_LO),
             addr_in    => sys_addr,
             data_in(0) => axon,
             data_out   => sys_data_out);

end architecture rtl;
