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

namespace SpinMessenger
{
    using SDP;

    public partial class SpinMessenger : Form
    {
        public SpinMessenger()
        {
            InitializeComponent();
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
            Host = this.Host_Textbox.Text;

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
                Port = (Int32)Convert.ToUInt16(this.Port_Textbox.Text);
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
        private bool GetSocket(out UdpClient Socket)
        {
            string Host;
            int Port;

            Socket = null;

            if (!FetchRemoteHost(out Host))
            {
                return false;
            }

            if (!FetchRemotePort(out Port))
            {
                return false;
            }

            Socket = new UdpClient();

            try
            {
                Socket.Connect(Host, Port);
            }
            catch (System.Net.Sockets.SocketException err)
            {
                //Console.WriteLine("Error while connecting to remote host: " + err.Message);
                //Console.WriteLine("Aborting!");
                Socket = null;
                return false;
            }
            return true;
        }
        private void GetHeader(out sdp_hdr_t Header)
        {
            Header = new sdp_hdr_t();

            if (this.Header_NoReply.Checked)
            {
                Header.flags = 0x07;
            }
            else
            {
                Header.flags = 0x87;
            }

            Header.tag = (byte) this.Header_Tag.Value;

            byte Dest_ChipX  = (byte)this.Header_Destx.Value;
            byte Dest_ChipY  = (byte)this.Header_Desty.Value;
            Header.dest_addr = (ushort)((Dest_ChipX << 8) + Dest_ChipY);
            Header.dest_cpu  = (byte)this.Header_Destcpu.Value;
            Header.dest_port = (byte)this.Header_Destport.Value;

            byte Srce_ChipX = (byte)this.Header_Srcex.Value;
            byte Srce_ChipY = (byte)this.Header_Srcey.Value;
            Header.srce_addr = (ushort)((Srce_ChipX << 8) + Srce_ChipY);
            Header.srce_cpu = (byte)this.Header_Srcecpu.Value;
            Header.srce_port = (byte)this.Header_Srceport.Value;
        }
        private bool GetCommand(out sdp_cmd_t Command)
        {
            Command = null;

            string CmdStr  = this.Cmd_Cmd.Text;
            string SeqStr  = this.Cmd_Seq.Text;
            string Arg1Str = this.Cmd_Arg1.Text;
            string Arg2Str = this.Cmd_Arg2.Text;
            string Arg3Str = this.Cmd_Arg3.Text;
            string DataStr = this.Cmd_data.Text;

            ushort Cmd;
            ushort Seq;
            uint Arg1;
            uint Arg2;
            uint Arg3;
            byte[] Data = null;

            if (!this.StringToNum(CmdStr, "CMD", out Cmd))
            {
                return false;
            }
            if (!this.StringToNum(SeqStr, "Seq", out Seq))
            {
                return false;
            }
            if (!this.StringToNum(Arg1Str, "Arg1", out Arg1))
            {
                return false;
            }
            if (!this.StringToNum(Arg2Str, "Arg2", out Arg2))
            {
                return false;
            }
            if (!this.StringToNum(Arg3Str, "Arg3", out Arg3))
            {
                return false;
            }

            if (DataStr != "")
            {
                if (this.Cmd_DataAs_Num.Checked)
                {
                    UInt32 Temp;

                    try
                    {
                        Temp = (UInt32)Int32.Parse(DataStr);
                        Data = new byte[4];
                        Data[0] = (byte)Temp;
                        Data[1] = (byte)(Temp >> 8);
                        Data[2] = (byte)(Temp >> 16);
                        Data[3] = (byte)(Temp >> 24);
                    }
                    catch (FormatException)
                    {
                        string Caption = "Invalid Number";
                        string Message = "Data is not a sequence of digits.";
                        MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                    catch (OverflowException)
                    {
                        string Caption = "Invalid Number";
                        string Message = "Data is too large to fit in an 32 bit integer";
                        MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
                else if (this.Cmd_DataAs_Hex.Checked)
                {
                    if (!this.HextStringToBytes(DataStr, out Data))
                    {
                        string Caption = string.Format("Invalid Hex Number");
                        string Message = "Data is not a valid hexadecimal number.";
                        MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
                else
                {
                    UTF8Encoding encoding = new UTF8Encoding();
                    Data = encoding.GetBytes(DataStr);
                }
            }

            Command = new sdp_cmd_t();
            Command.cmd_rc = Cmd;
            Command.seq = Seq;
            Command.arg1 = Arg1;
            Command.arg2 = Arg2;
            Command.arg3 = Arg3;

            if (Data != null)
            {
                Command.data = new byte[Data.Length];

                Array.Copy(Data, Command.data, Data.Length);
            }

            return true;
        }
        private bool HextStringToBytes(string HexString, out byte[] Bytes)
        {
            UInt32 StringLength = (UInt32)HexString.Length;

            bool Odd;

            if (StringLength % 2 == 0)
            {
                Odd = false;
                Bytes = new byte[StringLength / 2];
            }
            else
            {
                Odd = true;
                Bytes = new byte[(StringLength / 2) + 1];
            }

            try
            {
                for (uint i = 0; i < Bytes.Length; i++)
                {
                    string Temp;

                    if (((i == (StringLength - 1)) && (Odd == true)))
                    {
                        Temp = HexString.Substring((int)(i * 2), 1);
                        Bytes[i] = byte.Parse(Temp, System.Globalization.NumberStyles.HexNumber);
                    }
                    else
                    {
                        Temp = HexString.Substring((int)(i * 2), 2);
                        Bytes[i] = byte.Parse(Temp, System.Globalization.NumberStyles.HexNumber);
                    }
                }
            }
            catch (FormatException)
            {
                Bytes = null;
                return false;
            }
            return true;
        }
        private bool StringToNum(string NumString, string Msg, out Byte Num)
        {
            Num = 0;

            try
            {
                Num = (Byte)Convert.ToSByte(NumString);
            }
            catch (FormatException)
            {
                try
                {
                    Num = (Byte)SByte.Parse(NumString, System.Globalization.NumberStyles.HexNumber);
                }
                catch (FormatException)
                {
                    string Caption = string.Format("Invalid Hex Number - {0}",Msg);
                    string Message = "Input string is not a sequence of digits nor a hexadecimal number.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
                catch (OverflowException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "The number cannot fit in a Byte.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
            }
            catch (OverflowException)
            {
                string Caption = string.Format("Invalid Number - {0}", Msg);
                string Message = "The number cannot fit in a Byte.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private bool StringToNum(string NumString, string Msg, out UInt16 Num)
        {
            Num = 0;

            try
            {
                Num = (UInt16)Convert.ToInt16(NumString);
            }
            catch (FormatException)
            {
                try
                {
                    Num = (UInt16)Int16.Parse(NumString, System.Globalization.NumberStyles.HexNumber);
                }
                catch (FormatException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "Input string is not a sequence of digits nor a hexadecimal number.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
                catch (OverflowException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "The number cannot fit in a Int16.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
            }
            catch (OverflowException)
            {
                string Caption = string.Format("Invalid Number - {0}", Msg);
                string Message = "The number cannot fit in a Int16.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private bool StringToNum(string NumString, string Msg, out UInt32 Num)
        {
            Num = 0;

            try
            {
                Num = (uint)Convert.ToInt32(NumString);
            }
            catch (FormatException)
            {
                try
                {
                    Num = (uint)Int32.Parse(NumString, System.Globalization.NumberStyles.HexNumber);
                }
                catch (FormatException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "Input string is not a sequence of digits nor a hexadecimal number.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
                catch (OverflowException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "The number cannot fit in a Int32.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
            }
            catch (OverflowException)
            {
                string Caption = string.Format("Invalid Number - {0}", Msg);
                string Message = "The number cannot fit in a Int32.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        private bool StringToNum(string NumString, string Msg, out UInt64 Num)
        {
            Num = 0;

            try
            {
                Num = (UInt64)Convert.ToInt64(NumString);
            }
            catch (FormatException)
            {
                try
                {
                    Num = (UInt64)Int64.Parse(NumString, System.Globalization.NumberStyles.HexNumber);
                }
                catch (FormatException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "Input string is not a sequence of digits nor a hexadecimal number.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
                catch (OverflowException)
                {
                    string Caption = string.Format("Invalid Number - {0}", Msg);
                    string Message = "The number cannot fit in a Int64.";
                    MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
            }
            catch (OverflowException)
            {
                string Caption = string.Format("Invalid Number - {0}", Msg);
                string Message = "The number cannot fit in a Int64.";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }


        private void Button_sver_Click(object sender, EventArgs e)
        {
            uint ChipX = (uint)this.Header_Destx.Value;
            uint ChipY = (uint)this.Header_Desty.Value;
            uint CPU   = (uint)this.Header_Destcpu.Value;

            UdpClient Socket;

            if (!this.GetSocket(out Socket))
            {
                return;
            }

            sver_t VersionData;

            SCP CMD = new SCP();

            CMD.Set_Chip((byte)ChipX, (byte)ChipY, (byte)CPU);

            ushort RC = CMD.sver(ref Socket, out VersionData);

            string LogString = string.Format("Fetch Version Information from {0}:{1}:{2} : {3}", ChipX, ChipY, CPU, SDP.ParseResponseCode(RC));
            this.WriteLogLine(LogString);

            if (RC != SDP.RC_OK)
            {
                return;
            }

            DateTime BuildDate = this.UnixTimeToWindowsTime(VersionData.time);
            string BuildDateStr = BuildDate.ToString("dd/MM/yyyy hh:mm:ss");

            System.Text.Encoding enc = System.Text.Encoding.ASCII;
            string VersionStr = enc.GetString(VersionData.ver_string);

            LogString = string.Format("{0}:{1}:{2} - {3}, Version {4} - {5}", VersionData.chip_x, VersionData.chip_y,
                                                                                     VersionData.v_cpu, @VersionStr,
                                                                                     VersionData.ver_num, BuildDateStr);
            this.WriteLogLine(LogString);

            return;
        }
        private void Button_SendPkt_Click(object sender, EventArgs e)
        {
            UdpClient Socket;

            if (!this.GetSocket(out Socket))
            {
                return;
            }

            sdp_hdr_t Header;

            this.GetHeader(out Header);

            sdp_cmd_t Command;

            if (!this.GetCommand(out Command))
            {
                return;
            }

            SCP CMD = new SCP();

            if (!CMD.send(ref Socket, Header, Command))
            {
                return;
            }
            else
            {
                string LogString = string.Format("Packet Sent Successfully");
                this.WriteLogLine(LogString);
            }

            if (this.Header_Reply.Checked)
            {
                if (!CMD.receive(ref Socket, ref Header, ref Command))
                {

                }
                else
                {
                    string LogString = string.Format("Response From Remote Host {0}", SDP.ParseResponseCode(Command.cmd_rc));
                    this.WriteLogLine(LogString);

                    string[] Data = this.GenerateHexString(Command.data_inc_args);
                    this.WriteLogLine(Data);
                }
            }
            return;
        }
        private void Button_Clear_Click(object sender, EventArgs e)
        {
            this.Log.Rows.Clear();
        }

        private void Button_Save_Click(object sender, EventArgs e)
        {

        }
    }
}
