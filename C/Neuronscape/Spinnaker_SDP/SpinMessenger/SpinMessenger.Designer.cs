namespace SpinMessenger
{
    partial class SpinMessenger
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.RPort_Label = new System.Windows.Forms.Label();
            this.Port_Textbox = new System.Windows.Forms.TextBox();
            this.RHost_Label = new System.Windows.Forms.Label();
            this.Host_Textbox = new System.Windows.Forms.TextBox();
            this.Command = new System.Windows.Forms.GroupBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.Cmd_DataAs_Hex = new System.Windows.Forms.RadioButton();
            this.Cmd_DataAs_Num = new System.Windows.Forms.RadioButton();
            this.Cmd_DataAs_Text = new System.Windows.Forms.RadioButton();
            this.Cmd_data = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.Cmd_Arg3 = new System.Windows.Forms.TextBox();
            this.Cmd_Arg2 = new System.Windows.Forms.TextBox();
            this.Cmd_Arg1 = new System.Windows.Forms.TextBox();
            this.Cmd_Seq = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.Cmd_Cmd = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.Header = new System.Windows.Forms.GroupBox();
            this.label11 = new System.Windows.Forms.Label();
            this.Header_Srcex = new System.Windows.Forms.NumericUpDown();
            this.label12 = new System.Windows.Forms.Label();
            this.Header_Srcey = new System.Windows.Forms.NumericUpDown();
            this.label15 = new System.Windows.Forms.Label();
            this.Header_Srceport = new System.Windows.Forms.NumericUpDown();
            this.label16 = new System.Windows.Forms.Label();
            this.Header_Srcecpu = new System.Windows.Forms.NumericUpDown();
            this.label14 = new System.Windows.Forms.Label();
            this.Header_Destx = new System.Windows.Forms.NumericUpDown();
            this.label13 = new System.Windows.Forms.Label();
            this.Header_Desty = new System.Windows.Forms.NumericUpDown();
            this.label10 = new System.Windows.Forms.Label();
            this.Header_Destport = new System.Windows.Forms.NumericUpDown();
            this.label9 = new System.Windows.Forms.Label();
            this.Header_Destcpu = new System.Windows.Forms.NumericUpDown();
            this.label8 = new System.Windows.Forms.Label();
            this.Header_Tag = new System.Windows.Forms.NumericUpDown();
            this.Header_Reply = new System.Windows.Forms.RadioButton();
            this.Header_NoReply = new System.Windows.Forms.RadioButton();
            this.Button_sver = new System.Windows.Forms.Button();
            this.Button_SendPkt = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.Log = new System.Windows.Forms.DataGridView();
            this.Data = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Button_Clear = new System.Windows.Forms.Button();
            this.Button_Save = new System.Windows.Forms.Button();
            this.Command.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.Header.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcex)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcey)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srceport)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcecpu)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destx)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Desty)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destport)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destcpu)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Tag)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.Log)).BeginInit();
            this.SuspendLayout();
            // 
            // RPort_Label
            // 
            this.RPort_Label.AutoSize = true;
            this.RPort_Label.Location = new System.Drawing.Point(532, 30);
            this.RPort_Label.Name = "RPort_Label";
            this.RPort_Label.Size = new System.Drawing.Size(66, 13);
            this.RPort_Label.TabIndex = 22;
            this.RPort_Label.Text = "Remote Port";
            // 
            // Port_Textbox
            // 
            this.Port_Textbox.Location = new System.Drawing.Point(604, 28);
            this.Port_Textbox.MaxLength = 5;
            this.Port_Textbox.Name = "Port_Textbox";
            this.Port_Textbox.Size = new System.Drawing.Size(42, 20);
            this.Port_Textbox.TabIndex = 21;
            this.Port_Textbox.Text = "17893";
            // 
            // RHost_Label
            // 
            this.RHost_Label.AutoSize = true;
            this.RHost_Label.Location = new System.Drawing.Point(10, 31);
            this.RHost_Label.Name = "RHost_Label";
            this.RHost_Label.Size = new System.Drawing.Size(69, 13);
            this.RHost_Label.TabIndex = 20;
            this.RHost_Label.Text = "Remote Host";
            // 
            // Host_Textbox
            // 
            this.Host_Textbox.Location = new System.Drawing.Point(82, 27);
            this.Host_Textbox.MaxLength = 1024;
            this.Host_Textbox.Name = "Host_Textbox";
            this.Host_Textbox.Size = new System.Drawing.Size(444, 20);
            this.Host_Textbox.TabIndex = 19;
            // 
            // Command
            // 
            this.Command.Controls.Add(this.groupBox1);
            this.Command.Controls.Add(this.Cmd_data);
            this.Command.Controls.Add(this.label7);
            this.Command.Controls.Add(this.Cmd_Arg3);
            this.Command.Controls.Add(this.Cmd_Arg2);
            this.Command.Controls.Add(this.Cmd_Arg1);
            this.Command.Controls.Add(this.Cmd_Seq);
            this.Command.Controls.Add(this.label6);
            this.Command.Controls.Add(this.label5);
            this.Command.Controls.Add(this.Cmd_Cmd);
            this.Command.Controls.Add(this.label4);
            this.Command.Controls.Add(this.label3);
            this.Command.Controls.Add(this.label2);
            this.Command.Location = new System.Drawing.Point(15, 173);
            this.Command.Name = "Command";
            this.Command.Size = new System.Drawing.Size(631, 112);
            this.Command.TabIndex = 26;
            this.Command.TabStop = false;
            this.Command.Text = "Command";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.Cmd_DataAs_Hex);
            this.groupBox1.Controls.Add(this.Cmd_DataAs_Num);
            this.groupBox1.Controls.Add(this.Cmd_DataAs_Text);
            this.groupBox1.Location = new System.Drawing.Point(24, 67);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(584, 39);
            this.groupBox1.TabIndex = 18;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Data As";
            // 
            // Cmd_DataAs_Hex
            // 
            this.Cmd_DataAs_Hex.AutoSize = true;
            this.Cmd_DataAs_Hex.Location = new System.Drawing.Point(342, 11);
            this.Cmd_DataAs_Hex.Name = "Cmd_DataAs_Hex";
            this.Cmd_DataAs_Hex.Size = new System.Drawing.Size(86, 17);
            this.Cmd_DataAs_Hex.TabIndex = 2;
            this.Cmd_DataAs_Hex.Text = "Hexadecimal";
            this.Cmd_DataAs_Hex.UseVisualStyleBackColor = true;
            // 
            // Cmd_DataAs_Num
            // 
            this.Cmd_DataAs_Num.AutoSize = true;
            this.Cmd_DataAs_Num.Location = new System.Drawing.Point(251, 11);
            this.Cmd_DataAs_Num.Name = "Cmd_DataAs_Num";
            this.Cmd_DataAs_Num.Size = new System.Drawing.Size(62, 17);
            this.Cmd_DataAs_Num.TabIndex = 1;
            this.Cmd_DataAs_Num.Text = "Number";
            this.Cmd_DataAs_Num.UseVisualStyleBackColor = true;
            // 
            // Cmd_DataAs_Text
            // 
            this.Cmd_DataAs_Text.AutoSize = true;
            this.Cmd_DataAs_Text.Checked = true;
            this.Cmd_DataAs_Text.Location = new System.Drawing.Point(160, 11);
            this.Cmd_DataAs_Text.Name = "Cmd_DataAs_Text";
            this.Cmd_DataAs_Text.Size = new System.Drawing.Size(46, 17);
            this.Cmd_DataAs_Text.TabIndex = 0;
            this.Cmd_DataAs_Text.TabStop = true;
            this.Cmd_DataAs_Text.Text = "Text";
            this.Cmd_DataAs_Text.UseVisualStyleBackColor = true;
            // 
            // Cmd_data
            // 
            this.Cmd_data.Location = new System.Drawing.Point(64, 43);
            this.Cmd_data.Name = "Cmd_data";
            this.Cmd_data.Size = new System.Drawing.Size(540, 20);
            this.Cmd_data.TabIndex = 17;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(26, 46);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(30, 13);
            this.label7.TabIndex = 16;
            this.label7.Text = "Data";
            // 
            // Cmd_Arg3
            // 
            this.Cmd_Arg3.Location = new System.Drawing.Point(530, 17);
            this.Cmd_Arg3.MaxLength = 16;
            this.Cmd_Arg3.Name = "Cmd_Arg3";
            this.Cmd_Arg3.Size = new System.Drawing.Size(74, 20);
            this.Cmd_Arg3.TabIndex = 15;
            this.Cmd_Arg3.Text = "0";
            // 
            // Cmd_Arg2
            // 
            this.Cmd_Arg2.Location = new System.Drawing.Point(412, 17);
            this.Cmd_Arg2.MaxLength = 16;
            this.Cmd_Arg2.Name = "Cmd_Arg2";
            this.Cmd_Arg2.Size = new System.Drawing.Size(74, 20);
            this.Cmd_Arg2.TabIndex = 14;
            this.Cmd_Arg2.Text = "0";
            // 
            // Cmd_Arg1
            // 
            this.Cmd_Arg1.Location = new System.Drawing.Point(294, 17);
            this.Cmd_Arg1.MaxLength = 16;
            this.Cmd_Arg1.Name = "Cmd_Arg1";
            this.Cmd_Arg1.Size = new System.Drawing.Size(74, 20);
            this.Cmd_Arg1.TabIndex = 13;
            this.Cmd_Arg1.Text = "0";
            // 
            // Cmd_Seq
            // 
            this.Cmd_Seq.Location = new System.Drawing.Point(176, 17);
            this.Cmd_Seq.MaxLength = 16;
            this.Cmd_Seq.Name = "Cmd_Seq";
            this.Cmd_Seq.Size = new System.Drawing.Size(74, 20);
            this.Cmd_Seq.TabIndex = 12;
            this.Cmd_Seq.Text = "0";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(144, 20);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(26, 13);
            this.label6.TabIndex = 11;
            this.label6.Text = "Seq";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(26, 20);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(28, 13);
            this.label5.TabIndex = 9;
            this.label5.Text = "Cmd";
            // 
            // Cmd_Cmd
            // 
            this.Cmd_Cmd.Location = new System.Drawing.Point(64, 17);
            this.Cmd_Cmd.MaxLength = 16;
            this.Cmd_Cmd.Name = "Cmd_Cmd";
            this.Cmd_Cmd.Size = new System.Drawing.Size(74, 20);
            this.Cmd_Cmd.TabIndex = 8;
            this.Cmd_Cmd.Text = "0";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(492, 20);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(32, 13);
            this.label4.TabIndex = 7;
            this.label4.Text = "Arg 3";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(374, 20);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(32, 13);
            this.label3.TabIndex = 6;
            this.label3.Text = "Arg 2";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(256, 20);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(32, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Arg 1";
            // 
            // Header
            // 
            this.Header.Controls.Add(this.label11);
            this.Header.Controls.Add(this.Header_Srcex);
            this.Header.Controls.Add(this.label12);
            this.Header.Controls.Add(this.Header_Srcey);
            this.Header.Controls.Add(this.label15);
            this.Header.Controls.Add(this.Header_Srceport);
            this.Header.Controls.Add(this.label16);
            this.Header.Controls.Add(this.Header_Srcecpu);
            this.Header.Controls.Add(this.label14);
            this.Header.Controls.Add(this.Header_Destx);
            this.Header.Controls.Add(this.label13);
            this.Header.Controls.Add(this.Header_Desty);
            this.Header.Controls.Add(this.label10);
            this.Header.Controls.Add(this.Header_Destport);
            this.Header.Controls.Add(this.label9);
            this.Header.Controls.Add(this.Header_Destcpu);
            this.Header.Controls.Add(this.label8);
            this.Header.Controls.Add(this.Header_Tag);
            this.Header.Controls.Add(this.Header_Reply);
            this.Header.Controls.Add(this.Header_NoReply);
            this.Header.Location = new System.Drawing.Point(15, 54);
            this.Header.Name = "Header";
            this.Header.Size = new System.Drawing.Size(631, 113);
            this.Header.TabIndex = 27;
            this.Header.TabStop = false;
            this.Header.Text = "Header";
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(21, 82);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(70, 13);
            this.label11.TabIndex = 25;
            this.label11.Text = "Srce. Addr. X";
            // 
            // Header_Srcex
            // 
            this.Header_Srcex.Location = new System.Drawing.Point(100, 78);
            this.Header_Srcex.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.Header_Srcex.Name = "Header_Srcex";
            this.Header_Srcex.Size = new System.Drawing.Size(74, 20);
            this.Header_Srcex.TabIndex = 24;
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(180, 82);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(70, 13);
            this.label12.TabIndex = 23;
            this.label12.Text = "Srce. Addr. Y";
            // 
            // Header_Srcey
            // 
            this.Header_Srcey.Location = new System.Drawing.Point(256, 78);
            this.Header_Srcey.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.Header_Srcey.Name = "Header_Srcey";
            this.Header_Srcey.Size = new System.Drawing.Size(74, 20);
            this.Header_Srcey.TabIndex = 22;
            // 
            // label15
            // 
            this.label15.AutoSize = true;
            this.label15.Location = new System.Drawing.Point(476, 82);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(54, 13);
            this.label15.TabIndex = 21;
            this.label15.Text = "Srce. Port";
            // 
            // Header_Srceport
            // 
            this.Header_Srceport.Location = new System.Drawing.Point(535, 78);
            this.Header_Srceport.Maximum = new decimal(new int[] {
            7,
            0,
            0,
            0});
            this.Header_Srceport.Name = "Header_Srceport";
            this.Header_Srceport.Size = new System.Drawing.Size(74, 20);
            this.Header_Srceport.TabIndex = 20;
            // 
            // label16
            // 
            this.label16.AutoSize = true;
            this.label16.Location = new System.Drawing.Point(336, 82);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(57, 13);
            this.label16.TabIndex = 19;
            this.label16.Text = "Srce. CPU";
            // 
            // Header_Srcecpu
            // 
            this.Header_Srcecpu.Location = new System.Drawing.Point(395, 78);
            this.Header_Srcecpu.Maximum = new decimal(new int[] {
            31,
            0,
            0,
            0});
            this.Header_Srcecpu.Name = "Header_Srcecpu";
            this.Header_Srcecpu.Size = new System.Drawing.Size(74, 20);
            this.Header_Srcecpu.TabIndex = 18;
            // 
            // label14
            // 
            this.label14.AutoSize = true;
            this.label14.Location = new System.Drawing.Point(21, 56);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(70, 13);
            this.label14.TabIndex = 17;
            this.label14.Text = "Dest. Addr. X";
            // 
            // Header_Destx
            // 
            this.Header_Destx.Location = new System.Drawing.Point(100, 52);
            this.Header_Destx.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.Header_Destx.Name = "Header_Destx";
            this.Header_Destx.Size = new System.Drawing.Size(74, 20);
            this.Header_Destx.TabIndex = 16;
            // 
            // label13
            // 
            this.label13.AutoSize = true;
            this.label13.Location = new System.Drawing.Point(180, 56);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(70, 13);
            this.label13.TabIndex = 15;
            this.label13.Text = "Dest. Addr. Y";
            // 
            // Header_Desty
            // 
            this.Header_Desty.Location = new System.Drawing.Point(256, 52);
            this.Header_Desty.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.Header_Desty.Name = "Header_Desty";
            this.Header_Desty.Size = new System.Drawing.Size(74, 20);
            this.Header_Desty.TabIndex = 14;
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(476, 56);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(54, 13);
            this.label10.TabIndex = 9;
            this.label10.Text = "Dest. Port";
            // 
            // Header_Destport
            // 
            this.Header_Destport.Location = new System.Drawing.Point(535, 52);
            this.Header_Destport.Maximum = new decimal(new int[] {
            7,
            0,
            0,
            0});
            this.Header_Destport.Name = "Header_Destport";
            this.Header_Destport.Size = new System.Drawing.Size(74, 20);
            this.Header_Destport.TabIndex = 8;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(336, 56);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(57, 13);
            this.label9.TabIndex = 7;
            this.label9.Text = "Dest. CPU";
            // 
            // Header_Destcpu
            // 
            this.Header_Destcpu.Location = new System.Drawing.Point(395, 52);
            this.Header_Destcpu.Maximum = new decimal(new int[] {
            31,
            0,
            0,
            0});
            this.Header_Destcpu.Name = "Header_Destcpu";
            this.Header_Destcpu.Size = new System.Drawing.Size(74, 20);
            this.Header_Destcpu.TabIndex = 6;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(331, 20);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(26, 13);
            this.label8.TabIndex = 5;
            this.label8.Text = "Tag";
            // 
            // Header_Tag
            // 
            this.Header_Tag.Location = new System.Drawing.Point(363, 16);
            this.Header_Tag.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.Header_Tag.Name = "Header_Tag";
            this.Header_Tag.Size = new System.Drawing.Size(74, 20);
            this.Header_Tag.TabIndex = 4;
            // 
            // Header_Reply
            // 
            this.Header_Reply.AutoSize = true;
            this.Header_Reply.Location = new System.Drawing.Point(268, 18);
            this.Header_Reply.Name = "Header_Reply";
            this.Header_Reply.Size = new System.Drawing.Size(52, 17);
            this.Header_Reply.TabIndex = 3;
            this.Header_Reply.Text = "Reply";
            this.Header_Reply.UseVisualStyleBackColor = true;
            // 
            // Header_NoReply
            // 
            this.Header_NoReply.AutoSize = true;
            this.Header_NoReply.Checked = true;
            this.Header_NoReply.Location = new System.Drawing.Point(193, 18);
            this.Header_NoReply.Name = "Header_NoReply";
            this.Header_NoReply.Size = new System.Drawing.Size(69, 17);
            this.Header_NoReply.TabIndex = 2;
            this.Header_NoReply.TabStop = true;
            this.Header_NoReply.Text = "No Reply";
            this.Header_NoReply.UseVisualStyleBackColor = true;
            // 
            // Button_sver
            // 
            this.Button_sver.Location = new System.Drawing.Point(12, 291);
            this.Button_sver.Name = "Button_sver";
            this.Button_sver.Size = new System.Drawing.Size(631, 35);
            this.Button_sver.TabIndex = 28;
            this.Button_sver.Text = "Get CPU Software Version";
            this.Button_sver.UseVisualStyleBackColor = true;
            this.Button_sver.Click += new System.EventHandler(this.Button_sver_Click);
            // 
            // Button_SendPkt
            // 
            this.Button_SendPkt.Location = new System.Drawing.Point(12, 332);
            this.Button_SendPkt.Name = "Button_SendPkt";
            this.Button_SendPkt.Size = new System.Drawing.Size(631, 35);
            this.Button_SendPkt.TabIndex = 29;
            this.Button_SendPkt.Text = "Send Packet";
            this.Button_SendPkt.UseVisualStyleBackColor = true;
            this.Button_SendPkt.Click += new System.EventHandler(this.Button_SendPkt_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(657, 24);
            this.menuStrip1.TabIndex = 30;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // Log
            // 
            this.Log.AllowUserToAddRows = false;
            this.Log.AllowUserToDeleteRows = false;
            this.Log.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
            this.Log.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.Log.ColumnHeadersVisible = false;
            this.Log.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Data});
            this.Log.Location = new System.Drawing.Point(13, 414);
            this.Log.Name = "Log";
            this.Log.ReadOnly = true;
            this.Log.RowHeadersVisible = false;
            this.Log.Size = new System.Drawing.Size(631, 377);
            this.Log.TabIndex = 31;
            // 
            // Data
            // 
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.Data.DefaultCellStyle = dataGridViewCellStyle2;
            this.Data.HeaderText = "Data";
            this.Data.MaxInputLength = 32768;
            this.Data.Name = "Data";
            this.Data.ReadOnly = true;
            this.Data.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Data.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            this.Data.Width = 600;
            // 
            // Button_Clear
            // 
            this.Button_Clear.Location = new System.Drawing.Point(13, 373);
            this.Button_Clear.Name = "Button_Clear";
            this.Button_Clear.Size = new System.Drawing.Size(304, 35);
            this.Button_Clear.TabIndex = 32;
            this.Button_Clear.Text = "Clear Log";
            this.Button_Clear.UseVisualStyleBackColor = true;
            this.Button_Clear.Click += new System.EventHandler(this.Button_Clear_Click);
            // 
            // Button_Save
            // 
            this.Button_Save.Enabled = false;
            this.Button_Save.Location = new System.Drawing.Point(340, 373);
            this.Button_Save.Name = "Button_Save";
            this.Button_Save.Size = new System.Drawing.Size(304, 35);
            this.Button_Save.TabIndex = 33;
            this.Button_Save.Text = "Save Log";
            this.Button_Save.UseVisualStyleBackColor = true;
            this.Button_Save.Click += new System.EventHandler(this.Button_Save_Click);
            // 
            // SpinMessenger
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(657, 803);
            this.Controls.Add(this.Button_Save);
            this.Controls.Add(this.Button_Clear);
            this.Controls.Add(this.Log);
            this.Controls.Add(this.Button_SendPkt);
            this.Controls.Add(this.Button_sver);
            this.Controls.Add(this.Header);
            this.Controls.Add(this.Command);
            this.Controls.Add(this.RPort_Label);
            this.Controls.Add(this.Port_Textbox);
            this.Controls.Add(this.RHost_Label);
            this.Controls.Add(this.Host_Textbox);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "SpinMessenger";
            this.Text = "SpinMessenger";
            this.Command.ResumeLayout(false);
            this.Command.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.Header.ResumeLayout(false);
            this.Header.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcex)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcey)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srceport)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Srcecpu)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destx)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Desty)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destport)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Destcpu)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Header_Tag)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.Log)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label RPort_Label;
        private System.Windows.Forms.TextBox Port_Textbox;
        private System.Windows.Forms.Label RHost_Label;
        private System.Windows.Forms.TextBox Host_Textbox;
        private System.Windows.Forms.GroupBox Command;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox Cmd_Arg3;
        private System.Windows.Forms.TextBox Cmd_Arg2;
        private System.Windows.Forms.TextBox Cmd_Arg1;
        private System.Windows.Forms.TextBox Cmd_Seq;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox Cmd_Cmd;
        private System.Windows.Forms.TextBox Cmd_data;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.GroupBox Header;
        private System.Windows.Forms.RadioButton Header_Reply;
        private System.Windows.Forms.RadioButton Header_NoReply;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.NumericUpDown Header_Tag;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.NumericUpDown Header_Destport;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.NumericUpDown Header_Destcpu;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.NumericUpDown Header_Srcex;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.NumericUpDown Header_Srcey;
        private System.Windows.Forms.Label label15;
        private System.Windows.Forms.NumericUpDown Header_Srceport;
        private System.Windows.Forms.Label label16;
        private System.Windows.Forms.NumericUpDown Header_Srcecpu;
        private System.Windows.Forms.Label label14;
        private System.Windows.Forms.NumericUpDown Header_Destx;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.NumericUpDown Header_Desty;
        private System.Windows.Forms.Button Button_sver;
        private System.Windows.Forms.Button Button_SendPkt;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.DataGridView Log;
        private System.Windows.Forms.Button Button_Clear;
        private System.Windows.Forms.Button Button_Save;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton Cmd_DataAs_Hex;
        private System.Windows.Forms.RadioButton Cmd_DataAs_Num;
        private System.Windows.Forms.RadioButton Cmd_DataAs_Text;
        private System.Windows.Forms.DataGridViewTextBoxColumn Data;
    }
}

