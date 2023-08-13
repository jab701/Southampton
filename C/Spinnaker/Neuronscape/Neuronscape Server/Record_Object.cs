using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;

using Neuronscape;

namespace Neuronscape_Server
{
    class Record_Object
    {

        public UInt32 ID;
        public UInt32 Client_ID;
        public CartesianVector Position;
        public double Theta;
        public double Phi;
        public CartesianVector MotorForce;
        public double ThetaTorque;
        public double PhiTorque;
        public CartesianVector ExternForce;
        public CartesianVector Velocity;
        public double ThetaVelocity;
        public double PhiVelocity;
        public double Energy;
        public byte Red;
        public byte Green;
        public byte Blue;
        public byte Brightness;
        public UInt16 FLAGS;

        public Record_Object()
        {
            this.ID = 0;
            this.Client_ID = 0;
            this.Position = new CartesianVector(0.0, 0.0, 0.0);
            this.Theta = 0.0;
            this.Phi = 0.0;
            this.MotorForce = new CartesianVector(0.0, 0.0, 0.0);
            this.ThetaTorque = 0.0;
            this.PhiTorque = 0.0;
            this.ExternForce = new CartesianVector(0.0, 0.0, 0.0);
            this.Velocity = new CartesianVector(0.0, 0.0, 0.0);
            this.ThetaVelocity = 0.0;
            this.PhiVelocity = 0.0;
            this.Energy = 0.0;
            this.Red = 255;
            this.Green = 255;
            this.Blue = 255;
            this.Brightness = 255;
            this.FLAGS = 0;
        }


    }
}
