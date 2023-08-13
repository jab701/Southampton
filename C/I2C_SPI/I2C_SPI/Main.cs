using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;

using System.IO.Ports;

namespace I2C_SPI
{
    public partial class Main : Form
    {
        public Main()
        {
            InitializeComponent();
            RefreshCOMListBox();
        }
        public void RefreshCOMListBox()
        {
            // Get a list of serial port names.
            string[] ports = SerialPort.GetPortNames();

            if (ports.Count() == 0)
            {
                COM_ListBox.BeginUpdate();
                COM_ListBox.Items.Clear();
                COM_ListBox.Items.Add("No Device Detected!");
                COM_ListBox.EndUpdate();
                return;
            }

            COM_ListBox.BeginUpdate();
            COM_ListBox.Items.Clear();

            foreach (string port in ports)
            {
                COM_ListBox.Items.Add(port);
            }

            COM_ListBox.EndUpdate();
            COM_ListBox.SelectedIndex = 0;
            return;
        }
        private void MenuItem_Exit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        private void RefreshComList_Click(object sender, EventArgs e)
        {
            this.RefreshCOMListBox();
        }
        private void Run(object sender, EventArgs e)
        {
            SerialInterface Serial = new SerialInterface();
            SC18IM700 I2C = new SC18IM700(ref Serial);
            SC18IS602B SPI = new SC18IS602B(ref I2C,0);

            string COM = (string)COM_ListBox.SelectedItem;

            if (!Serial.Open_Port(COM, 9600, 2000))
            {
                return;
            }

            SPI.conf_spi(false, false, false, false, false);

            byte [] Data = {0x01,0x02,0x03};
            byte [] Data2 = {0x00,0x00,0x00};
            byte [] Data3 = new byte[200];

            if (!SPI.read_buffer(ref Data3))
            {
                Serial.Close_Port();
                return;
            }

            SPI.clear_int();

            if (!SPI.write_spi(0x01, Data))
            {
                Serial.Close_Port();
                return;
            }

            byte GPIO = 0;
//            I2C.read_gpio(ref GPIO);

//            if ((GPIO & 1) == 0)
//            {
//                while ((GPIO & 1) == 0)
//                {
//                    SPI.clear_int();
//                    I2C.read_gpio(ref GPIO);
//                }
//            }

            SPI.clear_int();

            if (!SPI.read_buffer(ref Data3))
            {
                Serial.Close_Port();
                return;
            }

            SPI.clear_int();

            Serial.Close_Port();
            return;
        }
    }
}
