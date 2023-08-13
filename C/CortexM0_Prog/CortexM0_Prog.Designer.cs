namespace CortexM0_Prog
{
    partial class CortexM0Prog
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
            this.COM_ListBox = new System.Windows.Forms.ComboBox();
            this.label_COMSelect = new System.Windows.Forms.Label();
            this.Refresh_COMList = new System.Windows.Forms.Button();
            this.MainMenu = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.FileSelect = new System.Windows.Forms.OpenFileDialog();
            this.FilePath = new System.Windows.Forms.TextBox();
            this.Browse = new System.Windows.Forms.Button();
            this.label_Program_File = new System.Windows.Forms.Label();
            this.GO = new System.Windows.Forms.Button();
            this.Statusbar = new System.Windows.Forms.StatusStrip();
            this.Status = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripProgressBar1 = new System.Windows.Forms.ToolStripProgressBar();
            this.Log = new System.Windows.Forms.TextBox();
            this.Label_Log = new System.Windows.Forms.Label();
            this.MainMenu.SuspendLayout();
            this.Statusbar.SuspendLayout();
            this.SuspendLayout();
            // 
            // COM_ListBox
            // 
            this.COM_ListBox.FormattingEnabled = true;
            this.COM_ListBox.Location = new System.Drawing.Point(69, 38);
            this.COM_ListBox.Name = "COM_ListBox";
            this.COM_ListBox.Size = new System.Drawing.Size(203, 21);
            this.COM_ListBox.TabIndex = 0;
            // 
            // label_COMSelect
            // 
            this.label_COMSelect.AutoSize = true;
            this.label_COMSelect.Location = new System.Drawing.Point(-2, 41);
            this.label_COMSelect.Name = "label_COMSelect";
            this.label_COMSelect.Size = new System.Drawing.Size(53, 13);
            this.label_COMSelect.TabIndex = 1;
            this.label_COMSelect.Text = "COM Port";
            // 
            // Refresh_COMList
            // 
            this.Refresh_COMList.Location = new System.Drawing.Point(284, 35);
            this.Refresh_COMList.Name = "Refresh_COMList";
            this.Refresh_COMList.Size = new System.Drawing.Size(57, 27);
            this.Refresh_COMList.TabIndex = 2;
            this.Refresh_COMList.Text = "Refresh";
            this.Refresh_COMList.UseVisualStyleBackColor = true;
            this.Refresh_COMList.Click += new System.EventHandler(this.Refresh_COMList_Click);
            // 
            // MainMenu
            // 
            this.MainMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.MainMenu.Location = new System.Drawing.Point(0, 0);
            this.MainMenu.Name = "MainMenu";
            this.MainMenu.Size = new System.Drawing.Size(349, 24);
            this.MainMenu.TabIndex = 3;
            this.MainMenu.Text = "MainMenu";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "&File";
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(92, 22);
            this.exitToolStripMenuItem.Text = "E&xit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutToolStripMenuItem});
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "&Help";
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.aboutToolStripMenuItem.Text = "&About";
            this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
            // 
            // FileSelect
            // 
            this.FileSelect.FileName = "FileSelect";
            // 
            // FilePath
            // 
            this.FilePath.Location = new System.Drawing.Point(69, 71);
            this.FilePath.Name = "FilePath";
            this.FilePath.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
            this.FilePath.Size = new System.Drawing.Size(203, 20);
            this.FilePath.TabIndex = 4;
            // 
            // Browse
            // 
            this.Browse.Location = new System.Drawing.Point(284, 64);
            this.Browse.Name = "Browse";
            this.Browse.Size = new System.Drawing.Size(57, 27);
            this.Browse.TabIndex = 5;
            this.Browse.Text = "Browse";
            this.Browse.UseVisualStyleBackColor = true;
            this.Browse.Click += new System.EventHandler(this.Browse_Click);
            // 
            // label_Program_File
            // 
            this.label_Program_File.AutoSize = true;
            this.label_Program_File.Location = new System.Drawing.Point(-2, 74);
            this.label_Program_File.Name = "label_Program_File";
            this.label_Program_File.Size = new System.Drawing.Size(65, 13);
            this.label_Program_File.TabIndex = 6;
            this.label_Program_File.Text = "Program File";
            // 
            // GO
            // 
            this.GO.Location = new System.Drawing.Point(1, 107);
            this.GO.Name = "GO";
            this.GO.Size = new System.Drawing.Size(348, 69);
            this.GO.TabIndex = 7;
            this.GO.Text = "GO!";
            this.GO.UseVisualStyleBackColor = true;
            this.GO.Click += new System.EventHandler(this.GO_Click);
            // 
            // Statusbar
            // 
            this.Statusbar.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.Status,
            this.toolStripProgressBar1});
            this.Statusbar.Location = new System.Drawing.Point(0, 451);
            this.Statusbar.Name = "Statusbar";
            this.Statusbar.Size = new System.Drawing.Size(349, 22);
            this.Statusbar.TabIndex = 8;
            this.Statusbar.Text = "statusStrip1";
            // 
            // Status
            // 
            this.Status.AutoSize = false;
            this.Status.Name = "Status";
            this.Status.Size = new System.Drawing.Size(200, 17);
            // 
            // toolStripProgressBar1
            // 
            this.toolStripProgressBar1.AutoSize = false;
            this.toolStripProgressBar1.Name = "toolStripProgressBar1";
            this.toolStripProgressBar1.Size = new System.Drawing.Size(130, 16);
            // 
            // Log
            // 
            this.Log.BackColor = System.Drawing.SystemColors.Window;
            this.Log.Location = new System.Drawing.Point(0, 204);
            this.Log.Multiline = true;
            this.Log.Name = "Log";
            this.Log.ReadOnly = true;
            this.Log.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.Log.Size = new System.Drawing.Size(348, 244);
            this.Log.TabIndex = 9;
            // 
            // Label_Log
            // 
            this.Label_Log.AutoSize = true;
            this.Label_Log.Location = new System.Drawing.Point(-2, 188);
            this.Label_Log.Name = "Label_Log";
            this.Label_Log.Size = new System.Drawing.Size(67, 13);
            this.Label_Log.TabIndex = 10;
            this.Label_Log.Text = "Log Window";
            // 
            // CortexM0Prog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(349, 473);
            this.Controls.Add(this.Label_Log);
            this.Controls.Add(this.Log);
            this.Controls.Add(this.Statusbar);
            this.Controls.Add(this.GO);
            this.Controls.Add(this.label_Program_File);
            this.Controls.Add(this.Browse);
            this.Controls.Add(this.FilePath);
            this.Controls.Add(this.Refresh_COMList);
            this.Controls.Add(this.label_COMSelect);
            this.Controls.Add(this.COM_ListBox);
            this.Controls.Add(this.MainMenu);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MainMenuStrip = this.MainMenu;
            this.MaximizeBox = false;
            this.Name = "CortexM0Prog";
            this.Text = "Soton Cortex M0 Programmer";
            this.MainMenu.ResumeLayout(false);
            this.MainMenu.PerformLayout();
            this.Statusbar.ResumeLayout(false);
            this.Statusbar.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox COM_ListBox;
        private System.Windows.Forms.Label label_COMSelect;
        private System.Windows.Forms.Button Refresh_COMList;
        private System.Windows.Forms.MenuStrip MainMenu;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.OpenFileDialog FileSelect;
        private System.Windows.Forms.TextBox FilePath;
        private System.Windows.Forms.Button Browse;
        private System.Windows.Forms.Label label_Program_File;
        private System.Windows.Forms.Button GO;
        private System.Windows.Forms.StatusStrip Statusbar;
        private System.Windows.Forms.TextBox Log;
        private System.Windows.Forms.Label Label_Log;
        private System.Windows.Forms.ToolStripStatusLabel Status;
        private System.Windows.Forms.ToolStripProgressBar toolStripProgressBar1;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;

    }
}

