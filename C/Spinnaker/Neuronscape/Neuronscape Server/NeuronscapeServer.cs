using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;

using Neuronscape;

namespace Neuronscape_Server
{
    public partial class NeuronscapeServer : Form
    {
        private CartesianVector EnvDimension;
        private double Gravity;
        private byte IntegrationTime;
        private UInt16 NetPort;

        private Thread PhysThread = null;

        ServerNetworkStack NetworkStack = null;
        DB_Client ClientDB = null;
        DB_Object ObjectDB = null;
        PhysicsThread PhysClass = null;

        public NeuronscapeServer()
        {
            InitializeComponent();
        }
        private void NeuronscapeServer_Load(object sender, EventArgs e)
        {

            this.EnvX.Text = string.Format("{0}", ServerDefinitions.Defaults_EnvX);
            this.EnvY.Text = string.Format("{0}", ServerDefinitions.Defaults_EnvY);
            this.EnvZ.Text = string.Format("{0}", ServerDefinitions.Defaults_EnvZ);
            this.EnvGravity.Text = string.Format("{0}", ServerDefinitions.Defaults_Gravity);
            this.EnvIntegrationTime.Text = string.Format("{0}", ServerDefinitions.Defaults_IntegrationTime);
            this.NetworkPort.Text = string.Format("{0}", ServerDefinitions.Defaults_Port);

            this.Start.Enabled = true;
            this.Restart.Enabled = false;
            this.Stop.Enabled = false;

        }
        private bool GetControls()
        {
            double X, Y, Z, Grav;
            byte IntTime;
            UInt16 Port;

            string EnvXStr = this.EnvX.Text;
            string EnvYStr = this.EnvY.Text;
            string EnvZStr = this.EnvZ.Text;
            string GravStr = this.EnvGravity.Text;
            string IntTimeStr = this.EnvIntegrationTime.Text;
            string NetPortStr = this.NetworkPort.Text;

            if (!double.TryParse(this.EnvX.Text, out X))
            {
                return false;
            }

            if (!double.TryParse(this.EnvY.Text, out Y))
            {
                return false;
            }

            if (!double.TryParse(this.EnvZ.Text, out Z))
            {
                return false;
            }

            if (!double.TryParse(this.EnvGravity.Text, out Grav))
            {
                return false;
            }

            if (!byte.TryParse(this.EnvIntegrationTime.Text, out IntTime))
            {
                return false;
            }

            if (!UInt16.TryParse(this.NetworkPort.Text, out Port))
            {
                return false;
            }

            this.EnvDimension = new CartesianVector(X, Y, Z);
            this.Gravity = Grav;
            this.IntegrationTime = IntTime;
            this.NetPort = Port;

            return true;
        }
        private void LockControls()
        {
            this.EnvX.Enabled = false;
            this.EnvY.Enabled = false;
            this.EnvZ.Enabled = false;
            this.EnvGravity.Enabled = false;
            this.EnvIntegrationTime.Enabled = false;
            this.NetworkPort.Enabled = false;
        }
        private void UnlockControls()
        {
            this.EnvX.Enabled = true;
            this.EnvY.Enabled = true;
            this.EnvZ.Enabled = true;
            this.EnvGravity.Enabled = true;
            this.EnvIntegrationTime.Enabled = true;
            this.NetworkPort.Enabled = true;
        }
        private void SystemStart()
        {
            this.LockControls();
            this.GetControls();
            this.ClientDB = new DB_Client();
            this.ObjectDB = new DB_Object(this.EnvDimension);

            this.NetworkStack = new ServerNetworkStack(this, ref this.ObjectDB, ref this.ClientDB, this.EnvDimension);
            this.NetworkStack.Start(this.NetPort);

            this.PhysClass = new PhysicsThread(ref this.NetworkStack, ref this.ClientDB, ref this.ObjectDB, this.IntegrationTime, this.EnvDimension, this.Gravity, 1.0, 1.0);

            this.PhysThread = new Thread(this.PhysClass.Exec);

            this.PhysThread.Start();

        }
        private void SystemStop()
        {
            try
            {
                this.PhysClass.Stop();

                this.PhysThread.Join();

                List<Record_Client> Clients = this.ClientDB.FetchAll();

                this.NetworkStack.SendBulkForceDisconnect(Clients);

                this.NetworkStack.Stop();

                this.PhysThread = null;
                this.PhysClass = null;

                this.NetworkStack = null;

                this.ObjectDB = null;

                this.ClientDB = null;

                this.UnlockControls();
            }
            catch
            {

            }
        }
        private void Start_Click(object sender, EventArgs e)
        {
            this.SystemStart();

            this.Start.Enabled = false;
            this.Restart.Enabled = true;
            this.Stop.Enabled = true;
        }

        private void Restart_Click(object sender, EventArgs e)
        {
            this.Start.Enabled = false;
            this.Restart.Enabled = false;
            this.Stop.Enabled = false;

            this.SystemStop();

            this.SystemStart();

            this.Start.Enabled = false;
            this.Restart.Enabled = true;
            this.Stop.Enabled = true;
        }

        private void Stop_Click(object sender, EventArgs e)
        {
            this.Restart.Enabled = false;
            this.Stop.Enabled = false;

            this.SystemStop();

            this.Start.Enabled = true;
            this.Restart.Enabled = false;
            this.Stop.Enabled = false;
        }

        private void ClearLog_Click(object sender, EventArgs e)
        {
            this.Log.Rows.Clear();
        }

        public void LogMessage(string Text)
        {
            if (this.InvokeRequired)
            {
                this.BeginInvoke((MethodInvoker)delegate { LogMessage(Text); });
            }
            else
            {
                DataGridViewRow Row = new DataGridViewRow();

                DataGridViewTextBoxCell TimeCell = new DataGridViewTextBoxCell();
                DataGridViewTextBoxCell DataCell = new DataGridViewTextBoxCell();

                TimeCell.Value = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss.fff");
                DataCell.Value = @Text;

                Row.Cells.Add(TimeCell);
                Row.Cells.Add(DataCell);
                this.Log.Rows.Add(Row);

                int iRow = this.Log.RowCount;
                this.Log.CurrentCell = this.Log.Rows[(iRow - 1)].Cells[0];
                this.Log.CurrentCell.Selected = false;
            }
        }
    }
}
