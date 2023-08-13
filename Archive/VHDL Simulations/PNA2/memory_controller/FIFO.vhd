library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO is
  generic 
  (
     width : natural := 4;
     depth : natural := 4
  );
  port 
  (  signal Clock  : in std_logic;
     signal nReset : in std_logic;
     signal cke    : in std_logic;
     
     -- FIFO Flags
     signal empty : out std_logic;
     signal full  : out std_logic;
     
     -- Write Port
     signal we : in std_logic;
     signal data_write : in std_logic_vector(width-1 downto 0);

     -- Read Port
     signal rd : in std_logic;
     signal data_read : out std_logic_vector(width-1 downto 0)    
   ); 
end entity FIFO;

architecture Behavioural of FIFO is

signal write_addr_D : std_logic_vector(depth downto 0);
signal write_addr_Q : std_logic_vector(depth downto 0);

signal read_addr_D : std_logic_vector(depth downto 0);
signal read_addr_Q : std_logic_vector(depth downto 0);

signal fifo_empty : std_logic;
signal fifo_full : std_logic;

signal mem_we : std_logic;
signal mem_read_addr : std_logic_vector(depth-1 downto 0);

begin
  full <= fifo_full;
  empty <= fifo_empty;
  mem_we <= we AND NOT(fifo_full);
 
  mem: entity work.dp_rw_sram
       generic map(address_width => depth,
                   data_width => width)
       port map(clock => clock,
                we => mem_we,
                rd => rd,
                addr_read  => mem_read_addr,
                addr_write => write_addr_Q(depth-1 downto 0),
                data_write => data_write,
                data_read  => data_read);

process (write_addr_Q, read_addr_Q) is
  variable write_addr : std_logic_vector(depth-1 downto 0);
  variable read_addr  : std_logic_vector(depth-1 downto 0);
  variable write_msb  : std_logic;
  variable read_msb   : std_logic;
begin
  write_addr := write_addr_Q(depth-1 downto 0);
  read_addr  := read_addr_Q(depth-1 downto 0);
  write_msb  := write_addr_Q(depth);
  read_msb   := read_addr_Q(depth);
  
  if (write_addr = read_addr) then
    if ((write_msb XOR read_msb) = '1') then
      fifo_full  <= '1';
      fifo_empty <= '0';
      mem_read_addr <= read_addr;  
    else
      fifo_full  <= '0';
      fifo_empty <= '1';
      mem_read_addr <= read_addr - 1;         
    end if;
  else
    fifo_full <= '0';
    fifo_empty <= '0';
    mem_read_addr <= read_addr; 
  end if;   

end process;

seq: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      write_addr_Q <= (others => '0');
      read_addr_Q  <= (others => '0');  
    elsif (cke = '1') then
      write_addr_Q <= write_addr_D;
      read_addr_Q  <= read_addr_D;          
    end if;
  end if;  
end process seq;

next_write: process (write_addr_Q, we, fifo_full) is
begin
  if (we = '1') then
    if (fifo_full = '0') then
      write_addr_D <= write_addr_Q + 1;
    else
      write_addr_D <= write_addr_Q;
    end if;    
  else
    write_addr_D <= write_addr_Q;      
  end if;
end process next_write;

next_read: process (read_addr_Q, rd, fifo_empty) is
begin
  if (rd = '1') then
    if (fifo_empty = '0') then
      read_addr_D <= read_addr_Q + 1;
    else
      read_addr_D <= read_addr_Q;
    end if;    
  else
    read_addr_D <= read_addr_Q;      
  end if;
end process next_read;  

end architecture Behavioural;




