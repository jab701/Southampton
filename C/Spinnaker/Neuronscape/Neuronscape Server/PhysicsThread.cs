using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Threading;
using System.Net;

using Neuronscape;

namespace Neuronscape_Server
{
    class PhysicsThread
    {
        
        private Object locker = new Object();

        bool StopFlag;
        private DB_Client ClientDB;
        private DB_Object ObjectDB;
        private byte TimeStep;
        private CartesianVector EnvDim;
        private double Gravity;
        private double mu_static;
        private double mu_kinetic;
        private ServerNetworkStack NetworkStack;

        public PhysicsThread(ref ServerNetworkStack NetworkStack,  ref DB_Client ClientDB, ref DB_Object ObjectDB, byte TimeStep, CartesianVector EnvDim, double Gravity, double mu_static, double mu_kinetic)
        {
            if (NetworkStack == null)
            {
                throw new ArgumentException("Argument Reference Cannot be null", "NetworkStack");
            }
            if (ClientDB == null)
            {
                throw new ArgumentException("Argument Reference Cannot be null", "ClientDB");
            }

            if (ObjectDB == null)
            {
                throw new ArgumentException("Argument Reference Cannot be null", "ObjectDB");
            }

            if (TimeStep == 0)
            {
                throw new ArgumentException("Argument Cannot be zero", "TimeStep");
            }

            if ((EnvDim.x <= 0.0)||(EnvDim.y <= 0.0)||(EnvDim.z <= 0.0))
            {
                throw new ArgumentException("All vector values must be non zero and positive", "EnvDim");
            }

            this.StopFlag = false;
            this.NetworkStack = NetworkStack;
            this.ClientDB = ClientDB;
            this.ObjectDB = ObjectDB;
            this.TimeStep = TimeStep;
            this.EnvDim = EnvDim;
            this.Gravity = Gravity;
            this.mu_static = mu_static;
            this.mu_kinetic = mu_kinetic;
        }
        public void Stop()
        {
            lock (locker)
            {
                this.StopFlag = true;
            }
        }
        public void Exec()
        {
            Physics Phys = new Physics(this.TimeStep * 1E-3, this.mu_static, this.mu_kinetic, this.Gravity, this.EnvDim);

            while (true)
            {
                lock (this.locker)
                {
                    if (this.StopFlag == true)
                    {
                        break;
                    }
                }

                List<Record_Object> Objects = this.ObjectDB.FetchAllMobile();

                foreach (Record_Object Object in Objects)
                {
                    CartesianVector FinishPosition;
                    CartesianVector FinishVelocity;
                    double FinishTheta;
                    double FinishThetaOmega;

                    double AvailableEnergy = Object.Energy;

                    Phys.CalculatePositionVelocity(this.TimeStep * 1E-3, Object.Position, Object.Velocity, Object.MotorForce,
                                                   Object.ExternForce, out FinishPosition, out FinishVelocity, ref AvailableEnergy,
                                                   Constants.Mass, Constants.Radius);

                    Phys.CalculateRotation(this.TimeStep * 1E-3, Constants.Radius, Object.ThetaTorque, Object.Theta, Object.ThetaVelocity,
                                           out FinishTheta, out FinishThetaOmega, ref AvailableEnergy, Constants.Mass);

                    if (Object.Client_ID != 0)
                    {
                        this.ObjectDB.UpdateRecord_Energy(Object.ID, AvailableEnergy);
                    }

                    this.ObjectDB.UpdateRecord_PositionVelocity(Object.ID, FinishPosition, FinishVelocity);
                    this.ObjectDB.UpdateRecord_Theta_ThetaVelocity(Object.ID, FinishTheta, FinishThetaOmega);
                }

                List<Record_Client> Clients;

                Clients = this.ClientDB.FetchAll();

                if (this.ObjectDB.IsDirty()) // if the database is dirty we must send out the whole database
                {
                    Objects = this.ObjectDB.FetchAll();
                    this.ObjectDB.ClearDirtyBit();
                }
                else // otherwise we must just send out the mobile objects
                {
                    Objects = this.ObjectDB.FetchAllMobile();
                }

                if (Objects.Count != 0)
                {
                    double NumPackets = (double)Objects.Count / (double)Constants.MAX_OBJ_BULK_PKT;

                    UInt32 NumberBulkPackets = (UInt32)Math.Ceiling(NumPackets);
                    UInt32 NumberObjects = (UInt32) Objects.Count;
                    List<byte[]> Packets = new List<byte[]>();

                    for (UInt32 i = 0; i < NumberBulkPackets; i++)
                    {
                        UInt32 Start = (i * Constants.MAX_OBJ_BULK_PKT);
                        UInt32 End = Start + Constants.MAX_OBJ_BULK_PKT;

                        List<Record_Object> Subset;

                        if (NumberObjects < End)
                        {
                            End = NumberObjects;
                        }

                        Subset = Objects.GetRange((int)Start, (int)(End - Start));

                        byte[] PacketData;

                        this.PrepareBulkUpdatePacket(Subset.ToArray(), out PacketData);

                        Packets.Add(PacketData);
                    } 
               
                    // Now we construct a pair to send packets
                    this.NetworkStack.QueuePacketToSend(ref Clients, ref Packets);

                }

                Thread.Sleep(this.TimeStep);
            }

            Phys = null;
            // Lets release our references to the Database References
            this.ClientDB = null;
            this.ObjectDB = null;
            this.EnvDim = null;
        }
        public bool PrepareBulkUpdatePacket(Record_Object[] Objects, out byte[] PacketData)
        {
            PacketData = null;

            if (Objects == null)
            {
                return false;
            }

            UInt32 NumberObjects = (UInt32)Objects.Count();

            if ((NumberObjects == 0) || (NumberObjects > Constants.MAX_OBJ_BULK_PKT))
            {
                return false;
            }

            byte[] PktType = BitConverter.GetBytes(PacketTypes.PKT_BULK_UPDATE_OBJ);
            byte[] NumObj = BitConverter.GetBytes(NumberObjects);

            PacketData = new byte[(Constants.UPDATE_OBJ_LENGTH * NumberObjects) + 6];

            Array.Copy(PktType, 0, PacketData, 0, PktType.Length);
            Array.Copy(NumObj, 0, PacketData, 2, NumObj.Length);

            for (UInt32 i = 0; i < NumberObjects; i++)
            {
                byte[] ObjectData = new byte[Constants.UPDATE_OBJ_LENGTH];
 
                byte[] ID = BitConverter.GetBytes(Objects[i].ID);
                byte[] X  = BitConverter.GetBytes(Objects[i].Position.x);
                byte[] Y  = BitConverter.GetBytes(Objects[i].Position.y);
                byte[] Z  = BitConverter.GetBytes(Objects[i].Position.z);
                byte[] Theta = BitConverter.GetBytes(Objects[i].Theta);
                byte[] Phi   = BitConverter.GetBytes(Objects[i].Phi);
                byte Red   = Objects[i].Red;
                byte Green = Objects[i].Green;
                byte Blue  = Objects[i].Blue;
                byte Brightness = Objects[i].Brightness;
                byte[] Energy = BitConverter.GetBytes(Objects[i].Energy);
                byte[] Flags  = BitConverter.GetBytes(Objects[i].FLAGS);

                Array.Copy(ID, 0, ObjectData, 0,  ID.Count());
                Array.Copy(X,  0, ObjectData, 4,  X.Count());
                Array.Copy(Y,  0, ObjectData, 12, Y.Count());
                Array.Copy(Z,  0, ObjectData, 20, Z.Count());
                Array.Copy(Theta, 0, ObjectData, 28, Theta.Count());
                Array.Copy(Phi,   0, ObjectData, 36, Phi.Count());
                ObjectData[44] = Red;
                ObjectData[45] = Green;
                ObjectData[46] = Blue;
                ObjectData[47] = Brightness;
                Array.Copy(Energy, 0, ObjectData, 48, Energy.Count());
                Array.Copy(Flags, 0, ObjectData, 56, Flags.Count());

                Array.Copy(ObjectData, 0, PacketData, (Constants.UPDATE_OBJ_LENGTH * i) + 6, ObjectData.Count());
            }

            return true;
        }
    }
}
