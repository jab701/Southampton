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

namespace SpinControl
{
    using SDP;

    public partial class AltBoot : Form
    {
        private UdpClient Socket = null;

        public AltBoot()
        {
            InitializeComponent();
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
        public DateTime UnixTimeToWindowsTime(uint Time)
        {
            DateTime Epoch = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            return Epoch.AddSeconds(Time);
        }
        private void Browse_Button_Click(object sender, EventArgs e)
        {
            OpenFileDialog Dialog = new OpenFileDialog();
            string CurrentPath = this.BootFile_Textbox.Text;

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
                this.BootFile_Textbox.Text = Dialog.FileName.ToString();
            }  
        }

        private void Boot_Button_Click(object sender, EventArgs e)
        {
            byte[] Data;

            this.BootStatus.Text = "Status: Reading File";
            this.BootStatus.Update();

            if (!this.ReadBinaryFile(this.BootFile_Textbox.Text, out Data))
            {
                this.BootStatus.Text = "Status: Reading File Failed.";
                this.BootStatus.Update();
                return;
            }

            string Host;

            if (!this.FetchRemoteHost(out Host))
            {
                this.BootStatus.Text = "Status: Invalid hostname or IP Address";
                this.BootStatus.Update();
                return;
            }

            this.Socket = new UdpClient();
            
            try
            {
                this.Socket.Connect(Host, (int)SDP.BOOT_PORT);
            }
            catch
            {
                this.BootStatus.Text = "Status: Connecting to Host Failed (Maybe does not exist?).";
                this.BootStatus.Update();
                return;
            }

            SCP CMD = new SCP();

            this.BootStatus.Text = "Status: Downloading to board";
            this.BootStatus.Update();

            CMD.boot(ref this.Socket, Data);

            this.BootStatus.Text = "Status: Pausing while board boots";
            this.BootStatus.Update();

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

                this.BootStatus.Text = string.Format("Status: Running Software {0}, Version {1} - {2}", @VersionStr,
                                                                                         VersionData.ver_num, BuildDateStr);
            }
            else
            {
                this.BootStatus.Text = "Status: Failed, Could not verify board was booted successfully";
            }
        }

        private void AltBoot_Load(object sender, EventArgs e)
        {
            this.BootStatus.Text = "Status: Ready To Go";
        }
    }
}
