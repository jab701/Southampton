----------------------------------------------------------------------------------
-- Company: 	ESD Group, School of Electronics, University Of Southampton
-- Engineer:	Julian A Bailey <jab@ecs.soton.ac.uk>
-- 
-- Create Date:  26th October 2010
-- Project Name: LibNeuron 2.0
-- Module Name:  
-- Description:  
--
-- Dependencies: None
--
-- Revision: 1.00 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library PNA_LibNeuron_com;
library Memory_Controller;

entity neuron2_pu is
  generic 
  (
     -- Module Specific Configuration Parameters
     address_width : natural := 4
  );
  port 
  (
     signal clock   : in  std_logic;
     signal nreset  : in std_logic;
     signal ce      : in std_logic;
     
     signal Trigger : in std_logic;
     signal Running : out std_logic;
     
     signal BankSelect   : in std_logic;
     
     signal NumNeurons : in std_logic_vector((address_width-1) downto 0);
     
     signal Param_Write : in std_logic_vector(135 downto 0);
     signal Param_Write_Addr : in std_logic_vector((address_width-1) downto 0);
     signal Param_We   : in std_logic;

     signal Enable_Write : in std_logic;
     signal Enable_Write_Addr : in std_logic_vector((address_width-1) downto 0);
     signal Enable_We : in std_logic;
          
     signal pu_addrunit_out : out std_logic_vector((address_width-1) downto 0);
     signal pu_we_out : out std_logic;
     
     signal PhaseEnable : in std_logic; 
     signal Axon_Out : out std_logic
   ); 
end entity neuron2_pu;

architecture Behavioural of neuron2_pu is
signal nReset_ex_pu : std_logic;
signal nReset_ex : std_logic;

signal pu_address : std_logic_vector((address_width-1) downto 0);
signal pu_address_buffer : std_logic_vector((address_width-1) downto 0); 
signal pu_we : std_logic;

signal AddrUnit_Running : std_logic;
signal AddrUnit_Go : std_logic;

signal AP_ON  : std_logic;
signal AP_OFF : std_logic;

signal mem_write_addr : std_logic_vector(address_width-1 downto 0);
signal mem_write_data : std_logic_vector(135 downto 0);

signal phase_mem_we : std_logic;
signal enable_mem_we : std_logic;
signal param_mem_we : std_logic;

signal enable_mem_read : std_logic;
signal param_mem_read  : std_logic_vector(135 downto 0);
signal state_mem_read  : std_logic_vector(80 downto 0);
signal phase_mem_read  : std_logic;

signal state_mem_write : std_logic_vector(80 downto 0);

begin
nReset_ex <= nReset_ex_pu AND enable_mem_read;

process (Clock) is
begin
  if (rising_edge(Clock)) then
    if (ce = '1') then
      pu_address_buffer <= pu_address;
    end if;
  end if;    
end process;

N2_PHASE_MEM: entity Memory_Controller.dp_rw_sram
   generic map(address_width => address_width,
               data_width => 1)
   port map(Clock => Clock,
            we => phase_mem_we,
            rd => '1',
            addr_read => pu_address,
            addr_write => mem_write_addr,
            data_read(0) => phase_mem_read,
            data_write(0) => mem_write_data(0));
            
N2_ENABLE_MEM:entity Memory_Controller.dp_rw_sram
   generic map(address_width => address_width,
               data_width => 1)
   port map(Clock => Clock,
            we => enable_mem_we,
            rd => '1',
            addr_read => pu_address,
            addr_write => mem_write_addr,
            data_read(0) => enable_mem_read,
            data_write(0) => mem_write_data(0));

N2_PARAM_MEM:entity Memory_Controller.dp_rw_sram
   generic map(address_width => address_width,
               data_width => 135)
   port map(Clock => Clock,
            we => param_mem_we,
            rd => '1',
            addr_read => pu_address,
            addr_write => mem_write_addr,
            data_read => param_mem_read,
            data_write => mem_write_data);
                         
N2_STATE_MEM: entity Memory_Controller.dp_rw_sram
   generic map(address_width => address_width,
               data_width => 80)
   port map(Clock => Clock,
            we => pu_we,
            rd => '1',
            addr_read => pu_address,
            addr_write => pu_address_buffer,
            data_read => state_mem_read,
            data_write => state_mem_write);
	         
pu_controller_1: entity work.pu_controller
                 port map(Clock   => Clock,
                          nReset  => nReset,
                          ce => ce,
                          
                          Trigger => Trigger,
                          AddrUnit_Running => AddrUnit_Running,
                          
                          Running => Running,
                          nReset_Ex   => nReset_ex_pu,
                          AddrUnit_Go => AddrUnit_Go);
                            
address_unit1: entity work.neuronaddressunit
               generic map(Address_Width =>address_width)
               port map(Clock => Clock,
                        nReset => nReset,
                        ce => ce,
                        Go => AddrUnit_Go,
                        AddressMax => NumNeurons,
                        Address => pu_Address,
                        we => pu_we,
                        Running => AddrUnit_Running);
                          
-- execution pipeline phase
neuron2_ex: entity PNA_LibNeuron_com.Neuron2_com
            generic map(32)
            port map(-- System Control Input Signals
                     nReset  => nReset_ex,
                     -- Register Inputs
                     Reg_In  => state_mem_read,
                     -- Register Outputs  
                     Reg_Out => state_mem_write,
                     -- Static Parameters
                     Parameters => param_mem_read,
                     Phase_Enable   => phase_mem_read,
                      -- Combinatorial Output Signals
                     AP_ON => AP_ON,
                     AP_OFF => AP_OFF);


end architecture Behavioural;


