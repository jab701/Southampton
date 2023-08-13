using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Neuronscape;

namespace Neuronscape_Server
{
    class Physics
    {
        double TimeStep;
        double mu_static;
        double mu_kinetic;
        double Gravity;
        CartesianVector EnvDim = new CartesianVector();

        public Physics(double TimeStep, double mu_static, double mu_kinetic, double Gravity, CartesianVector EnvDim)
        {
            this.TimeStep = TimeStep;
            this.mu_static = mu_static;
            this.mu_kinetic = mu_kinetic;
            this.Gravity = Gravity;
            this.EnvDim = EnvDim;
        }
        public void CalculatePositionVelocity(double TimeStep, CartesianVector StartPosition, CartesianVector StartVelocity, CartesianVector MotorForce, CartesianVector ExternForce, out CartesianVector FinishPosition, out CartesianVector FinishVelocity, ref double AvailableEnergy, double Mass, double Radius)
        {

            CartesianVector ForceDueToGravity = new CartesianVector(0.0, 0.0, -this.Gravity) * Mass;
            CartesianVector Force = MotorForce + ExternForce + ForceDueToGravity;

            CartesianVector Friction = new CartesianVector();
            CartesianVector Displacement = new CartesianVector();
            FinishVelocity = new CartesianVector();

            // X Direction
            // If force in the X direction is 0 then we are coasting
            if (Force.x == 0.0)
            {
                this.Coasting_PV(TimeStep, Mass, Radius, StartVelocity.x, out FinishVelocity.x, out Displacement.x);
            }
            else
            {
                this.Powered_PV(TimeStep, Mass, Radius, Force.x, StartVelocity.x, out FinishVelocity.x, out Displacement.x, out Friction.x);
            }

            // Y Direction
            // If force in the Y direction is 0 then we are coasting
            if (Force.y == 0.0)
            {
                this.Coasting_PV(TimeStep, Mass, Radius, StartVelocity.y, out FinishVelocity.y, out Displacement.y);
            }
            else
            {
                this.Powered_PV(TimeStep, Mass, Radius, Force.y, StartVelocity.y, out FinishVelocity.y, out Displacement.y, out Friction.y);
            }

            // Z Direction
            // If force in the Z direction is 0 then we are coasting
            if (Force.z == 0.0)
            {
                this.Coasting_PV(TimeStep, Mass, Radius, StartVelocity.z, out FinishVelocity.z, out Displacement.z);
            }
            else
            {
                this.Powered_PV(TimeStep, Mass, Radius, Force.z, StartVelocity.z, out FinishVelocity.z, out Displacement.z, out Friction.z);
            }

            FinishPosition = StartPosition + Displacement;

            this.EnvBoundsCheck(ref FinishPosition, ref FinishVelocity, Radius, EnvDim);

            CartesianVector ActualDisplacement = FinishPosition - StartPosition;

            double WorkDone = this.CalculateMovementWorkDone(ActualDisplacement, MotorForce, Friction, ExternForce, Mass);

            if ((AvailableEnergy - WorkDone) < 0.0)
            {
                // There is not enough energy to perform the movement
                AvailableEnergy = 0.0;
            }
            else
            {

                AvailableEnergy -= WorkDone;

            }
        }
        public void Coasting_PV(double TimeStep, double Mass, double Radius, double U, out double V, out double S)
        {
            double U_Sign = Utilities.GetSign(U);

            double Friction = -1.0 * U_Sign * mu_kinetic * Mass * this.Gravity;

            double A = Friction / Mass;

            if (U == 0.0)
            {
                V = 0.0;
            }
            else
            {
                V = U + A * TimeStep;

                if (!Utilities.SameSign(U, V)) // If we are coasting our velocity cannot change direction
                {
                    V = 0.0;
                }
            }
            
            S = (V + U * 0.5) * TimeStep;
        }
        public void Powered_PV(double TimeStep, double Mass, double Radius, double Force, double U, out double V, out double S, out double Friction)
        {
            double A;
            double ResultantForce;
            double Force_Sign = Utilities.GetSign(Force);
            double U_Sign = Utilities.GetSign(U);

            if (U == 0.0)
            {
                // We are dealing with Static Friction, Friction opposes the motor force
                Friction = -1.0 * Force_Sign * mu_static * Mass * this.Gravity;
                ResultantForce = Force + Friction;

                if (!Utilities.SameSign(ResultantForce, Force))
                    // If the resultant force is in the direction of friction then 
                    // We cannot overcome static friction so we stay still
                {
                    ResultantForce = 0.0;
                    A = 0.0;
                    S = 0.0;
                    V = 0.0;
                }
                else
                    // We can overcome static friction so we start accellerating
                {
                    A = ResultantForce / Mass;
                    V = U + A * TimeStep;
                    S = ((V + U) * 0.5) * TimeStep;
                }
            }
            else
                // We are already moving, Friction opposes motion.
            {
                Friction = -1.0 * U_Sign * mu_kinetic * Mass * this.Gravity;

                A = (Force + Friction) / Mass;

                 // Are friction and the motor force in the same direction?
                if (Utilities.SameSign(Force, Friction))
                {
                    // Force & Friction has the same sign. This means the object could stop and reverse
                    // direction in this time step.
                    V = U + A * TimeStep;
                }
                else
                {
                    // Force and Friction are in opposition. If we are slowing down then we cant reverse direction
                    V = U + A * TimeStep;

                    if (!Utilities.SameSign(U, V))
                    {
                        V = 0.0;
                    }
                }

                S = ((V + U) * 0.5) * TimeStep;
            }
        }
        public void CalculateRotation(double TimeStep, double Radius, double Torque, double StartTheta, double StartOmega, out double FinishTheta, out double FinishOmega, ref double AvailableEnergy, double Mass)
        {
            double Friction = 0.0;
            double AngularDisplacement;

            if (Torque == 0.0)
            {
                this.Coasting_Rotation(TimeStep, Mass, Radius, StartOmega, out FinishOmega, out AngularDisplacement);
            }
            else
            {
                this.Powered_Rotation(TimeStep, Mass, Radius, Torque, StartOmega, out FinishOmega, out AngularDisplacement, out Friction);
            }

            double WorkDone = this.CalculateRotationWorkDone(Torque, Friction, AngularDisplacement);

            FinishTheta = StartTheta + AngularDisplacement;

            if (FinishTheta > 2.0 * Constants.PI)
            {
                FinishTheta -= 2.0 * Constants.PI;
            }

            if (FinishTheta < 0.0)
            {
                FinishTheta += 2.0 * Constants.PI;
            }

            if ((AvailableEnergy - WorkDone) < 0.0)
            {
                // There is not enough energy to perform the movement
                AvailableEnergy = 0.0;
            }
            else
            {
                AvailableEnergy -= WorkDone;
            }
        }
        public void Coasting_Rotation(double TimeStep, double Mass, double Radius, double U, out double V, out double S)
        {
            double U_Sign = Utilities.GetSign(U);

            double Friction = -1.0 * U_Sign * mu_kinetic * Mass * this.Gravity;

            // Model object as a sphere and calculate interia
            double Inertia = (2.0 / 5.0) * Mass * Radius * Radius;
            double A = Friction / Inertia;

            if (U == 0.0)
            {
                V = 0.0;
            }
            else
            {
                V = U + A * TimeStep;

                if (!Utilities.SameSign(U, V)) // If we are coasting our velocity cannot change direction
                {
                    V = 0.0;
                }
            }

            S = (V + U * 0.5) * TimeStep;
        }
        public void Powered_Rotation(double TimeStep, double Mass, double Radius, double Force, double U, out double V, out double S, out double Friction)
        {
            double A;
            double ResultantForce;
            double Force_Sign = Utilities.GetSign(Force);
            double U_Sign = Utilities.GetSign(U);

            // Model object as a sphere and calculate interia
            double Inertia = (2.0 / 5.0) * Mass * Radius * Radius;

            if (U == 0.0)
            {
                // We are dealing with Static Friction, Friction opposes the motor force
                Friction = -1.0 * Force_Sign * mu_static * Mass * this.Gravity;
                ResultantForce = Force + Friction;

                if (!Utilities.SameSign(ResultantForce, Force))
                // If the resultant force is in the direction of friction then 
                // We cannot overcome static friction so we stay still
                {
                    ResultantForce = 0.0;
                    A = 0.0;
                    S = 0.0;
                    V = 0.0;
                }
                else
                // We can overcome static friction so we start accellerating
                {
                    A = ResultantForce / Inertia;
                    V = U + A * TimeStep;
                    S = ((V + U) * 0.5) * TimeStep;
                }
            }
            else
            // We are already moving, Friction opposes motion.
            {
                Friction = -1.0 * U_Sign * mu_kinetic * Mass * this.Gravity;

                A = (Force + Friction) / Inertia;

                // Are friction and the motor force in the same direction?
                if (Utilities.SameSign(Force, Friction))
                {
                    // Force & Friction has the same sign. This means the object could stop and reverse
                    // direction in this time step.
                    V = U + A * TimeStep;
                }
                else
                {
                    // Force and Friction are in opposition. If we are slowing down then we cant reverse direction
                    V = U + A * TimeStep;

                    if (!Utilities.SameSign(U, V))
                    {
                        V = 0.0;
                    }
                }

                S = ((V + U) * 0.5) * TimeStep;
            }
        }
        
