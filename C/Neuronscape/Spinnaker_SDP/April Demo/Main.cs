using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Resources;

namespace April_Demo
{
    using SDP;

    public partial class Main : Form
    {
        private UdpClient Socket = null;
        private UdpClient ListenSocket = null;
        private bool Running = false;
        private UDPState StateObj;

        // Delegate Declarations
        public delegate void WriteLogLineCallback(string Text);
        public delegate void WriteLogLineCallbackArray(string [] Text);

        public Main()
        {
            InitializeComponent();
            this.GetLocalInterfaces();
            this.Socket = new UdpClient();
        }
        private string[] GenerateHexString(byte[] Data)
        {
            string[] HexString;

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
                HexString[i] += string.Format("{0:x2}: ", i * 16);

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
        private string[] GenerateHexString(ushort[] Data)
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
        private string[] GenerateHexString(uint[] Data)
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

                if ((Data.Length % 4 != 0) && (i == (HexString.Length - 1)))
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
        private void WriteLogLine(string[] Text)
        {
            if (this.Log.InvokeRequired)
            {
                WriteLogLineCallbackArray d = new WriteLogLineCallbackArray(WriteLogLine);
                this.Invoke(d, new object[] { Text });
            }
            else
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
        }
        private void WriteLogLine(string Text)
        {

            if (this.Log.InvokeRequired)
            {
                WriteLogLineCallback d = new WriteLogLineCallback(WriteLogLine);
                this.Invoke(d, new object[] { Text });
            }
            else
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
        private bool FetchInterface(out string Interface)
        {
            int Selected = this.Interfaces.SelectedIndex;
            Interface = this.Interfaces.Items[Selected].ToString();
            return true;
        }
        private void GetLocalInterfaces()
        {
            string strHostName = "";
            strHostName = System.Net.Dns.GetHostName();


            IPHostEntry ipEntry = System.Net.Dns.GetHostEntry(strHostName);

            foreach (IPAddress A in ipEntry.AddressList)
            {
                UriHostNameType Host = Uri.CheckHostName(A.ToString());

                // for now lets ignore IPV6
                if ((Host != UriHostNameType.Unknown) && (Host != UriHostNameType.IPv6))
                {
                    this.Interfaces.Items.Add(A.ToString());
                }
            }

            this.Interfaces.SelectedIndex = 0;
            return;
        }
        private void StartListening()
        {
            if (Running == false)
            {
                IPEndPoint endpoint = new IPEndPoint(IPAddress.Any, (int)ListenPort_NumUpDown.Value);
                this.ListenSocket = new UdpClient(endpoint);

                this.StateObj = new UDPState();
                this.StateObj.e = endpoint;
                this.StateObj.u = this.ListenSocket;

                this.ListenSocket.BeginReceive(new AsyncCallback(ReceiveCallback), this.StateObj);
                this.Running = true;
            }
        }
        private void StopListening()
        {
            if (Running == true)
            {
                this.Running = false;
                this.ListenSocket.Close();
            }
        }
        // UDP Socket Receive Data Callback
        public void ReceiveCallback(IAsyncResult ar)
        {
            if (this.Running == true)
            {
                try
                {
                    DateTime CurrentDT = DateTime.Now;

                    UdpClient u = (UdpClient)((UDPState)(ar.AsyncState)).u;
                    IPEndPoint e = (IPEndPoint)((UDPState)(ar.AsyncState)).e;

                    Byte[] receiveBytes = u.EndReceive(ar, ref e);

                    sdp_hdr_t Header = new sdp_hdr_t();
                    byte[] HeaderBytes = new byte[8];
                    Array.Copy(receiveBytes, 2, HeaderBytes, 0, 8);
                    Header.bytes = HeaderBytes;

                    byte CPU_x = (byte)(Header.srce_addr >> 8);
                    byte CPU_y = (byte)(Header.srce_addr);
                    string Source = string.Format("{0}:{1}:{2}:{3}", CPU_x, CPU_y, Header.srce_cpu, Header.srce_port);


                    sdp_cmd_t Command = new sdp_cmd_t();
                    byte[] CommandBytes = new byte[receiveBytes.Length - 10];
                    Array.Copy(receiveBytes, 10, CommandBytes, 0, CommandBytes.Length);
                    Command.bytes = CommandBytes;

                    byte[] arg1bytes = BitConverter.GetBytes(Command.arg1);
                    byte[] arg2bytes = BitConverter.GetBytes(Command.arg2);
                    byte[] arg3bytes = BitConverter.GetBytes(Command.arg3);
                    byte[] DataBytes = Command.data;

                    string Data = "";
                    System.Text.Encoding enc = System.Text.Encoding.ASCII;
                    Data = enc.GetString(arg1bytes);
                    Data += enc.GetString(arg2bytes);
                    Data += enc.GetString(arg3bytes);
                    Data += enc.GetString(DataBytes);

                    if (Command.cmd_rc != SDP.CMD_TUBE)
                    {
                        Data = this.ConvertStringToHex(Data);
                    }

                    Data = string.Format("{0} :- {1}", Source, Data);
                    this.WriteLogLine(Data);


                    this.ListenSocket.BeginReceive(new AsyncCallback(ReceiveCallback), this.StateObj);
                }
                catch (System.ObjectDisposedException e)
                {
                    // We might end up here if the socket is closed and collected while waiting on data
                    // Ignore the error and we return.
                    return;
                }
            }
        }

        private void Boot_Click(object sender, EventArgs e)
        {
            string Host;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, (int)SDP.BOOT_PORT);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }

            // Get the data from the resource file
            byte[] Data = April_Demo.Boot.scamp_0_96;

            SCP CMD = new SCP();
            

            CMD.boot(ref this.Socket, Data);

            this.WriteLogLine("Status: Pausing while board boots");

            Thread.Sleep(3000);

            this.Socket.Connect(Host, 17893);

            CMD.Set_Chip(0, 0, 0);

            sver_t VersionData;

            ushort RC = CMD.sver(ref this.Socket, out VersionData);

            if (RC == SDP.RC_OK)
            {
                DateTime BuildDate = this.UnixTimeToWindowsTime(VersionData.time);
                string BuildDateStr = BuildDate.ToString("dd/MM/yyyy hh:mm:ss");

                System.Text.Encoding enc = System.Text.Encoding.ASCII;

                byte[] VerString = new byte[VersionData.ver_string.Length - 1];

                Array.Copy(VersionData.ver_string, VerString, VerString.Length);

                string VersionStr = enc.GetString(VerString);

                this.WriteLogLine(string.Format("Status: Running Software {0}, Version {1} - {2}", @VersionStr, VersionData.ver_num, BuildDateStr));
            }
            else
            {
                this.WriteLogLine("Status: Failed, Could not verify board was booted successfully");
            }

            return;
        }

