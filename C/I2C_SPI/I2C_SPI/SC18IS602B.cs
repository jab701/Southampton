using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace I2C_SPI
{
    class SC18IS602B
    {
        private SC18IM700 UARTI2C;
        private byte BaseAddress;
        private byte AddressOffset;

        public SC18IS602B(ref SC18IM700 UARTI2C)
        {
            this.AddressOffset = 0; 
            this.BaseAddress = 40;
            this.UARTI2C = UARTI2C;
        }
        public SC18IS602B(ref SC18IM700 UARTI2C, byte AddressOffset)
        {
            this.AddressOffset = AddressOffset;
            this.BaseAddress = 40;
            this.UARTI2C = UARTI2C;
        }
        public byte Address
        {
            get { return (byte)(this.BaseAddress + this.AddressOffset); }
            set { this.AddressOffset = (byte)(value - this.BaseAddress); }
        }
        public byte Address_Offset
        {
            get { return AddressOffset; }
            set { AddressOffset = value; }
        }
        public bool clear_int()
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[1];

            CommandPacket[0] = 0xF1;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool conf_gpio(byte Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[2];

            CommandPacket[0] = 0xF7;
            CommandPacket[1] = Data;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool conf_spi(bool Order, bool Mode0, bool Mode1, bool F0, bool F1)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte Data = 0;

            if (F1 == true)
            {
                Data = 1;
            }

            if (F0 == true)
            {
                Data += 2;
            }

            if (Mode0 == true)
            {
                Data += 4;
            }

            if (Mode1 == true)
            {
                Data += 8;
            }

            if (Order == true)
            {
                Data += 32;
            }

            byte[] CommandPacket = new byte[2];

            CommandPacket[0] = 0xF0;
            CommandPacket[1] = Data;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool idle_mode()
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[1];

            CommandPacket[0] = 0xF2;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool enable_gpio(byte Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[2];

            CommandPacket[0] = 0xF6;
            CommandPacket[1] = Data;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool read_gpio(ref byte Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[1];

            CommandPacket[0] = 0xF5;
            
            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool write_gpio(byte Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] CommandPacket = new byte[2];

            CommandPacket[0] = 0xF4;
            CommandPacket[1] = Data;

            bool ReturnValue = this.UARTI2C.write_i2c(Address, CommandPacket);

            return ReturnValue;
        }
        public bool read_buffer(ref byte[] Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            bool ReturnValue = this.UARTI2C.read_i2c(Address, (byte)Data.Length, ref Data);

            return ReturnValue;
        }
        public bool write_spi(byte ID, byte[] Data)
        {
            if (this.UARTI2C == null)
            {
                return false;
            }

            byte Address = (byte)(this.BaseAddress + this.AddressOffset);

            byte[] Packet = new byte[Data.Length + 1];

            Packet[0] = (byte)(ID & 0x0F);

            for (int i = 0; i < Data.Length; i++)
            {
                Packet[i + 1] = Data[i];
            }

            bool ReturnValue = this.UARTI2C.write_i2c(Address, Packet);

            return ReturnValue;
        }
    }
}
