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
using System.Threading;

using System.Timers;

using Neuronscape;

namespace Neuronscape_Interactor
{
    public partial class NeuronscapeInteractor : Form
    {
        // Class Variable Declarations
        private System.Timers.Timer NetworkTimeoutTimer;

        private System.Timers.Timer ForceTimer;

        private DB_ClientObject ObjectDB = null;
        private ClientNetworkStack NetworkStack = null;
        private UInt32 ClientID = 0;
        private CartesianVector EnvironmentDimensions = new CartesianVector(0.0, 0.0, 0.0);
        private UInt32 NumberOfObjects = 0;
        private UInt32 SelectedObjectID = 0;
        private UInt32 ApplyForce_ObjectID = 0;

        // Class Consturctor
        public NeuronscapeInteractor()
        {
            InitializeComponent();
        }
        // Form Load Function (Initialization)
        private void NeuronscapeInteractor_Load(object sender, EventArgs e)
        {
            this.Disconnect_Button.Enabled = false;

            this.ViewSelectBox.Items.Add("Normal");
            this.ViewSelectBox.Items.Add("Birds-Eye View");
            this.ViewSelectBox.Items.Add("Object POV");
            this.ViewSelectBox.SelectedIndex = 0;

            this.ObjectSelectBox.Items.Add("No Objects Available");
            this.ObjectSelectBox.SelectedIndex = 0;

            this.AddInanimate_ThetaTrack.Value = 0;
            this.AddInanimate_PhiTrack.Value = 90;

            this.AddInanimate_ThetaTrack_Scroll(this, new EventArgs());
            this.AddInanimate_PhiTrack_Scroll(this, new EventArgs());

        }
        // Form Close Function (Shutdown)
        private void NeuronscapeInteractor_Close(object sender, FormClosingEventArgs e)
        {
            if (this.NetworkStack != null)
            {
                this.StopSystem();
            }
        }
        //******************************************************************************************
        // Button Delegate Callbacks
        // Delegate Callbacks to allow Connect/Disconnect button state to be altered from different threads
        // (this is required so the Network timeout timer can enable buttons).
        //******************************************************************************************
        // Connect Button Enable Delegate Callback
        public delegate void ConnectButton_Enabled_CB(bool Value);
        private void ConnectButton_Enabled(bool Value)
        {
            if (this.Connect_Button.InvokeRequired)
            {
                ConnectButton_Enabled_CB d = new ConnectButton_Enabled_CB(ConnectButton_Enabled);
                this.Invoke(d, new object[] { Value });
            }
            else
            {
                this.Connect_Button.Enabled = Value;
            }
        }
        // Disconnect Button Enable Delegate Callback
        public delegate void DisconnectButton_Enabled_CB(bool Value);
        private void DisconnectButton_Enabled(bool Value)
        {
            if (this.Disconnect_Button.InvokeRequired)
            {
                DisconnectButton_Enabled_CB d = new DisconnectButton_Enabled_CB(DisconnectButton_Enabled);
                this.Invoke(d, new object[] { Value });
            }
            else
            {
                this.Disconnect_Button.Enabled = Value;
            }
        }
        public delegate void ApplyForceButton_Enabled_CB(bool Value);
        private void ApplyForceButton_Enabled(bool Value)
        {
            if (this.ApplyForce_Button.InvokeRequired)
            {
                ApplyForceButton_Enabled_CB d = new ApplyForceButton_Enabled_CB(ApplyForceButton_Enabled);
                this.Invoke(d, new object[] { Value });
            }
            else
            {
                this.ApplyForce_Button.Enabled = Value;
            }
        }
        //***********************************************************
        // Button Click Callbacks
        //***********************************************************
        // Connect Button Click Callback
        private void Connect_Button_Click(object sender, EventArgs e)
        {
            this.StartSystem();
        }
        // Disconnect Button Click Callback
        private void Disconnect_Button_Click(object sender, EventArgs e)
        {
            this.StopSystem();
        }
        //*************************************************************************
        // Listbox Value Change Callbacks
        //*************************************************************************
        private void ViewSelectBox_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
        private void ObjectSelectBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            string SelectedText = this.ObjectSelectBox.SelectedItem.ToString();

            if (SelectedText.Length == 0)
            {
                return;
            }

            int Index = SelectedText.IndexOf(':');

            if (Index <= 0)
            {
                return;
            }

            string ID_Str = SelectedText.Substring(0, Index);

