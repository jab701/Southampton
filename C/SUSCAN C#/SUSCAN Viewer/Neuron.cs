using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace SUSCAN
{
    class Neuron
    {
        public PointF Position;
        public PointF Size;
        public Color RGB;
        public String Name;
        public bool Active;
        public bool Enabled;

        public Neuron()
        {
            this.Position = new PointF(0,0);
            this.Size = new PointF(0, 0);
            this.RGB = Color.FromArgb(255, 255, 255);
            this.Name = "";
            this.Active = false;
            this.Enabled = true;
        }
        public Neuron(PointF Position, PointF Size, Color RGB, String Name, bool Enabled = true)
        {
            this.Position = Position;
            this.Size = Size;
            this.RGB = RGB;
            this.Name = Name;
            this.Active = false;
            this.Enabled = Enabled;
        }
    }
}