        private void Load_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }

            SCP CMD = new SCP();

            // If the Redirect Checkbox is set
            if (this.RedirectStdIO_CheckBox.Checked == true)
            {
                string IP_Str;
                this.FetchInterface(out IP_Str);
                IPAddress Address = IPAddress.Parse(IP_Str);

                if (CMD.iptag_set(ref this.Socket, Address.GetAddressBytes(), (uint)ListenPort_NumUpDown.Value, (uint)0) != SDP.RC_OK)
                {
                    this.WriteLogLine("Status: An error occurred when setting the IP Tag. Please check the spinnaker board and try again.");
                    return;
                }

                this.StartListening();
            }

            // Get the data from the resource file
            byte[] Data = April_Demo.Boot.lightfollow;
 
            if (CMD.sload(ref this.Socket, 0x70000000, Data) != SDP.RC_OK)
            {
                // Failed to Write To Memory
                this.WriteLogLine("Status: An error occurred when loading program into memory. Please check the spinnaker board and try again.");
                this.StopListening();
                return;
            }

            CMD.Set_Chip(0, 0, (byte)this.Sim1Proc.Value);
            CMD.aplx(ref this.Socket, 0x70000000);

            CMD.Set_Chip(0, 0, (byte)this.Sim2Proc.Value);
            CMD.aplx(ref this.Socket, 0x70000000);

