library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pna_config_pack.ALL;
use work.pna_sys_pack.ALL;

entity pna_sys is
    port (signal sys_clk    : in  std_logic;
          signal sys_rst_n  : in  std_logic;
          signal sys_rst_o  : out std_logic;
          signal tick_1us_o : out std_logic;
          signal tick_1ms_o : out std_logic;
          -- Bus Interface
          signal sck    : in  std_logic;
          signal cs_n   : in  std_logic;
          signal si    : in  std_logic;
          signal so   : out std_logic);
end pna_sys;

architecture rtl of pna_sys is

--{{ Components Section
component pna_sys_timer
    port (signal clk       : in  std_logic;
          signal rst_n     : in  std_logic;
          signal halt      : in std_logic;
          signal restart   : in std_logic;
          signal tick_1us  : out std_logic;
          signal tick_1ms  : out std_logic);
end component;

component pna_spi_if
   port (clk   : in std_logic;
         rst_n : in std_logic;
         din   : in std_logic_vector(7 downto 0);
         drdy  : out std_logic;
         dout  : out std_logic_vector(7 downto 0);
         sck   : in std_logic;
         cs_n  : in std_logic;
         sdi   : in std_logic;
         sdo   : out std_logic);
end component;

component pna_spi_control
   port (clk         : in std_logic;
         rst_n       : in std_logic;
         sys_status  : in  std_logic_vector(7 downto 0);
         sys_ctrl_i  : in  std_logic_vector(7 downto 0);
         sys_ctrl_o  : out std_logic_vector(7 downto 0);
         sys_ctrl_wr : out std_logic_vector(7 downto 0);
         sys_addr    : out std_logic_vector(11 downto 0);
         sys_wr      : out std_logic;
         sys_din     : in  std_logic_vector(31 downto 0);
         sys_dout    : out std_logic_vector(31 downto 0);
         spi_cs_n    : in std_logic;
         spi_drdy    : in std_logic;
         spi_din     : in std_logic_vector(7 downto 0);
         spi_dout    : out std_logic_vector(7 downto 0));
end component;

component pna_comp_input
   generic(CONFIG_ADDR : integer := 0);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        --
        config_addr     : in  std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
        config_wr       : in  std_logic;
        config_di       : in  std_logic_vector(31 downto 0);
        config_do       : out std_logic_vector(31 downto 0);
        --
        sys_addr        : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
        sys_data_out    : out std_logic_vector(0 downto 0));
end component;

component pna_comp_output
   generic(CONFIG_ADDR : integer := 0);
   port(clk    : in std_logic;
        rst_n   : in std_logic;
        --
        config_addr     : in  std_logic_vector(CONF_ADDR_WIDTH-1 downto 0);
        config_wr       : in  std_logic;
        config_di       : in  std_logic_vector(31 downto 0);
        config_do       : out std_logic_vector(31 downto 0);
        --
        sys_addr        : in  std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
        sys_data_in     : in  std_logic_vector(0  downto 0));
end component;

component pna_comp_neuron
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
        sys_data_in     : in  std_logic_vector(BUS_I_N_WIDTH-1  downto 0);
        sys_data_out    : out std_logic_vector(BUS_O_N_WIDTH-1  downto 0));
end component;

component pna_comp_patterngen
   generic(CONFIG_ADDR          : integer := 0);
   port(clk    : in std_logic;
        rst_n  : in std_logic;
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
end component;

component pna_comp_synapse
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
end component;
--}}

--{{ Types Section
   type type_syn_link_o is array(NUM_SYNAPSE downto 0) of std_logic_vector(SYNAPSE_WIDTH-1 downto 0);
--}}

--{{ Constants
   constant NUM_CONF_ADDR_INOUT : integer := (2**SYS_ADDR_WIDTH)/32);
   constant CONF_ADDR_INPUT     : integer := 8;
   constant CONF_ADDR_OUTPUT    : integer := CONF_ADDR_INPUT  + NUM_CONF_ADDR_INOUT;
   constant CONF_ADDR_NEURON    : integer := CONF_ADDR_OUTPUT + NUM_CONF_ADDR_INOUT;
   constant CONF_ADDR_PG        : integer := CONF_ADDR_NEURON + (NUM_NEURONS*4);
   constant CONF_ADDR_SYN       : integer := CONF_ADDR_PG     + (NUM_PATTERN*4);
   constant CONF_ADDR_MAX       : integer := CONF_ADDR_SYN    + (NUM_SYNAPSE*4);
--}}

--{{ Signals Section
--{{ Control Register
   signal sys_ctrl     : std_logic_vector(7 downto 0);
   signal n_sys_ctrl   : std_logic_vector(7 downto 0);
   signal sys_spi_ctrl : std_logic_vector(7 downto 0);
   signal sys_ctrl_wr  : std_logic;
--}}

   signal sys_status  : std_logic_vector(7 downto 0);

--{{ Timer Signals
   signal halt     : std_logic;
   signal restart  : std_logic;
   signal tick_1us : std_logic;
   signal tick_1ms : std_logic;
--}}

--{{ SPI Signals
   signal if_di    : std_logic_vector(7 downto 0);
   signal if_do    : std_logic_vector(7 downto 0);
   signal if_drdy  : std_logic;
   signal conf_din  : std_logic_vector(31 downto 0);
   signal conf_dout : std_logic_vector(31 downto 0);
   signal conf_addr : std_logic_vector(11 downto 0);
   signal conf_wr   : std_logic;
--}}
   signal bus_addr   : std_logic_vector(SYS_ADDR_WIDTH-1 downto 0);
   signal ns_bus     : std_logic_vector(0 downto 0);
   signal sn_bus     : std_logic_vector(BUS_I_N_WIDTH-1 downto 0);
   signal syn_i_link : std_logic_vector(NUM_SYNAPSE downto 0);
   signal syn_o_link : type_syn_link_o;
--}}

