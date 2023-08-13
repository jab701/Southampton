using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;


namespace April_Demo
{
    using SDP;

    class SimControlComms
    {
        public const ushort CMD_EXIT        = 0; // Command Exit Simulation Code
        public const ushort CMD_VISUAL_DATA = 1; // Command Visual Data Code
        public const ushort CMD_PARAMETERS  = 2; // Command Parameter update
        public const ushort CMD_START       = 3; //
        public const ushort CMD_STOP        = 4; //

        public const uint PARAM_CHANGETAG   = 0;
        public const uint PARAM_CHANGETICK  = 1;
        public const uint PARAM_CHANGETHOLD = 2;
        public const uint PARAM_CHANGEEATTHOLD = 3;

        private byte _chipx;
        private byte _chipy;

        private int _Timeout;

        public SimControlComms()
        {
            this._chipx = 0;
            this._chipy = 0;
            this._Timeout = 3000;
        }
        public SimControlComms(int Timeout)
        {
            this._chipx = 0;
            this._chipy = 0;
            this._Timeout = Timeout;
        }
        public void Set_Chip(byte chipx, byte chipy)
        {
            this._chipx = chipx;
            this._chipy = chipy;
        }
        public void Get_Chip(out byte chipx, out byte chipy)
        {
            chipx = this._chipx;
            chipy = this._chipy;
        }

        // Public Functions
        // Control Simulation
        public void StartSimulation(ref UdpClient Socket, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_START;
            Command.seq = 0;
            Command.arg1 = 0;
            Command.arg2 = 0;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        public void PauseSimulation(ref UdpClient Socket, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_STOP;
            Command.seq = 0;
            Command.arg1 = 0;
            Command.arg2 = 0;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        public void ExitSimulation(ref UdpClient Socket, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_EXIT;
            Command.seq = 0;
            Command.arg1 = 0;
            Command.arg2 = 0;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        // Change Simulation Parameters
        public void ChTag(ref UdpClient Socket, uint Tag, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_PARAMETERS;
            Command.seq = 0;
            Command.arg1 = PARAM_CHANGETAG;
            Command.arg2 = Tag;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        public void ChTick(ref UdpClient Socket, uint Tick, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_PARAMETERS;
            Command.seq = 0;
            Command.arg1 = PARAM_CHANGETICK;
            Command.arg2 = Tick;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        public void ChThreshold(ref UdpClient Socket, uint Threshold, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_PARAMETERS;
            Command.seq = 0;
            Command.arg1 = PARAM_CHANGETHOLD;
            Command.arg2 = Threshold;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        public void ChEatThreshold(ref UdpClient Socket, uint Threshold, byte CPU)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = 0x07;
            Header.tag = 255;
            Header.dest_cpu = CPU;
            Header.dest_port = 1;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = CMD_PARAMETERS;
            Command.seq = 0;
            Command.arg1 = PARAM_CHANGEEATTHOLD;
            Command.arg2 = Threshold;
            Command.arg3 = 0;
            Command.data = new byte[0];

            this.send(ref Socket, Header, Command);
        }
        // Send/Receive Functions
        public bool send(ref UdpClient Socket, sdp_hdr_t Header, sdp_cmd_t Command)
        {
            byte[] Packet = new byte[Header.length + Command.length + 2];
            // Pad bytes
            Packet[0] = 0;
            Packet[1] = 0;

            Header.bytes.CopyTo(Packet, 2);
            Command.bytes.CopyTo(Packet, (2 + Header.length));

            Socket.Send(Packet, Packet.Length);
            return true;
        }
        public bool receive(ref UdpClient Socket, ref sdp_hdr_t ReplyHeader, ref sdp_cmd_t ReplyCommand)
            {
                int CurrentTimeout = Socket.Client.ReceiveTimeout;

                Socket.Client.ReceiveTimeout = this._Timeout;

                IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);

                Byte[] Bytes;

                try
                {
                    Bytes = Socket.Receive(ref RemoteIpEndPoint);
                }
                catch (SocketException)
                {
                    return false;
                }

                Socket.Client.ReceiveTimeout = CurrentTimeout;

                byte[] HeaderBytes = new byte[8];
                byte[] CommandBytes = new byte[Bytes.Length - 10];


                Array.Copy(Bytes, 2, HeaderBytes, 0, 8);
                Array.Copy(Bytes, 10, CommandBytes, 0, CommandBytes.Length);

                ReplyHeader.bytes = HeaderBytes;
                ReplyCommand.bytes = CommandBytes;
                return true;
            }
        
    }
}
