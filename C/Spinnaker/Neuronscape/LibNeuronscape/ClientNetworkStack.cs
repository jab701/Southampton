using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Neuronscape
{
    public class ClientNSEventArgs : EventArgs
    {
        public readonly UInt32 CODE;
        public readonly CartesianVector EnvDimensions;
        public readonly UInt32 Payload1;
        public readonly UInt32 Payload2;
        public readonly string Text;

        public ClientNSEventArgs(UInt32 CODE, UInt32 Payload1, UInt32 Payload2)
        {
            this.CODE = CODE;
            this.EnvDimensions = new CartesianVector(0.0, 0.0, 0.0);
            this.Payload1 = Payload1;
            this.Payload2 = Payload2;
            this.Text = "";
        }

        public ClientNSEventArgs(UInt32 CODE, CartesianVector EnvDimensions)
        {
            this.CODE = CODE;
            this.EnvDimensions = EnvDimensions;
            this.Payload1 = 0;
            this.Payload2 = 0;
            this.Text = "";
        }

        public ClientNSEventArgs(UInt32 CODE, string Text)
        {
            this.CODE = CODE;
            this.EnvDimensions = new CartesianVector(0.0, 0.0, 0.0);
            this.Payload1 = 0;
            this.Payload2 = 0;
            this.Text = Text;
        }
    }

    public delegate void ClientNSEventHandler(object sender, ClientNSEventArgs e);

    class UDPState
    {
        public IPEndPoint e;
        public UdpClient u;
    }

    public class ClientNetworkStack
    {
        private const UInt16 COMMANDSET_MAJ = 0x0000;
        private const UInt16 COMMANDSET_MIN = 0x0000;

        public event ClientNSEventHandler ClientNSEvent;

        private IPEndPoint ServerAddress;

        private Object Shutdownlocker = new Object();

        private Queue<byte[]> TxPacketQueue;
        private Queue<KeyValuePair<IPEndPoint, byte[]>> RxPacketQueue;

        private UdpClient Socket;
        private UDPState StateObj;

        private Thread TxThread;
        private Thread RxThread;

        private volatile bool Shutdown;
        private volatile bool Running;

        // Neuronscape CLient State
        UInt32 ClientID = 0;
        UInt32 ObjectID = 0;
        CartesianVector EnvironmentDimensions = new CartesianVector(0.0, 0.0, 0.0);

        private volatile DB_ClientObject Object_DB;

        protected virtual void OnClientNSEvent(ClientNSEventArgs e)
        {
            if (ClientNSEvent != null)
            {
                // Invoke the delegate
                ClientNSEvent(this, e);
            }
        }

        public ClientNetworkStack()
        {

        }
        public void Start(DB_ClientObject Object_DB, string Host, int Port)
        {
            this.Object_DB = Object_DB;

            this.Shutdown = false;

            this.TxPacketQueue = new Queue<byte[]>();
            this.RxPacketQueue = new Queue<KeyValuePair<IPEndPoint, byte[]>>();

            this.Socket = new UdpClient();
            this.TxThread = new Thread(TransmitProcess);
            this.TxThread.Name = "NS_TxThread";
            this.RxThread = new Thread(ReceiveProcess);
            this.RxThread.Name = "NS_RxThread";

            IPEndPoint endpoint = new IPEndPoint(IPAddress.Any, 0);
            this.Socket = new UdpClient(endpoint);
            this.Socket.Connect(Host, Port);

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
        // Packet Send Queue Functions
        public void QueuePacketToSend(ref byte[] Packet)
        {
            lock (TxPacketQueue)
            {
                this.TxPacketQueue.Enqueue(Packet);
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
        // Transmit Thread Function
        private void TransmitProcess()
        {
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

                    Packet = this.TxPacketQueue.Dequeue();
                }

                byte[] FinalizedPacket;
                byte[] FinalPacketLength;

                FinalizedPacket = new byte[Packet.Length + 2];
                FinalPacketLength = BitConverter.GetBytes(Packet.Length);

                Array.Copy(FinalPacketLength, FinalizedPacket, 2);
                Array.Copy(Packet, 0, FinalizedPacket, 2, Packet.Length);
                this.Socket.Send(FinalizedPacket, FinalizedPacket.Length);
            }

        }
        // Transmit Packet Functions
        // Send packet Functions
        public void SendAck(UInt32 Data1, UInt32 Data2)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ACK);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendError(UInt32 Data1, UInt32 Data2)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ERROR);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendError(IPEndPoint Addr, UInt32 Data1, UInt32 Data2)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ERROR);
            byte[] Data1_B = BitConverter.GetBytes(Data1);
            byte[] Data2_B = BitConverter.GetBytes(Data2);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(Data1_B, 0, Packet, 2, Data1_B.Length);
            Array.Copy(Data2_B, 0, Packet, 6, Data2_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendConnectionRequest(byte ROLE)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_CONNECTION_REQ);
            byte[] CSMAJ_B = BitConverter.GetBytes(ClientNetworkStack.COMMANDSET_MAJ);
            byte[] CSMIN_B = BitConverter.GetBytes(ClientNetworkStack.COMMANDSET_MIN);

            byte[] Packet = new byte[7];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Packet[2] = ROLE;
            Array.Copy(CSMAJ_B, 0, Packet, 3, CSMAJ_B.Length);
            Array.Copy(CSMIN_B, 0, Packet, 5, CSMIN_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendDisconnectionRequest()
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_DISCONNECTION_REQ);

            this.QueuePacketToSend(ref ID);
        }
        public void SendAddObjectRequest(double InitialEnergy)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_REQ_ADD_OBJ);
            byte[] E_B = BitConverter.GetBytes(InitialEnergy);

            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(E_B, 0, Packet, 2, E_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendAddObjectRequest(double InitialEnergy, CartesianVector Position)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_REQ_ADD_OBJ);
            byte[] E_B = BitConverter.GetBytes(InitialEnergy);
            byte[] X_B = BitConverter.GetBytes(Position.x);
            byte[] Y_B = BitConverter.GetBytes(Position.y);
            byte[] Z_B = BitConverter.GetBytes(Position.z);

            byte[] Packet = new byte[34];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(E_B, 0, Packet, 2, E_B.Length);
            Array.Copy(X_B, 0, Packet, 10, X_B.Length);
            Array.Copy(Y_B, 0, Packet, 18, Y_B.Length);
            Array.Copy(Z_B, 0, Packet, 26, Z_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendDeleteObject(UInt32 ObjectID)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_DELETE_OBJ);
            byte[] OID_B = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID_B, 0, Packet, 2, OID_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendObjectForces(UInt32 ForceObjId, CartesianVector Force)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_FORCES_OBJ);
            byte[] OID_B = BitConverter.GetBytes(ForceObjId);
            byte[] X_B = BitConverter.GetBytes(Force.x);
            byte[] Y_B = BitConverter.GetBytes(Force.y);
            byte[] Z_B = BitConverter.GetBytes(Force.z);

            byte[] Packet = new byte[30];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID_B, 0, Packet, 2, OID_B.Length);
            Array.Copy(X_B, 0, Packet, 6, X_B.Length);
            Array.Copy(Y_B, 0, Packet, 14, Y_B.Length);
            Array.Copy(Z_B, 0, Packet, 22, Z_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendObjectTorque(UInt32 ForceObjId, double ThetaTorque, double PhiTorque)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TORQUE_OBJ);
            byte[] OID_B = BitConverter.GetBytes(ForceObjId);
            byte[] T_B = BitConverter.GetBytes(ThetaTorque);
            byte[] P_B = BitConverter.GetBytes(PhiTorque);


            byte[] Packet = new byte[22];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID_B, 0, Packet, 2, OID_B.Length);
            Array.Copy(T_B, 0, Packet, 6, T_B.Length);
            Array.Copy(P_B, 0, Packet, 14, P_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendObjectColour(UInt32 ObjectID, byte Red, byte Green, byte Blue, byte Brightness)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_COLOUR_OBJ);
            byte[] OID_B = BitConverter.GetBytes(ObjectID);


            byte[] Packet = new byte[10];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID_B, 0, Packet, 2, OID_B.Length);
            Packet[6] = Red;
            Packet[7] = Green;
            Packet[8] = Blue;
            Packet[9] = Brightness;

            this.QueuePacketToSend(ref Packet);
        }
        public void SendAddInanimateObj(double X, double Y, double Z, byte Red, byte Green, byte Blue, byte Brightness, float Energy, UInt16 Flags)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_ADDINANIMATE_OBJ);
            byte[] X_B = BitConverter.GetBytes(X);
            byte[] Y_B = BitConverter.GetBytes(Y);
            byte[] Z_B = BitConverter.GetBytes(Z);
            byte[] E_B = BitConverter.GetBytes(Energy);
            byte[] F_B = BitConverter.GetBytes(Flags);

            byte[] Packet = new byte[36];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(X_B, 0, Packet, 2, X_B.Length);
            Array.Copy(Y_B, 0, Packet, 10, Y_B.Length);
            Array.Copy(Z_B, 0, Packet, 18, Z_B.Length);
            Packet[26] = Red;
            Packet[27] = Green;
            Packet[28] = Blue;
            Packet[29] = Brightness;
            Array.Copy(E_B, 0, Packet, 30, E_B.Length);
            Array.Copy(F_B, 0, Packet, 34, F_B.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendEatObject(UInt32 ObjectID)
        {
            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_EAT_OBJ);
            byte[] OID = BitConverter.GetBytes(ObjectID);

            byte[] Packet = new byte[6];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(OID, 0, Packet, 2, OID.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendKillSystem(string KillCode)
        {
            if (KillCode.Length > 32)
            {
                KillCode = KillCode.Substring(0, 32);
            }

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_KILL_SYSTEM);

            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] STR = encoding.GetBytes(KillCode);

            byte[] Packet = new byte[2 + STR.Length];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendTestsEchoReply(IPEndPoint Addr, string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO_REPLY);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendTestsEcho(string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Packet);
        }
        public void SendTestsEcho(IPEndPoint Addr, string Data)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            byte[] ID = BitConverter.GetBytes(PacketTypes.PKT_TEST_ECHO);
            byte[] STR = encoding.GetBytes(Data);

            byte[] Packet = new byte[(2 + STR.Length)];

            Array.Copy(ID, 0, Packet, 0, ID.Length);
            Array.Copy(STR, 0, Packet, 2, STR.Length);

            this.QueuePacketToSend(ref Packet);
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
            UInt16 Length = BitConverter.ToUInt16(Packet, 0);
            UInt16 Type = BitConverter.ToUInt16(Packet, 2);

            byte[] Payload = new byte[Packet.Length - 4];

            Array.Copy(Packet, 4, Payload, 0, Payload.Length);

            switch (Type)
            {
                case PacketTypes.PKT_ACK:
                    this.RecvAck(Payload);
                    break;

                case PacketTypes.PKT_ERROR:
                    this.RecvError(Payload);
                    break;

                case PacketTypes.PKT_FORCEDISCONNECT:
                    this.RecvForceDisconnect();
                    break;

                case PacketTypes.PKT_CLIENT_ENUMERATE:
                    this.RecvClientEnum(Payload);
                    break;

                case PacketTypes.PKT_BULK_UPDATE_OBJ:
                    this.RecvBulkUpdate(Payload);
                    break;

                case PacketTypes.PKT_DELETE_OBJ:
                    this.RecvDeleteObject(Payload);
                    break;

                case PacketTypes.PKT_REMOVE_EATEN_OBJ:
                    this.RecvRemoveEatenObject(Payload);
                    break;

                case PacketTypes.PKT_KILL_SYSTEM:
                    this.RecvKillSystem(Payload);
                    break;

                case PacketTypes.PKT_TEST_ECHO_REPLY:
                    this.RecvTestsEchoReply(Addr, Payload);
                    break;

                case PacketTypes.PKT_TEST_ECHO:
                    this.RecvTestsEcho(Addr, Payload);
                    break;

                default:
                    this.SendError(Addr, 0, 0);
                    break;
            }
        }
        // Receive Packet Functions
        private bool RecvAck(byte[] Data)
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
                case PacketTypes.PKT_CONNECTION_REQ:
                    if (this.ClientID == 0)
                    {
                        this.ClientID = ACK_CODE;

                        this.EnvironmentDimensions = new CartesianVector(0.0, 0.0, 0.0);

                        ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.CONNECTED, ACK_CODE, 0);
                        this.OnClientNSEvent(Event);
                    }
                    break;

                case PacketTypes.PKT_DISCONNECTION_REQ:
                    if (this.ClientID != 0)
                    {
                        this.ClientID = 0;

                        this.EnvironmentDimensions = new CartesianVector(0.0, 0.0, 0.0);

                        ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.DISCONNECTED, 0, 0);
                        this.OnClientNSEvent(Event);
                    }
                    break;

                case PacketTypes.PKT_REQ_ADD_OBJ:
                    if (this.ObjectID == 0)
                    {
                        this.ObjectID = ACK_CODE;

                        ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.ASSIGNED_OBJECT, ACK_CODE, 0);
                        this.OnClientNSEvent(Event);
                    }
                    break;

                case PacketTypes.PKT_DELETE_OBJ:
                    if (this.ObjectID != 0)
                    {
                        this.ObjectID = 0;

                        ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.ASSIGNED_OBJECT_REMOVED, 0, 0);
                        this.OnClientNSEvent(Event);
                    }
                    break;

                case PacketTypes.PKT_FORCES_OBJ:

                    break;

                case PacketTypes.PKT_TORQUE_OBJ:
                    break;

                case PacketTypes.PKT_COLOUR_OBJ:
                    break;

                case PacketTypes.PKT_ADDINANIMATE_OBJ:

                    break;

                default:
                    // unknown packet, send error to client
                    break;
            }
            return true;
        }
        private bool RecvError(byte[] Data)
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
        private void RecvForceDisconnect()
        {
            this.ClientID = 0;
            this.ObjectID = 0;
            this.EnvironmentDimensions = new CartesianVector(0.0, 0.0, 0.0);

            ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.DISCONNECT_FORCED, 0, 0);
            this.OnClientNSEvent(Event);
            return;
        }
        private bool RecvClientEnum(byte[] Data)
        {
            if (this.EnvironmentDimensions != new CartesianVector(0.0, 0.0, 0.0))
            {
                return true;
            }

            if (Data.Length < 24)
            {
                return false;
            }

            CartesianVector XYZ = new CartesianVector();

            XYZ.x = BitConverter.ToDouble(Data, 0);
            XYZ.y = BitConverter.ToDouble(Data, 8);
            XYZ.z = BitConverter.ToDouble(Data, 16);

            if ((XYZ.x <= 0.0) || (XYZ.y <= 0.0) || (XYZ.z <= 0.0))
            {
                return false;
            }

            this.EnvironmentDimensions = XYZ;

            ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.ENUM, this.EnvironmentDimensions);
            this.OnClientNSEvent(Event);

            return true;
        }
        private bool RecvBulkUpdate(byte[] Data)
        {
            if (this.EnvironmentDimensions == new CartesianVector(0.0, 0.0, 0.0))
            {
                return false;
            }

            if (this.ClientID == 0)
            {
                return false;
            }

            if (Data.Length < 2)
            {
                return false;
            }

            UInt32 NumObjects = BitConverter.ToUInt32(Data, 0);

            UInt32 ExpectedDataLength = (Constants.UPDATE_OBJ_LENGTH * NumObjects) + sizeof(UInt32);

            if (Data.Length != ExpectedDataLength)
            {
                return false;
            }

            

            for (UInt32 i = 0; i < NumObjects; i++)
            {
                Record_ClientObject Object = new Record_ClientObject();
                UInt32 BaseIndex = (i * Constants.UPDATE_OBJ_LENGTH) + sizeof(UInt32);

                Object.ID = BitConverter.ToUInt32(Data, (int)BaseIndex);
                Object.Position.x = BitConverter.ToDouble(Data, (int)(BaseIndex + 4));
                Object.Position.y = BitConverter.ToDouble(Data, (int)(BaseIndex + 12));
                Object.Position.z = BitConverter.ToDouble(Data, (int)(BaseIndex + 20));
                Object.Theta = BitConverter.ToDouble(Data, (int)(BaseIndex + 28));
                Object.Phi = BitConverter.ToDouble(Data, (int)(BaseIndex + 36));
                Object.Red = Data[44];
                Object.Green = Data[45];
                Object.Blue = Data[46];
                Object.Brightness = Data[47];
                Object.Energy = BitConverter.ToDouble(Data, (int)(BaseIndex + 48));
                Object.FLAGS = BitConverter.ToUInt16(Data, (int)(BaseIndex + 56));

                this.Object_DB.AddUpdateRecord(Object.ID, Object);
            }

            ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.OBJECT_DB_DIRTY, 0, 0);
            this.OnClientNSEvent(Event);

            return true;
        }
        private bool RecvDeleteObject(byte[] Data)
        {
            if (this.EnvironmentDimensions == new CartesianVector(0.0, 0.0, 0.0))
            {
                return false;
            }

            if (Data.Length < 4)
            {
                return false;
            }

            UInt32 DelObjectID = BitConverter.ToUInt32(Data, 0);

            if (!this.Object_DB.DeleteRecordByID(DelObjectID))
            {
                return false;
            }

            ClientNSEventArgs Event;

            if (DelObjectID == this.ObjectID)
            {
                this.ObjectID = 0;
                Event = new ClientNSEventArgs(ClientStatus.ASSIGNED_OBJECT_REMOVED, 0, 0);
            }
            else
            {
                Event = new ClientNSEventArgs(ClientStatus.OBJECT_DB_DIRTY, 0, 0);
            }

            this.OnClientNSEvent(Event);

            return true;
        }
        private bool RecvRemoveEatenObject(byte[] Data)
        {
            if (Data.Length < 4)
            {
                return false;
            }

            UInt32 DelObjectID = BitConverter.ToUInt32(Data, 0);

            if (!this.Object_DB.DeleteRecordByID(DelObjectID))
            {
                return false;
            }

            ClientNSEventArgs Event;

            if (DelObjectID == this.ObjectID)
            {
                this.ObjectID = 0;
                Event = new ClientNSEventArgs(ClientStatus.ASSIGNED_OBJECT_REMOVED, 0, 0);
            }
            else
            {
                Event = new ClientNSEventArgs(ClientStatus.OBJECT_DB_DIRTY, 0, 0);
            }

            this.OnClientNSEvent(Event);

            return true;
        }
        private bool RecvKillSystem(byte[] Data)
        {
            return true;
        }
        private bool RecvTestsEchoReply(IPEndPoint Addr, byte[] Packet)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();

            // Recv test Echo Packet must be less than 1022 bytes
            if (Packet.Length > 1022)
            {
                this.SendError(Addr, PacketTypes.PKT_TEST_ECHO, 0);
                return false;
            }

            string Str = ASCIIEncoding.ASCII.GetString(Packet);

            ClientNSEventArgs Event = new ClientNSEventArgs(ClientStatus.TESTS_ECHO_REPLY, Str);

            this.OnClientNSEvent(Event);

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