            CMD.Set_Chip(0, 0, (byte)this.Sim3Proc.Value);
            CMD.aplx(ref this.Socket, 0x70000000);
        }

        private void Sim1_TXSettings_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte CPU = (byte)this.Sim1Proc.Value;
            uint Tag = (uint)this.Sim1_TagSelect.Value;
            uint Time = (uint)this.Sim1ExecuteTimer.Value;
            uint Threshold = (uint)this.Sim1Threshold.Value;
            uint EatThreshold = (uint)this.Sim1EatThreshold.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }


            SimControlComms SimCmd = new SimControlComms();

            SimCmd.ChTag(ref Socket, Tag, CPU);
            SimCmd.ChTick(ref Socket, Time, CPU);
            SimCmd.ChThreshold(ref Socket, Threshold, CPU);
            SimCmd.ChEatThreshold(ref Socket, EatThreshold, CPU);
        }

        private void Sim2_TXSettings_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte CPU = (byte)this.Sim2Proc.Value;
            uint Tag = (uint)this.Sim2_TagSelect.Value;
            uint Time = (uint)this.Sim2ExecuteTimer.Value;
            uint Threshold = (uint)this.Sim2Threshold.Value;
            uint EatThreshold = (uint)this.Sim2EatThreshold.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }


            SimControlComms SimCmd = new SimControlComms();

            SimCmd.ChTag(ref Socket, Tag, CPU);
            SimCmd.ChTick(ref Socket, Time, CPU);
            SimCmd.ChThreshold(ref Socket, Threshold, CPU);
            SimCmd.ChEatThreshold(ref Socket, EatThreshold, CPU);
        }

        private void Sim3_TXSettings_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte CPU = (byte)this.Sim3Proc.Value;
            uint Tag = (uint)this.Sim3_TagSelect.Value;
            uint Time = (uint)this.Sim3ExecuteTimer.Value;
            uint Threshold = (uint)this.Sim3Threshold.Value;
            uint EatThreshold = (uint)this.Sim3EatThreshold.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }


            SimControlComms SimCmd = new SimControlComms();

            SimCmd.ChTag(ref Socket, Tag, CPU);
            SimCmd.ChTick(ref Socket, Time, CPU);
            SimCmd.ChThreshold(ref Socket, Threshold, CPU);
            SimCmd.ChEatThreshold(ref Socket, EatThreshold, CPU);
        }

        private void Start_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte Cpu1 = (byte)this.Sim1Proc.Value;
            byte Cpu2 = (byte)this.Sim2Proc.Value;
            byte Cpu3 = (byte)this.Sim3Proc.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }

            SimControlComms SimCmd = new SimControlComms();

            SimCmd.StartSimulation(ref Socket, Cpu1);
            SimCmd.StartSimulation(ref Socket, Cpu2);
            SimCmd.StartSimulation(ref Socket, Cpu3);
        }

        private void Pause_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte Cpu1 = (byte)this.Sim1Proc.Value;
            byte Cpu2 = (byte)this.Sim2Proc.Value;
            byte Cpu3 = (byte)this.Sim3Proc.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }

            SimControlComms SimCmd = new SimControlComms();

            SimCmd.PauseSimulation(ref Socket, Cpu1);
            SimCmd.PauseSimulation(ref Socket, Cpu2);
            SimCmd.PauseSimulation(ref Socket, Cpu3);
        }

        private void Kill_Click(object sender, EventArgs e)
        {
            string Host;
            int Port;
            byte Cpu1 = (byte)this.Sim1Proc.Value;
            byte Cpu2 = (byte)this.Sim2Proc.Value;
            byte Cpu3 = (byte)this.Sim3Proc.Value;

            // Get the Remote Host Name
            if (!this.FetchRemoteHost(out Host))
            {
                return;
            }

            // Get the Remote Port
            if (!this.FetchRemotePort(out Port))
            {
                return;
            }

            try
            {
                this.Socket.Connect(Host, Port);
            }
            catch
            {
                this.WriteLogLine("Status: Connecting to Host Failed (Maybe does not exist?).");
                return;
            }

            SimControlComms SimCmd = new SimControlComms();

            SimCmd.ExitSimulation(ref Socket, Cpu1);
            SimCmd.ExitSimulation(ref Socket, Cpu2);
            SimCmd.ExitSimulation(ref Socket, Cpu3);
        }

        private void LogClear_Button_Click(object sender, EventArgs e)
        {
            this.Log.Rows.Clear();
        }
    }
}
