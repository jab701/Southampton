using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;

using System.IO.Ports;

namespace CortexM0_Prog
{
    enum ISPReturnCode
    {
        CMD_SUCCESS = 0,
        INVALID_COMMAND,
        SRC_ADDR_ERROR,
        DST_ADDR_ERROR,
        SRC_ADDR_NOT_MAPPED,
        DST_ADDR_NOT_MAPPED,
        COUNT_ERROR,
        INVALID_SECTOR,
        SECTOR_NOT_BLANK,
        SECTOR_NOT_PREPARED_FOR_WRITE_OPERATION,
        COMPARE_ERROR,
        BUSY,
        PARAM_ERROR,
        ADDR_ERROR,
        ADDR_NOT_MAPPED,
        CMD_LOCKED,
        INVALID_CODE,
        INVALID_BAUD_RATE,
        INVALID_STOP_BIT,
        CODE_READ_PROTECTION_ENABLED
    }
}

namespace CortexM0_Prog
{
    public partial class CortexM0Prog : Form
    {
        public const byte LF = 0x0A;
        public const byte CR = 0x0D;

        private string CurrentDirectory;
        public int RWAttempts;

        public CortexM0Prog()
        {
            InitializeComponent();
            RefreshCOMListBox();
            CurrentDirectory = Directory.GetCurrentDirectory();
        }
        public void RefreshCOMListBox()
        {
            // Get a list of serial port names.
            string[] ports = SerialPort.GetPortNames();

            if (ports.Count() == 0)
            {
                COM_ListBox.BeginUpdate();
                COM_ListBox.Items.Clear();
                COM_ListBox.Items.Add("No WDM Device Detected!");
                COM_ListBox.EndUpdate();
                return;
            }

            COM_ListBox.BeginUpdate();
            COM_ListBox.Items.Clear();
            COM_ListBox.Items.Add("Select a COM Port");

            foreach (string port in ports)
            {
                COM_ListBox.Items.Add(port);
            }

            COM_ListBox.EndUpdate();
            COM_ListBox.SelectedIndex = 0;
            return;
        }
        private void Refresh_COMList_Click(object sender, EventArgs e)
        {
            RefreshCOMListBox();
        }
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        private void Browse_Click(object sender, EventArgs e)
        {
            FileSelect.InitialDirectory = this.CurrentDirectory;

            FileSelect.Filter = "Binary Files (*.bin)|*.bin|All files (*.*)|*.*";
            FileSelect.FilterIndex = 1;
            FileSelect.FileName = "";

            if (FileSelect.ShowDialog() == DialogResult.OK)
            {
                this.CurrentDirectory = Path.GetDirectoryName(FileSelect.FileName);
                this.FilePath.Text = FileSelect.FileName;
            }
        }
        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CortexAboutBox About = new CortexAboutBox();
            About.ShowDialog();
        }
        private void GO_Click(object sender, EventArgs e)
        {
            this.Lock_Controls();
            this.Run();
            this.Unlock_Controls();
            return;
        }
        private static void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sp = (SerialPort)sender;
        }
        public void LogMessage(string Message)
        {
            Message = "Message: " + Message + "\n";
            Log.AppendText(Message);
        }
        public void LogError(string Message)
        {
            Message = "Error: " + Message + "\n";
            Log.AppendText(Message);
        }
        private void Lock_Controls()
        {
            this.COM_ListBox.Enabled = false;
            this.Refresh_COMList.Enabled = false;
            this.FilePath.Enabled = false;
            this.Browse.Enabled = false;
            this.GO.Enabled = false;
        }
        private void Unlock_Controls()
        {
            this.COM_ListBox.Enabled = true;
            this.Refresh_COMList.Enabled = true;
            this.FilePath.Enabled = true;
            this.Browse.Enabled = true;
            this.GO.Enabled = true;
        }
        private void Run()
        {
            LogMessage("Operation: Read program file");
            byte[] BinaryData;
            if (!ReadBinaryFile(FilePath.Text, out BinaryData))
            {
                // print message, couldnt read file
                LogError("Input file does not exist, cannot be opened or an IO error occurred");
                return;
            }

            LogMessage("Operation: Open COM Port");
            SerialPort _SerialPort = new SerialPort((string)COM_ListBox.SelectedItem, 9600, Parity.None, 8, StopBits.One);
            _SerialPort.Handshake = Handshake.XOnXOff;
            _SerialPort.ReadTimeout = 2000;
            _SerialPort.WriteTimeout = 2000;
            _SerialPort.DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandler);
            _SerialPort.Open();

            LogMessage("Operation: Initializing");
            if (!InitRemoteDevice(_SerialPort))
            {
                // print message
                _SerialPort.Close();
                return;
            }

            LogMessage("Operation: Preparing");
            if (!ProgramChipPrepare(_SerialPort))
            {
                _SerialPort.Close();
                return;
            }

            LogMessage("Operation: Programming");
            if (!ProgramChip(_SerialPort, BinaryData))
            {
                _SerialPort.Close();
                return;
            }

            _SerialPort.Close();
            LogMessage("Programming Sequence Completed Successfully!");

            return;
        }
        private bool ReadBinaryFile(string FileName, out byte[] Data)
        {
            Data = null;

            try
            {
                if (!File.Exists(FileName))
                {
                    throw new FileNotFoundException();
                }

                using (FileStream fs = File.OpenRead(FileName))
                {
                    Data = new byte[fs.Length];

                    int ReadBytes = fs.Read(Data, 0, (int)fs.Length);

                    if (fs.Length != ReadBytes)
                    {
                        Data = null;
                    }

                    fs.Close();
                }
            }
            catch (Exception ex)
            {

                return false;
            }

            if (Data == null)
            {
                return false;
            }
            return true;
        }
        private bool InitRemoteDevice(SerialPort _SerialPort)
        {
            string DataReceived;

            _SerialPort.Write("?");

            Thread.Sleep(500); // Sleep for 500ms, this allows the Cortex M0 to process and catch up

            DataReceived = _SerialPort.ReadExisting();

            if (DataReceived != "Synchronized\r\n")
            {
                // Okay so we didn't receive the expected response, what have we receieved?
                if (DataReceived == "?")
                {
                    _SerialPort.Write("?\r\n");
                    Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                    DataReceived = _SerialPort.ReadExisting();

                    if ((DataReceived == "?\r\n1\r\n") || (DataReceived == "?\r1\r\n"))
                    {
                        // We are already synchronized, proceed as normal!
                        return true;
                    }
                    else
                    {
                        LogError("Failed to synchronize with device");
                        return false;
                    }
                }
                else
                {
                    LogError("Failed to synchronize with device");
                    return false;
                }
            }

            // Write the string ("Synchronized<cr><lf>") to device
            _SerialPort.Write("Synchronized\r\n");

            Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up

            DataReceived = _SerialPort.ReadExisting();

            // Did we receive string ("Synchronized<cr><lf>OK<cr><lf>")
            if ((DataReceived != "Synchronized\r\nOK\r\n") && (DataReceived != "Synchronized\rOK\r\n"))
            {
                // Okay so we didn't receive the expected response, what have we receieved?
                LogError("Device did not respond Synchronized OK");
                return false;
            }

            // Write the crystal frequency (in khz) ("25000\x0D\x0A") to device
            _SerialPort.Write("25000\r\n");

            Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up

            DataReceived = _SerialPort.ReadExisting();

            // Did we receive string ("25000\x0D\x0AOK<cr><lf>")
            if ((DataReceived != "25000\r\nOK\r\n") && (DataReceived != "25000\rOK\r\n"))
            {
                // Okay so we didn't receive the expected response, what have we receieved?
                LogError("Device did not respond OK to setting crystal frequency");
                return false;
            }
            return true;
        }
        private bool ProgramChipPrepare(SerialPort _SerialPort)
        {
            int[] DataReceivedIntArray;

            //*******************************************************
            // First turn echo off
            //*******************************************************

            if (this.ChangeEchoSetting(_SerialPort,false) != 0)
            {
                LogError("Failed to change echo setting on device");
                return false;
            }
            //*******************************************************
            // First lets get the device to tell us its part number
            //*******************************************************

            DataReceivedIntArray = this.ReadPartID(_SerialPort, 9600);

            if (DataReceivedIntArray[0] != (int)ISPReturnCode.CMD_SUCCESS)
            {
                // Read Part ID Failed
                LogError("Read Part ID Failed");
                return false;
            }

            uint DeviceTypeID = (uint)DataReceivedIntArray[1];
            if (DeviceTypeID != 0x3670002B)
            {
                LogMessage("Programming Unsupported device found (not an LPC1227)");
                return false;
            }

            LogMessage("Found LPC1227 Device, Beginning programming sequence");

            //************************************************************************************
            // Right now we send the unlock command to allow programming commands to be accepted
            //************************************************************************************
            if (this.RequestUnlock(_SerialPort) != (int)ISPReturnCode.CMD_SUCCESS)
            {
                LogMessage("Failed to unlock the write commands");
                return false;
            }

            LogMessage("Preparation: Unlock Flash Commands Complete");

            //************************************************
            // Now increase the baud rate of the serial port
            //************************************************
            //if (this.ChangeBaudRate(_SerialPort,115200) != 0)
            //{
            //    LogMessage("Failed to change Serial Port Baud Rate");
            //    return false;
            //}

            //_SerialPort.Close();
            //_SerialPort.BaudRate = 115200;
            //_SerialPort.Open();

            DataReceivedIntArray = this.ReadPartID(_SerialPort, 9600);

            if (DataReceivedIntArray[0] != (int)ISPReturnCode.CMD_SUCCESS)
            {
                // Read Part ID Failed
                LogMessage("Preparation: Verify successful baud rate increased failed");
                return false;
            }

            if ((uint)DataReceivedIntArray[1] != DeviceTypeID)
            {
                // If not the same then the speed switch was not successful
                LogMessage("Preparation: Switch Serial Baud Rate Failed");
                return false;
            }
            LogMessage("Preparation: COM BAUD Rate increased");

            //*******************************************
            // Now prepare sectors for write operations
            //*******************************************
            if (PrepareSectorsForWrite(_SerialPort, 0, 31) != 0)
            {
                LogMessage("Preparation: Could not prepare sectors for write");
                return false;
            }

            //************************************************
            // Now erase all the sectors of the flash memory
            //************************************************
            if (EraseFlashSectors(_SerialPort, 0, 31) != 0)
            {
                LogMessage("Preparation: Could not erase flash sectors");
                return false;
            }

            //*****************************************
            // Now Blank check all the erased sectors
            // Sector 0 always blank checks as false
            //*****************************************
            if (BlankCheckSectors(_SerialPort, 1, 31) != 0)
            {
                LogMessage("Preparation: Erased sectors were not blank, Erase failed!");
                return false;
            }
            LogMessage("Preparation: Completed");
            return true;
        }
        private bool ProgramChip(SerialPort _SerialPort, byte[] Data)
        {
            uint Length = (uint)Data.Length;

            uint NumSectors = Length / 4096;
            uint Remainder = Length % 4096;

            if (Remainder != 0)
            {
                NumSectors++;
            }

            for (int i = 0; i < NumSectors; i++)
            {
                if (Data.Length > 4096)
                {
                    this.WriteToRam(_SerialPort, 0x10000000, 4096);
                    byte[] SectorBytes = new byte[4096];

                    Array.Copy(Data, 0, SectorBytes, 0, 4096);

                    for (int j = 0; j < 92; j++)
                    {
                        if (SectorBytes.Length > 900)
                        {
                            byte[] LineBytes = new byte[900];
                            Array.Copy(SectorBytes, 0, LineBytes, 0, 900);
                            byte[][] EncodedLines;
                            string Checksum;

                            uucodec.uuencodearray(LineBytes, out EncodedLines, out Checksum);

                            this.WriteData(_SerialPort, EncodedLines, Checksum, true);

                            byte[] NewSectorBytes = new byte[SectorBytes.Length - 900];

                            Array.Copy(SectorBytes, 900, NewSectorBytes, 0, NewSectorBytes.Length);

                            SectorBytes = NewSectorBytes;
                        }
                        else
                        {
                            byte[][] EncodedLines;
                            string Checksum;

                            uucodec.uuencodearray(SectorBytes, out EncodedLines, out Checksum);

                            this.WriteData(_SerialPort, EncodedLines, Checksum, true);
                        }
                    }

                    byte[] NewData = new byte[Data.Length - 4096];

                    Array.Copy(Data, 4096, NewData, 0, NewData.Length);

                    Data = NewData;

                    if (this.PrepareSectorsForWrite(_SerialPort, i, i) != (int)ISPReturnCode.CMD_SUCCESS)
                    {
                        LogError("Programming: Failed to prepare sector for writing");
                        return false;
                    }

                    if (this.CopyRamToFlash(_SerialPort, i, 0x10000000, 4096) != (int)ISPReturnCode.CMD_SUCCESS)
                    {
                        LogError("Programming: Failed to Copy Sector to flash memory");
                        return false;
                    }
                }
                else
                {
                    this.WriteToRam(_SerialPort, 0x10000000, Data.Length);
                    uint SectorLength = (uint) Data.Length/900;
                    if ((Data.Length % 900) != 0)
                    {
                        SectorLength++;
                    }
                    for (int j = 0; j < SectorLength; j++)
                    {
                        if (Data.Length > 900)
                        {
                            byte[] LineBytes = new byte[900];
                            Array.Copy(Data, 0, LineBytes, 0, 900);
                            byte[][] EncodedLines;
                            string Checksum;

                            uucodec.uuencodearray(LineBytes, out EncodedLines, out Checksum);

                            this.WriteData(_SerialPort, EncodedLines, Checksum, true);

                            byte[] NewData = new byte[Data.Length - 4096];

                            Array.Copy(Data, 4096, NewData, 0, NewData.Length);

                            Data = NewData;
                        }
                        else
                        {
                            byte[][] EncodedLines;
                            string Checksum;

                            uucodec.uuencodearray(Data, out EncodedLines, out Checksum);

                            this.WriteData(_SerialPort, EncodedLines, Checksum, true);
                        }
                    }

                    if (this.PrepareSectorsForWrite(_SerialPort, i, i) != (int)ISPReturnCode.CMD_SUCCESS)
                    {
                        LogError("Programming: Failed to prepare sector for writing");
                        return false;
                    }

                    if (this.CopyRamToFlash(_SerialPort, i, 0x10000000, Data.Length) != (int)ISPReturnCode.CMD_SUCCESS)
                    {
                        LogError("Programming: Failed to Copy Sector to flash memory");
                        return false;
                    }
                }
            }

            return true;
        }
        public int RequestUnlock(SerialPort _SerialPort)
        {
            try
            {
                _SerialPort.Write("U 23130\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int ChangeBaudRate(SerialPort _SerialPort, int NewBaud)
        {
            try
            {
                _SerialPort.Write("B " + Convert.ToString(NewBaud) + " 1\r\n");
                Thread.Sleep(500); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int ChangeEchoSetting(SerialPort _SerialPort, bool Setting)
        {
            try
            {
                if (Setting == true) // Then we arent echoing yet
                {
                    _SerialPort.Write("A " + Convert.ToString(Convert.ToUInt32(Setting)) + "\r\n");
                    Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                    return Convert.ToInt32(_SerialPort.ReadLine());
                }
                else
                {
                    _SerialPort.Write("A " + Convert.ToString(Convert.ToUInt32(Setting)) + "\r\n");
                    Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                    _SerialPort.ReadLine(); // Read echoed command and throw away
                    return Convert.ToInt32(_SerialPort.ReadLine()); // Read return code
                }
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int WriteToRam(SerialPort _SerialPort, int address, int NumberBytes)
        {
            try
            {
                string DataToSend = "W " + Convert.ToString(address) + " " + Convert.ToString(NumberBytes) + "\r\n";
                byte [] DataToSend2 = Encoding.ASCII.GetBytes(DataToSend);
                _SerialPort.Write(DataToSend2, 0, DataToSend2.Length);
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                string returnval = _SerialPort.ReadLine();
                return Convert.ToInt32(returnval);
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        //public int ReadMemory(SerialPort _SerialPort, int address, int NumberBytes)
        //{
        //    try
        //    {
        //        _SerialPort.Write("R " + Convert.ToString(address) + " " + Convert.ToString(NumberBytes) + "\r\n");
        //        Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
        //        return Convert.ToInt32(_SerialPort.ReadLine());
        //    }
        //    catch (TimeoutException e)
        //    {
        //        LogError(e.ToString());
        //        return -1;
        //    }
        //}
        public int PrepareSectorsForWrite(SerialPort _SerialPort, int Start, int End)
        {
            try
            {
                _SerialPort.ReadTimeout = 10000;
                string StringToWrite = "P " + Convert.ToString(Start) + " " + Convert.ToString(End) + "\r\n";
                byte[] Data = Encoding.ASCII.GetBytes(StringToWrite);
                _SerialPort.Write(Data,0,Data.Length);
                Thread.Sleep(2000); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                string temp = _SerialPort.ReadLine();
                int ReturnValue = Convert.ToInt32(temp);
                return ReturnValue;
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int CopyRamToFlash(SerialPort _SerialPort, int FlashDest, int RamSrc, int NumberBytes)
        {
            try
            {
                _SerialPort.Write("C " + Convert.ToString(FlashDest) + " " + Convert.ToString(RamSrc) + " " + Convert.ToString(NumberBytes) + "\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int Go(SerialPort _SerialPort, int address, char Mode)
        {
            try
            {
                if ((Mode != 'A') || (Mode != 'T'))
                {
                    return -2;
                }
                _SerialPort.Write("G " + Convert.ToString(address) + " " + Mode + "\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int EraseFlashSectors(SerialPort _SerialPort, int Start, int End)
        {
            try
            {
                _SerialPort.Write("E " + Convert.ToString(Start) + " " + Convert.ToString(End) + "\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int BlankCheckSectors(SerialPort _SerialPort, int Start, int End)
        {
            try
            {
                _SerialPort.Write("I " + Convert.ToString(Start) + " " + Convert.ToString(End) + "\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int[] ReadPartID(SerialPort _SerialPort, int Baud)
        {
            int[] ReturnData = new int[2];

            try
            {
                // Send Command "J<cr><lf>" to device
                // This should return an Ascii string representing the part number
                _SerialPort.Write("J\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                string ReturnValue = _SerialPort.ReadLine();
                ReturnData[0] = Convert.ToInt32(ReturnValue);

                if (ReturnData[0] == 0)
                {
                    ReturnData[1] = Convert.ToInt32(_SerialPort.ReadLine());
                }
                else
                {
                    ReturnData[1] = 0;
                }


                return ReturnData;
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                ReturnData[0] = -1;
                ReturnData[1] = 0;
                return ReturnData;
            }
        }
        public int ReadBootCodeVersion(SerialPort _SerialPort, out string VersionNumber)
        {
            try
            {
                // Send Command "J<cr><lf>" to device
                // This should return an Ascii string representing the part number
                _SerialPort.Write("K\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                int ReturnData = Convert.ToInt32(_SerialPort.ReadLine());
                VersionNumber = _SerialPort.ReadLine();

                return ReturnData;
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                VersionNumber = null;
                return -1;
            }
        }
        public int Compare(SerialPort _SerialPort, int Address1, int Address2, int NumberBytes)
        {
            try
            {
                _SerialPort.Write("M " + Convert.ToString(Address1) + " " + Convert.ToString(Address2) + " " + Convert.ToString(NumberBytes) + "\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                return Convert.ToInt32(_SerialPort.ReadLine());
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                return -1;
            }
        }
        public int[] ReadUID(SerialPort _SerialPort)
        {
            int[] ReturnData = new int[5];
            try
            {
                // Send Command "N<cr><lf>" to device
                // This should return an Ascii string representing the part number
                _SerialPort.Write("N\r\n");
                Thread.Sleep(200); // Sleep for 500ms, this allows the Cortex M0 to process and catch up
                ReturnData[0] = Convert.ToInt32(_SerialPort.ReadLine());

                if (ReturnData[0] == 0)
                {
                    ReturnData[1] = Convert.ToInt32(_SerialPort.ReadLine());
                    ReturnData[2] = Convert.ToInt32(_SerialPort.ReadLine());
                    ReturnData[3] = Convert.ToInt32(_SerialPort.ReadLine());
                    ReturnData[4] = Convert.ToInt32(_SerialPort.ReadLine());
                }
                return ReturnData;
            }
            catch (TimeoutException e)
            {
                LogError(e.ToString());
                ReturnData[0] = -1;
                ReturnData[1] = 0;
                ReturnData[2] = 0;
                ReturnData[3] = 0;
                ReturnData[4] = 0;
                return ReturnData;
            }
        }
        public bool ReadData(SerialPort _SerialPort, int NumberBytes, out string[] Data)
        {
            Data = null;
            return false;
        }
        public bool WriteData(SerialPort _SerialPort, byte [][] Data, string Checksum, bool ResetAttempts = true)
        {
            if (ResetAttempts == true)
            {
                this.RWAttempts = 0;
            }

            this.RWAttempts++;

            _SerialPort.Close();
            _SerialPort.ReadTimeout = SerialPort.InfiniteTimeout;
            _SerialPort.Open();
            _SerialPort.DiscardOutBuffer();
            _SerialPort.DiscardInBuffer();
            for (int i = 0; i < Data.Length; i++)
            {
                _SerialPort.Write(Data[i],0,Data[i].Length);
                Thread.Sleep(200);
            }
            _SerialPort.Write((Checksum + "\r\n"));
            
            byte [] Buffer = new byte[1000];
            _SerialPort.Read(Buffer, 0, 1000);
            //if (Response.Equals("RESEND\r\n"))
            //{
            //    if (this.RWAttempts == 3)
            //    {
            //        return false;
            //    }
            //    return this.WriteData(_SerialPort, Data, Checksum, false);
            //}
            //if (!Response.Equals("OK\r\n"))
            //{
            //    return false;
            //}

            return true;
        }
    }
}
