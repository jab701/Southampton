using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace SpinControl
{
    using SDP;

    public partial class SpinControl : Form
    {
        private UdpClient Socket = null;

        public SpinControl()
        {
            InitializeComponent();
            this.Command_Tab.Enabled = false;
            this.Target_Groupbox.Enabled = false;
            this.Disconnect_Button.Enabled = false;
            this.TagNum_NumUpDown.Maximum = (SDP.IPTAG_MAX);
            this.Socket = null;
        }
        private string [] GenerateHexString(byte[] Data)
        {
            string [] HexString;

            if ((Data.Length % 16) != 0)
            {
                HexString = new string[(Data.Length / 16) + 1];
            }
            else
            {
                HexString = new string[(Data.Length / 16)];
            }

            for (uint i = 0; i < HexString.Length; i++)
            {
                HexString[i] += string.Format("{0:x2}: ", i*16);

                uint JMAX;

                if ((Data.Length % 16 != 0) && (i == (HexString.Length - 1)))
                {
                    JMAX = (uint)(Data.Length % 16);
                }
                else
                {
                    JMAX = 16;
                }

                for (uint j = 0; j < JMAX; j++)
                {
                    HexString[i] += string.Format("{0:x2} ", Data[(i * 16) + j]);
                }
            }
            return HexString;
        }
        private string [] GenerateHexString(ushort[] Data)
        {
            string[] HexString;

            if ((Data.Length % 8) != 0)
            {
                HexString = new string[(Data.Length / 8) + 1];
            }
            else
            {
                HexString = new string[(Data.Length / 8)];
            }

            for (uint i = 0; i < HexString.Length; i++)
            {
                HexString[i] += string.Format("{0:x2}: ", i * 16);

                uint JMAX;

                if ((Data.Length % 8 != 0) && (i == (HexString.Length - 1)))
                {
                    JMAX = (uint)(Data.Length % 8);
                }
                else
                {
                    JMAX = 8;
                }

                for (uint j = 0; j < JMAX; j++)
                {
                    uint Base = (i * 8) + j;
                    HexString[i] += string.Format("{0:x2} {1:x2} ", (byte)Data[Base], (byte)(Data[Base] >> 8));
                }
            }
            return HexString;
        }
        private string [] GenerateHexString(uint[] Data)
        {
            string[] HexString;

            if ((Data.Length % 4) != 0)
            {
                HexString = new string[(Data.Length / 4) + 1];
            }
            else
            {
                HexString = new string[(Data.Length / 4)];
            }

            for (uint i = 0; i < HexString.Length; i++)
            {
                HexString[i] += string.Format("{0:x2}: ", i * 16);

                uint JMAX;

                if ((Data.Length % 4 != 0)&&(i == (HexString.Length -1)))
                {
                    JMAX = (uint)(Data.Length % 4);
                }
                else
                {
                    JMAX = 4;
                }

                for (uint j = 0; j < JMAX; j++)
                {
                    uint Base = (i * 4) + j;
                    HexString[i] += string.Format("{0:x2} {1:x2} {2:x2} {3:x2} ", (byte)Data[Base], (byte)(Data[Base] >> 8), (byte)(Data[Base] >> 16), (byte)(Data[Base] >> 24));
                }
            }
            return HexString;
        }
        private string ConvertStringToHex(String Input)
        {
            string hexOutput = "";
            char[] values = Input.ToCharArray();
            for (uint i = 0; i < values.Length; i++)
            {
                if ((i % 16) == 0)
                {
                    if (i != 0)
                    {
                        hexOutput += '\n';
                    }
                    hexOutput += string.Format("{0:x2}: ", i);
                }
                // Get the byte value of the character.
                byte value = Convert.ToByte(values[i]);
                // Convert the decimal value to a hexadecimal value in string form.
                hexOutput += String.Format("{0:x2} ", value);
            }

            return hexOutput;
        }
        public DateTime UnixTimeToWindowsTime(uint Time)
        {
            DateTime Epoch = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            return Epoch.AddSeconds(Time);
        }
        private void WriteLogLine(string [] Text)
        {
            for (uint i = 0; i < Text.Length; i++)
            {
                DataGridViewRow Row = new DataGridViewRow();

                DataGridViewTextBoxCell Data = new DataGridViewTextBoxCell();

                Data.Value = @Text[i];

                Row.Cells.Add(Data);
                this.Log.Rows.Add(Row);
            }
            int iRow = this.Log.RowCount;
            this.Log.CurrentCell = this.Log.Rows[(iRow - 1)].Cells[0];
            this.Log.CurrentCell.Selected = false;
        }
        private void WriteLogLine(string Text)
        {
            DataGridViewRow Row = new DataGridViewRow();

            DataGridViewTextBoxCell Data = new DataGridViewTextBoxCell();
            
            Data.Value = @Text;

            Row.Cells.Add(Data);
            this.Log.Rows.Add(Row);

            int iRow = this.Log.RowCount;
            this.Log.CurrentCell = this.Log.Rows[(iRow - 1)].Cells[0];
            this.Log.CurrentCell.Selected = false;
        }
        private bool FetchRemoteHost(out string Host)
        {
            Host = this.RHost_TextBox.Text;

            // Check for invalid hostname
            if (Uri.CheckHostName(Host) == UriHostNameType.Unknown)
            {
                string Caption = "Invalid Remote Host";
                string Message = "The Specified Remote Host is not a valid hostname or IP Address";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }

            return true;
        }
        private bool FetchRemotePort(out int Port)
        {
            Port = 0;

            try
            {
                Port = (Int32)Convert.ToUInt16(this.RPort_TextBox.Text);
            }
            catch (System.FormatException)
            {
                string Caption = "Invalid Remote Port";
                string Message = "The Specified Remote Port is not a valid number";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (System.OverflowException)
            {
                string Caption = "Invalid Remote Port";
                string Message = "The Specified Remote Port is outside the valid range (between 0 and 65536)";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private bool FetchNewTagHost(out byte[] IP)
        {
            IP = null;
            string IPStr = this.TagIP_TextBox.Text;

            // Check for invalid hostname
            if (Uri.CheckHostName(IPStr) != UriHostNameType.IPv4)
            {
                string Caption = "Invalid Remote Host";
                string Message = "The Specified Remote Host is not a valid IPv$ Address (x.x.x.x)";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }

            IPAddress IP1 = IPAddress.Parse(IPStr);

            IP = IP1.GetAddressBytes();

            return true;
        }
        private bool FetchNewTagPort(out int Port)
        {
            Port = 0;

            try
            {
                Port = (Int32)Convert.ToUInt16(this.TagPort_Textbox.Text);
            }
            catch (System.FormatException)
            {
                string Caption = "Invalid Tag Port";
                string Message = "The Specified Remote Port is not a valid number";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (System.OverflowException)
            {
                string Caption = "Invalid Tag Port";
                string Message = "The Specified Remote Port is outside the valid range (between 0 and 65536)";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private bool FetchNewTagNum(out uint Tag)
        {
            Tag = decimal.ToUInt32(this.TagNum_NumUpDown.Value);
            return true;
        }
        private void FetchChipxyCPU(out uint Chipx, out uint ChipY, out uint CPU)
        {
            Chipx = (uint)this.ChipX_NumUpDown.Value;
            ChipY = (uint)this.ChipY_NumUpDown.Value;
            CPU = (uint)this.CPU_NumUpDown.Value;
            return; 
        }
        private uint FetchLED0Control()
        {
            uint LED;

            if (LED0Off_Radio.Checked)
            {
                LED = SDP.LED_OFF;
            }
            else if (LED0On_Radio.Checked)
            {
                LED = SDP.LED_ON;
            }
            else
            {
                LED = SDP.LED_INV;
            }

            return LED;
        }
        private uint FetchLED1Control()
        {
            uint LED;

            if (LED1Off_Radio.Checked)
            {
                LED = SDP.LED_OFF;
            }
            else if (LED1On_Radio.Checked)
            {
                LED = SDP.LED_ON;
            }
            else
            {
                LED = SDP.LED_INV;
            }

            return LED;
        }
        private uint FetchLED2Control()
        {
            uint LED;

            if (LED2Off_Radio.Checked)
            {
                LED = SDP.LED_OFF;
            }
            else if (LED2On_Radio.Checked)
            {
                LED = SDP.LED_ON;
            }
            else
            {
                LED = SDP.LED_INV;
            }

            return LED;
        }
        private uint FetchLED3Control()
        {
            uint LED;

            if (LED3Off_Radio.Checked)
            {
                LED = SDP.LED_OFF;
            }
            else if (LED3On_Radio.Checked)
            {
                LED = SDP.LED_ON;
            }
            else
            {
                LED = SDP.LED_INV;
            }

            return LED;
        }
        private byte[] FetchSelectedExecuteCores()
        {
            int NumberSelectedItems = this.ExecutionCoreSelect_CheckboxList.CheckedItems.Count;

            string[] Items = new string[NumberSelectedItems];

            for (int i = 0; i < NumberSelectedItems; i++)
            {
                Items[i] = this.ExecutionCoreSelect_CheckboxList.CheckedItems[i].ToString();
            }

            byte[] SelectedCores = new byte[NumberSelectedItems];

            for (int i = 0; i < NumberSelectedItems; i++)
            {
                int Index = Items[i].IndexOf(' ');
                Items[i] = Items[i].Substring(Index + 1);
                Index = Items[i].IndexOf(' ');

                if (Index == -1)
                {
                    SelectedCores[i] = Convert.ToByte(Items[i]);
                }
                else
                {
                    string Number;
                    Number = Items[i].Substring(0, Index);
                    SelectedCores[i] = Convert.ToByte(Number);
                }
            }

            return SelectedCores;
        }
        private byte[] FetchSelectedFFCores()
        {
            int NumberSelectedItems = this.FFCoreSelect_CheckboxList.CheckedItems.Count;

            string[] Items = new string[NumberSelectedItems];

            for (int i = 0; i < NumberSelectedItems; i++)
            {
                Items[i] = this.FFCoreSelect_CheckboxList.CheckedItems[i].ToString();
            }

            byte[] SelectedCores = new byte[NumberSelectedItems];

            for (int i = 0; i < NumberSelectedItems; i++)
            {
                int Index = Items[i].IndexOf(' ');
                Items[i] = Items[i].Substring(Index + 1);
                Index = Items[i].IndexOf(' ');

                if (Index == -1)
                {
                    SelectedCores[i] = Convert.ToByte(Items[i]);
                }
                else
                {
                    string Number;
                    Number = Items[i].Substring(0, Index);
                    SelectedCores[i] = Convert.ToByte(Number);
                }
            }

            return SelectedCores;
        }
        bool ReadBinaryFile(string Filename, out byte[] Data)
        {
            Data = null;

            if (!File.Exists(Filename))
            {
                string Caption = "File Does Not Exist";
                string Message = string.Format("File {0} does not exist, please check and try again", @Filename);
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }

            FileInfo f = new FileInfo(Filename);

            uint FileLength = (uint)f.Length;

            BinaryReader binReader = new BinaryReader(File.Open(Filename, FileMode.Open));

            Data = new byte[FileLength];

            try
            {
                int count = binReader.Read(Data, 0, (int)FileLength);

                if (count != FileLength)
                {
                    Data = null;
                    return false;
                }
            }
            catch (EndOfStreamException e)
            {
                // We should never get here, we shoudl read the length of the data int eh file and thats it!
                binReader.Close();
                Data = null;
                return false;
            }
            catch (ArgumentException)
            {
                string Caption = "Invalid File Path";
                string Message = "path is a zero-length string, contains only white space, or contains one or more invalid characters";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (PathTooLongException)
            {
                string Caption = "Invalid File Path";
                string Message = "The specified path, file name, or both exceed the system-defined maximum length. For example, on Windows-based platforms, paths must be less than 248 characters, and file names must be less than 260 characters.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (DirectoryNotFoundException)
            {
                string Caption = "Invalid File Path";
                string Message = "The specified path is invalid, (for example, it is on an unmapped drive).";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (FileNotFoundException)
            {
                string Caption = "Invalid File";
                string Message = "The file specified in path was not found.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (IOException)
            {
                string Caption = "File Error";
                string Message = "An I/O error occurred while opening the file. ";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (UnauthorizedAccessException)
            {
                string Caption = "Access Error";
                string Message = "File or Path is read-only or the user does not have the required permission to write to the directory/file";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }
            catch (NotSupportedException)
            {
                string Caption = "Unsupported Path";
                string Message = "path is in an invalid format.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Data = null;
                binReader.Close();
                return false;
            }

            binReader.Close();
            return true;
        }
        bool WriteBinaryFile(string Filename, byte[] Data)
        {
            BinaryWriter binWriter;

            try
            {
                binWriter = new BinaryWriter(File.Open(Filename, FileMode.Create));
                binWriter.Write(Data);
            }
            catch (ArgumentException)
            {
                string Caption = "Invalid File Path";
                string Message = "path is a zero-length string, contains only white space, or contains one or more invalid characters";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (PathTooLongException)
            {
                string Caption = "Invalid File Path";
                string Message = "The specified path, file name, or both exceed the system-defined maximum length. For example, on Windows-based platforms, paths must be less than 248 characters, and file names must be less than 260 characters.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (DirectoryNotFoundException)
            {
                string Caption = "Invalid File Path";
                string Message = "The specified path is invalid, (for example, it is on an unmapped drive).";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (FileNotFoundException)
            {
                string Caption = "Invalid File";
                string Message = "The file specified in path was not found.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (IOException e)
            {
                string Caption = "File Error";
                string Message = string.Format("An I/O error occurred while opening the file.\n\n{0}", e.ToString());
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (UnauthorizedAccessException)
            {
                string Caption = "Access Error";
                string Message = "File or Path is read-only or the user does not have the required permission to write to the directory/file";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (NotSupportedException)
            {
                string Caption = "Unsupported Path";
                string Message = "path is in an invalid format.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }

            binWriter.Close();

            FileInfo f = new FileInfo(Filename);

            uint FileLength = (uint)f.Length;

            if (FileLength != Data.Length)
            {
                string Caption = "File Length Incorrect";
                string Message = "The length of the data and the written length is inconsistent";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }

            return true;
        }
        private void RefreshTags()
        {
            SCP CMD = new SCP();

            CMD.Set_Chip((byte)0, (byte)0, (byte)0);

            iptag_t[] Tags;

            uint RC = CMD.iptag_get_all(ref Socket, out Tags);

            string ResponseStr = string.Format("Refresh Tags Operation: {0}", SDP.ParseResponseCode(RC));
            this.WriteLogLine(ResponseStr);

            if (RC == SDP.RC_OK)
            {
                this.IPTAG_ListBox.Items.Clear();

                for (uint i = 0; i < Tags.Length; i++)
                {
                    iptag_t T = Tags[i];

                    if (T.Flags != 0)
                    {
                        if (i < SDP.IPTAG_MAX+1)
                        {
                            byte[] IP = T.IP;
                            string TagStr = String.Format("{0}: {1}.{2}.{3}.{4}:{5}", i, IP[0], IP[1], IP[2], IP[3], T.Port);
                            this.IPTAG_ListBox.Items.Add(TagStr);
                        }
                        else
                        {
                            byte[] IP = T.IP;
                            string TagStr = String.Format("{0}: {1}.{2}.{3}.{4}:{5} (TEMP TAG)", i, IP[0], IP[1], IP[2], IP[3], T.Port);
                            this.IPTAG_ListBox.Items.Add(TagStr);
                        }
                    }
                }
                //DateTime BuildDate = this.UnixTimeToWindowsTime(VersionData.time);
                //string BuildDateStr = BuildDate.ToString("dd/MM/yyyy hh:mm:ss");

                //System.Text.Encoding enc = System.Text.Encoding.ASCII;
                //string VersionStr = enc.GetString(VersionData.ver_string);

                //string LogString = string.Format("{0}:{1}:{2} - {3}, Version {4} - {5}", VersionData.chip_x, VersionData.chip_y,
                //                                                                         VersionData.v_cpu, @VersionStr,
                //                                                                         VersionData.ver_num, BuildDateStr);
                //this.WriteLogLine(LogString);
            }

            CMD = null;
        }

        // BUTTON CALLBACKS
        // General Buttons
        private void Connect_Button_Click(object sender, EventArgs e)
        {
            if (this.Socket == null)
            {
                string Host;
                int Port;

                if (!this.FetchRemoteHost(out Host))
                {
                    return;
                }

                if (!this.FetchRemotePort(out Port))
                {
                    return;
                }

                this.Socket = new UdpClient();

                try
                {
                    this.Socket.Connect(Host, Port);
                }
                catch (System.Net.Sockets.SocketException err)
                {
                    Console.WriteLine("Error while connecting to remote host: " + err.Message);
                    Console.WriteLine("Aborting!");
                    return;
                }
                this.RHost_TextBox.Enabled = false;
                this.RPort_TextBox.Enabled = false;
                this.Connect_Button.Enabled = false;
                this.Disconnect_Button.Enabled = true;
                this.Command_Tab.Enabled = true;
                this.Target_Groupbox.Enabled = true;
                this.RefreshTags();
            }

            return;
        }
        private void Disconnect_Button_Click(object sender, EventArgs e)
        {
            if (this.Socket != null)
            {
                this.RHost_TextBox.Enabled = true;
                this.RPort_TextBox.Enabled = true;
                this.Connect_Button.Enabled = true;
                this.Disconnect_Button.Enabled = false;
                this.Command_Tab.Enabled = false;
                this.Target_Groupbox.Enabled = false;


                this.Socket.Close();
                this.Socket = null;
            }
            return;
        }
        private void SpinnVersion_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            SCP CMD = new SCP();

            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            sver_t VersionData;
            uint RC = CMD.sver(ref this.Socket, out VersionData);

            if (RC == SDP.RC_OK)
            {
                DateTime BuildDate = this.UnixTimeToWindowsTime(VersionData.time);
                string BuildDateStr = BuildDate.ToString("dd/MM/yyyy hh:mm:ss");

                System.Text.Encoding enc = System.Text.Encoding.ASCII;
                string VersionStr = enc.GetString(VersionData.ver_string);

                string LogString = string.Format("{0}:{1}:{2} - {3}, Version {4} - {5}", VersionData.chip_x, VersionData.chip_y,
                                                                                         VersionData.v_cpu, @VersionStr,
                                                                                         VersionData.ver_num, BuildDateStr);
                this.WriteLogLine(LogString);
            }
            else
            {
                string ResponseStr = SDP.ParseResponseCode(RC);
                this.WriteLogLine(ResponseStr);
            }

            CMD = null;
        }
        private void LogClear_Button_Click(object sender, EventArgs e)
        {
            this.Log.Rows.Clear();
        }

        // Basic Command Buttons
        // -- Tag Buttons
        private void TagRefresh_Button_Click(object sender, EventArgs e)
        {
            this.RefreshTags();
        }
        private void RemoveTag_Button_Click(object sender, EventArgs e)
        {
            int NumberSelectedItems = this.IPTAG_ListBox.CheckedItems.Count;

            string [] Items = new string[NumberSelectedItems];

            for(int i=0; i < NumberSelectedItems; i++)
            {
                Items[i] = this.IPTAG_ListBox.CheckedItems[i].ToString();
            }

            byte[] SelectedTags = new byte[NumberSelectedItems];

            for (int i = 0; i < NumberSelectedItems; i++)
            {
                int Index = Items[i].IndexOf(':');
                string Number = Items[i].Substring(0, Index);
                SelectedTags[i] = Convert.ToByte(Number);
            }

            SCP CMD = new SCP();

            CMD.Set_Chip((byte)0, (byte)0, (byte)0);

            foreach (byte b in SelectedTags)
            {
                if (b < SDP.IPTAG_MAX+1)
                {
                    uint RC = CMD.iptag_clr(ref this.Socket, (uint)b);

                    string ResponseStr = string.Format("Remove Tag {0}: {1}", b, SDP.ParseResponseCode(RC));
                    this.WriteLogLine(ResponseStr);
                }
                else
                {
                    string ResponseStr = string.Format("Remove Tag {0}: Denied (Temporary Tag)", b);
                    this.WriteLogLine(ResponseStr);
                }
            }

            CMD = null;

            this.RefreshTags();
            return;
        }
        private void AddTag_Button_Click(object sender, EventArgs e)
        {
            byte[] IP;
            int Port;
            uint Tag;

            if (!this.FetchNewTagHost(out IP))
            {
                return;
            }

            if (!this.FetchNewTagPort(out Port))
            {
                return;
            }

            this.FetchNewTagNum(out Tag);

            SCP CMD = new SCP();

            CMD.Set_Chip((byte)0, (byte)0, (byte)0);

            ushort RC = CMD.iptag_set(ref this.Socket, IP, (uint)Port, Tag);

            if (RC == SDP.RC_OK)
            {
                string LogString = string.Format("Add Tag {0}:{1}.{2}.{3}.{4}:{5} - {6}", Tag, IP[0], IP[1], IP[2], IP[3], Port, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }
            else
            {
                string ResponseStr = SDP.ParseResponseCode(RC);
                this.WriteLogLine(ResponseStr);
            }

            this.RefreshTags();

        }
        // -- LED Buttons
        private void SendLED_Button_Click(object sender, EventArgs e)
        {
            uint LED0 = this.FetchLED0Control();
            uint LED1 = this.FetchLED1Control();
            uint LED2 = this.FetchLED2Control();
            uint LED3 = this.FetchLED3Control();

            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            SCP CMD = new SCP();

            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            ushort RC = CMD.led(ref this.Socket, (byte)LED0, (byte)LED1, (byte)LED2, (byte)LED3);

            string LogString = string.Format("Update LEDs: {0}", SDP.ParseResponseCode(RC));
            this.WriteLogLine(LogString);
        }

        // Read Command Buttons
        private void ReadBytes_Radio_CheckedChanged(object sender, EventArgs e)
        {
            this.ReadBytes_NumUpDown.Maximum = 256;
        }
        private void ReadHalfwords_radio_CheckedChanged(object sender, EventArgs e)
        {
            this.ReadBytes_NumUpDown.Maximum = 128;
        }
        private void ReadWords_Radio_CheckedChanged(object sender, EventArgs e)
        {
            this.ReadBytes_NumUpDown.Maximum = 64;
        }
        private void ReadBytes_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            string AddrStr = this.ReadAddr_Textbox.Text;
            uint Address = 0;

            try
            {
                Address = uint.Parse(AddrStr, System.Globalization.NumberStyles.HexNumber);
            }
            catch
            {
                string Caption = "Invalid Read Address";
                string Message = "Addresses must be hexadecimal numbers without the preceeding '0x'\nFor Example: '0x123' should be entered as '123'";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            uint NumberToRead = (uint)this.ReadBytes_NumUpDown.Value;

            byte[] ReadBytes = null;
            ushort[] ReadShorts = null;
            uint[] ReadInts = null;

            SCP CMD = new SCP();
            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            ushort RC;

            if (this.ReadBytes_Radio.Checked)
            {
                RC = CMD.mem_read(ref this.Socket, Address, NumberToRead, out ReadBytes);

                string LogString = string.Format("Read {0} Bytes from Address 0x{1:x} on {2}:{3}:{4}: {5}", ReadBytes.Length, Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);

                string [] DataString = this.GenerateHexString(ReadBytes);
                this.WriteLogLine(DataString);
            }
            else if (this.ReadHalfwords_radio.Checked)
            {
                RC = CMD.mem_read(ref this.Socket, Address, NumberToRead, out ReadShorts);

                string LogString = string.Format("Read {0} Shorts from Address 0x{1:x} on {2}:{3}:{4}: {5}", ReadShorts.Length, Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);

                string [] DataString = this.GenerateHexString(ReadShorts);
                this.WriteLogLine(DataString);
            }
            else
            {
                RC = CMD.mem_read(ref this.Socket, Address, NumberToRead, out ReadInts);

                string LogString = string.Format("Read {0} Words from Address 0x{1:x} on {2}:{3}:{4}: {5}", ReadInts.Length, Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);

                string [] DataString = this.GenerateHexString(ReadInts);
                this.WriteLogLine(DataString);
            }

            ReadBytes = null;
            ReadShorts = null;
            ReadInts = null;

            CMD = null;
        }
        private void ReadDumpBrowseFile_Button_Click(object sender, EventArgs e)
        {
            SaveFileDialog Dialog = new SaveFileDialog();
            string CurrentPath = this.ReadDumpFile_Textbox.Text;

            try
            {
                CurrentPath = Path.GetFullPath(CurrentPath);
            }
            catch
            {
                CurrentPath = @"c:\";
            }

            Dialog.InitialDirectory = @CurrentPath;
            Dialog.Filter = "All Files (*.*)|*.*";
            Dialog.FilterIndex = 0;

            if (Dialog.ShowDialog() == DialogResult.OK)
            {
                this.ReadDumpFile_Textbox.Text = Dialog.FileName.ToString();
            } 

        }
        private void ReadDump_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            string AddrStr = this.ReadDumpAddr_Textbox.Text;
            uint Address = 0;
            uint Length = (uint)this.ReadDump_NumericUpDown.Value;

            string FileName = this.ReadDumpFile_Textbox.Text;

            try
            {
                Address = uint.Parse(AddrStr, System.Globalization.NumberStyles.HexNumber);
            }
            catch
            {
                string Caption = "Invalid Read Address";
                string Message = "Addresses must be hexadecimal numbers without the preceeding '0x'\nFor Example: '0x123' should be entered as '123'";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            SCP CMD = new SCP();
            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            byte[] Data;
            ushort RC = CMD.sdump(ref this.Socket, Address, Length, out Data);

            string LogString;

            if (RC != SDP.RC_OK)
            {
                LogString = string.Format("Read {0} bytes from address 0x{1:x} on {2}:{3}:{4}: {5}", Length, Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
                return;
            }
            else
            {
                LogString = string.Format("Read {0} bytes from address 0x{1:x} on {2}:{3}:{4}: {5}", Data.Length, Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }


            if (!this.WriteBinaryFile(FileName, Data))
            {
                LogString = string.Format("Failed to save data to file {0}", FileName);
                this.WriteLogLine(LogString);
                return;
            }

            LogString = string.Format("Saved {0} bytes to file {1}", Data.Length, FileName);
            this.WriteLogLine(LogString);
            return;
        }

        // Write Command Buttons
        private void WriteBytes_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);
 
            // Grab the data from the address box
            string AddrStr = this.WriteBaseMem_TextBox.Text;
            // Grab the data from the Data Box
            string DataStr = this.WriteData_TextBox.Text;
            uint Address = 0;
            int Data = 0;

            try
            {
                // Check Address is a valid number
                Address = uint.Parse(AddrStr, System.Globalization.NumberStyles.HexNumber);
            }
            catch
            {
                string Caption = "Invalid Read Address";
                string Message = "Addresses must be hexadecimal numbers without the preceeding '0x'\nFor Example: '0x123' should be entered as '123'";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                // Check Data is a valid number
                Data = int.Parse(DataStr, System.Globalization.NumberStyles.HexNumber);
            }
            catch
            {
                string Caption = "Invalid Data";
                string Message = "Data must be hexadecimal numbers without the preceeding '0x'\nFor Example: '0x123' should be entered as '123'";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            SCP CMD = new SCP();
            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);
            ushort RC;

            if (this.WriteByte_Radio.Checked)
            {
                RC = CMD.mem_write(ref this.Socket, Address, (byte)Data);

                string LogString = string.Format("Write Byte to Address 0x{0:x} on {1}:{2}:{3}: {4}", Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }
            else if (this.WriteShort_Radio.Checked)
            {
                RC = CMD.mem_write(ref this.Socket, Address, (ushort)Data);

                string LogString = string.Format("Write Short to Address 0x{0:x} on {1}:{2}:{3}: {4}", Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }
            else
            {
                RC = CMD.mem_write(ref this.Socket, Address, (uint)Data);

                string LogString = string.Format("Write Word to Address 0x{0:x} on {1}:{2}:{3}: {4}", Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }

            CMD = null;
        }
        private void WriteBrowse_Button_Click(object sender, EventArgs e)
        {
            OpenFileDialog Dialog = new OpenFileDialog();
            string CurrentPath = this.WriteFileLocation_Textbox.Text;

            try
            {
                CurrentPath = Path.GetFullPath(CurrentPath);
            }
            catch
            {
                CurrentPath = @"c:\";
            }

            Dialog.InitialDirectory = @CurrentPath;
            Dialog.Filter = "APLX Files (*.aplx)|*.aplx|All Files (*.*)|*.*";
            Dialog.FilterIndex = 0;

            if (Dialog.ShowDialog() == DialogResult.OK)
            {
                this.WriteFileLocation_Textbox.Text = Dialog.FileName.ToString();
            }            
        }
        private void LoadMemory_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            string AddrStr = this.WriteLoadAddress_Textbox.Text;
            uint Address = 0;

            try
            {
                Address = uint.Parse(AddrStr, System.Globalization.NumberStyles.HexNumber);
            }
            catch
            {
                string Caption = "Invalid Load Address";
                string Message = "Addresses must be hexadecimal numbers without the preceeding '0x'\nFor Example: '0x123' should be entered as '123'";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            byte [] Data;

            if (!this.ReadBinaryFile(this.WriteFileLocation_Textbox.Text,out Data))
            {
                return;
            }

            SCP CMD = new SCP();
            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            ushort RC = CMD.sload(ref this.Socket, Address, Data);

            string LogString = string.Format("Load file to address 0x{0:x} on {1}:{2}:{3}: {4}", Address, ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
            this.WriteLogLine(LogString);

        }

        // Execution Buttons
        private void ExecutionRun_Button_Click(object sender, EventArgs e)
        {
            uint ChipX;
            uint ChipY;
            uint CPU;

            this.FetchChipxyCPU(out ChipX, out ChipY, out CPU);

            string AddrStr = this.ExecutionLoadMem_TextBox.Text;
            uint Address = uint.Parse(AddrStr, System.Globalization.NumberStyles.HexNumber);

            byte[] SelectedCores = this.FetchSelectedExecuteCores();

            ushort RC = 0;
            SCP CMD = new SCP();

            if (SelectedCores.Length == 0)
            {
                CMD = null;
                return;
            }
            else if (SelectedCores.Length == 1)
            {
                CMD.Set_Chip((byte)ChipX, (byte)ChipY, SelectedCores[0]);
                RC = CMD.aplx(ref this.Socket, Address);

                string LogString = string.Format("APLX -> {0:x} on {1}:{2}:{3} - {4}", Address, ChipX, ChipY, SelectedCores[0], SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }
            else
            {
                CMD.Set_Chip((byte)ChipX, (byte)ChipY, 0);

                uint Mask = 0;
                string CoreList = "";

                for (uint i = 0; i < SelectedCores.Length; i++)
                {
                    uint MaskBit = (uint) (1 << SelectedCores[i]);

                    Mask |= MaskBit;

                    CoreList += string.Format("{0},", SelectedCores[i]);
                }

                RC = CMD.appstart(ref this.Socket, Address, Mask);

                CoreList = CoreList.Substring(0, CoreList.Length - 1);
                string LogString = string.Format("AS -> {0:x} on {1}:{2} - Cores {3} - {4}", Address, ChipX, ChipY, CoreList, SDP.ParseResponseCode(RC));
                this.WriteLogLine(LogString);
            }

            CMD = null;
            return;
        }

        // Flood Fill Buttons
        private void FFBrowse_Button_Click(object sender, EventArgs e)
        {
            OpenFileDialog Dialog = new OpenFileDialog();
            string CurrentPath = this.FFFileLocation_Textbox.Text;

            try
            {
                CurrentPath = Path.GetFullPath(CurrentPath);
            }
            catch
            {
                CurrentPath = @"c:\";
            }

            Dialog.InitialDirectory = @CurrentPath;
            Dialog.Filter = "APLX Files (*.aplx)|*.aplx|All Files (*.*)|*.*";
            Dialog.FilterIndex = 0;

            if (Dialog.ShowDialog() == DialogResult.OK)
            {
                this.FFFileLocation_Textbox.Text = Dialog.FileName.ToString();
            }  
        }
        private void FF_Go_Click(object sender, EventArgs e)
        {
            byte[] Data;

            if (!this.ReadBinaryFile(this.FFFileLocation_Textbox.Text, out Data))
            {
                return;
            }

            byte[] SelectedCores = this.FetchSelectedFFCores();

            if (SelectedCores.Length == 0)
            {
                return;
            }

            ushort RC = 0;
            SCP CMD = new SCP();

            CMD.Set_Chip(0, 0, 0);

            uint Mask = 0;
            string CoreList = "";

            for (uint i = 0; i < SelectedCores.Length; i++)
            {
                uint MaskBit = (uint)(1 << SelectedCores[i]);

                Mask |= MaskBit;

                CoreList += string.Format("{0},", SelectedCores[i]);
            }

            RC = CMD.ff(ref this.Socket, Data, Mask);

            CoreList = CoreList.Substring(0, CoreList.Length - 1);
            string LogString = string.Format("FF -> on cores {0} - {1}", CoreList, SDP.ParseResponseCode(RC));
            this.WriteLogLine(LogString);


            CMD = null;
            return;
        }

        // Board Setup - P2P
        private void BoardSetup_P2P_Click(object sender, EventArgs e)
        {
            byte X = (byte)this.BoardSetup_P2PX_NumUpDown.Value;
            byte Y = (byte)this.BoardSetup_P2PY_NumUpDown.Value;

            SCP CMD = new SCP();
            CMD.Set_Chip((byte)0, (byte)0, (byte)0);

            ushort RC = CMD.p2pc(ref this.Socket, X, Y);

            string LogString = string.Format("Board Setup - P2PC : {0}", SDP.ParseResponseCode(RC));
            this.WriteLogLine(LogString);
        }

        // Boot a board in alternate boot mode.
        private void bootBoardToolStripMenuItem_Click(object sender, EventArgs e)
        {
            AltBoot BootForm = new AltBoot();
            BootForm.ShowDialog();
        }

        private void SpinControl_Load(object sender, EventArgs e)
        {

        }
  }
}
