using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class DB_ClientObject
    {
        private object locker = new object();
        private Dictionary<UInt32, Record_ClientObject> DB_ID = new Dictionary<UInt32, Record_ClientObject>();
        private bool DirtyBit = false;

        public DB_ClientObject()
        {
            this.Clear();
        }
        public void Clear()
        {
            lock (locker)
            {
                this.DB_ID.Clear();
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
        public UInt32 NumberObjects
        {
            get
            {
                UInt32 NumObjects;

                lock (locker)
                {
                    NumObjects = (UInt32) DB_ID.Count;
                }

                return NumObjects;
            }
        }
        public List<Record_ClientObject> FetchAll()
        {
            List<Record_ClientObject> Objects = new List<Record_ClientObject>();

            lock (locker)
            {
                foreach (KeyValuePair<UInt32, Record_ClientObject> entry in DB_ID)
                {
                    Objects.Add(entry.Value);
                }
            }

            return Objects;
        }
        public bool FindByID(UInt32 ID, out Record_ClientObject Object)
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

        public bool AddUpdateRecord(UInt32 ID, CartesianVector Position, double Theta, double Phi, byte Red, byte Green, byte Blue, byte Alpha, double Energy, UInt16 Flags)
        {
            Record_ClientObject Record = new Record_ClientObject();

            Record.ID = ID;
            Record.Position = Position;
            Record.Theta = Theta;
            Record.Phi = Phi;
            Record.Red = Red;
            Record.Green = Green;
            Record.Blue = Blue;
            Record.Brightness = Alpha;
            Record.Energy = Energy;
            Record.FLAGS = Flags;

            return this.AddUpdateRecord(ID, Record);
        }
        public bool AddUpdateRecord(UInt32 ID, Record_ClientObject Record)
        {
            bool ReturnValue = false;

            lock (locker)
            {
                if (this.DB_ID.ContainsKey(ID))
                {
                    this.DB_ID[ID] = Record;
                }
                else
                {
                    this.DB_ID.Add(Record.ID, Record);
                }

                this.DirtyBit = true;
            }            

            return ReturnValue;
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

                 this.DB_ID.Remove(ID);

                 this.DirtyBit = true;
            }
            return true;
        }
    }
}
