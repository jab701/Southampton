library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use pna_config_pack.ALL;

package pna_pack is

constant BUS_I_N_WIDTH  : integer := SYNAPSE_WIDTH + 1;
constant BUS_I_PG_WIDTH : integer := 1;
constant BUS_I_S_WIDTH  : integer := 1;

constant BUS_O_N_WIDTH  : integer := 1;
constant BUS_O_PG_WIDTH : integer := 1;
constant BUS_O_S_WIDTH  : integer := SYNAPSE_WIDTH;

-- Neuron
constant N_CONF_ADDRESS_LO  : integer := 0;
constant N_CONF_ADDRESS_HI  : integer := SYS_ADDR_WIDTH - 1;
constant N_CONF_EXTHLD_LO   : integer := N_CONF_ADDRESS_HI + 1;
constant N_CONF_EXTHLD_HI   : integer := N_CONF_EXTHLD_LO + SYNAPSE_WIDTH - 1;
constant N_CONF_INTHLD_LO   : integer := N_CONF_EXTHLD_HI + 1;
constant N_CONF_INTHLD_HI   : integer := N_CONF_INTHLD_LO + SYNAPSE_WIDTH - 1;
constant N_CONF_AP_LO       : integer := N_CONF_INTHLD_HI + 1;
constant N_CONF_AP_HI       : integer := N_CONF_AP_LO + N_TIMER_WIDTH - 1;
constant N_CONF_REF_LO      : integer := N_CONF_AP_HI + 1;
constant N_CONF_REF_HI      : integer := N_CONF_REF_LO + N_TIMER_WIDTH - 1;
constant N_CONF_BURST_LO    : integer := N_CONF_REF_HI + 1;
constant N_CONF_BURST_HI    : integer := N_CONF_BURST_LO + 7;

-- Pattern Generator
constant PG_CONF_ADDRESS_LO : integer := 0;
constant PG_CONF_ADDRESS_HI : integer := SYS_ADDR_WIDTH - 1;
constant PG_CONF_PHASE_EN   : integer := PG_CONF_ADDR_HI + 1;
constant PG_CONF_PERIOD_LO  : integer := PG_CONF_PHASE_EN + 1;
constant PG_CONF_PERIOD_HI  : integer := PG_CONF_PERIOD_LO + PG_TIMER_WIDTH - 1;
constant PG_CONF_PHASE_LO   : integer := PG_CONF_PERIOD_HI + 1;
constant PG_CONF_PHASE_HI   : integer := PG_CONF_PHASE_LO + PG_TIMER_WIDTH - 1;
constant PG_CONF_AP_LO      : integer := PG_CONF_PHASE_HI + 1;
constant PG_CONF_AP_HI      : integer := PG_CONF_AP_LO + N_TIMER_WIDTH - 1;
constant PG_CONF_REF_LO     : integer := PG_CONF_AP_HI + 1;
constant PG_CONF_REF_HI     : integer := PG_CONF_REF_LO + N_TIMER_WIDTH - 1;
constant PG_CONF_BURST_LO   : integer := PG_CONF_REF_HI + 1;
constant PG_CONF_BURST_HI   : integer := PG_CONF_BURST_LO + 7;

-- Synapse
constant S_CONF_PREADDR_LO  : integer := 0;
constant S_CONF_PREADDR_HI  : integer := SYS_ADDR_WIDTH - 1;
constant S_CONF_POSADDR_LO  : integer := S_CONF_PREADDR_HI + 1;
constant S_CONF_POSADDR_HI  : integer := S_CONF_POSADDR_LO + SYS_ADDR_WIDTH - 1;
constant S_CONF_DELAY_LO    : integer := S_CONF_POSADDR_HI + 1;
constant S_CONF_DELAY_HI    : integer := S_CONF_DELAY_LO + SYN_TIMER_WIDTH - 1;
constant S_CONF_DURAT_LO    : integer := S_CONF_DELAY_HI + 1;
constant S_CONF_DURAT_HI    : integer := S_CONF_DURAT_LO + SYN_TIMER_WIDTH - 1;
constant S_CONF_WEIGHT_LO   : integer := S_CONF_DURAT_HI + 1;
constant S_CONF_WEIGHT_HI   : integer := S_CONF_WEIGHT_LO + SYNAPSE_WIDTH - 1;
constant S_CONF_LINK_LO     : integer := S_CONF_WEIGHT_HI + 1;
constant S_CONF_LINK_HI     : integer := S_CONF_LINK_LO + 1;

end package pna_pack;
