using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class SphericalVector
    {
        public double Mag;
        public double Theta;
        public double Phi;

        public SphericalVector()
        {
            this.Mag = 0.0;
            this.Theta = 0.0;
            this.Phi = 0.0;
        }
        public SphericalVector(double Mag, double Theta, double Phi)
        {
            this.Mag = Mag;
            this.Theta = Theta;
            this.Phi = Phi;
        }
        public override bool Equals(Object o)
        {
            if (o == null)
            {
                return false;
            }

            if (!(o is SphericalVector))
            {
                return false;
            }

            return (this == (SphericalVector)o);
        }
        public override int GetHashCode()
        {
            UInt64 M64 = Convert.ToUInt64(this.Mag);
            UInt64 T64 = Convert.ToUInt64(this.Theta);
            UInt64 P64 = Convert.ToUInt64(this.Phi);

            return (int)(M64 ^ T64 ^ P64);
        }
        public static implicit operator SphericalVector(CartesianVector rhs)
        {
            SphericalVector NewVector = new SphericalVector();

	        double S_temp = Math.Sqrt(Math.Pow(rhs.x,2.0) + Math.Pow(rhs.y,2.0));
	        NewVector.Mag = Math.Sqrt(Math.Pow(rhs.x,2.0) + Math.Pow(rhs.y,2.0) + Math.Pow(rhs.z,2.0));

	        if (NewVector.Mag == 0.0)
	        {
		        NewVector.Phi = Math.Acos(0.0);
	        }
	        else
	        {
		        NewVector.Phi = Math.Acos(rhs.z/NewVector.Mag);
	        }

	        if (S_temp == 0.0)
	        {
		        NewVector.Theta = Math.Asin(0.0);
	        }
	        else
	        {
		        if (rhs.x < 0) 
		        {
			        NewVector.Theta = 3.1415926535897932384626433832795 - Math.Asin(rhs.y/S_temp);
		        }
		        else
		        {
                    NewVector.Theta = Math.Asin(rhs.y / S_temp);
		        }
	        }

	        return NewVector;
        }
        public static SphericalVector operator +(SphericalVector lhs, SphericalVector rhs)
        {
            CartesianVector Vector1 = lhs;
            CartesianVector Vector2 = rhs;

            Vector1 += Vector2;

            return Vector1;
        }
        public static SphericalVector operator -(SphericalVector lhs, SphericalVector rhs)
        {
            CartesianVector Vector1 = lhs;
            CartesianVector Vector2 = rhs;

            Vector1 -= Vector2;

            return Vector1;
        }
        public static SphericalVector operator *(SphericalVector lhs, double rhs)
        {
            SphericalVector Result = lhs;

            Result.Mag = Result.Mag * rhs;

            return Result;
        }
        public static SphericalVector operator *(double lhs, SphericalVector rhs)
        {
            return (rhs * lhs);
        }
        public static SphericalVector operator /(SphericalVector lhs, double rhs)
        {
            SphericalVector Result = lhs;

            Result.Mag = Result.Mag / rhs;

            return Result;
        }
        public static bool operator ==(SphericalVector lhs, SphericalVector rhs)
        {
            bool M = false;
            bool T = false;
            bool P = false;

            if (lhs.Mag == rhs.Mag)
            {
                M = true;
            }

            if (lhs.Theta == rhs.Theta)
            {
                T = true;
            }

            if (lhs.Phi == rhs.Phi)
            {
                P = true;
            }

            return (M && T && P);
        }
        public static bool operator !=(SphericalVector lhs, SphericalVector rhs)
        {
            return !(lhs == rhs);
        }
        public bool Equals(SphericalVector Vector)
        {
            return (this == Vector);
        }
    }
}
