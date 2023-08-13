using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;
using System.Net.Sockets;
using System.Threading;

using Neuronscape;

namespace Neuronscape_Server
{
    class UDPState
    {
        public IPEndPoint e;
        public UdpClient u;
    }

    class ServerNetworkStack
    {
        private Object Shutdownlocker = new Object();

        private Queue<KeyValuePair<List<Record_Client>, List<byte[]>>> TxPacketQueue;
        private Queue<KeyValuePair<IPEndPoint, byte[]>> RxPacketQueue;

        private UdpClient Socket;
        private UDPState StateObj;

        private Thread TxThread;
        private Thread RxThread;

        private volatile bool Shutdown;
        private volatile bool Running;

        private volatile DB_Object Object_DB;
        private volatile DB_Client Client_DB;

        private CartesianVector EnvironmentDimensions;
        private NeuronscapeServer Parent;

        public ServerNetworkStack(NeuronscapeServer Parent, ref DB_Object Object_DB, ref DB_Client Client_DB, CartesianVector EnvironmentDimensions)
        {
            this.Parent = Parent;
            this.Object_DB = Object_DB;
            this.Client_DB = Client_DB;
            this.EnvironmentDimensions = EnvironmentDimensions;
            this.Shutdown = false;
        }
        // Stack Control Functions
        public void Start(UInt16 NetworkPort)
        {
            this.Shutdown = false;

            this.TxPacketQueue = new Queue<KeyValuePair<List<Record_Client>, List<byte[]>>>();
            this.RxPacketQueue = new Queue<KeyValuePair<IPEndPoint, byte[]>>();

            this.Socket = new UdpClient();
            this.TxThread = new Thread(TransmitProcess);
            this.RxThread = new Thread(ReceiveProcess);

            IPEndPoint endpoint = new IPEndPoint(IPAddress.Any, NetworkPort);
            this.Socket = new UdpClient(endpoint);

            this.StateObj = new UDPState();
            this.StateObj.e = endpoint;
            this.StateObj.u = this.Socket;

            

            this.TxThread.Start();
            this.RxThread.Start();

            this.Running = true;

            this.Socket.BeginReceive(new AsyncCallback(SocketCallback), this.StateObj);
        }
        public void Stop()
        {
            lock (this.TxPacketQueue)
            {
                this.TxPacketQueue.Clear();

                lock (this.RxPacketQueue)
                {
                    this.RxPacketQueue.Clear();

                    this.Shutdown = true;

                    Monitor.Pulse(this.TxPacketQueue);
                    Monitor.Pulse(this.RxPacketQueue);
                }
            }

            this.TxThread.Join();
            this.RxThread.Join();

            this.Running = false;
            this.Socket.Close();
        }
        // Packet Send Queue Functions
        public void QueuePacketToSend(ref Record_Client Client, ref byte[] Packet)
        {
            List<Record_Client> ClientList = new List<Record_Client>();
            List<byte[]> PacketList = new List<byte[]>();

            ClientList.Add(Client);

            PacketList.Add(Packet);

            this.QueuePacketToSend(ref ClientList, ref PacketList);
        }
        public void QueuePacketToSend(ref Record_Client Client, ref List<byte[]> Packet)
        {
            List<Record_Client> ClientList = new List<Record_Client>();

            ClientList.Add(Client);

            this.QueuePacketToSend(ref ClientList, ref Packet);
        }
        public void QueuePacketToSend(ref List<Record_Client> Clients, ref byte[] Packet)
        {
            List<byte[]> PacketList = new List<byte[]>();

            PacketList.Add(Packet);

            this.QueuePacketToSend(ref Clients, ref PacketList);
        }
        public void QueuePacketToSend(ref List<Record_Client> Clients, ref List<byte[]> Packets)
        {
            KeyValuePair<List<Record_Client>, List<byte[]>> NewEntry = new KeyValuePair<List<Record_Client>, List<byte[]>>(Clients, Packets);

            lock (TxPacketQueue)
            {
                this.TxPacketQueue.Enqueue(NewEntry);
                Monitor.Pulse(this.TxPacketQueue);
            }
        }
        // Packet Receive Queue
        public void QueueReceivedPacket(ref IPEndPoint Addr, ref byte[] Packet)
        {
            lock (RxPacketQueue)
            {
                KeyValuePair<IPEndPoint, byte[]> NewEntry = new KeyValuePair<IPEndPoint, byte[]>(Addr, Packet);
                this.RxPacketQueue.Enqueue(NewEntry);
                Monitor.Pulse(this.RxPacketQueue);
            }
        }
        // Asynchronous Socket Callback
        public void SocketCallback(IAsyncResult ar)
        {
            if (this.Running == true)
            {
                try
                {
                    DateTime CurrentDT = DateTime.Now;

                    UdpClient u = (UdpClient)((UDPState)(ar.AsyncState)).u;
                    IPEndPoint e = (IPEndPoint)((UDPState)(ar.AsyncState)).e;

                    Byte[] receiveBytes = u.EndReceive(ar, ref e);
              
                    this.QueueReceivedPacket(ref e, ref receiveBytes);

                    this.Socket.BeginReceive(new AsyncCallback(SocketCallback), this.StateObj);
                }


                catch (System.ObjectDisposedException)
                {
                    // We might end up here if the socket is closed and collected while waiting on data
                    // Ignore the error and we return.
                    return;
                }
                catch (System.Net.Sockets.SocketException e)
                {
                    // If we try to connect to a server on the same machine (localhost) but it does not exist
                    // then it is possible that the OS shuts our socket and throws a SocketException.
                    // This is the firewall rejecting out connection. This error corresponds to error code 10054
                    if (e.ErrorCode == 10054)
                    {
                        if (this.Running)
                        {
                            this.Socket.BeginReceive(new AsyncCallback(SocketCallback), this.StateObj);
                        }
                        else
                        {
                            return;
                        }
                    }
                    else
                    {
                        // A different error has occured so we throw it again
                        throw (e);
                    }
                }
            }
        }
        // Transmit Thread Function
        private void TransmitProcess()
        {
            KeyValuePair<List<Record_Client>, List<byte[]>> TxQueueEntry;
            List<Record_Client> Records;
            List<byte[]> Packets;

            bool Exit = false;

            while (!Exit)
            {
                lock (this.Shutdownlocker)
                {
                    if (this.Shutdown)
                    {
                        Exit = true;
                        continue;
                    }
                }

                lock (this.TxPacketQueue)
                {
                    if (this.TxPacketQueue.Count == 0)
                    {
                        Monitor.Wait(this.TxPacketQueue);
                    }

                    lock (this.Shutdownlocker)
                    {
                        if (this.Shutdown)
                        {
                            Exit = true;
                            continue;
                        }
                    }

                    TxQueueEntry = this.TxPacketQueue.Dequeue();
                }

                Records = TxQueueEntry.Key;
                Packets = TxQueueEntry.Value;

                byte [] FinalizedPacket;
                byte [] FinalPacketLength;

                foreach (byte[] Packet in Packets)
                {
                    FinalizedPacket = new byte[Packet.Length + 2];
                    FinalPacketLength = BitConverter.GetBytes(Packet.Length);

                    Array.Copy(FinalPacketLength, FinalizedPacket, 2);
                    Array.Copy(Packet, 0, FinalizedPacket, 2, Packet.Length);

                    foreach (Record_Client Record in Records)
                    {
                        this.Socket.Send(FinalizedPacket, FinalizedPacket.Length, Record.Addr);
                    }
                }
            }
        }
        // Transmit Packet Functions
        public void SendAck(Record_Client Record, UInt32 Data1, UInt32 Data2)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ACK);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendError(Record_Client Record, UInt32 Data1, UInt32 Data2)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ERROR);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendError(IPEndPoint Address, UInt32 Data1, UInt32 Data2)
        {
            Record_Client Record = new Record_Client();

            Record.Addr = Address;

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ERROR);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendForceDisconnect(Record_Client Record)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_FORCEDISCONNECT);

            this.QueuePacketToSend(ref Record, ref ID);
        }
        public void SendBulkForceDisconnect(List<Record_Client> Records)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_FORCEDISCONNECT);

            this.QueuePacketToSend(ref Records, ref ID);
        }
        public void SendClientEnum(Record_Client Record)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_CLIENT_ENUMERATE);
            byte[] X = BitConverter.GetBytes(this.EnvironmentDimensions.x);
            byte[] Y = BitConverter.GetBytes(this.EnvironmentDimensions.y);
            byte[] Z = BitConverter.GetBytes(this.EnvironmentDimensions.z);

            byte[] Packet = new byte[26];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(X, 0, Packet, 2, X.Length);
            Array.Copy(Y, 0, Packet, 10, Y.Length);
            Array.Copy(Z, 0, Packet, 18, Z.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        //public bool SendBulkUpdateObjects(std::vector<DBRecord_Client> ClientRecords,  std::vector<DBRecord_Object> ObjectRecords)
        //{

        //    uint32_t NumPackets = (uint32_t) std::ceil((double)ObjectRecords.size()/MAX_OBJ_BULK_PKT);

        //    std::string *BulkUpdatePackets = new std::string[NumPackets];
        //    DBRecord_Object ObjectRecordsSubSet[MAX_OBJ_BULK_PKT];

        //    for (uint32_t i = 0; i < NumPackets; i++)
        //    {
        //        int Counter = 0;
        //        for (uint32_t j = 0; ((j < MAX_OBJ_BULK_PKT)&&((j + (i*MAX_OBJ_BULK_PKT)) < ObjectRecords.size())); j++)
        //        {
        //            ObjectRecordsSubSet[j] = ObjectRecords[(i*MAX_OBJ_BULK_PKT)+j];
        //            Counter++;
        //        }
        //        this->PrepareBulkUpdatePacket(&BulkUpdatePackets[i],Counter,ObjectRecordsSubSet);
        //    }

        //    for (uint32_t i = 0; i < NumPackets; i++)
        //    {
        //        if (!this->SendStringToMultipleClients(ClientRecords,BulkUpdatePackets[i]))
        //        {
        //            return false;
        //        }
        //    }
        //    delete [] BulkUpdatePackets;
        //    return true;
        //}
        public void SendDeleteObject(Record_Client Record, UInt32 ObjectID)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_DELETE_OBJ);
            byte[] OID = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID, 0, Packet, 2, OID.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendDeleteObjectToAllClients(UInt32 ObjectID)
        {
            List<Record_Client> Records = this.Client_DB.FetchAll();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_DELETE_OBJ);
            byte[] OID = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID, 0, Packet, 2, OID.Length);

            this.QueuePacketToSend(ref Records, ref Packet);
        }
        public void SendRemoveEatenObj(Record_Client Record, UInt32 ObjectID)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_REMOVE_EATEN_OBJ);
            byte[] OID = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID, 0, Packet, 2, OID.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendRemoveEatenObjToAllClients(UInt32 ObjectID)
        {
            List<Record_Client> Records = this.Client_DB.FetchAll();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_REMOVE_EATEN_OBJ);
            byte[] OID = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID, 0, Packet, 2, OID.Length);

            this.QueuePacketToSend(ref Records, ref Packet);
        }
        //public bool SendKillSystemToAllClients(std::string PacketData)
        //{
        //    if (PacketData.size() > 32) // truncate to 32 bytes
        //    {
        //        PacketData = PacketData.substr(0, 32);
        //    }

        //    std::string Message;

        //    std::vector<unsigned char> ID = ushort2uchar(PKT_KILL_SYSTEM);

        //    Message.append(ID.begin(),ID.end());
        //    Message.append(PacketData);

        //    std::vector<DBRecord_Client> Records;

        //    this->m_DB_Client->FetchAll(Records);

        //    if (!this->SendStringToMultipleClients(Records,Message))
        //    {
        //        return false;
        //    }

        //    return true;
        //}
        public void SendTestsEchoReply(Record_Client Record, string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO_REPLY);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendTestsEchoReply(IPEndPoint Address, string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO_REPLY);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            Record_Client Record = new Record_Client();
            Record.Addr = Address;

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        public void SendTestsEcho(Record_Client Record, string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Record, ref Packet);
        }
        // Receive Thread Function
        private void ReceiveProcess()
        {
            KeyValuePair<IPEndPoint, byte[]> RxQueueEntry;
            IPEndPoint Address;
            byte[] Packet;

            bool Exit = false;

            while (!Exit)
            {
                lock (this.Shutdownlocker)
                {
                    if (this.Shutdown)
                    {
                        Exit = true;
                        continue;
                    }
                }

                lock (this.RxPacketQueue)
                {
                    if (this.RxPacketQueue.Count == 0)
                    {
                        Monitor.Wait(this.RxPacketQueue);
                    }

                    lock (this.Shutdownlocker)
                    {
                        if (this.Shutdown)
                        {
                            Exit = true;
                            continue;
                        }
                    }

                    RxQueueEntry = this.RxPacketQueue.Dequeue();
                }

                Address = RxQueueEntry.Key;
                Packet = RxQueueEntry.Value;
                this.ProcessPacket(Address, Packet);
            }
        }
        private void ProcessPacket(IPEndPoint Addr, byte[] Packet)
        {
            Record_Client Client;

            if (this.Client_DB.FindByIPV4Port(Addr, out Client))
            {
                // Client is in the database!
                this.KnownClient(Client, Packet);
            }
            else
            {
                // Client is not in the database!
                this.UnknownClient(Addr, Packet);
            }
        }
        private void UnknownClient(IPEndPoint Addr, byte[] Packet)
        {
            UInt16 Length = BitConverter.ToUInt16(Packet, 0);
            UInt16 Type = BitConverter.ToUInt16(Packet, 2);

            byte[] Payload = new byte[Packet.Length - 4];

            Array.Copy(Packet, 4, Payload, 0, Payload.Length);

            switch (Type)
            {
                case PacketTypes.PKT_CONNECTION_REQ:
                    this.RecvConnectionReq(Addr, Payload);
                    break;

                case PacketTypes.PKT_TEST_ECHO:
                    this.RecvTestsEcho(Addr, Payload);
                    break;

                default:
                    // Send error back to client indicating invalid Packet type.
                    break;
            }
        }
        private void KnownClient(Record_Client ClientRecord, byte[] Packet)
        {
            UInt16 Length = BitConverter.ToUInt16(Packet, 0);
            UInt16 Type = BitConverter.ToUInt16(Packet, 2);

            byte[] Payload = new byte[Packet.Length - 4];

            Array.Copy(Packet, 4, Payload, 0, Payload.Length);

            switch (Type)
            {
                case PacketTypes.PKT_ACK:
                    this.RecvAck(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_ERROR:
                    this.RecvError(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_CONNECTION_REQ:
                    // Client is already registered, Send error
                    this.SendError(ClientRecord, PacketTypes.PKT_CONNECTION_REQ, 0);
                    break;

                case PacketTypes.PKT_DISCONNECTION_REQ:
                    this.RecvDisconnectionReq(ClientRecord);
                    break;

                case PacketTypes.PKT_FORCEDISCONNECT:
                    // This is a server, cannot receive force disconnect!
                    this.SendError(ClientRecord, PacketTypes.PKT_FORCEDISCONNECT, 0);		
                    break;

                case PacketTypes.PKT_CLIENT_ENUMERATE:
                    // This is a server, it should not be receiving client enumerate packets
                    this.SendError(ClientRecord, PacketTypes.PKT_CLIENT_ENUMERATE, 0);
                    break;

                case PacketTypes.PKT_REQ_ADD_OBJ:
                    this.RecvAddObjectReq(ref ClientRecord, Payload);
                    break;

                // UPDATE_OBJ IS DEPRECATED
                case PacketTypes.PKT_UPDATE_OBJ:
                    this.SendError(ClientRecord, PacketTypes.PKT_UPDATE_OBJ, 0);
                    break;

                case PacketTypes.PKT_BULK_UPDATE_OBJ:
                    this.SendError(ClientRecord, PacketTypes.PKT_BULK_UPDATE_OBJ, 0);
                    break;

                case PacketTypes.PKT_DELETE_OBJ:
                    this.RecvDeleteObject(ref ClientRecord);
                    break;

                case PacketTypes.PKT_FORCES_OBJ:
                    this.RecvObjForces(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_TORQUE_OBJ:
                    this.RecvObjTorque(ClientRecord, Payload);
                    break;

                // ENERGYDELTA IS DEPRECATED
                case PacketTypes.PKT_ENERGYDELTA:
                    this.SendError(ClientRecord, PacketTypes.PKT_BULK_UPDATE_OBJ, 0);
                    break;

                case PacketTypes.PKT_COLOUR_OBJ:
                    this.RecvObjColour(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_ADDINANIMATE_OBJ:
                    this.RecvAddInanimate(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_EAT_OBJ:
                    this.RecvEatObj(ClientRecord, Payload);
                    break;

                case PacketTypes.PKT_REMOVE_EATEN_OBJ:
                    this.SendError(ClientRecord, PacketTypes.PKT_REMOVE_EATEN_OBJ, 0);
                    break;

                case PacketTypes.PKT_KILL_SYSTEM:
                    this.SendError(ClientRecord, PacketTypes.PKT_KILL_SYSTEM, 0);
                    break;

                case PacketTypes.PKT_TEST_ECHO_REPLY:
                    // Do nothing
                    break;

                case PacketTypes.PKT_TEST_ECHO:
                    this.RecvTestsEcho(ClientRecord, Payload);
                    break;

                default:
                    this.SendError(ClientRecord, 0, 0);
                    break;
            }
        }
        // Receive Packet Functions
        private bool RecvAck(Record_Client ClientRecord, byte[] Data)
        {
            if (Data.Length != 8)
            {
                // Ignore the packet!
                return false;
            }

            UInt32 ACK_TYPE = BitConverter.ToUInt32(Data, 0);
            UInt32 ACK_CODE = BitConverter.ToUInt32(Data, 4);

            // Process packet based on the packet_id
            switch (ACK_TYPE)
            {
                case PacketTypes.PKT_ACK:

                    break;

                case PacketTypes.PKT_ERROR:

                    break;

                case PacketTypes.PKT_CONNECTION_REQ:

                    break;

                case PacketTypes.PKT_DISCONNECTION_REQ:

                    break;

                case PacketTypes.PKT_FORCEDISCONNECT:

                    break;

                case PacketTypes.PKT_CLIENT_ENUMERATE:

                    break;

                case PacketTypes.PKT_REQ_ADD_OBJ:

                    break;

                case PacketTypes.PKT_UPDATE_OBJ:

                    break;

                case PacketTypes.PKT_BULK_UPDATE_OBJ:

                    break;

                case PacketTypes.PKT_DELETE_OBJ:

                    break;

                case PacketTypes.PKT_FORCES_OBJ:

                    break;

                case PacketTypes.PKT_TEST_ECHO:

                    break;

                default:
                    // unknown packet, send error to client
                    break;
            }
            return true;
        }
        private bool RecvError(Record_Client ClientRecord, byte[] Data)
        {
            if (Data.Length != 8)
            {
                // Ignore the packet!
                return false;
            }

            UInt32 ERROR_TYPE = BitConverter.ToUInt32(Data, 0);
            UInt32 ERROR_CODE = BitConverter.ToUInt32(Data, 4);

            // Process packet based on the packet_id
            switch (ERROR_TYPE)
            {
                case PacketTypes.PKT_ACK:

                    break;

                case PacketTypes.PKT_ERROR:

                    break;

                case PacketTypes.PKT_CONNECTION_REQ:

                    break;

                case PacketTypes.PKT_DISCONNECTION_REQ:

                    break;

                case PacketTypes.PKT_FORCEDISCONNECT:

                    break;

                case PacketTypes.PKT_CLIENT_ENUMERATE:

                    break;

                case PacketTypes.PKT_REQ_ADD_OBJ:

                    break;

                case PacketTypes.PKT_UPDATE_OBJ:

                    break;

                case PacketTypes.PKT_BULK_UPDATE_OBJ:

                    break;

                case PacketTypes.PKT_DELETE_OBJ:

                    break;

                case PacketTypes.PKT_FORCES_OBJ:

                    break;

                case PacketTypes.PKT_TEST_ECHO:

                    break;

                default:
                    // unknown packet, send error to client
                    break;
            }
            return true;
        }
        private bool RecvConnectionReq(IPEndPoint Address, byte[] Data)
        {
            byte Role;
            UInt16 CommandSetMajor;
            UInt16 CommandSetMinor;

            Record_Client Record = new Record_Client();

            // Connection Request must be 5 bytes
            if (Data.Length != 5)
            {
                // Report an error has occurred
                // Pakcet is incorrect length!

                this.SendError(Address, PacketTypes.PKT_CONNECTION_REQ, 0);
                return false;
            }

            Role = Data[0];
            CommandSetMajor = BitConverter.ToUInt16(Data, 1);
            CommandSetMinor = BitConverter.ToUInt16(Data, 3);

            Record.Addr = Address;
            Record.ID = 0;
            Record.Role = Role;
            Record.Command_Major = CommandSetMajor;
            Record.Command_Minor = CommandSetMinor;
            // The Client is currently in enumeration phase 1
            // This means the client should not participate in normal network behaviour
            Record.Status = ClientStatus.ENUM;

            if (!this.Client_DB.InsertRecord(Record))
            {
                // Error has Occurred, Database error has occurred
                this.SendError(Address, PacketTypes.PKT_CONNECTION_REQ, 0);
                return false;
            }

            // Now read back the record from the database
            if (!this.Client_DB.FindByIPV4Port(Address, out Record))
            {
                // Error has occurred, Database Error has occurred
                this.SendError(Address, PacketTypes.PKT_CONNECTION_REQ, 0);
                return false;
            }

            // Acknowledge that client has been added successfully
            this.SendAck(Record, PacketTypes.PKT_CONNECTION_REQ, Record.ID);
            // Send Enumeration Information
            this.SendClientEnum(Record);

            this.Object_DB.SetDirtyBit();

            string LogMessage = string.Format("Client Connected: id = {0}", Record.ID);
            this.Parent.LogMessage(LogMessage);

            // Return true to indicate functions completed successfully
            return true;
        }
        private bool RecvDisconnectionReq(Record_Client Record)
        {
            if (!this.Client_DB.DeleteRecordByID(Record.ID))
            {
                // Delete Record failed!
                // Indicate an error has occurred to the client
                this.SendError(Record, PacketTypes.PKT_DISCONNECTION_REQ, 0);
                return false;
            }

            // Acknowledge that the client has been removed
            this.SendAck(Record, PacketTypes.PKT_DISCONNECTION_REQ, Record.ID);

            string LogMessage = string.Format("Client Disconnected: id = {0}", Record.ID);
            this.Parent.LogMessage(LogMessage);
            //wxString LogMsg;
            //LogMsg.Printf("Client %d - Request Disconnection",ClientRecord.ID);
            //wxLogMessage(LogMsg);
            return true;
        }
        private bool RecvAddObjectReq(ref Record_Client Record, byte[] Packet)
        {
            double InitialX = 0.0;
            double InitialY = 0.0;
            double InitialZ = 0.0;
            double InitialEnergy = 0.0;

            if (Packet.Length == 8)
            {
                InitialX = -1.0;
                InitialY = -1.0;
                InitialZ = -1.0;
                InitialEnergy = BitConverter.ToDouble(Packet, 0);
            }
            else if (Packet.Length == 32)
            {
                InitialEnergy = BitConverter.ToDouble(Packet, 0);
                InitialX = BitConverter.ToDouble(Packet, 8);
                InitialY = BitConverter.ToDouble(Packet, 16);
                InitialZ = BitConverter.ToDouble(Packet, 24);
            }
            else
            {
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_REQ_ADD_OBJ, 1);
            }

            Record_Object ObjectRecord;

            // First check, what is the client identified as? Viewer or NEI?
            // Only Neuron-Environment Interfaces can  request add objects
            if (Record.Role != Roles.NEUENV)
            {
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_REQ_ADD_OBJ, 2);
                return false;
            }
            // Does the Client already own an object?
            if (this.Object_DB.FindByClientID(Record.ID, out ObjectRecord))
            // if return value is true then Clients already owns an object
            {
                // report and return
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_REQ_ADD_OBJ, 3);
                return false;
            }

            Record_Object NewObjectRecord = new Record_Object();

            NewObjectRecord.Client_ID = Record.ID;
            NewObjectRecord.Position = new CartesianVector(InitialX, InitialY, InitialZ);
            NewObjectRecord.Energy = InitialEnergy;
            NewObjectRecord.FLAGS = 0;

            if (!this.Object_DB.InsertRecord(NewObjectRecord))
            {
                // report error to server
                //wxLogError("Failed to add object to the database");
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_REQ_ADD_OBJ, 4);
                return false;
            }

            if (!this.Object_DB.FindByClientID(Record.ID, out ObjectRecord))
            {
                // No object could be found, report and return false
                // report error to server
                //wxLogError("Failed to verify object was added to database, warning database may be inconsistent!");
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_REQ_ADD_OBJ, 5);
                return false;
            }

            // Acknowledge successful object creation
            this.SendAck(Record, PacketTypes.PKT_REQ_ADD_OBJ, ObjectRecord.ID);

            string LogMessage = string.Format("New object (id = {0}) added for client (id = {1})", ObjectRecord.ID, Record.ID);
            this.Parent.LogMessage(LogMessage);
            return true;
        }
        private bool RecvDeleteObject(ref Record_Client Record)
        {
            // Is the client an NEI?
            if (Record.Role != Roles.NEUENV)
            {
                // report error
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_DELETE_OBJ, 1);
                return false;
            }

            Record_Object ObjectRecord;

            // find the object that is owned by the client
            if (!this.Object_DB.FindByClientID(Record.ID, out ObjectRecord))
            // Was the fetch object by Associated Client ID Successful?
            {
                // No, Client doesn't own an object
                // Report error
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_DELETE_OBJ, 2);
                return false;
            }

            // Try to delete the object
            if (!this.Object_DB.DeleteRecordByID(ObjectRecord.ID))
            {
                // Report Delete failed
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_DELETE_OBJ, 3);
                return false;
            }

            // Acknowledge successful object creation
            this.SendAck(Record, PacketTypes.PKT_DELETE_OBJ, ObjectRecord.ID);

            this.SendDeleteObjectToAllClients(ObjectRecord.ID);

            string LogMessage = string.Format("Client (id = {0}) Request Delete Object (id = {1})", Record.ID, ObjectRecord.ID);
            this.Parent.LogMessage(LogMessage);

            return true;
        }
        private bool RecvObjForces(Record_Client Record, byte[] Packet)
        {
            if (Packet.Length != 28)
            {
                // Packet is incorrect length
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_FORCES_OBJ, 1);
                return false;
            }

            UInt32 ObjectID = BitConverter.ToUInt32(Packet, 0);
            double Force_x = BitConverter.ToDouble(Packet, 4);
            double Force_y = BitConverter.ToDouble(Packet, 12);
            double Force_z = BitConverter.ToDouble(Packet, 20);
            CartesianVector Force = new CartesianVector(Force_x, Force_y, Force_z);

            // Is client an NEI or a Viewer
            if ((Record.Role != Roles.VIEWER) && (Record.Role != Roles.NEUENV))
            {
                // report phase - Error, Client not supported
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_FORCES_OBJ, 2);
                return false;
            }

            Record_Object ObjectRecord;

            if (!this.Object_DB.FindByID(ObjectID, out ObjectRecord))
            {
                // No such object exists with the given ID
                // Report phase - Error!
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_FORCES_OBJ, 3);
                return false;
            }

            if (Record.Role == Roles.VIEWER) // if it is Viewer then update external force
            {
                this.Object_DB.UpdateRecord_ExternForce(ObjectRecord.ID, Force);
            }
            else if (Record.Role == Roles.NEUENV) // if it is a NEI and the object belongs to the client update Locomotion force
            {
                // Does the object belong to the client?
                if (Record.ID != ObjectRecord.Client_ID)
                {
                    // NEI Client does not own object, cannot apply loco force
                    // Report phase - Error
                    // report phase - report error to client
                    this.SendError(Record, PacketTypes.PKT_FORCES_OBJ, 4);
                    return false;
                }

                this.Object_DB.UpdateRecord_MotorForce(ObjectRecord.ID, Force);
            }

            // Acknowledge The Force Update
            this.SendAck(Record, PacketTypes.PKT_FORCES_OBJ, 0);
            // Return true
            return true;
        }
        private bool RecvObjTorque(Record_Client Record, byte[] Packet)
        {
            if (Packet.Length != 20)
            {
                // Packet is incorrect length
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_TORQUE_OBJ, 1);
                return false;
            }

            UInt32 ObjectID = BitConverter.ToUInt32(Packet, 0);
            double ThetaTorque = BitConverter.ToDouble(Packet, 4);
            double PhiTorque = BitConverter.ToDouble(Packet, 12);

            // Is client an NEI
            if (Record.Role != Roles.NEUENV)
            {
                // report phase - Error, Client not supported
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_TORQUE_OBJ, 2);
                return false;
            }

            Record_Object ObjectRecord;

            if (!this.Object_DB.FindByID(ObjectID, out ObjectRecord))
            {
                // No such object exists with the given ID
                // Report phase - Error!
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_TORQUE_OBJ, 3);
                return false;
            }

            // if it is a NEI and the object belongs to the client update Locomotion force

            // Does the object belong to the client?
            if (Record.ID != ObjectRecord.Client_ID)
            {
                // NEI Client does not own object, cannot apply loco force
                // Report phase - Error
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_TORQUE_OBJ, 4);
                return false;
            }

            this.Object_DB.UpdateRecord_TorqueForces(ObjectRecord.ID, ThetaTorque, PhiTorque);

            // Acknowledge The Force Update
            this.SendAck(Record, PacketTypes.PKT_TORQUE_OBJ, 0);
            // Return true
            return true;
        }
        private bool RecvObjColour(Record_Client Record, byte[] Packet)
        {
            if (Packet.Length != 8)
            {
                // Packet is incorrect length
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_COLOUR_OBJ, 1);
                return false;
            }

            UInt32 ObjectID = BitConverter.ToUInt32(Packet, 0);
            byte Red = Packet[4];
            byte Green = Packet[5];
            byte Blue = Packet[6];
            byte Brightness = Packet[7];

            // Is client an NEI
            if (Record.Role != Roles.NEUENV)
            {
                // report phase - Error, Client not supported
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_COLOUR_OBJ, 2);
                return false;
            }

            Record_Object ObjectRecord;

            if (!this.Object_DB.FindByID(ObjectID, out ObjectRecord))
            {
                // No such object exists with the given ID
                // Report phase - Error!
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_COLOUR_OBJ, 3);
                return false;
            }

            // if it is a NEI and the object belongs to the client update Locomotion force

            // Does the object belong to the client?
            if (Record.ID != ObjectRecord.Client_ID)
            {
                // NEI Client does not own object, cannot apply loco force
                // Report phase - Error
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_COLOUR_OBJ, 4);
                return false;
            }

            this.Object_DB.UpdateRecord_Colour(ObjectID, Red, Green, Blue, Brightness);

            // Acknowledge The Force Update
            this.SendAck(Record, PacketTypes.PKT_COLOUR_OBJ, 0);
            // Return true
            return true;
        }
        private bool RecvAddInanimate(Record_Client Record, byte[] Packet)
        {
            if (Packet.Length != 34)
            {
                // Packet is incorrect length
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_ADDINANIMATE_OBJ, 1);
                return false;
            }

            double X = BitConverter.ToDouble(Packet, 0);
            double Y = BitConverter.ToDouble(Packet, 8);
            double Z = BitConverter.ToDouble(Packet, 16);
            byte Red = Packet[24];
            byte Green = Packet[25];
            byte Blue = Packet[26];
            byte Brightness = Packet[27];
            float Energy = BitConverter.ToSingle(Packet, 28);
            UInt16 FLAGS = BitConverter.ToUInt16(Packet, 32);

            // Is client a Viewer
            if (Record.Role != Roles.VIEWER)
            {
                // report phase - Error, Client not supported
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_ADDINANIMATE_OBJ, 2);
                return false;
            }

            Record_Object NewObjectRecord = new Record_Object();

            NewObjectRecord.Client_ID = 0;
            NewObjectRecord.Position = new CartesianVector(X, Y, Z);
            NewObjectRecord.Red = Red;
            NewObjectRecord.Green = Green;
            NewObjectRecord.Blue = Blue;
            NewObjectRecord.Brightness = Brightness;
            NewObjectRecord.Energy = Energy;
            NewObjectRecord.FLAGS = (UInt16) (FLAGS | ObjectFlags.OBJFLAG_INANIMATE);

            if (!this.Object_DB.InsertRecord(NewObjectRecord))
            {
                // report error
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_ADDINANIMATE_OBJ, 3);
                return false;
            }

            // Acknowledge successful object creation
            this.SendAck(Record, PacketTypes.PKT_ADDINANIMATE_OBJ, NewObjectRecord.ID);
            this.Object_DB.SetDirtyBit(); // Force whole database to be sent on next physics update

            string LogMessage = string.Format("Client (id = {0}) Request Add Inanimate Object (id = {1})", Record.ID, NewObjectRecord.ID);
            this.Parent.LogMessage(LogMessage);

            // Return true
            return true;
        }
        private bool RecvEatObj(Record_Client Record, byte[] Packet)
        {
            if (Packet.Length != 4)
            {
                // Packet is incorrect length
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_EAT_OBJ, 1);
                return false;
            }

            // Find object associated with Client
            Record_Object Clients_Object;

            if (!this.Object_DB.FindByClientID(Record.ID, out Clients_Object))
            {
                // CLient does not own an object!
                // report phase - report error to client
                this.SendError(Record, PacketTypes.PKT_EAT_OBJ, 2);
                return false;
            }


            // Find the object directly in front of the object for EatingRange!

            // Edge of Object
            // Find Edge of object directly in front
            SphericalVector EdgeOfObject_S = new SphericalVector(Constants.Radius, Clients_Object.Theta, Constants.PI / 2.0);

            CartesianVector EdgeOfObject_C = Clients_Object.Position + (CartesianVector)EdgeOfObject_S;

            // Find Point 0.5m directly infront of where object is facing
            SphericalVector InFront_S = new SphericalVector(Constants.EatingRange, Clients_Object.Theta, Constants.PI / 2.0);

            CartesianVector InFront_C = EdgeOfObject_C + (CartesianVector)InFront_S;

            List<Record_Object> FoundObjects;

            this.Object_DB.FindBetweenCoordinates(EdgeOfObject_C, InFront_C, out FoundObjects);

            if (FoundObjects.Count > 1) // If some objects were found
            {
                // Find the Closest
                CartesianVector CliObjPosition = Clients_Object.Position;

                Record_Object NearestObject = null;
                SphericalVector Nearest = null;

                bool FirstLoop = true;

                foreach (Record_Object FoundObject in FoundObjects)
                {
                    if (FoundObject.ID != Clients_Object.ID)
                    {
                        Record_Object Current = FoundObject;
                        SphericalVector Distance = FoundObject.Position - Clients_Object.Position;

                        if (FirstLoop)
                        {
                            NearestObject = FoundObject;
                            Nearest = Distance;
                            FirstLoop = false;
                        }
                        else
                        {
                            if (Distance.Mag < Nearest.Mag)
                            {
                                NearestObject = FoundObject;
                                Nearest = Distance;
                            }
                        }

                    }
                }

                // Ok Now we have our nearest objject that is directly in front of us and less than EatingRange Away

                // Is it edible?
                if ((NearestObject.FLAGS & ObjectFlags.OBJFLAG_EDIBLE) != 0)
                {
                    // Read the energy used and send it to the client
                    this.Object_DB.UpdateRecord_Energy(Clients_Object.ID, (Clients_Object.Energy + NearestObject.Energy));

                    // Tell Clients it has been eaten
                    this.SendRemoveEatenObjToAllClients(NearestObject.ID);

                    // Remove it from the environment
                    this.Object_DB.DeleteRecordByID(NearestObject.ID);
                }
            }
            return true;
        }
        //private bool ServerPacketProcessingThread::RecvKillSystem(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
        //{
        //    if (this->m_KillCode.size() == 0)
        //    {
        //        // No Kill Code Set So Kill System is disabled
        //        this.SendError(Record, PacketTypes.PKT_KILL_SYSTEM,4);
        //        return false;
        //    }

        //    if (PacketData.size() != 32)
        //    {
        //        // Packet is not the right length
        //        this.SendError(Record, PacketTypes.PKT_KILL_SYSTEM,1);
        //        return false;
        //    }

        //    if (ClientRecord.Role != ROLE_CNTRL)
        //    {
        //        // Client Sending the packet is not a Remote Control
        //        this.SendError(Record, PacketTypes.PKT_KILL_SYSTEM,2);
        //        return false;
        //    }

        //    std::string KillCode;

        //    KillCode.append(PacketData.begin(),PacketData.end());

        //    int Match = KillCode.compare(this->m_KillCode);

        //    if (Match == 0)
        //    {
        //        // Kill Code is correct, Send acknowledge
        //        this->SendAck(ClientRecord,PKT_KILL_SYSTEM,0);
        //        // Kill Code is correct, broadcast it out to all clients
        //        this->SendKillSystemToAllClients(KillCode);
        //        return true;		
        //    }
        //    else
        //    {
        //        // Kill code was incorrect, send back an error to the client
        //        this.SendError(Record, PacketTypes.PKT_KILL_SYSTEM,3);
        //        return false;
        //    }
        //}
        private bool RecvTestsEcho(Record_Client Record, byte[] Packet)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            // Recv test Echo Packet must be less than 1022 bytes
            if (Packet.Length > 1022)
            {
                this.SendError(Record, PacketTypes.PKT_TEST_ECHO, 0);
                return false;
            }

            string Str = ASCIIEncoding.ASCII.GetString(Packet);

            this.SendTestsEchoReply(Record, Str);

            return true;
        }
        private bool RecvTestsEcho(IPEndPoint Addr, byte[] Packet)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            // Recv test Echo Packet must be less than 1022 bytes
            if (Packet.Length > 1022)
            {
                this.SendError(Addr, PacketTypes.PKT_TEST_ECHO, 0);
                return false;
            }

            string Str = ASCIIEncoding.ASCII.GetString(Packet);

            this.SendTestsEchoReply(Addr, Str);

            return true;
        }
    }
}
