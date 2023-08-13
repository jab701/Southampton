using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;
using System.Threading;

using Neuronscape;

namespace Neuronscape_Server
{
    class DB_Client
    {
        private object locker = new object();
        private Dictionary<UInt32, Record_Client> DB_ID = new Dictionary<UInt32, Record_Client>();
        private Dictionary<IPEndPoint, UInt32> DB_IP = new Dictionary<IPEndPoint, UInt32>();
        private UInt32 NextID = 1;

        public DB_Client()
        {
            this.Clear();
        }
        public void Clear()
        {
            lock (locker)
            {
                this.DB_ID.Clear();
                this.DB_IP.Clear();
                this.NextID = 1;
            }
        }
        public List<Record_Client> FetchAll()
        {
            List<Record_Client> Clients = new List<Record_Client>();
 
            lock (locker)
            {
                foreach (KeyValuePair<UInt32, Record_Client> entry in DB_ID)
                {
                    Clients.Add(entry.Value);
                }

            }

            return Clients;
        }
        public bool FindByID(UInt32 ID, out Record_Client Record)
        {
            lock (locker)
            {
                if (DB_ID.ContainsKey(ID))
                {
                    Record = DB_ID[ID];
                    return true;
                }
                else
                {
                    Record = null;
                    return false;
                }
            }
        }
        public bool FindByIPV4Port(IPEndPoint Addr, out Record_Client Record)
        {
            lock (locker)
            {

                if (DB_IP.ContainsKey(Addr))
                {
                    UInt32 ID = DB_IP[Addr];
                    bool ReturnVal = this.FindByID(ID, out Record);
                    return ReturnVal;
                }
                else
                {
                    Record = null;
                    return false;
                }
            }
        }
        // Insert Record Functions
        public bool InsertRecord(Record_Client Record)
        {
            lock (locker)
            {

                if (DB_IP.ContainsKey(Record.Addr))
                {
                    return false;
                }

                if (this.NextID == 0)
                {
                    return false;
                }

                Record.ID = this.NextID;

                try
                {
                    this.DB_ID.Add(this.NextID, Record);
                }
                catch (ArgumentException)
                {
                    return false;
                }

                try
                {
                    this.DB_IP.Add(Record.Addr, this.NextID);
                }
                catch (ArgumentException)
                {
                    return false;
                }


                this.NextID++;
            }
            return true;
        }
        // Update Record Functions
        public bool UpdateRecord(Record_Client Record)
        {
            lock (locker)
            {

                if (!DB_IP.ContainsKey(Record.Addr) || !DB_ID.ContainsKey(Record.ID))
                {
                    return false;
                }

                DB_ID[Record.ID] = Record;
                DB_IP[Record.Addr] = Record.ID;
            }
            return true;
        }
        // Delete Record Functions
        public bool DeleteRecordByID(UInt32 ID)
        {
            lock (locker)
            {
                if (!DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                Record_Client Record = DB_ID[ID];

                if (!DB_IP.ContainsKey(Record.Addr))
                {
                    return false;
                }

                DB_ID.Remove(ID);
                DB_IP.Remove(Record.Addr);
            }
            return true;
        }
        public bool DeleteRecordByIPV4Port(IPEndPoint Address)
        {
            lock (locker)
            {
                if (!DB_IP.ContainsKey(Address))
                {
                    return false;
                }

                UInt32 ID = DB_IP[Address];

                if (!DB_ID.ContainsKey(ID))
                {
                    return false;
                }

                DB_ID.Remove(ID);
                DB_IP.Remove(Address);
            }
            return true;
        }
    }
}
