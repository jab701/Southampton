library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
  generic (PacketLength : natural := 32);
  port 
  (
     signal clock   : in std_logic;
     signal nReset  : in std_logic;
          
     signal rx    : in std_logic;
     
     signal Data_Clock : in std_logic;
     signal Empty      : out std_logic;
     signal RD         : in std_logic;
     signal Data_Out   : out std_logic_vector(PacketLength-1 downto 0));
     
   constant ActualPacketLength : natural := PacketLength + 2; 
end entity uart_rx;

architecture Behavioural of uart_rx is
signal Valid : std_logic;
signal Flush : std_logic;
signal Packet : std_logic_vector(ActualPacketLength-1 downto 0);

signal packet_d, packet_q : std_logic_vector(PacketLength-1 downto 0);

signal BitCount_d, BitCount_q : std_logic_vector(16 downto 0);

TYPE SampleState is (IDLE, READING);
signal SAM_STATE_D, SAM_STATE_Q : SampleState;
 
TYPE State is (IDLE, WRITE);
signal STATE_D, STATE_Q : State;

signal FIFO_Full : std_logic;
signal FIFO_WE : std_logic;

begin
UART_SAMPLE_SEQ: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
     SAM_STATE_Q <= IDLE; 
     BitCount_Q <= (others => '0');
    else
     SAM_STATE_Q <= SAM_STATE_D; 
     BitCount_Q <= BitCount_D;
    end if;
  end if;  
end process UART_SAMPLE_SEQ;

UART_SAMPLE_COM: process (SAM_STATE_Q, rx, BitCount_Q) is
begin
  case SAM_STATE_Q is
  when IDLE =>
    BitCount_D <= (others => '0');
    VALID <= '0';
    
    if rx = '0' then
      SAM_STATE_D <= READING;
    else
      SAM_STATE_D <= IDLE;
    end if;
    
  when READING =>
    BitCount_D <= BitCount_Q + 1;
    
    if (BitCount_Q = std_logic_vector(to_unsigned(ActualPacketLength-1,16))) then
      SAM_STATE_D <= IDLE;
      VALID <= '1';
    else
      SAM_STATE_D <= READING;
      VALID <= '0';
    end if;
    
  end case;
end process UART_SAMPLE_COM;
            
UART_DESERIALZIER_1: entity work.uart_deserializer
  generic map(PacketLength => ActualPacketLength-1)
  port map(clock => clock,
           nReset => nReset,
           SERIAL_IN => rx,
           FLUSH => FLUSH,
           DATA_OUT => Packet);

WRITE_FLUSH_SEQ: process (Clock) is
begin
  if rising_edge(Clock) then
    if (nReset = '0') then
      State_Q <= IDLE;
      packet_q <= (others => '0');  
    else
      State_Q <= State_D;
      packet_q <= packet_d;
    end if;
  end if;
end process WRITE_FLUSH_SEQ;

WRITE_FLUSH_COM: process (State_Q, Packet, packet_q, FIFO_Full, VALID) is
begin
  case State_Q is
  when IDLE =>
    FIFO_WE <= '0';
    
    if (VALID = '1') then
      -- if Packet(MSB) = '1' and Packet(0) = '0' then
      -- it is a valid UART packet, copy and flush
      if ((Packet(ActualPacketLength-1) = '1') AND (Packet(0) = '0')) then
        packet_d <= Packet(ActualPacketLength-2 downto 1);
        Flush <= '1';
        state_D <= WRITE;
      -- oitherwise a framing error has occurred, flush and discard     
      else 
        packet_d <= (others => '0');
        Flush <= '1';
        state_D <= IDLE;
      end if;
    else
      packet_d <= (others => '0');
      Flush <= '0';
      state_D <= IDLE;
    end if;
    
  when WRITE =>
    packet_d <= packet_q;
    Flush <= '0';
    state_D <= IDLE;
    
    if (FIFO_FULL = '1') then
      FIFO_WE <= '0';  
    else
      FIFO_WE <= '1';         
    end if;

  end case;
end process WRITE_FLUSH_COM;

FIFO_1: entity work.async_fifo
  generic map(width => PacketLength,
              depth => 6)
  port map(nReset => nReset,
           empty => Empty,
           full => FIFO_full,
           wclk => Clock,
           we => FIFO_we,
           data_write => Packet_Q,
           rclk => Data_Clock,
           rd => RD,
           data_read => Data_Out);
end architecture Behavioural;




