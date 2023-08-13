using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Threading;

using Neuronscape;

namespace Neuronscape_Server
{
    class DB_Object
    {
        private object locker = new object();
        private Dictionary<UInt32, Record_Object> DB_ID = new Dictionary<UInt32, Record_Object>();
        private Dictionary<UInt32, UInt32> DB_ClientID = new Dictionary<UInt32, UInt32>();
        private UInt32 NextID = 1;
        private CartesianVector EnvDimensions = new CartesianVector(0.0, 0.0, 0.0);
        private bool DirtyBit = false;

        public DB_Object(CartesianVector EnvDimensions)
        {
            this.Clear();
            this.EnvDimensions  = EnvDimensions;
        }
        public void Clear()
        {
            lock (locker)
            {
                this.DB_ID.Clear();
                this.DB_ClientID.Clear();
                this.NextID = 1;
                this.DirtyBit = false;
            }
        }
        public void SetDirtyBit()
        {
            lock (locker)
            {
                this.DirtyBit = true;
            }
        }
        public void ClearDirtyBit()
        {
            lock (locker)
            {
                this.DirtyBit = false;
            }
        }
        public bool IsDirty()
        {
            lock (locker)
            {
                return this.DirtyBit;
            }
        }
        public List<Record_Object> FetchAll()
        {
            List<Record_Object> Objects = new List<Record_Object>();

            lock (locker)
            {
                foreach (KeyValuePair<UInt32, Record_Object> entry in DB_ID)
                {
                    Objects.Add(entry.Value);
                }
            }

            return Objects;
        }
        public List<Record_Object> FetchAllMobile()
        {
            List<Record_Object> Objects = new List<Record_Object>();

            lock (locker)
            {
                foreach (KeyValuePair<UInt32, Record_Object> entry in DB_ID)
                {
                    Record_Object Object = entry.Value;

                    if ((Object.FLAGS & ObjectFlags.OBJFLAG_FIXED) == 0)
                    {
                        Objects.Add(entry.Value);
                    }
                }
            }

            return Objects;
        }
        public bool FindByID(UInt32 ID, out Record_Object Object)
        {
            lock (locker)
            {

                if (this.DB_ID.ContainsKey(ID))
                {
                    Object = this.DB_ID[ID];
                    return true;
                }
                else
                {
                    Object = null;
                    return false;
                }
            }

        }
        public bool FindByClientID(UInt32 ClientID, out Record_Object Object)
        {
            lock (locker)
            {

                if (this.DB_ClientID.ContainsKey(ClientID))
                {
                    bool ReturnVal = this.FindByID(this.DB_ClientID[ClientID], out Object);
                    return ReturnVal;
                }
                else
                {
                    Object = null;
                    return false;
                }
            }

        }
        public bool FindBetweenCoordinates(CartesianVector Point1, CartesianVector Point2, out List<Record_Object> Records)
        {
            lock (locker)
            {

                double X1 = Point1.x;
                double Y1 = Point1.y;
                double Z1 = Point1.z;

                double X2 = Point2.x;
                double Y2 = Point2.y;
                double Z2 = Point2.z;

                Records = new List<Record_Object>();

                foreach (KeyValuePair<UInt32, Record_Object> entry in DB_ID)
                {
                    Record_Object CurrentRecord = entry.Value;

                    double ObjXmin = CurrentRecord.Position.x - Constants.Radius;
                    double ObjYmin = CurrentRecord.Position.y - Constants.Radius;
                    double ObjZmin = CurrentRecord.Position.z - Constants.Radius;

                    double ObjXmax = CurrentRecord.Position.x + Constants.Radius;
                    double ObjYmax = CurrentRecord.Position.y + Constants.Radius;
                    double ObjZmax = CurrentRecord.Position.z + Constants.Radius;

                    bool IntersectX = Utilities.IntersectLines(X1, X2, ObjXmin, ObjXmax);
                    bool IntersectY = Utilities.IntersectLines(Y1, Y2, ObjYmin, ObjYmax);
                    bool IntersectZ = Utilities.IntersectLines(Z1, Z2, ObjZmin, ObjZmax);

                    if (IntersectX & IntersectY & IntersectZ)
                    {
                        // If we get here then an object has been found
                        Records.Add(CurrentRecord);
                    }
                }

            }
            return true;
        }
        public bool CollisionDetector(CartesianVector Obj, double Obj_Radius)
        {
            bool Collision = false;

            lock (locker)
            {
                foreach (KeyValuePair<UInt32, Record_Object> entry in DB_ID)
                {
                    Record_Object CurrentRecord = entry.Value;

                    CartesianVector Position = CurrentRecord.Position;

                    Collision = Utilities.IntersectSpheres(Obj, Obj_Radius, Position, Constants.Radius);
                }
            }
            return Collision;
        }
        public void WithinLimits(ref CartesianVector Position, CartesianVector Limits)
        {
            if ((Position.x - Constants.Radius) <= 0.0)
            {
                Position.x = Constants.Radius;
            }

            if ((Position.x + Constants.Radius) >= Limits.x)
            {
                Position.x = Limits.x - Constants.Radius;
            }

            if ((Position.y - Constants.Radius) <= 0.0)
            {
                Position.y = Constants.Radius;
            }

            if ((Position.y + Constants.Radius) >= Limits.y)
            {
                Position.y = Limits.y - Constants.Radius;
            }

            if ((Position.z - Constants.Radius) <= 0.0)
            {
                Position.z = Constants.Radius;
            }

            if ((Position.z + Constants.Radius) >= Limits.z)
            {
                Position.z = Limits.z - Constants.Radius;
            }
        }

