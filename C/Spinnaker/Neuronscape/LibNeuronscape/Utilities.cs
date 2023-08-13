using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class Utilities
    {
        public static bool IntersectLines(double X1, double X2, double Y1, double Y2)
        {
            if (X1 > X2)
            {
                double Temp1 = X1;
                X1 = X2;
                X2 = Temp1;
            }

            if (Y1 > Y2)
            {
                double Temp2 = Y1;
                Y1 = Y2;
                Y2 = Temp2;
            }

            if (X1 < Y1)
            {
                if (Y1 < X2)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                if (X1 < Y2)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        public static bool IntersectSpheres(CartesianVector Obj1, double Obj1Radius, CartesianVector Obj2, double Obj2Radius)
        {
            CartesianVector Resultant_C = Obj1 - Obj2;

            SphericalVector Resultant_S = Resultant_C;

            double TotalCollisionDistance = Obj1Radius + Obj2Radius;

            if (TotalCollisionDistance > Resultant_S.Mag) // Radius 1 + Radius2 > Distance between objects = Collision!
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public static void RandomlyGeneratePosition(CartesianVector Limits, out CartesianVector RandomPosition)
        {
            System.Random Rand = new System.Random();

	        double X = Rand.NextDouble() * Limits.x;
	        double Y = Rand.NextDouble() * Limits.y;
	        double Z = 0.0;

	        RandomPosition = new CartesianVector(X,Y,Z);
        }
        public static bool SameSign(double x, double y)
        {
            return ((x >= 0) ^ (y < 0));
        }
        public static double GetSign(double x)
        {
            if (x > 0.0)
            {
                return 1.0;
            }
            else if (x < 0)
            {
                return -1.0;
            }
            else
            {
                return 0.0;
            }
        }
    }
}
