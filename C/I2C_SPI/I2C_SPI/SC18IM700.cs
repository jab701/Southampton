using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace I2C_SPI
{
    class SC18IM700
    {
        private SerialInterface _SerialInterface;

        public SC18IM700(ref SerialInterface hSerialInterface)
        {
            _SerialInterface = hSerialInterface;
        }
        public bool write_reg(byte Reg, byte Data)
        {
            byte[] Register = new byte[1];
            byte[] DataToWrite = new byte[1];

            Register[0] = Reg;
            DataToWrite[0] = Data;

            bool ReturnValue = write_reg(Register, DataToWrite);

            return ReturnValue;
        }
        public bool write_reg(byte[] Reg, byte[] Data)
        {
            if (this._SerialInterface == null)
            {
                return false;
            }

            if (Reg.Length != Data.Length)
            {
                return false;
            }

            uint datalength = (uint)Reg.Length;
            uint pktlength = 2 + (datalength * 2);

            byte[] Packet = new byte[pktlength];

            Packet[0] = 0x57;

            for (int i = 0; i < datalength; i++)
            {
                Packet[i * 2] = Reg[i];
                Packet[(i * 2) + 1] = Data[i];
            }

            Packet[pktlength - 1] = 0x50;

            if (!this._SerialInterface.write(Packet))
            {
                return false;
            }

            return true;
        }
        public bool read_reg(byte Reg, ref byte Data)
        {
            byte[] Register = new byte[1];
            byte[] DataToRead = new byte[1];

            Register[0] = Reg;

            bool ReturnValue = read_reg(Register, ref DataToRead);

            if (ReturnValue == true)
            {
                Data = DataToRead[0];
            }

            return ReturnValue;
        }
        public bool read_reg(byte[] Reg, ref byte[] Data)
        {
            if (this._SerialInterface == null)
            {
                return false;
            }

            if (Reg.Length != Data.Length)
            {
                return false;
            }

            uint datalength = (uint)Reg.Length;
            uint pktlength = 2 + datalength;

            byte[] Packet = new byte[pktlength];

            Packet[0] = 0x52;

            for (int i = 0; i < datalength; i++)
            {
                Packet[i + 1] = Reg[i];
            }

            Packet[pktlength - 1] = 0x50;

            if (!this._SerialInterface.write(Packet))
            {
                return false;
            }

            if (!this._SerialInterface.read(ref Data))
            {
                return false;
            }

            return true;
        }
        public bool write_gpio(byte Data)
        {
            byte[] packet = new byte[3];

            packet[0] = 0x4F;
            packet[1] = Data;
            packet[2] = 0x50;

            if (!_SerialInterface.write(packet))
            {
                return false;
            }

            return true;
        }
        public bool read_gpio(ref byte Data)
        {
            byte[] packet = new byte[2];

            packet[0] = 0x49;
            packet[1] = 0x50;

            if (!_SerialInterface.write(packet))
            {
                return false;
            }

            byte[] ReadData = new byte[1];

            if (!_SerialInterface.read(ref ReadData))
            {
                return false;
            }

            Data = ReadData[0];

            return true;
        }
        public bool write_i2c(byte Addr, byte[] Data)
        {
            int intlength = Data.Length;

            if (Addr > 127)
            {
                return false;
            }

            if (intlength > 255)
            {
                return false;
            }

            if (this._SerialInterface == null)
            {
                return false;
            }

            byte _Addr = (byte)(Addr << 1);

            byte length = (byte)intlength;

            byte[] packet = new byte[length + 4];

            packet[0] = 0x53;
            packet[1] = _Addr;
            packet[2] = length;

            for (int i = 0; i < length; i++)
            {
                packet[3 + i] = Data[i];
            }

            packet[length + 3] = 0x50;

            if (!_SerialInterface.write(packet))
            {
                return false;
            }
            return true;
        }
        public bool read_i2c(byte Addr, byte NumBytes, ref byte[] Data)
        {
            if (Addr > 127)
            {
                return false;
            }

            if (NumBytes > 255)
            {
                return false;
            }

            if (this._SerialInterface == null)
            {
                return false;
            }

            byte _Addr = (byte)(Addr << 1);
            _Addr = (byte)(_Addr + 1);

            byte[] packet = new byte[4];

            packet[0] = 0x53;
            packet[1] = _Addr;
            packet[2] = NumBytes;
            packet[3] = 0x50;

            if (!_SerialInterface.write(packet))
            {
                return false;
            }

            if (!_SerialInterface.read(ref Data))
            {
                return false;
            }

            return true;
        }
    }
}
