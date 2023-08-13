using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class CartesianVector
    {
        public double x;
        public double y;
        public double z;

        public CartesianVector()
        {
            this.x = 0.0;
            this.y = 0.0;
            this.z = 0.0;
        }
        public CartesianVector(double x, double y, double z)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        public override bool Equals(Object o)
        {
            if (o == null)
            {
                return false;
            }

            if (!(o is CartesianVector))
            {
                return false;
            }

            return (this == (CartesianVector)o);
        }
        public override int GetHashCode()
        {
            UInt64 X64 = Convert.ToUInt64(this.x);
            UInt64 Y64 = Convert.ToUInt64(this.y);
            UInt64 Z64 = Convert.ToUInt64(this.z);

            return (int)(X64 ^ Y64 ^ Z64);
        }
        public static implicit operator CartesianVector (SphericalVector rhs)
        {
            CartesianVector NewVector = new CartesianVector();

            NewVector.x = rhs.Mag * Math.Cos(rhs.Theta) * Math.Sin(rhs.Phi);
            NewVector.y = rhs.Mag * Math.Sin(rhs.Theta) * Math.Sin(rhs.Phi);
	        NewVector.z = rhs.Mag * Math.Cos(rhs.Phi);

	        return NewVector;
        }
        public static CartesianVector operator +(CartesianVector lhs, CartesianVector rhs)
        {
            CartesianVector Result = new CartesianVector();

            Result.x = lhs.x + rhs.x;
            Result.y = lhs.y + rhs.y;
            Result.z = lhs.z + rhs.z;

            return Result;
        }
        public static CartesianVector operator -(CartesianVector lhs, CartesianVector rhs)
        {
            CartesianVector Result = new CartesianVector();

            Result.x = lhs.x - rhs.x;
            Result.y = lhs.y - rhs.y;
            Result.z = lhs.z - rhs.z;

            return Result;
        }
        public static CartesianVector operator *(CartesianVector lhs, double rhs)
        {
            CartesianVector Result = new CartesianVector();

            Result.x = lhs.x * rhs;
            Result.y = lhs.y * rhs;
            Result.z = lhs.z * rhs;

            return Result;
        }
        public static CartesianVector operator *(double lhs, CartesianVector rhs)
        {
            return (rhs*lhs);
        }
        public static CartesianVector operator /(CartesianVector lhs, double rhs)
        {
            CartesianVector Result = new CartesianVector();

            Result.x = lhs.x / rhs;
            Result.y = lhs.y / rhs;
            Result.z = lhs.z / rhs;

            return Result;
        }
        public static bool operator ==(CartesianVector lhs, CartesianVector rhs)
        {
            bool X = false;
            bool Y = false;
            bool Z = false;

            if (lhs.x == rhs.x)
            {
                X = true;
            }

            if (lhs.y == rhs.y)
            {
               Y = true;
            }

            if (lhs.z == rhs.z)
            {
                Z = true;
            }

            return (X && Y && Z);
        }
        public static bool operator !=(CartesianVector lhs, CartesianVector rhs)
        {
            return !(lhs == rhs);
        }
        public CartesianVector UnitVector()
        {
            CartesianVector Unit = this;

            if (Unit.x != 0.0)
            {
                if (Unit.x < 0.0)
                {
                    Unit.x = -1.0;
                }
                else
                {
                    Unit.x = +1.0;
                }
            }
            if (Unit.y != 0.0)
            {
                if (Unit.y < 0.0)
                {
                    Unit.y = -1.0;
                }
                else
                {
                    Unit.y = +1.0;
                }
            }
            if (Unit.z != 0.0)
            {
                if (Unit.z < 0.0)
                {
                    Unit.z = -1.0;
                }
                else
                {
                    Unit.z = +1.0;
                }
            }

            return Unit;
        }
        public CartesianVector Abs()
        {
	        CartesianVector Result = this;
	        Result.x = Math.Abs(Result.x);
	        Result.y = Math.Abs(Result.y);
            Result.z = Math.Abs(Result.z);
	        return Result;
        }
    }
}
