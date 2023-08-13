namespace SpinControl
{
    partial class AltBoot
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
            this.RHost_Label = new System.Windows.Forms.Label();
            this.RHost_TextBox = new System.Windows.Forms.TextBox();
            this.Browse_Button = new System.Windows.Forms.Button();
            this.label9 = new System.Windows.Forms.Label();
            this.BootFile_Textbox = new System.Windows.Forms.TextBox();
            this.Boot_Button = new System.Windows.Forms.Button();
            this.BootStatus = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // RHost_Label
            // 
            this.RHost_Label.AutoSize = true;
            this.RHost_Label.Location = new System.Drawing.Point(12, 17);
            this.RHost_Label.Name = "RHost_Label";
            this.RHost_Label.Size = new System.Drawing.Size(69, 13);
            this.RHost_Label.TabIndex = 12;
            this.RHost_Label.Text = "Remote Host";
            // 
            // RHost_TextBox
            // 
            this.RHost_TextBox.Location = new System.Drawing.Point(84, 13);
            this.RHost_TextBox.MaxLength = 1024;
            this.RHost_TextBox.Name = "RHost_TextBox";
            this.RHost_TextBox.Size = new System.Drawing.Size(444, 20);
            this.RHost_TextBox.TabIndex = 11;
            // 
            // Browse_Button
            // 
            this.Browse_Button.Location = new System.Drawing.Point(461, 37);
            this.Browse_Button.Name = "Browse_Button";
            this.Browse_Button.Size = new System.Drawing.Size(67, 25);
            this.Browse_Button.TabIndex = 15;
            this.Browse_Button.Text = "Browse";
            this.Browse_Button.UseVisualStyleBackColor = true;
            this.Browse_Button.Click += new System.EventHandler(this.Browse_Button_Click);
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(12, 43);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(67, 13);
            this.label9.TabIndex = 14;
            this.label9.Text = "File Location";
            // 
            // BootFile_Textbox
            // 
            this.BootFile_Textbox.Location = new System.Drawing.Point(84, 39);
            this.BootFile_Textbox.Name = "BootFile_Textbox";
            this.BootFile_Textbox.Size = new System.Drawing.Size(371, 20);
            this.BootFile_Textbox.TabIndex = 13;
            // 
            // Boot_Button
            // 
            this.Boot_Button.Location = new System.Drawing.Point(15, 75);
            this.Boot_Button.Name = "Boot_Button";
            this.Boot_Button.Size = new System.Drawing.Size(513, 26);
            this.Boot_Button.TabIndex = 16;
            this.Boot_Button.Text = "Boot";
            this.Boot_Button.UseVisualStyleBackColor = true;
            this.Boot_Button.Click += new System.EventHandler(this.Boot_Button_Click);
            // 
            // BootStatus
            // 
            this.BootStatus.ImeMode = System.Windows.Forms.ImeMode.On;
            this.BootStatus.Location = new System.Drawing.Point(19, 114);
            this.BootStatus.Name = "BootStatus";
            this.BootStatus.ReadOnly = true;
            this.BootStatus.Size = new System.Drawing.Size(508, 20);
            this.BootStatus.TabIndex = 17;
            // 
            // AltBoot
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(541, 145);
            this.Controls.Add(this.BootStatus);
            this.Controls.Add(this.Boot_Button);
            this.Controls.Add(this.Browse_Button);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.BootFile_Textbox);
            this.Controls.Add(this.RHost_Label);
            this.Controls.Add(this.RHost_TextBox);
            this.Name = "AltBoot";
            this.Text = "Alternate Boot Loader";
            this.Load += new System.EventHandler(this.AltBoot_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label RHost_Label;
        private System.Windows.Forms.TextBox RHost_TextBox;
        private System.Windows.Forms.Button Browse_Button;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.TextBox BootFile_Textbox;
        private System.Windows.Forms.Button Boot_Button;
        private System.Windows.Forms.TextBox BootStatus;
    }
}