            try
            {
                this.SelectedObjectID = UInt32.Parse(ID_Str);
            }
            catch
            {
                return;
            }
        }
        //*************************************************************************
        // Neuronscape Connect (Start) and Disconnect (Stop Functions)
        //*************************************************************************
        public void StartSystem()
        {
            this.Connect_Button.Enabled = false;

            string Caption;
            string Message;

            string HostStr = this.ServerAddress_Text.Text;
            string PortStr = this.ServerPort_Text.Text;

            // Check for invalid hostname
            UriHostNameType HostType = Uri.CheckHostName(HostStr);

            // Check for invalid hostname
            if (Uri.CheckHostName(HostStr) == UriHostNameType.Unknown)
            {
                Caption = "Invalid Remote Host";
                Message = "The Specified Remote Host is not a valid hostname or IP Address";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Connect_Button.Enabled = true;
                return;
            }

            Int32 Port = 0;

            try
            {
                Port = (Int32)Convert.ToUInt16(PortStr);
            }
            catch (System.FormatException)
            {
                Caption = "Invalid Remote Port";
                Message = "The Specified Remote Port is not a valid number";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Connect_Button.Enabled = true;
                return;
            }
            catch (System.OverflowException)
            {
                Caption = "Invalid Remote Port";
                Message = "The Specified Remote Port is outside the valid range (between 0 and 65536)";
                MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Connect_Button.Enabled = true;
                return;
            }

            this.ObjectDB = new DB_ClientObject();
            this.NetworkStack = new ClientNetworkStack();
            this.NetworkStack.ClientNSEvent += this.OnNSEvent;
            this.NetworkStack.Start(this.ObjectDB, HostStr, Port);

            this.NetworkStack.SendConnectionRequest(Roles.VIEWER);

            this.NetworkTimeoutTimer = new System.Timers.Timer();
            this.NetworkTimeoutTimer.Interval = Constants.NetworkTimeout;
            this.NetworkTimeoutTimer.AutoReset = false;
            this.NetworkTimeoutTimer.Elapsed += this.OnConnectTimeout;
            this.NetworkTimeoutTimer.Enabled = true;
            this.NetworkTimeoutTimer.Start();
        }
        public delegate void StopSystem_CB();
        public void StopSystem()
        {
                DisconnectButton_Enabled(false);

                // First check to see if we are connected
                if (this.ClientID != 0)
                {
                    this.NetworkTimeoutTimer = new System.Timers.Timer();
                    this.NetworkTimeoutTimer.Interval = Constants.NetworkTimeout;
                    this.NetworkTimeoutTimer.AutoReset = false;
                    this.NetworkTimeoutTimer.Elapsed += this.OnDisconnectTimeout;
                    this.NetworkTimeoutTimer.Enabled = true;
                    this.NetworkTimeoutTimer.Start();

                    // Okay so we have to disconnect first
                    this.NetworkStack.SendDisconnectionRequest();
                }
                else
                {
                    // Otherwise we are free to just kill the network stack and reset the system
                    this.ObjectDB.Clear();
                    this.NetworkStack.Stop();

                    this.ObjectDB = null;
                    this.NetworkStack = null;

                    ConnectButton_Enabled(true);
                }
           
        }
        //*************************************************************************
        // Event Handlers
        //*************************************************************************
        // Network Stack Event Handler
        public void OnNSEvent(object sender, ClientNSEventArgs e)
        {
            if (this.InvokeRequired)
            {
                this.BeginInvoke((MethodInvoker)delegate { ProcessNSEvent(e); });
            }
            else
            {
                this.ProcessNSEvent(e);                
            }
        }
        private void ProcessNSEvent(ClientNSEventArgs e)
        {
            switch (e.CODE)
            {
                case ClientStatus.ENUM:
                    this.EnvironmentDimensions = e.EnvDimensions;
                    break;
                case ClientStatus.INIT:
                    break;
                case ClientStatus.CONNECTED:
                    this.ClientID = e.Payload1;
                    this.NetworkTimeoutTimer.Stop();
                    this.NetworkTimeoutTimer = null;
                    this.ConnectButton_Enabled(false);
                    this.DisconnectButton_Enabled(true);
                    break;
                case ClientStatus.DISCONNECTED:
                    this.ClientID = e.Payload1;
                    this.NetworkTimeoutTimer.Stop();
                    this.NetworkTimeoutTimer = null;
                    this.StopSystem();
                    break;
                case ClientStatus.DISCONNECT_FORCED:
                    this.ClientID = e.Payload1;
                    this.StopSystem();
                    this.ConnectButton_Enabled(true);
                    this.DisconnectButton_Enabled(false);
                    break;
                case ClientStatus.OBJECT_DB_DIRTY:
                    this.UpdateObjectSelectBox();
                    break;
                case ClientStatus.TESTS_ECHO_REPLY:
                    break;
                default:
                    break;
            }
        }
        private void UpdateObjectSelectBox()
        {
            bool SelectedSet = false;

            if (this.ObjectDB.NumberObjects == 0)
            {
                this.ObjectSelectBox.Items.Add("No Objects Available");
                this.ObjectSelectBox.SelectedIndex = 0;
            }
            else
            {
                List<Record_ClientObject> Objects = this.ObjectDB.FetchAll();

                if (this.ObjectDB.NumberObjects != this.NumberOfObjects)
                {
                    this.NumberOfObjects = this.ObjectDB.NumberObjects;

                    this.ObjectSelectBox.Items.Clear();
                    this.ObjectSelectBox.Items.Add("0: No Object Selected");

                    foreach (Record_ClientObject Object in Objects)
                    {

                        string Item = string.Format("{0}:", Object.ID);
                        this.ObjectSelectBox.Items.Add(Item);

                        if (Object.ID == this.SelectedObjectID)
                        {
                            this.ObjectSelectBox.SelectedItem = Item;
                            SelectedSet = true;
                        }
                    }

                    if (!SelectedSet)
                    {
                        this.ObjectSelectBox.SelectedItem = "0: No Object Selected";
                    }
                }
            }
        }
        // Network Timout on Connect Handler
        public void OnConnectTimeout(object source, ElapsedEventArgs e)
        {
            string Caption = "Connection Timeout";
            string Message = "The Neuronscape Server did not respond or does not exist.";
            MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);

