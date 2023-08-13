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


namespace SpinLogger
{
    using SDP;

    public partial class SpinnLogger : Form
    {
        // Variable Declarations
        private bool Running = false;
        private UdpClient socket;
        private UDPState StateObj;

        // Delegate Declarations
        public delegate void AddNewRowToDataGridCallback(DataGridViewRow Row);

        // Public Functions
        public SpinnLogger()
        {
            InitializeComponent();
            this.Running = false;
            this.socket = null;
            this.GetLocalInterfaces();
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
 
                    DataGridViewRow NewRow;
                    this.AddNewRowOfData(CurrentDT, Source, Data, out NewRow);
                    this.AddRowToDataGrid(NewRow);


                    this.socket.BeginReceive(new AsyncCallback(ReceiveCallback), this.StateObj);
                }
                catch (System.ObjectDisposedException e)
                {
                    // We might end up here if the socket is closed and collected while waiting on data
                    // Ignore the error and we return.
                    return;
                }
            }
        }

        // Private Functions
        private void AddNewRowOfData(DateTime Time, string Source, string Data, out DataGridViewRow Row)
        {
            Row = new DataGridViewRow();

            DataGridViewTextBoxCell TimeCell = new DataGridViewTextBoxCell();
            DataGridViewTextBoxCell SourceCell = new DataGridViewTextBoxCell();
            DataGridViewTextBoxCell DataCell = new DataGridViewTextBoxCell();

            TimeCell.Value = Time.ToString("dd/MM/yyyy hh:mm:ss.fff");
            SourceCell.Value = Source;
            DataCell.Value = @Data;

            Row.Cells.Add(TimeCell);
            Row.Cells.Add(SourceCell);
            Row.Cells.Add(DataCell);
        }
        private void AddRowToDataGrid(DataGridViewRow Row)
        {
            if (this.DataGrid.InvokeRequired)
            {
                AddNewRowToDataGridCallback d = new AddNewRowToDataGridCallback(AddRowToDataGrid);
                this.Invoke(d, new object[] { Row });
            }
            else
            {
                DataGrid.Rows.Add(Row);

                int iRow = this.DataGrid.RowCount;
                this.DataGrid.CurrentCell = this.DataGrid.Rows[(iRow - 1)].Cells[0];
                this.DataGrid.CurrentCell.Selected = false;
            }
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
        private bool FetchLocalPort(out int Port)
        {
            Port = 0;

            try
            {
                string PortStr = this.Port_Text.Text;
                Port = (Int32)Convert.ToUInt16(this.Port_Text.Text);
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
        private bool FetchTag(out int Tag)
        {
            Tag = 0;

            try
            {
                Tag = (Int32)Convert.ToByte(this.Tag_Textbox.Text);
            }
            catch (System.FormatException)
            {
                string Caption = "Invalid Tag";
                string Message = "The Specified Tag is not a valid number";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            catch (System.OverflowException)
            {
                string Caption = "Invalid Tag";
                string Message = "The Specified Tag is outside the valid range (between 0 and 255)";
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
                if ((Host != UriHostNameType.Unknown)&&(Host != UriHostNameType.IPv6))
                {
                    this.Interfaces.Items.Add(A.ToString());
                }
            }

            this.Interfaces.SelectedIndex = 0;
            return;
        }
        private bool IPTagThisMachine(int LocalPort)
        {
            string RHost;
            int RPort;
            int Tag;

            if (!this.FetchRemoteHost(out RHost))
            {
                return false;
            }
            if (!this.FetchRemotePort(out RPort))
            {
                return false;
            }
            if (!this.FetchTag(out Tag))
            {
                return false;
            }

            UdpClient TagSocket = new UdpClient();

            try
            {
                TagSocket.Connect(RHost, RPort);
            }
            catch (System.Net.Sockets.SocketException e)
            {
                string Caption = "Remote Host Connection Error";
                string Message = "An error occurred while connecting to the remote host. Host is unreachable.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }

            SCP _SCP = new SCP();
            string IP_Str;
            this.FetchInterface(out IP_Str);
            IPAddress Address = IPAddress.Parse(IP_Str);

            if (_SCP.iptag_set(ref TagSocket, Address.GetAddressBytes(), (uint)LocalPort, (uint)Tag) != SDP.RC_OK)
            {
                string Caption = "Failed To Set Tag";
                string Message = "An error occurred when setting the IP Tag. Please check the spinnaker board and try again";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private void StartListening()
        {

            int port;

            if (!this.FetchLocalPort(out port))
            {
                return;
            }

            if (this.SetTag_CheckBox.Checked == true)
            {
                if (!this.IPTagThisMachine(port))
                {
                    return;
                }
            }

            IPEndPoint endpoint = new IPEndPoint(IPAddress.Any, port);
            this.socket = new UdpClient(endpoint);

            this.StateObj = new UDPState();
            this.StateObj.e = endpoint;
            this.StateObj.u = this.socket;

            this.socket.BeginReceive(new AsyncCallback(ReceiveCallback), this.StateObj);
            this.Listen_Button.Text = "Stop Listening";
            this.Running = true;
        }
        private void StopListening()
        {
            this.Running = false;
            this.socket.Close();
            this.Listen_Button.Text = "Start Listening";
        }

        // Private Functions - UI Element Callbacks
        private void Clear_Log_Click(object sender, EventArgs e)
        {
            DataGrid.Rows.Clear();
        }
        private void Listen_Button_Click(object sender, EventArgs e)
        {
            if (this.Running == false)
            {
                this.StartListening();
            }
            else
            {
                this.StopListening();
            }
        }

        private void SpinnLogger_Load(object sender, EventArgs e)
        {

        }
    }
}
