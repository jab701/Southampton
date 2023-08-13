library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package pna_config_pack is

constant NUM_NEURONS : integer := 100;
constant NUM_PATTERN : integer := 16;
constant NUM_SYNAPSE : integer := 200;

constant CONF_ADDR_WIDTH : integer := 12;
constant SYS_ADDR_WIDTH  : integer := 8;

constant SYNAPSE_WIDTH   : integer := 8;

constant N_TIMER_WIDTH   : integer := 16;
constant PG_TIMER_WIDTH  : integer := 32;
constant SYN_TIMER_WIDTH : integer := 32;

constant SYS_TIMER_WIDTH : integer := 7;
constant SYS_TIMER_1US   : integer := 100;

end package pna_config_pack;
