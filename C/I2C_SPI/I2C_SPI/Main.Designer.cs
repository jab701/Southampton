namespace I2C_SPI
{
    partial class Main
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
            this.label_COMSelect = new System.Windows.Forms.Label();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.MenuItem_Exit = new System.Windows.Forms.ToolStripMenuItem();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.Status = new System.Windows.Forms.ToolStripStatusLabel();
            this.COM_ListBox = new System.Windows.Forms.ComboBox();
            this.RefreshComList = new System.Windows.Forms.Button();
            this.Log = new System.Windows.Forms.TextBox();
            this.label_logwindow = new System.Windows.Forms.Label();
            this.StartButton = new System.Windows.Forms.CheckBox();
            this.menuStrip1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // label_COMSelect
            // 
            this.label_COMSelect.AutoSize = true;
            this.label_COMSelect.Location = new System.Drawing.Point(-1, 30);
            this.label_COMSelect.Name = "label_COMSelect";
            this.label_COMSelect.Size = new System.Drawing.Size(53, 13);
            this.label_COMSelect.TabIndex = 0;
            this.label_COMSelect.Text = "COM Port";
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(302, 24);
            this.menuStrip1.TabIndex = 2;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.MenuItem_Exit});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "&File";
            // 
            // MenuItem_Exit
            // 
            this.MenuItem_Exit.Name = "MenuItem_Exit";
            this.MenuItem_Exit.Size = new System.Drawing.Size(92, 22);
            this.MenuItem_Exit.Text = "E&xit";
            this.MenuItem_Exit.Click += new System.EventHandler(this.MenuItem_Exit_Click);
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.Status});
            this.statusStrip1.Location = new System.Drawing.Point(0, 240);
            this.statusStrip1.MaximumSize = new System.Drawing.Size(0, 279);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(302, 22);
            this.statusStrip1.TabIndex = 3;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // Status
            // 
            this.Status.Name = "Status";
            this.Status.Size = new System.Drawing.Size(39, 17);
            this.Status.Text = "Status";
            // 
            // COM_ListBox
            // 
            this.COM_ListBox.FormattingEnabled = true;
            this.COM_ListBox.Location = new System.Drawing.Point(56, 27);
            this.COM_ListBox.Name = "COM_ListBox";
            this.COM_ListBox.Size = new System.Drawing.Size(180, 21);
            this.COM_ListBox.TabIndex = 4;
            // 
            // RefreshComList
            // 
            this.RefreshComList.Location = new System.Drawing.Point(242, 27);
            this.RefreshComList.Name = "RefreshComList";
            this.RefreshComList.Size = new System.Drawing.Size(57, 20);
            this.RefreshComList.TabIndex = 5;
            this.RefreshComList.Text = "Refresh";
            this.RefreshComList.UseVisualStyleBackColor = true;
            this.RefreshComList.Click += new System.EventHandler(this.RefreshComList_Click);
            // 
            // Log
            // 
            this.Log.BackColor = System.Drawing.SystemColors.Window;
            this.Log.Location = new System.Drawing.Point(2, 107);
            this.Log.Multiline = true;
            this.Log.Name = "Log";
            this.Log.ReadOnly = true;
            this.Log.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.Log.Size = new System.Drawing.Size(299, 133);
            this.Log.TabIndex = 6;
            // 
            // label_logwindow
            // 
            this.label_logwindow.AutoSize = true;
            this.label_logwindow.Location = new System.Drawing.Point(-1, 91);
            this.label_logwindow.Name = "label_logwindow";
            this.label_logwindow.Size = new System.Drawing.Size(67, 13);
            this.label_logwindow.TabIndex = 7;
            this.label_logwindow.Text = "Log Window";
            // 
            // StartButton
            // 
            this.StartButton.Appearance = System.Windows.Forms.Appearance.Button;
            this.StartButton.Location = new System.Drawing.Point(2, 53);
            this.StartButton.Name = "StartButton";
            this.StartButton.Size = new System.Drawing.Size(300, 23);
            this.StartButton.TabIndex = 9;
            this.StartButton.Text = "Start";
            this.StartButton.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.StartButton.UseVisualStyleBackColor = true;
            this.StartButton.CheckedChanged += new System.EventHandler(this.Run);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(302, 262);
            this.Controls.Add(this.StartButton);
            this.Controls.Add(this.label_logwindow);
            this.Controls.Add(this.Log);
            this.Controls.Add(this.RefreshComList);
            this.Controls.Add(this.COM_ListBox);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.label_COMSelect);
            this.Controls.Add(this.menuStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.MainMenuStrip = this.menuStrip1;
            this.MaximizeBox = false;
            this.Name = "Main";
            this.Text = "I2C_SPI";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label_COMSelect;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem MenuItem_Exit;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel Status;
        private System.Windows.Forms.ComboBox COM_ListBox;
        private System.Windows.Forms.Button RefreshComList;
        private System.Windows.Forms.TextBox Log;
        private System.Windows.Forms.Label label_logwindow;
        private System.Windows.Forms.CheckBox StartButton;
    }
}

