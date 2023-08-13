namespace SpinLogger
{
    partial class SpinnLogger
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            this.Port_Text = new System.Windows.Forms.TextBox();
            this.Port_Label = new System.Windows.Forms.Label();
            this.Listen_Button = new System.Windows.Forms.Button();
            this.DataGrid = new System.Windows.Forms.DataGridView();
            this.Time = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Source = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Data = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Tag_Options_Box = new System.Windows.Forms.GroupBox();
            this.RPort_Label = new System.Windows.Forms.Label();
            this.RPort_TextBox = new System.Windows.Forms.TextBox();
            this.RHost_Label = new System.Windows.Forms.Label();
            this.RHost_TextBox = new System.Windows.Forms.TextBox();
            this.Tag_Num_Lebel = new System.Windows.Forms.Label();
            this.Tag_Textbox = new System.Windows.Forms.TextBox();
            this.SetTag_CheckBox = new System.Windows.Forms.CheckBox();
            this.Options_Box = new System.Windows.Forms.GroupBox();
            this.Log_Box = new System.Windows.Forms.GroupBox();
            this.Clear_Log = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.Interfaces = new System.Windows.Forms.ComboBox();
            ((System.ComponentModel.ISupportInitialize)(this.DataGrid)).BeginInit();
            this.Tag_Options_Box.SuspendLayout();
            this.Options_Box.SuspendLayout();
            this.Log_Box.SuspendLayout();
            this.SuspendLayout();
            // 
            // Port_Text
            // 
            this.Port_Text.Location = new System.Drawing.Point(510, 11);
            this.Port_Text.MaxLength = 5;
            this.Port_Text.Name = "Port_Text";
            this.Port_Text.Size = new System.Drawing.Size(94, 20);
            this.Port_Text.TabIndex = 3;
            // 
            // Port_Label
            // 
            this.Port_Label.AutoSize = true;
            this.Port_Label.Location = new System.Drawing.Point(474, 15);
            this.Port_Label.Name = "Port_Label";
            this.Port_Label.Size = new System.Drawing.Size(26, 13);
            this.Port_Label.TabIndex = 2;
            this.Port_Label.Text = "Port";
            // 
            // Listen_Button
            // 
            this.Listen_Button.AllowDrop = true;
            this.Listen_Button.Location = new System.Drawing.Point(116, 212);
            this.Listen_Button.Name = "Listen_Button";
            this.Listen_Button.Size = new System.Drawing.Size(415, 26);
            this.Listen_Button.TabIndex = 4;
            this.Listen_Button.Text = "Start Listening";
            this.Listen_Button.UseVisualStyleBackColor = true;
            this.Listen_Button.Click += new System.EventHandler(this.Listen_Button_Click);
            // 
            // DataGrid
            // 
            this.DataGrid.AllowUserToAddRows = false;
            this.DataGrid.AllowUserToDeleteRows = false;
            this.DataGrid.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
            this.DataGrid.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.DataGrid.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Time,
            this.Source,
            this.Data});
            this.DataGrid.Location = new System.Drawing.Point(14, 244);
            this.DataGrid.Name = "DataGrid";
            this.DataGrid.ReadOnly = true;
            this.DataGrid.RowHeadersVisible = false;
            this.DataGrid.Size = new System.Drawing.Size(620, 375);
            this.DataGrid.TabIndex = 5;
            // 
            // Time
            // 
            this.Time.HeaderText = "Time";
            this.Time.Name = "Time";
            this.Time.ReadOnly = true;
            this.Time.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Time.Width = 150;
            // 
            // Source
            // 
            this.Source.HeaderText = "Source";
            this.Source.Name = "Source";
            this.Source.ReadOnly = true;
            this.Source.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            // 
            // Data
            // 
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.Data.DefaultCellStyle = dataGridViewCellStyle1;
            this.Data.HeaderText = "Data";
            this.Data.MaxInputLength = 512;
            this.Data.Name = "Data";
            this.Data.ReadOnly = true;
            this.Data.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.Data.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Programmatic;
            this.Data.Width = 350;
            // 
            // Tag_Options_Box
            // 
            this.Tag_Options_Box.Controls.Add(this.RPort_Label);
            this.Tag_Options_Box.Controls.Add(this.RPort_TextBox);
            this.Tag_Options_Box.Controls.Add(this.RHost_Label);
            this.Tag_Options_Box.Controls.Add(this.RHost_TextBox);
            this.Tag_Options_Box.Controls.Add(this.Tag_Num_Lebel);
            this.Tag_Options_Box.Controls.Add(this.Tag_Textbox);
            this.Tag_Options_Box.Controls.Add(this.SetTag_CheckBox);
            this.Tag_Options_Box.Location = new System.Drawing.Point(6, 13);
            this.Tag_Options_Box.Name = "Tag_Options_Box";
            this.Tag_Options_Box.Size = new System.Drawing.Size(607, 70);
            this.Tag_Options_Box.TabIndex = 7;
            this.Tag_Options_Box.TabStop = false;
            this.Tag_Options_Box.Text = "Tag Options";
            // 
            // RPort_Label
            // 
            this.RPort_Label.AutoSize = true;
            this.RPort_Label.Location = new System.Drawing.Point(162, 47);
            this.RPort_Label.Name = "RPort_Label";
            this.RPort_Label.Size = new System.Drawing.Size(66, 13);
            this.RPort_Label.TabIndex = 6;
            this.RPort_Label.Text = "Remote Port";
            // 
            // RPort_TextBox
            // 
            this.RPort_TextBox.Location = new System.Drawing.Point(234, 43);
            this.RPort_TextBox.MaxLength = 5;
            this.RPort_TextBox.Name = "RPort_TextBox";
            this.RPort_TextBox.Size = new System.Drawing.Size(367, 20);
            this.RPort_TextBox.TabIndex = 5;
            this.RPort_TextBox.Text = "17893";
            // 
            // RHost_Label
            // 
            this.RHost_Label.AutoSize = true;
            this.RHost_Label.Location = new System.Drawing.Point(162, 22);
            this.RHost_Label.Name = "RHost_Label";
            this.RHost_Label.Size = new System.Drawing.Size(69, 13);
            this.RHost_Label.TabIndex = 4;
            this.RHost_Label.Text = "Remote Host";
            // 
            // RHost_TextBox
            // 
            this.RHost_TextBox.Location = new System.Drawing.Point(234, 18);
            this.RHost_TextBox.MaxLength = 1024;
            this.RHost_TextBox.Name = "RHost_TextBox";
            this.RHost_TextBox.Size = new System.Drawing.Size(367, 20);
            this.RHost_TextBox.TabIndex = 3;
            // 
            // Tag_Num_Lebel
            // 
            this.Tag_Num_Lebel.AutoSize = true;
            this.Tag_Num_Lebel.Location = new System.Drawing.Point(9, 47);
            this.Tag_Num_Lebel.Name = "Tag_Num_Lebel";
            this.Tag_Num_Lebel.Size = new System.Drawing.Size(66, 13);
            this.Tag_Num_Lebel.TabIndex = 2;
            this.Tag_Num_Lebel.Text = "Tag Number";
            // 
            // Tag_Textbox
            // 
            this.Tag_Textbox.Location = new System.Drawing.Point(81, 43);
            this.Tag_Textbox.MaxLength = 3;
            this.Tag_Textbox.Name = "Tag_Textbox";
            this.Tag_Textbox.Size = new System.Drawing.Size(69, 20);
            this.Tag_Textbox.TabIndex = 1;
            // 
            // SetTag_CheckBox
            // 
            this.SetTag_CheckBox.AutoSize = true;
            this.SetTag_CheckBox.Location = new System.Drawing.Point(9, 20);
            this.SetTag_CheckBox.Name = "SetTag_CheckBox";
            this.SetTag_CheckBox.Size = new System.Drawing.Size(129, 17);
            this.SetTag_CheckBox.TabIndex = 0;
            this.SetTag_CheckBox.Text = "Automatically Set Tag";
            this.SetTag_CheckBox.UseVisualStyleBackColor = true;
            // 
            // Options_Box
            // 
            this.Options_Box.Controls.Add(this.Tag_Options_Box);
            this.Options_Box.Controls.Add(this.Log_Box);
            this.Options_Box.Location = new System.Drawing.Point(15, 44);
            this.Options_Box.Name = "Options_Box";
            this.Options_Box.Size = new System.Drawing.Size(619, 162);
            this.Options_Box.TabIndex = 8;
            this.Options_Box.TabStop = false;
            this.Options_Box.Text = "Options";
            // 
            // Log_Box
            // 
            this.Log_Box.Controls.Add(this.Clear_Log);
            this.Log_Box.Location = new System.Drawing.Point(6, 96);
            this.Log_Box.Name = "Log_Box";
            this.Log_Box.Size = new System.Drawing.Size(464, 60);
            this.Log_Box.TabIndex = 8;
            this.Log_Box.TabStop = false;
            this.Log_Box.Text = "Log Options";
            // 
            // Clear_Log
            // 
            this.Clear_Log.AllowDrop = true;
            this.Clear_Log.Location = new System.Drawing.Point(9, 17);
            this.Clear_Log.Name = "Clear_Log";
            this.Clear_Log.Size = new System.Drawing.Size(107, 26);
            this.Clear_Log.TabIndex = 7;
            this.Clear_Log.Text = "Clear Log";
            this.Clear_Log.UseVisualStyleBackColor = true;
            this.Clear_Log.Click += new System.EventHandler(this.Clear_Log_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(43, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Interface";
            // 
            // Interfaces
            // 
            this.Interfaces.FormattingEnabled = true;
            this.Interfaces.Location = new System.Drawing.Point(98, 12);
            this.Interfaces.Name = "Interfaces";
            this.Interfaces.Size = new System.Drawing.Size(370, 21);
            this.Interfaces.TabIndex = 11;
            // 
            // SpinnLogger
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(646, 631);
            this.Controls.Add(this.Interfaces);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.Options_Box);
            this.Controls.Add(this.DataGrid);
            this.Controls.Add(this.Listen_Button);
            this.Controls.Add(this.Port_Text);
            this.Controls.Add(this.Port_Label);
            this.Name = "SpinnLogger";
            this.Text = "SpinLogger - Spinnaker Logging Tool";
            this.Load += new System.EventHandler(this.SpinnLogger_Load);
            ((System.ComponentModel.ISupportInitialize)(this.DataGrid)).EndInit();
            this.Tag_Options_Box.ResumeLayout(false);
            this.Tag_Options_Box.PerformLayout();
            this.Options_Box.ResumeLayout(false);
            this.Log_Box.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox Port_Text;
        private System.Windows.Forms.Label Port_Label;
        private System.Windows.Forms.Button Listen_Button;
        private System.Windows.Forms.DataGridView DataGrid;
        private System.Windows.Forms.GroupBox Tag_Options_Box;
        private System.Windows.Forms.CheckBox SetTag_CheckBox;
        private System.Windows.Forms.TextBox Tag_Textbox;
        private System.Windows.Forms.GroupBox Options_Box;
        private System.Windows.Forms.GroupBox Log_Box;
        private System.Windows.Forms.Button Clear_Log;
        private System.Windows.Forms.DataGridViewTextBoxColumn Time;
        private System.Windows.Forms.DataGridViewTextBoxColumn Source;
        private System.Windows.Forms.DataGridViewTextBoxColumn Data;
        private System.Windows.Forms.Label RHost_Label;
        private System.Windows.Forms.TextBox RHost_TextBox;
        private System.Windows.Forms.Label Tag_Num_Lebel;
        private System.Windows.Forms.Label RPort_Label;
        private System.Windows.Forms.TextBox RPort_TextBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox Interfaces;
    }
}