        // Insert Record Functions
        public bool InsertRecord(Record_Object Record)
        {
            lock (locker)
            {

                if (this.NextID == 0)
                {
                    return false;
                }

                // if any of the requested positions are negative (i.e., invalid) then place the new object uniformly at random
                if ((Record.Position.x < 0) || (Record.Position.y < 0) || (Record.Position.z < 0))
                {
                    Utilities.RandomlyGeneratePosition(this.EnvDimensions, out Record.Position);
                }

                // Ensure object is within limits
                this.WithinLimits(ref Record.Position, this.EnvDimensions);

                bool Placed = false;

                if (this.CollisionDetector(Record.Position, Constants.Radius)) // If the new object collides with an exisiting one we must generate position
                {
                    for (int i = 0; i < Constants.MaxPlacementAttempts; i++)
                    {
                        Utilities.RandomlyGeneratePosition(this.EnvDimensions, out Record.Position); // Generate new position

                        // Ensure object is within limits
                        this.WithinLimits(ref Record.Position, this.EnvDimensions);

                        if (!this.CollisionDetector(Record.Position, Constants.Radius)) // Does it collide?
                        {
                            Placed = true;
                            break; // No
                        }
                    }

                    if (Placed == false)
                    {
                        return false;
                    }
                }

                if (Record.Client_ID == 0)
                // Object is inanimate since it does not have an owner
                {


                    Record.ID = this.NextID;
                    Record.Client_ID = 0;

                    this.DB_ID.Add(this.NextID, Record);
                }
                else
                // Object "Belongs" to an NEI Client
                {
                    if (this.DB_ClientID.ContainsKey(Record.Client_ID))
                    {
                        return false;
                    }

                    Record.ID = this.NextID;

                    this.DB_ID.Add(Record.ID, Record);
                    this.DB_ClientID.Add(Record.Client_ID, Record.ID);
                }

                this.NextID++;
            }
            return true;
        }
        // Update Record Functions
        public bool UpdateRecord_Colour(UInt32 ID, byte Red, byte Green, byte Blue, byte Brightness)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].Red = Red;
                this.DB_ID[ID].Green = Green;
                this.DB_ID[ID].Blue = Blue;
                this.DB_ID[ID].Brightness = Brightness;

            }
            return true;
        }
        public bool UpdateRecord_Energy(UInt32 ID, double Energy)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].Energy = Energy;

            }
            return true;
        }
        public bool UpdateRecord_ExternForce(UInt32 ID, CartesianVector ExternalForce)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].ExternForce = ExternalForce;

            }
            return true;
        }
        public bool UpdateRecord_MotorForce(UInt32 ID, CartesianVector MotorForce)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].MotorForce = MotorForce;

            }
            return true;
        }
        public bool UpdateRecord_TorqueForces(UInt32 ID, double ThetaTorque, double PhiTorque)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].ThetaTorque = ThetaTorque;
                this.DB_ID[ID].PhiTorque = PhiTorque;

            }
            return true;
        }
        public bool UpdateRecord_PositionVelocity(UInt32 ID, CartesianVector Position, CartesianVector Velocity)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].Position = Position;
                this.DB_ID[ID].Velocity = Velocity;

            }
            return true;
        }
        public bool UpdateRecord_Theta_ThetaVelocity(UInt32 ID, double Theta, double ThetaVelocity)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].Theta = Theta;
                this.DB_ID[ID].ThetaVelocity = ThetaVelocity;

            }
            return true;
        }
        public bool UpdateRecord_Phi_PhiVelocity(UInt32 ID, double Phi, double PhiVelocity)
        {
            lock (locker)
            {

                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                this.DB_ID[ID].Phi = Phi;
                this.DB_ID[ID].PhiVelocity = PhiVelocity;

            }
            return true;
        }
        // Delete Record Functions
        public bool DeleteRecordByID(UInt32 ID)
        {
            lock (locker)
            {
                if (!this.DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                Record_Object Record = DB_ID[ID];

                if (!this.DB_ClientID.ContainsKey(Record.Client_ID))
                {
                    return false;
                }

                this.DB_ID.Remove(ID);
                this.DB_ClientID.Remove(Record.Client_ID);
            }
            return true;
        }
        public bool DeleteRecordByAssociatedClientID(UInt32 ID)
        {
            lock (locker)
            {
                if (!this.DB_ClientID.ContainsKey(ID))
                {
                    return false;
                }

                UInt32 ObjID = this.DB_ClientID[ID];

                if (!this.DB_ID.ContainsKey(ObjID))
                {
                    return false;
                }

                this.DB_ID.Remove(ObjID);
                this.DB_ClientID.Remove(ID);
            }
            return true;
        }
    }
}
