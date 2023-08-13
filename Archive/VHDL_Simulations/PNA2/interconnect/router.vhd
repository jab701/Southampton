library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use WORK.NETWORKDEFS.ALL;

entity Router is
  generic ( AddressLength : natural := 16;
            PacketLength : natural := 56);
  port 
  (
     signal clk  : in std_logic;
     signal nrst : in std_logic;
     signal cke  : in std_logic;
     
     -- Router Programming Signals
     signal Route_Table_Clk : in std_logic;
     signal Route_Table_WR : in std_logic;
     signal Route_Table_Address : in std_logic_vector(AddressLength-1 downto 0);
     signal Route_Table_Data : in std_logic_vector(31 downto 0);
     
     -- Router FIFO Signals
     signal Port_Empty : in  std_logic_vector(15 downto 0);
     signal Port_RD    : out std_logic_vector(15 downto 0);
     signal Port_WR    : out std_logic_vector(15 downto 0);
 
     signal FIFO_IN : in std_logic_vector((PacketLength-1) downto 0);
          
     signal FIFO_OUT : out std_logic_vector((PacketLength-1) downto 0)); 
end entity Router;

architecture Behavioural of Router is

signal RouteTable_RD : std_logic;
signal RouteTable_RD_Addr : std_logic_vector(AddressLength-1 downto 0);
signal RouteTable_RD_Data : std_logic_vector(31 downto 0);

signal Route_Valid : std_logic;

signal PipelineStg1_DAT   : std_logic_vector(PacketLength-1 downto 0);
signal PipelineStg2_DAT   : std_logic_vector(PacketLength-1 downto 0);
signal PipelineStg3_DAT   : std_logic_vector(PacketLength-1 downto 0);

signal PipelineStg1_VALID : std_logic;
signal PipelineStg2_VALID : std_logic;
signal PipelineStg3_VALID : std_logic;

begin
  
ROUTE_TABLE:  entity work.async_dp_rw_sram
              generic map(address_width => AddressLength,
                          data_width => 31)
              port map(rclock => clk,
                       rd => '1',
                       addr_read => RouteTable_RD_Addr,
                       data_read => RouteTable_RD_Data,
                       
                       wclock => Route_Table_Clk,
                       we => Route_Table_WR,
                       addr_write => Route_Table_Address,
                       data_write => Route_Table_Data); 

ROUTE_DISPATCH: entity work.RouterDispatcher
                port map(clk => clk,
                         nrst => nrst,
                         cke => cke,
                         Port_Empty => Port_Empty,
                         Port_RD => Port_RD,
                         Valid => Route_Valid);

PIPELINESTG1_SEQ: process (clk) is
begin
  if rising_edge(clk) then
    if (nrst = '0') then
      PipelineStg1_DAT   <= (others => '0');
      PipelineStg1_VALID <= '0';  
    elsif (cke = '1') then
      PipelineStg1_DAT   <= FIFO_IN;
      PipelineStg1_VALID <= Route_Valid;
    end if;
  end if;
end process PIPELINESTG1_SEQ;

-- Decode Pipeline Stage
PIPELINESTG1_COM: process (PipelineStg1_DAT) is
begin
  RouteTable_RD_Addr <= Pipelinestg1_DAT(23 downto 8); 
end process PIPELINESTG1_COM;

PIPELINESTG2_SEQ: process (clk) is
begin
  if rising_edge(clk) then
    if (nrst = '0') then
      PipelineStg2_DAT   <= (others => '0');
      PipelineStg2_VALID <= '0';  
    elsif (cke = '1') then
      PipelineStg2_DAT   <= PipelineStg1_DAT;
      PipelineStg2_VALID <= PipelineStg1_VALID;
    end if;
  end if;
end process PIPELINESTG2_SEQ;  

-- Read Pipeline Stage
PIPELINESTG2_COM: process (cke, RouteTable_RD_Data, PipelineStg2_DAT, PipelineStg2_VALID) is
variable PKT_TYPE : std_logic_vector(7 downto 0);
begin
  PKT_TYPE := PipelineStg2_DAT(7 downto 0);
  
  FIFO_OUT <= PipelineStg2_DAT;
  
  if ((PipelineStg2_VALID = '1') AND (cke = '1')) then
    if (PKT_TYPE = TYPE_AP) then -- Address was a source address
      Port_WR <= RouteTable_RD_Data(15 downto 0);
    else -- Address is a target address
      Port_WR <= RouteTable_RD_Data(31 downto 16);
    end if;     
  else
    Port_WR <= (others => '0');    
  end if;
end process PIPELINESTG2_COM;
end architecture Behavioural;