            this.ObjectDB.Clear();
            this.NetworkStack.Stop();

            this.ObjectDB = null;
            this.NetworkStack = null;

            this.NetworkTimeoutTimer.Stop();
            this.NetworkTimeoutTimer = null;

            this.ConnectButton_Enabled(true);
        }
        // Network Timeout on Disconnect Handler
        public void OnDisconnectTimeout(object source, ElapsedEventArgs e)
        {
            string Caption = "Disconnection Timeout";
            string Message = "The Neuronscape Server did not respond or does not exist. Exiting anyway, the Server Databases may be inconsistent.";
            MessageBox.Show(Message, Caption, MessageBoxButtons.OK, MessageBoxIcon.Error);

            this.ObjectDB.Clear();
            this.NetworkStack.Stop();

            this.ObjectDB = null;
            this.NetworkStack = null;

            this.NetworkTimeoutTimer.Stop();
            this.NetworkTimeoutTimer = null;

            this.ConnectButton_Enabled(true);
        }

        private void ApplyForce_Button_Click(object sender, EventArgs e)
        {
            if (this.SelectedObjectID != 0)
            {
                this.ApplyForce_ObjectID = SelectedObjectID;

                this.ApplyForce_Button.Enabled = false;

                decimal MagDeci = this.ApplyForce_Magnitude.Value;
                decimal RotDeci = this.ApplyForce_Direction.Value;
                decimal EleDeci = this.ApplyForce_Elevation.Value;
                decimal DurDeci = this.ApplyForce_Duration.Value;

                double Magnitude = (double)MagDeci;
                double Rotation = (double)RotDeci;
                double Elevation = (double)EleDeci;

                double Rotation_Rad = (Rotation / 180.0) * Constants.PI;
                double Elevation_Rad = (Elevation / 180.0) * Constants.PI;

                SphericalVector Force = new SphericalVector(Magnitude, Rotation_Rad, Elevation_Rad);
                UInt32 Duration = (UInt32)DurDeci;

                this.NetworkStack.SendObjectForces(this.ApplyForce_ObjectID, Force);

                this.ForceTimer = new System.Timers.Timer();
                this.ForceTimer.Interval = Duration;
                this.ForceTimer.AutoReset = false;
                this.ForceTimer.Elapsed += this.ApplyForce_Done;
                this.ForceTimer.Enabled = true;
                this.ForceTimer.Start();
            }
        }
        public void ApplyForce_Done(object source, ElapsedEventArgs e)
        {
            this.NetworkStack.SendObjectForces(this.ApplyForce_ObjectID, new CartesianVector(0.0,0.0,0.0));
            this.ForceTimer.Stop();
            this.ForceTimer = null;
            this.ApplyForceButton_Enabled(true);
        }

        private void AddInanimate_ThetaTrack_Scroll(object sender, EventArgs e)
        {
            Int32 Value = this.AddInanimate_ThetaTrack.Value;

            this.AddInanimate_ThetaText.Text = string.Format("{0}", Value);
        }
        private void AddInanimate_PhiTrack_Scroll(object sender, EventArgs e)
        {
            Int32 Value = this.AddInanimate_PhiTrack.Value;

            this.AddInanimate_PhiText.Text = string.Format("{0}", Value);
        }
        private void AddInanimate_Button_Click(object sender, EventArgs e)
        {

        }
    }
}