        private void EnvBoundsCheck(ref CartesianVector Position, ref CartesianVector Velocity, double Radius, CartesianVector Bounds)
        {
            //*********************************************************
            // Check that object is still within bounds of environment!
            //*********************************************************
            // Check x direction
            if ((Position.x - Radius) < 0.0)
            {
                Position.x = Radius; // Ensures whole object is within bounds
                Velocity.x = 0.0;
            }
            else if ((Position.x + Radius) > Bounds.x)
            {
                Position.x = (Bounds.x - Radius); // Ensures whole object is within bounds
                Velocity.x = 0.0;
            }

            // Check y direction
            if ((Position.y - Radius) < 0.0)
            {
                Position.y = Radius; // Ensures whole object is within bounds
                Velocity.y = 0.0;
            }
            else if ((Position.y + Radius) > Bounds.y)
            {
                Position.y = (Bounds.y - Radius); // Ensures whole object is within bounds
                Velocity.y = 0.0;
            }

            // Check z direction
            if ((Position.z - Radius) < 0.0)
            {
                Position.z = Radius; // Ensures whole object is within bounds
                Velocity.z = 0.0;
            }
            else if ((Position.z + Radius) > Bounds.z)
            {
                Position.z = (Bounds.z - Radius); // Ensures whole object is within bounds
                Velocity.z = 0.0;
            }
        }
        private double CalculateMovementWorkDone(CartesianVector Displacement, CartesianVector MotorForce, CartesianVector Friction, CartesianVector ExternalForce, double Mass)
        {
            CartesianVector ForceDueToGravity = new CartesianVector(0.0, 0.0, -9.8) * Mass;
            CartesianVector MotorUnitVector = MotorForce.UnitVector();
            CartesianVector WorkDoneVector = MotorForce - Friction - ExternalForce - ForceDueToGravity;

            Displacement = Displacement.Abs();

            double WorkDoneX = MotorUnitVector.x * WorkDoneVector.x * Displacement.x;
            double WorkDoneY = MotorUnitVector.y * WorkDoneVector.y * Displacement.y;
            double WorkDoneZ = MotorUnitVector.z * WorkDoneVector.z * Displacement.z;

            double WorkDone = WorkDoneX + WorkDoneY + WorkDoneZ;

            return WorkDone;
        }
        private double CalculateRotationWorkDone(double Torque, double TorqueFriction, double Displacement)
        {
            double WorkDoneForce = 0.0;

            if (Torque != 0.0)
            {
                WorkDoneForce = Torque - TorqueFriction;
            }

            return (Math.Abs(WorkDoneForce * Displacement));
        }
    }
}