begin
--{{ Control Register
   p_ctrl_reg: process (clk, rst_n)
   begin
      if rst_n = '0' then
         sys_ctrl <= "00000000";
      elsif rising_edge(clk) then
         sys_ctrl <= n_sys_ctrl;
      end if;
   end process p_ctrl_reg;

   p_ctrl_com: process (sys_ctrl, sys_spi_ctrl, sys_ctrl_wr)
   begin
      if sys_ctrl_wr = '1' then
         n_sys_ctrl <= sys_spi_ctrl;
      else
         n_sys_ctrl <= sys_ctrl;
      end if;
   end process p_ctrl_com;
--}}
--{{ Configuration Registers
   p_creg_reg: process()
   begin

   end process p_creg_reg;

   p_creg_com: process()
   begin

   end process p_creg_com;
--}}
--{{ System Timer
   i_timer: pna_sys_timer
      port map(clk      => clk,
               rst_n    => rst_n,
               halt     => sys_ctrl(RCTRL_HALT),
               restart  => restart,
               tick_1us => tick_1us,
               tick_1ms => tick_1ms);
--}}
--{{ SPI Interface
   i_pna_if: pna_spi_if
      port map(clk   => clk,
               rst_n => rst_n,
               din   => if_din,
               drdy  => if_drdy,
               dout  => if_dout,
               sck   => sck,
               cs_n  => cs_n,
               sdi   => si,
               sdo   => so);

   i_pna_ctrl: pna_spi_control
      port map(clk         => clk,
               rst_n       => rst_n,
               sys_status  => sys_status,
               sys_ctrl_i  => sys_ctrl,
               sys_ctrl_o  => sys_spi_ctrl,
               sys_ctrl_wr => sys_ctrl_wr,
               sys_addr    => conf_addr,
               sys_wr      => conf_wr,
               sys_din     => conf_din,
               sys_dout    => conf_dout,
               spi_cs_n    => spi_cs_n,
               spi_drdy    => if_drdy,
               spi_din     => if_din,
               spi_dout    => if_dout);
--}}
--{{ Address Unit
   p_addrunit_reg: process()
   end process p_addrunit_reg;

   p_addrunit_com: process()
   end process p_addrunit_com;
--}}
--{{ Input Units
   i_pna_input: pna_comp_input
      generic map(CONFIG_ADDR => CONF_ADDR_INPUT)
      port map(clk          => clk,
               rst_n        => rst_n,
               --
               config_addr  => conf_addr,
               config_wr    => conf_wr,
               config_di    => conf_dout,
               config_do    => conf_din,
               --
              sys_addr     => bus_addr,
              sys_data_out => sn_bus(BUS_I_N_WIDTH));
--}}
--{{ Output Units
   i_pna_output: pna_comp_output
      generic map(CONFIG_ADDR => CONF_ADDR_OUTPUT)
      port map(clk          => clk,
               rst_n        => rst_n,
               --
               config_addr  => conf_addr,
               config_wr    => conf_wr,
               config_di    => conf_dout,
               config_do    => conf_din,
               --
               sys_addr     => bus_addr,
               sys_data_in  => ns_bus(0));
--}}
--{{ Neurons
   g_neuron: for i in 0 to NUM_NEURONS-1 generate
      i_pna_neuron: pna_comp_neuron
         generic map(CONFIG_ADDR => CONF_ADDR_NEURON + i)
         port map(clk          => clk,
                  rst_n        => rst_n,
                  tick         => tick_1us,
                  --
                  config_addr  => conf_addr,
                  config_wr    => conf_wr,
                  config_di    => conf_dout,
                  config_do    => conf_din,
                  --
                  sys_addr     => bus_addr,
                  sys_data_in  => sn_bus,
                  sys_data_out => ns_bus);
   end generate g_neuron;
--}}
--{{ Pattern Generators
   g_pattern: for i in 0 to NUM_PATTERN-1 generate
      i_pna_pattern: pna_comp_patterngen
         generic map(CONFIG_ADDR => CONF_ADDR_PG + i)
         port map(clk          => clk,
                  rst_n        => rst_n,
                  tick         => tick_1us,
                  --
                  config_addr  => conf_addr,
                  config_wr    => conf_wr,
                  config_di    => conf_dout,
                  config_do    => conf_din,
                  --
                  sys_addr     => bus_addr,
                  sys_data_in  => sn_bus,
                  sys_data_out => ns_bus);
   end generate g_pattern;
--}}
--{{ Synapses
   syn_i_link(0) <= '0';
   syn_o_link(0) <= (others => '0');

   g_synapse: for i in 0 to NUM_SYNAPSE-1 generate
      i_synapse: pna_comp_synapse
         generic map(CONFIG_ADDR => CONF_ADDR_SYN + i)
         port map(clk          => clk,
                  rst_n        => rst_n,
                  tick         => tick_1us,
                  --
                  config_addr  => conf_addr,
                  config_wr    => conf_wr,
                  config_di    => conf_dout,
                  config_do    => conf_din,
                  --
                  sys_addr     => bus_addr,
                  sys_data_in  => ns_bus,
                  sys_data_out => sn_bus(SYNAPSE_WIDTH-1 downto 0),
                  --
                  syn_i_link_i => syn_i_link(i),
                  syn_i_link_o => syn_i_link(i+1),
                  syn_o_link_i => syn_o_link(i),
                  syn_o_link_o => syn_o_link(i+1));
   end generate g_synapse;

--}}
end architecture rtl;
