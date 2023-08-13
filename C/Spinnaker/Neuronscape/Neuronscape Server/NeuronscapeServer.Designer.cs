namespace Neuronscape_Server
{
    partial class NeuronscapeServer
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.NetworkSettings = new System.Windows.Forms.GroupBox();
            this.label6 = new System.Windows.Forms.Label();
            this.NetworkPort = new System.Windows.Forms.TextBox();
            this.ServerControl = new System.Windows.Forms.GroupBox();
            this.Stop = new System.Windows.Forms.Button();
            this.Restart = new System.Windows.Forms.Button();
            this.Start = new System.Windows.Forms.Button();
            this.Log = new System.Windows.Forms.DataGridView();
            this.Time = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Message = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.label7 = new System.Windows.Forms.Label();
            this.ClearLog = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label8 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.label11 = new System.Windows.Forms.Label();
            this.label12 = new System.Windows.Forms.Label();
            this.EnvIntegrationTime = new System.Windows.Forms.TextBox();
            this.EnvGravity = new System.Windows.Forms.TextBox();
            this.EnvZ = new System.Windows.Forms.TextBox();
            this.EnvY = new System.Windows.Forms.TextBox();
            this.EnvX = new System.Windows.Forms.TextBox();
            this.NetworkSettings.SuspendLayout();
            this.ServerControl.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.Log)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // NetworkSettings
            // 
            this.NetworkSettings.Controls.Add(this.label6);
            this.NetworkSettings.Controls.Add(this.NetworkPort);
            this.NetworkSettings.Location = new System.Drawing.Point(9, 175);
            this.NetworkSettings.Name = "NetworkSettings";
            this.NetworkSettings.Size = new System.Drawing.Size(475, 60);
            this.NetworkSettings.TabIndex = 1;
            this.NetworkSettings.TabStop = false;
            this.NetworkSettings.Text = "Network Configuration";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(92, 26);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(142, 13);
            this.label6.TabIndex = 11;
            this.label6.Text = "Listen for connection on port";
            // 
            // NetworkPort
            // 
            this.NetworkPort.Location = new System.Drawing.Point(282, 23);
            this.NetworkPort.Name = "NetworkPort";
            this.NetworkPort.Size = new System.Drawing.Size(100, 20);
            this.NetworkPort.TabIndex = 10;
            // 
            // ServerControl
            // 
            this.ServerControl.Controls.Add(this.Stop);
            this.ServerControl.Controls.Add(this.Restart);
            this.ServerControl.Controls.Add(this.Start);
            this.ServerControl.Location = new System.Drawing.Point(9, 241);
            this.ServerControl.Name = "ServerControl";
            this.ServerControl.Size = new System.Drawing.Size(475, 52);
            this.ServerControl.TabIndex = 2;
            this.ServerControl.TabStop = false;
            this.ServerControl.Text = "Server Control";
            // 
            // Stop
            // 
            this.Stop.Location = new System.Drawing.Point(292, 19);
            this.Stop.Name = "Stop";
            this.Stop.Size = new System.Drawing.Size(98, 23);
            this.Stop.TabIndex = 2;
            this.Stop.Text = "Stop";
            this.Stop.UseVisualStyleBackColor = true;
            this.Stop.Click += new System.EventHandler(this.Stop_Click);
            // 
            // Restart
            // 
            this.Restart.Location = new System.Drawing.Point(188, 19);
            this.Restart.Name = "Restart";
            this.Restart.Size = new System.Drawing.Size(98, 23);
            this.Restart.TabIndex = 1;
            this.Restart.Text = "Restart";
            this.Restart.UseVisualStyleBackColor = true;
            this.Restart.Click += new System.EventHandler(this.Restart_Click);
            // 
            // Start
            // 
            this.Start.Location = new System.Drawing.Point(84, 19);
            this.Start.Name = "Start";
            this.Start.Size = new System.Drawing.Size(98, 23);
            this.Start.TabIndex = 0;
            this.Start.Text = "Start";
            this.Start.UseVisualStyleBackColor = true;
            this.Start.Click += new System.EventHandler(this.Start_Click);
            // 
            // Log
            // 
            this.Log.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.Log.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Time,
            this.Message});
            this.Log.Location = new System.Drawing.Point(10, 332);
            this.Log.Name = "Log";
            this.Log.RowHeadersVisible = false;
            this.Log.Size = new System.Drawing.Size(474, 156);
            this.Log.TabIndex = 3;
            // 
            // Time
            // 
            this.Time.HeaderText = "Time";
            this.Time.Name = "Time";
            this.Time.ReadOnly = true;
            // 
            // Message
            // 
            this.Message.HeaderText = "Message";
            this.Message.Name = "Message";
            this.Message.ReadOnly = true;
            this.Message.Width = 360;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(11, 310);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(25, 13);
            this.label7.TabIndex = 10;
            this.label7.Text = "Log";
            // 
            // ClearLog
            // 
            this.ClearLog.Location = new System.Drawing.Point(398, 306);
            this.ClearLog.Name = "ClearLog";
            this.ClearLog.Size = new System.Drawing.Size(86, 20);
            this.ClearLog.TabIndex = 11;
            this.ClearLog.Text = "Clear Log";
            this.ClearLog.UseVisualStyleBackColor = true;
            this.ClearLog.Click += new System.EventHandler(this.ClearLog_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label8);
            this.groupBox1.Controls.Add(this.label9);
            this.groupBox1.Controls.Add(this.label10);
            this.groupBox1.Controls.Add(this.label11);
            this.groupBox1.Controls.Add(this.label12);
            this.groupBox1.Controls.Add(this.EnvIntegrationTime);
            this.groupBox1.Controls.Add(this.EnvGravity);
            this.groupBox1.Controls.Add(this.EnvZ);
            this.groupBox1.Controls.Add(this.EnvY);
            this.groupBox1.Controls.Add(this.EnvX);
            this.groupBox1.Location = new System.Drawing.Point(9, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(475, 157);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Physics Environment Settings";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(92, 126);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(172, 13);
            this.label8.TabIndex = 9;
            this.label8.Text = "Physics Integration Timestemp (ms)";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(92, 100);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(180, 13);
            this.label9.TabIndex = 8;
            this.label9.Text = "Acceleration Due To Gravity (m/s^2)";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(92, 74);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(76, 13);
            this.label10.TabIndex = 7;
            this.label10.Text = "Environment Z";
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(92, 48);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(76, 13);
            this.label11.TabIndex = 6;
            this.label11.Text = "Environment Y";
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(92, 22);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(76, 13);
            this.label12.TabIndex = 5;
            this.label12.Text = "Environment X";
            // 
            // EnvIntegrationTime
            // 
            this.EnvIntegrationTime.Location = new System.Drawing.Point(282, 123);
            this.EnvIntegrationTime.Name = "EnvIntegrationTime";
            this.EnvIntegrationTime.Size = new System.Drawing.Size(100, 20);
            this.EnvIntegrationTime.TabIndex = 4;
            // 
            // EnvGravity
            // 
            this.EnvGravity.Location = new System.Drawing.Point(282, 97);
            this.EnvGravity.Name = "EnvGravity";
            this.EnvGravity.Size = new System.Drawing.Size(100, 20);
            this.EnvGravity.TabIndex = 3;
            // 
            // EnvZ
            // 
            this.EnvZ.Location = new System.Drawing.Point(282, 71);
            this.EnvZ.Name = "EnvZ";
            this.EnvZ.Size = new System.Drawing.Size(100, 20);
            this.EnvZ.TabIndex = 2;
            // 
            // EnvY
            // 
            this.EnvY.Location = new System.Drawing.Point(282, 45);
            this.EnvY.Name = "EnvY";
            this.EnvY.Size = new System.Drawing.Size(100, 20);
            this.EnvY.TabIndex = 1;
            // 
            // EnvX
            // 
            this.EnvX.Location = new System.Drawing.Point(282, 19);
            this.EnvX.Name = "EnvX";
            this.EnvX.Size = new System.Drawing.Size(100, 20);
            this.EnvX.TabIndex = 0;
            // 
            // NeuronscapeServer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(496, 490);
            this.Controls.Add(this.ClearLog);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.Log);
            this.Controls.Add(this.ServerControl);
            this.Controls.Add(this.NetworkSettings);
            this.Controls.Add(this.groupBox1);
            this.Name = "NeuronscapeServer";
            this.Text = "Neuronscape Server";
            this.Load += new System.EventHandler(this.NeuronscapeServer_Load);
            this.NetworkSettings.ResumeLayout(false);
            this.NetworkSettings.PerformLayout();
            this.ServerControl.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.Log)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox NetworkSettings;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox NetworkPort;
        private System.Windows.Forms.GroupBox ServerControl;
        private System.Windows.Forms.Button Stop;
        private System.Windows.Forms.Button Restart;
        private System.Windows.Forms.Button Start;
        private System.Windows.Forms.DataGridView Log;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button ClearLog;
        private System.Windows.Forms.DataGridViewTextBoxColumn Time;
        private System.Windows.Forms.DataGridViewTextBoxColumn Message;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.TextBox EnvIntegrationTime;
        private System.Windows.Forms.TextBox EnvGravity;
        private System.Windows.Forms.TextBox EnvZ;
        private System.Windows.Forms.TextBox EnvY;
        private System.Windows.Forms.TextBox EnvX;
    }
}

