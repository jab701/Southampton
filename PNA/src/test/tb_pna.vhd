library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.pna_config_pack.ALL;
use work.pna_sys_pack.ALL;

entity tb_pna_sys is

end tb_pna_sys;

architecture tb of tb_pna_sys is

--{{ Components Section
   component pna_sys
      port (signal sys_clk    : in  std_logic;
            signal sys_rst_n  : in  std_logic;
            signal sys_rst_o  : out std_logic;
            signal tick_1us_o : out std_logic;
            signal tick_1ms_o : out std_logic;
            -- Bus Interface
            signal sck        : in  std_logic;
            signal cs_n       : in  std_logic;
            signal si         : in  std_logic;
            signal so         : out std_logic);
   end component;
--}}

--{{ Types Section
--}}

--{{ Signals Section

--}}

begin


end architecture rtl;
