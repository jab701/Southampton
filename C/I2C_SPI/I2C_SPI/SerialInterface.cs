using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO.Ports;

namespace I2C_SPI
{
    class SerialInterface
    {
        private SerialPort _SerialPort;

        public SerialInterface()
        {
            _SerialPort = new SerialPort();
        }
        public bool Open_Port(string Name, int Baud, int Timeout)
        {
            try
            {
                _SerialPort.PortName = Name;
                _SerialPort.BaudRate = Baud;
                _SerialPort.Parity = Parity.None;
                _SerialPort.DataBits = 8;
                _SerialPort.StopBits = StopBits.One;
                _SerialPort.Handshake = Handshake.None;

                _SerialPort.ReadTimeout = Timeout;
                _SerialPort.WriteTimeout = Timeout;

                _SerialPort.Open();
            }
            catch (Exception ex)
            {
                return false;
            }

            return true;

        }
        public bool Close_Port()
        {
            try
            {
                _SerialPort.Close();
            }
            catch (Exception ex)
            {
                return false;
            }

            return true;
        }
        public bool read(ref byte [] data)
        {
            try
            {
                int temp = this._SerialPort.Read(data, 0, data.Length);
            }
            catch (Exception ex)
            {
                return false;
            }
            return true;
        }
        public bool write(byte [] data)
        {
            try
            {
                this._SerialPort.Write(data, 0, data.Length);
            }
            catch (Exception ex)
            {
                return false;
            }
            return true;
        }
        public string [] Get_List_Of_Ports()
        {
            return SerialPort.GetPortNames();
        }
    }
}
