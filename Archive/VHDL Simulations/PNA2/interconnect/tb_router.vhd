library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;

entity tb_router
  generic ( AddressLength : natural := 16;
            PacketLength : natural := 56);
end entity tb_router;

architecture Behavioural of tb_router is

signal clock   : std_logic := '1';
signal nReset  : std_logic := '0';

signal Route_Table_Clk     : std_logic := '0';
signal Route_Table_WR      : std_logic := '0';
signal Route_Table_Address : std_logic_vector(AddressLength-1 downto 0);
signal Route_Table_Data    : std_logic_vector(31 downto 0) := x"00000000"; 

signal Port_Empty : std_logic_vector(15 downto 0);
signal Port_RD    : std_logic_vector(15 downto 0);
signal Port_WR    : std_logic_vector(15 downto 0);

signal FIFO_IN    : std_logic_vector(PacketLength-1 downto 0);
signal FIFO_OUT   : std_logic_vector(PacketLength-1 downto 0);

begin
-- ROUTER ENTITY
--     signal clk  : in std_logic;
--     signal nrst : in std_logic;
--     signal cke  : in std_logic;  
-- Router Programming Signals
--     signal Route_Table_Clk : in std_logic;
--     signal Route_Table_WR : in std_logic;
--     signal Route_Table_Address : in std_logic_vector(AddressLength-1 downto 0);
--     signal Route_Table_Data : inout std_logic_vector(31 downto 0); 
-- Router FIFO Signals
--     signal Port_Empty : in  std_logic_vector(15 downto 0);
--     signal Port_RD    : out std_logic_vector(15 downto 0);
--     signal Port_WR    : out std_logic_vector(15 downto 0);
--     signal FIFO_IN : in std_logic_vector((PacketLength-1) downto 0);      
--     signal FIFO_OUT : out std_logic_vector((PacketLength-1) downto 0)); 
     
ROUTER_1:  entity work.RouterDispatcher
                      port map(clk  => clock,
                               nrst => nReset,
                               cke  => '1',
                               Route_Table_Clk => ,
                               Route_Table_WR  => ,
                               Route_Table_Address => ,
                               Route_Table_Data    => ,
                               Port_Empty => Port_Empty,
                               Port_RD    => Port_RD,
                               Port_WR    => ,
                               FIFO_IN    => ,
                               FIFO_OUT   =>);
                                                      
clock <= NOT clock after clock_period/2;
nReset <= '0', '1' after clock_period*10;

Port_Empty <= x"FFFF",
              x"0000" after clock_period*20,
              x"FFFF" after clock_period*21,
              x"EEEE" after clock_period*40,
              x"FFFF" after clock_period*41;
end architecture Behavioural;











