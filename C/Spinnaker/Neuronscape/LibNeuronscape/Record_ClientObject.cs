using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class Record_ClientObject
    {
        public UInt32 ID;
        public CartesianVector Position;
        public double Theta;
        public double Phi;
        public double Energy;
        public byte Red;
        public byte Green;
        public byte Blue;
        public byte Brightness;
        public UInt16 FLAGS;

        public Record_ClientObject()
        {
            this.ID = 0;
            this.Position = new CartesianVector(0.0, 0.0, 0.0);
            this.Theta = 0.0;
            this.Phi = 0.0;
            this.Energy = 0.0;
            this.Red = 255;
            this.Green = 255;
            this.Blue = 255;
            this.Brightness = 255;
            this.FLAGS = 0;
        }

    }
}
