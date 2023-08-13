using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO.Ports;

public class SC18IM700
{
    // I2C Register Names
    public const byte BRG0 = 0x00;
    public const byte BRG1 = 0x01;
    public const byte PortConf1 = 0x02;
    public const byte PortConf2 = 0x03;
    public const byte IOState = 0x04;
    public const byte I2CAdr = 0x06;
    public const byte I2CClkL = 0x07;
    public const byte I2CClkH = 0x08;
    public const byte I2CTO = 0x09;
    public const byte I2CStat = 0x0A;
    // I2C Bus Status Values
    public const byte I2CSTAT_FAIL = 0x00;
    public const byte I2CSTAT_OK = 0xF0;
    public const byte I2CSTAT_NACK_ON_ADDRESS = 0xF1;
    public const byte I2CSTAT_NACK_ON_DATA = 0xF2;
    public const byte I2CSTAT_TIME_OUT = 0xF8;

    private SerialPort _SerialPort;

    public SC18IM700(ref SerialPort ComPort)
    {
        this._SerialPort = ComPort;
    }
    public byte I2C_Status
    {
        get
        {
            byte Status = I2CSTAT_FAIL;

            if (!this.read_reg(I2CStat, ref Status))
            {
                return I2CSTAT_FAIL;
            }
            else
            {
                return Status;
            }
        }
    }
    public bool write_reg(byte Reg, byte Data)
    {
        byte[] Register = new byte[1];
        byte[] DataToWrite = new byte[1];

        Register[0] = Reg;
        DataToWrite[0] = Data;

        return write_reg(Register, DataToWrite);
    }
    public bool write_reg(byte[] Reg, byte[] Data)
    {
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

        return this.SerialWrite(Packet);
    }
    public bool read_reg(byte Reg, ref byte Data)
    {
        byte[] Register = new byte[1];
        byte[] DataToRead = new byte[1];

        Register[0] = Reg;

        bool ReturnValue = read_reg(Register, ref DataToRead);

        if (ReturnValue)
        {
            Data = DataToRead[0];
        }

        return ReturnValue;
    }
    public bool read_reg(byte[] Reg, ref byte[] Data)
    {
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

        if (!this.SerialWrite(Packet))
        {
            return false;
        }

        return this.SerialRead(ref Data);
    }
    public bool write_gpio(byte Data)
    {
        byte[] packet = new byte[3];

        packet[0] = 0x4F;
        packet[1] = Data;
        packet[2] = 0x50;

        return this.SerialWrite(packet);
    }
    public bool read_gpio(ref byte Data)
    {
        byte[] packet = new byte[2];

        packet[0] = 0x49;
        packet[1] = 0x50;

        bool ReturnValue = this.SerialWrite(packet);

        if (!ReturnValue)
        {
            return ReturnValue;
        }

        byte[] ReadData = new byte[1];

        ReturnValue = this.SerialRead(ref ReadData);

        if (ReturnValue)
        {
            Data = ReadData[0];
        }

        return ReturnValue;
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

        return this.SerialWrite(packet);
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

        byte _Addr = (byte)(Addr << 1);
        _Addr = (byte)(_Addr + 1);

        byte[] packet = new byte[4];

        packet[0] = 0x53;
        packet[1] = _Addr;
        packet[2] = NumBytes;
        packet[3] = 0x50;

        if (!this.SerialWrite(packet))
        {
            return false;
        }

        return this.SerialRead(ref Data);
    }
    public bool writeafterwrite_i2c(byte AddrWrite1, byte[] DataToWrite1, byte AddrWrite2, byte[] DataToWrite2)
    {
        if ((AddrWrite1 > 127) || (AddrWrite2 > 127))
        {
            return false;
        }

        if ((DataToWrite1.Length > 255) || (DataToWrite2.Length > 255))
        {
            return false;
        }

        byte _AddrWrite1 = (byte)(AddrWrite1 << 1);
        byte _AddrWrite2 = (byte)(AddrWrite2 << 1);

        byte length1 = (byte)DataToWrite1.Length;
        byte length2 = (byte)DataToWrite2.Length;

        byte[] packet = new byte[3 + length1 + length2 + 4];

        packet[0] = 0x53;
        packet[1] = _AddrWrite1;
        packet[2] = length1;

        for (uint i = 0; i < length1; i++)
        {
            packet[3 + i] = DataToWrite1[i];
        }
        packet[3 + length1] = 0x53;
        packet[3 + length1 + 1] = _AddrWrite2;
        packet[3 + length1 + 2] = length2;
        for (uint i = 0; i < length2; i++)
        {
            packet[3 + length1 + 3] = DataToWrite2[i];
        }
        packet[3 + length1 + 3 + length2] = 0x50;

        return this.SerialWrite(packet);
    }
    public bool readafterwrite_i2c(byte AddrWrite, byte[] DataToWrite, byte AddrRead, byte NumBytes, ref byte[] DataToRead)
    {
        if ((AddrWrite > 127) || (AddrRead > 127))
        {
            return false;
        }

        if ((NumBytes > 255) || (DataToWrite.Length > 255))
        {
            return false;
        }

        byte _AddrWrite = (byte)(AddrWrite << 1);
        byte _AddrRead = (byte)(AddrRead << 1);
        _AddrRead = (byte)(_AddrRead + 1);

        byte length = (byte)DataToWrite.Length;

        byte[] packet = new byte[3 + length + 4];

        packet[0] = 0x53;
        packet[1] = _AddrWrite;
        packet[2] = length;

        for (uint i = 0; i < length; i++)
        {
            packet[3 + i] = DataToWrite[i];
        }
        packet[3 + length] = 0x53;
        packet[3 + length + 1] = _AddrRead;
        packet[3 + length + 2] = NumBytes;
        packet[3 + length + 3] = 0x50;

        if (!this.SerialWrite(packet))
        {
            return false;
        }

        return this.SerialRead(ref DataToRead);
    }

    private bool SerialWrite(byte[] Data)
    {
        if (this._SerialPort == null)
        {
            return false;
        }

        if (!this._SerialPort.IsOpen)
        {
            return false;
        }

        this._SerialPort.Write(Data, 0, Data.Length);

        return true;
    }
    private bool SerialRead(ref byte[] Data)
    {
        if (this._SerialPort == null)
        {
            return false;
        }

        if (!this._SerialPort.IsOpen)
        {
            return false;
        }

        this._SerialPort.Read(Data, 0, Data.Length);

        return true;
    }
}

