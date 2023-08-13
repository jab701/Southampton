using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SUSCAN
{
    public partial class Main : Form
    {
        List<Neuron> Neurons = new List<Neuron>();

        public Main()
        {
            InitializeComponent();

            // Set Double Buffered Drawing Mode to Reduce FLicker
            this.DoubleBuffered = true;

            Neuron NewNeuron1 = new Neuron(new PointF (0, 0), new PointF(50,50), Color.FromArgb(0,218,0), "NRV");
            Neuron NewNeuron2 = new Neuron(new PointF(0, 360), new PointF(50, 50), Color.FromArgb(0, 218, 0), "NRD");
            Neurons.Add(NewNeuron1);
            Neurons.Add(NewNeuron2);
        }
        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics DC = e.Graphics;
            DC.Clear(Color.FromArgb(255, 255, 255));
            Rectangle R = e.ClipRectangle;
            DC.TranslateTransform(R.X, R.Y);

            foreach(Neuron N in Neurons)
            {
                this.DrawNeuron(DC, N.Position, N.Size, N.RGB, N.Name, N.Active, N.Enabled);
            }
        }
        private void DrawNeuron(Graphics DC, PointF Position, PointF Size, Color Col, String Name, bool Active = false, bool Enabled = true)
        {

            SolidBrush Brush1;

            if ((Active == true)&&(Enabled == true))
            {
                byte red = (byte)~Col.R;
                byte green = (byte)~Col.G;
                byte blue = (byte)~Col.B;
                Color InvCol = Color.FromArgb(red, green, blue);
                Brush1 = new SolidBrush(InvCol);
            }
            else
            {
                Brush1 = new SolidBrush(Col);
            }

            Pen Pen1 = new Pen(Color.FromArgb(0, 0, 0));
            
            SolidBrush Brush2 = new SolidBrush(Color.FromArgb(0, 0, 0));
            Font font1 = new Font("Arial", 11, FontStyle.Bold);

            // Fill ellipse on screen.
            DC.FillEllipse(Brush1, Position.X, Position.Y, Size.X, Size.Y);
            DC.DrawEllipse(Pen1, Position.X, Position.Y, Size.X, Size.Y);
            DC.DrawString(Name, font1, Brush2, new PointF(Position.X + 8, Position.Y + 18));

            if (Enabled == false)
            {
                this.DrawDisabledNeuronOverlay(DC, Position, Size);
            }
        }
        private void DrawDisabledNeuronOverlay(Graphics DC, PointF Position, PointF Size)
        {
            Pen Pen1 = new Pen(Color.FromArgb(0, 0, 0));
            Pen1.Width = 5.0F;

            Size.X = Size.X / 2.0F;
            Size.Y = Size.Y / 2.0F;

            Position.X = Position.X + Size.X;
            Position.Y = Position.Y + Size.Y;

            PointF Line1_S = new PointF(Position.X - Size.X, Position.Y - Size.Y);
            PointF Line1_F = new PointF(Position.X + Size.X, Position.Y + Size.Y);

            PointF Line2_S = new PointF(Position.X - Size.X, Position.Y + Size.Y);
            PointF Line2_F = new PointF(Position.X + Size.X, Position.Y - Size.Y);

            // First Line
            DC.DrawLine(Pen1, Line1_S, Line1_F);
            // Second Line
            DC.DrawLine(Pen1, Line2_S, Line2_F);
        }
        private void Main_Load(object sender, EventArgs e)
        {
            //this.MouseClick += Mouse_Event;
            this.MouseDown += Mouse_Event;
            this.Connect.Enabled = true;
            this.Disconnect.Enabled = false;
            this.Reset.Enabled = false;
            this.Forwards.Enabled = false;
            this.Stop.Enabled = false;
            this.Backwards.Enabled = false;
            this.Coil.Enabled = false;

            this.Update_StatusText("Program Loaded");
        }
        private void Update_StatusText(string Text)
        {
            this.StatusText.Text = Text;
        }
        private void Connect_Click(object sender, EventArgs e)
        {

        }
        private void Disconnect_Click(object sender, EventArgs e)
        {

        }
        private void Reset_Click(object sender, EventArgs e)
        {

        }
        private void Forwards_Click(object sender, EventArgs e)
        {

        }
        private void Stop_Click(object sender, EventArgs e)
        {

        }
        private void Backwards_Click(object sender, EventArgs e)
        {

        }
        private void Coil_Click(object sender, EventArgs e)
        {

        }
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            AboutBox About = new AboutBox();
            About.ShowDialog();
        }
        private void Mouse_Event(object sender, MouseEventArgs e)
        {
            // We have to correct for the fact that the menu & toobar sits in client space. 
            uint OffsetY = (uint)(this.toolStrip1.Size.Height + this.MainMenuStrip.Height);

            if (e.Button == MouseButtons.Left)
            {
                // First lets see if a neuron was clicked on
                bool NeuronClick = this.EnableDisableNeuron((uint)e.X, (uint)e.Y, OffsetY);

                if (NeuronClick)
                {
                    this.Invalidate();
                    this.Update();

                    // Send updated Neuron Control Data To Hardware
                    return;
                }
            }
        }
        private bool EnableDisableNeuron(uint MouseX, uint MouseY, uint OffsetY)
        {
            bool Found = false;

            foreach (Neuron N in Neurons)
            {
                uint LimitX_Min = (uint)N.Position.X;
                uint LimitX_Max = (uint)(LimitX_Min + N.Size.X);

                uint LimitY_Min = (uint)N.Position.Y + OffsetY;
                uint LimitY_Max = (uint)(LimitY_Min + N.Size.Y);

                if ((LimitX_Min <= MouseX) && (LimitX_Max >= MouseX))
                {
                    if ((LimitY_Min <= MouseY) && (LimitY_Max >= MouseY))
                    {
                        Found = true;
                        N.Enabled = !N.Enabled;

                        if (N.Enabled == false)
                        {
                            N.Active = false;
                        }
                    }
                }
            }

            return Found;
        }
    }
}
