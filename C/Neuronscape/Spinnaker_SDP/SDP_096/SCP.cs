using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace SDP
{
    // This class contains constant definitions for the SDP Packet Type
    public class SCP
    {
        private byte _nn_id;
        private byte _chipx;
        private byte _chipy;
        private byte _cpu;
        private int _Timeout;

        public SCP()
        {
            this._nn_id = 0;
            this._chipx = 0;
            this._chipy = 0;
            this._cpu = 0;
            this._Timeout = 3000;
        }
        public SCP(int Timeout)
        {
            this._nn_id = 0;
            this._chipx = 0;
            this._chipy = 0;
            this._cpu = 0;
            this._Timeout = Timeout;
        }
        public void Set_Chip(byte chipx, byte chipy, byte cpu)
        {
            this._chipx = chipx;
            this._chipy = chipy;
            this._cpu = cpu;
        }
        public void Get_Chip(out byte chipx, out byte chipy, out byte cpu)
        {
            chipx = this._chipx;
            chipy = this._chipy;
            cpu = this._cpu;
        }

        // Private Functions
        // Private Utility Functions
        private void Reset_NN_ID()
        {
            this._nn_id = 0;
        }
        private byte Next_ID()
        {
            this._nn_id = (byte)(this._nn_id + 1);

            if (this._nn_id > 127)
            {
                this._nn_id = 1;
            }

            return (byte)(2 * this._nn_id);
        }
        // Public Functions
        public  ushort aplx(ref UdpClient Socket, uint Address)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_APLX;
            Command.seq = 0;
            Command.arg1 = (uint)Address;
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort appstart(ref UdpClient Socket, uint Address, uint Mask)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_AS;
            Command.seq = 0;
            Command.arg1 = (uint)Address;
            Command.arg2 = (uint)Mask;
            Command.arg3 = 0;
            Command.data = new byte[0];

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort boot(ref UdpClient Socket, byte[] Data)
        {
            uint Length = (uint)Data.Length;

            uint NumBlocks = Length / (SDP.BLOCKS_SIZE * 4);

            if (Length % (SDP.BLOCKS_SIZE * 4) != 0)
            {
                NumBlocks++;
            }

            if (NumBlocks > SDP.MAX_BLOCKS)
            {
                return SDP.RC_LEN;
            }

            this.send_boot(ref Socket, 1, 0, 0, NumBlocks - 1, null);

            for (uint i = 0; i < NumBlocks; i++)
            {
                byte[] PktData;

                if ((i == NumBlocks-1)&&(Length % (SDP.BLOCKS_SIZE * 4) != 0))
                {
                    uint Size = Length % (SDP.BLOCKS_SIZE * 4);
                    PktData = new byte[Size];
                }
                else
                {
                    PktData = new byte[SDP.BLOCKS_SIZE * 4];
                }

                Array.Copy(Data, (i * SDP.BLOCKS_SIZE * 4), PktData, 0, PktData.Length);

                uint Arg1 = ((SDP.BLOCKS_SIZE  - 1) << 8) | (i & 255);

                this.send_boot(ref Socket, 3, Arg1, 0, 0, PktData);
            }

            this.send_boot(ref Socket, 5, 1, 0, 0, null);

            return SDP.RC_OK;
        }
        public  ushort ff(ref UdpClient Socket, byte[] Data, uint mask, uint addr = 0xf5000000, byte fwd = 0x3e, byte rty = 0x18, byte sfwd = 0x3f, byte srty = 0x18)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            byte ID = this.Next_ID();
            uint FR = (uint)((sfwd << 8) + srty);

            byte[][] DataChunks;
            Utility.To256ByteBlocks(Data, out DataChunks);

            // FFS Packet
            byte Blocks = (byte)DataChunks.Length;

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = 0;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = 0;
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_NNP;
            Command.seq = 0;
            Command.arg1 = (uint)((SDP.NN_CMD_FFS << 24) + (0 << 16) + (Blocks << 8) + ID);
            Command.arg2 = addr;
            Command.arg3 = FR;
            Command.data = new byte[0];

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc != SDP.RC_OK)
            {
                return Command.cmd_rc;
            }

            // FF data blocks ($blocks << 24) + ($fwd << 16) + ($rty << 8)
            uint Address = addr;
            for (uint i = 0; i < Blocks; i++)
            {
                byte Size = (byte)((DataChunks[i].Length / 4) - 1);

                Command.cmd_rc = SDP.CMD_FFD;
                Command.seq = 0;
                Command.arg1 = (uint)((sfwd << 24) + (srty << 16) + (0 << 8) + ID);
                Command.arg2 = (uint)((0 << 24) + (i << 16) + (Size << 8) + 0);
                Command.arg3 = Address;

                Command.data = new byte[DataChunks[i].Length];
                Array.Copy(DataChunks[i], Command.data, DataChunks[i].Length);

                send(ref Socket, Header, Command);

                if (!receive(ref Socket, ref Header, ref Command))
                {
                    return SDP.RC_TIMEOUT;
                }

                if (Command.cmd_rc != SDP.RC_OK)
                {
                    return Command.cmd_rc;
                }

                Address += (uint)DataChunks[i].Length;
            }

            // arg1 = key
            // arg2 = data
            // arg3 = mark[31] : : fwd : retry
            Command.cmd_rc = SDP.CMD_NNP;
            Command.seq = 0;
            Command.arg1 = (uint)((SDP.NN_CMD_FFE << 24) + (0 << 16) + (0 << 8) + ID);
            Command.arg2 = mask;
            Command.arg3 = FR;
            Command.data = null;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }

        public  ushort led(ref UdpClient Socket, byte led, byte function)
        {
            // Now Set the LED

            // Check arguements
            if (led > 3)
            {
                return SDP.RC_ARG;
            }

            if ((function == 0) || (function > SDP.LED_ON))
            {
                return SDP.RC_ARG;
            }

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_LED;
            Command.seq = 0;
            Command.arg1 = (uint)(function << (led * 2));
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort led(ref UdpClient Socket, byte led0, byte led1, byte led2, byte led3)
        {
            // Now Set the LED
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_LED;
            Command.seq = 0;
            Command.arg1 = (uint)((led3 << 6) + (led2 << 4) + (led1 << 2) + led0);
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }

        public  ushort iptag_clr(ref UdpClient Socket, uint tag = 0)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_IPTAG;
            Command.seq = 0;
            Command.arg1 = (SDP.IPTAG_CLR << 16) + (tag & 0xF);
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort iptag_get(ref UdpClient Socket, out iptag_t tag_data, uint tagnum = 0)
        {
            tag_data = null;

            // Now Set the IPTAG
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_IPTAG;
            Command.seq = 0;
            Command.arg1 = (SDP.IPTAG_GET << 16) + (tagnum & 0xF);
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {
                byte[] temp = new byte[16];
                Array.Copy(Command.bytes, 4, temp, 0, 16);
                tag_data = new iptag_t();
                tag_data.bytes = temp;
            }

            return Command.cmd_rc;
        }
        public  ushort iptag_get_all(ref UdpClient Socket, out iptag_t[] tag_data)
        {
            ushort RC = 0;

            tag_data = new iptag_t[16];

            for (uint i = 0; i < 16; i++)
            {
                iptag_t tag;
                RC = this.iptag_get(ref Socket, out tag, i);

                if (RC != SDP.RC_OK)
                {
                    break;
                }
                else
                {
                    tag_data[i] = tag;
                }
            }

            if (RC != SDP.RC_OK)
            {
                tag_data = null;
            }

            return RC;
        }
        public  ushort iptag_set(ref UdpClient Socket, byte[] IP, uint port, uint tag = 0)
        {
            if (tag > 3)
            {
                return SDP.RC_ARG;
            }

            // Now Set the IPTAG
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_IPTAG;
            Command.seq = 0;
            Command.arg1 = (SDP.IPTAG_SET << 16) + tag;
            Command.arg2 = port;
            Command.arg3 = (uint)((IP[3] << 24) + (IP[2] << 16) + (IP[1] << 8) + IP[0]);

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort iptag_auto(ref UdpClient Socket, uint port)
        {
            // First clear any exisiting IPTAG
            ushort RC = this.iptag_clr(ref Socket);
            if (RC != SDP.RC_OK)
            {
                return RC;
            }

            // Now Set the IPTAG in auto Mode
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_IPTAG;
            Command.seq = 0;
            Command.arg1 = (SDP.IPTAG_AUTO << 16);
            Command.arg2 = (uint)port;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }

        public  ushort linkboot(ref UdpClient Socket, byte link, byte[] Data)
        {
            uint Address = 0xf5000000; // System RAM

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            // Phase 1
            byte[] Ph1_Data = new byte[4] { 0xff, 0xff, 0xcf, 0x5e };

            ushort RC = this.link_mem_write(ref Socket, 0xf2000018, link, Ph1_Data);

            if (RC != SDP.RC_OK)
            {
                return RC;
            }

            // Phase 2
            byte[] Ph2_Data = new byte[4] { 0x01, 0x00, 0x00, 0x00 };

            RC = this.link_mem_write(ref Socket, 0xf2000038, link, Ph2_Data);

            if (RC != SDP.RC_OK)
            {
                return RC;
            }

            // Phase 3 - Load Data Phase
            RC = this.linkload(ref Socket, Address, link, Data);

            if (RC != SDP.RC_OK)
            {
                return RC;
            }

            // Phase 4
            byte[] Ph4_Data = new byte[4] { 0x02, 0x00, 0xc0, 0x5e };

            RC = this.link_mem_write(ref Socket, 0xf2000018, link, Ph4_Data);

            return RC;
        }
        public  ushort linkdump(ref UdpClient Socket, uint BaseAddress, byte link, uint Length, out byte[] Data)
        {
            Data = null;

            byte[][] DataChunks = Utility.Allocate256ByteBlockArray(Length);

            uint Address = BaseAddress;
            ushort RC = 0;

            for (uint i = 0; i < (uint)DataChunks.Length; i++)
            {
                byte[] DataTemp;

                RC = this.link_mem_read(ref Socket, Address, link, (uint)DataChunks[i].Length, out DataTemp);

                if (RC != SDP.RC_OK)
                {
                    break;
                }

                Array.Copy(DataTemp, DataChunks[i], DataChunks[i].Length);

                // Calculate the next address in the block
                Address += (uint)DataTemp.Length;
            }

            if (RC == SDP.RC_OK)
            {
                Utility.From256ByteBlocks(DataChunks, out Data);
            }

            return RC;
        }
        public  ushort linkload(ref UdpClient Socket, uint BaseAddress, byte link, byte[] Data)
        {
            byte[][] DataChunks;

            Utility.To256ByteBlocks(Data, out DataChunks);

            uint Address = BaseAddress;
            ushort RC = 0;
            for (uint i = 0; i < DataChunks.Length; i++)
            {
                RC = this.link_mem_write(ref Socket, Address, link, DataChunks[i]);

                if (RC != SDP.RC_OK)
                {
                    break;
                }

                // Calculate the next address in the block
                Address += (uint)DataChunks[i].Length;
            }

            return RC;
        }

        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, out byte Data)
        {
            Data = 0;

            byte[] DataArray;

            ushort RC = this.link_mem_read(ref Socket, Address, link, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }
        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, out ushort Data)
        {
            Data = 0;

            ushort[] DataArray;

            ushort RC = this.link_mem_read(ref Socket, Address, link, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }
        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, out uint Data)
        {
            Data = 0;

            uint[] DataArray;

            ushort RC = this.link_mem_read(ref Socket, Address, link, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }

        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, uint NumberBytes, out byte[] Data)
        {
            Data = null;

            if (NumberBytes > 256)
            {
                return SDP.RC_ARG;
            }

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_LINK_READ;
            Command.seq = 0;
            Command.arg1 = Address;
            Command.arg2 = NumberBytes;
            Command.arg3 = (uint)link;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {
                Data = new byte[Command.data_inc_args.Length];

                Array.Copy(Command.data_inc_args, Data, Command.data_inc_args.Length);
            }

            return Command.cmd_rc;
        }
        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, uint NumberShorts, out ushort[] Data)
        {
            Data = null;

            if (NumberShorts > 128)
            {
                return SDP.RC_ARG;
            }

            byte[] DataBytes;
            uint NumberBytes = NumberShorts * 2;
            uint Mod_Address = (uint)(Address & (~0x01));

            ushort RC = this.link_mem_read(ref Socket, Mod_Address, link, NumberBytes, out DataBytes);

            if (RC == SDP.RC_OK)
            {
                Data = new ushort[(DataBytes.Length / 2)];

                for (uint i = 0; i < Data.Length; i++)
                {
                    Data[i] = (ushort)((DataBytes[(i * 2) + 1] << 8) + (DataBytes[(i * 2) + 0] << 0));
                }
            }

            return RC;
        }
        public  ushort link_mem_read(ref UdpClient Socket, uint Address, byte link, uint NumberWords, out uint[] Data)
        {
            Data = null;

            if (NumberWords > 64)
            {
                return SDP.RC_ARG;
            }

            byte[] DataBytes;
            uint NumberBytes = NumberWords * 4;
            uint Mod_Address = (uint)(Address & (~0x03));

            ushort RC = this.link_mem_read(ref Socket, Mod_Address, link, NumberBytes, out DataBytes);

            if (RC == SDP.RC_OK)
            {
                Data = new uint[(DataBytes.Length / 4)];

                for (uint i = 0; i < Data.Length; i++)
                {
                    Data[i] = (uint)((DataBytes[(i * 4) + 3] << 24) + (DataBytes[(i * 4) + 2] << 16) + (DataBytes[(i * 4) + 1] << 8) + (DataBytes[(i * 4) + 0] << 0));
                }
            }

            return RC;
        }

        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, byte Data)
        {
            byte[] DataArray = new byte[1];
            DataArray[0] = Data;

            return this.link_mem_write(ref Socket, Address, link, DataArray);
        }
        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, ushort Data)
        {
            ushort[] DataArray = new ushort[1];
            DataArray[0] = Data;

            return this.link_mem_write(ref Socket, Address, link, DataArray);
        }
        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, uint Data)
        {
            uint[] DataArray = new uint[1];
            DataArray[0] = Data;

            return this.link_mem_write(ref Socket, Address, link, DataArray);
        }

        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, byte[] Data)
        {
            uint NumberBytes = (uint)Data.Length;

            if (NumberBytes > 256)
            {
                return SDP.RC_ARG;
            }

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_LINK_WRITE;
            Command.seq = 0;
            Command.arg1 = Address;
            Command.arg2 = NumberBytes;
            Command.arg3 = (uint)link;

            Command.data = new byte[NumberBytes];

            Array.Copy(Data, Command.data, NumberBytes);

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, ushort[] Data)
        {
            Data = null;

            uint NumberShorts = (uint)Data.Length;

            if (NumberShorts > 128)
            {
                return SDP.RC_ARG;
            }

            uint NumberBytes = NumberShorts * 2;
            uint Mod_Address = (uint)(Address & (~0x01));
            byte[] databytes = new byte[NumberBytes];

            for (uint i = 0; i < NumberShorts; i++)
            {
                databytes[i * 2] = (byte)Data[i];
                databytes[(i * 2) + 1] = (byte)(Data[i] >> 8);
            }

            ushort RC = this.link_mem_write(ref Socket, Mod_Address, link, databytes);

            return RC;
        }
        public  ushort link_mem_write(ref UdpClient Socket, uint Address, byte link, uint[] Data)
        {
            Data = null;

            uint NumberWords = (uint)Data.Length;

            if (NumberWords > 64)
            {
                return SDP.RC_ARG;
            }

            uint NumberBytes = NumberWords * 4;
            uint Mod_Address = (uint)(Address & (~0x03));
            byte[] databytes = new byte[NumberBytes];

            for (uint i = 0; i < NumberWords; i++)
            {
                databytes[i * 4] = (byte)Data[i];
                databytes[(i * 4) + 1] = (byte)(Data[i] >> 8);
                databytes[(i * 4) + 2] = (byte)(Data[i] >> 16);
                databytes[(i * 4) + 3] = (byte)(Data[i] >> 24);
            }

            ushort RC = this.link_mem_write(ref Socket, Mod_Address, link, databytes);

            return RC;
        }

        // NNP PACKET FIXED BEHAVIOUR - CHECK
        public  ushort nnp(ref UdpClient Socket, uint key, uint data, byte fwd = 0x3e, byte rty = 0x18, byte sfwd = 0x3f, byte srty = 0x18)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            byte ID = this.Next_ID();

            key = (uint)(SDP.NN_CMD_SIG1 << 24) + (0x04 << 16) + (0x2c << 8) + ID;
            data = 0;

            uint FR = (uint)((sfwd << 8) + srty);

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_NNP;
            Command.seq = 0;
            Command.arg1 = key;
            Command.arg2 = data;
            Command.arg3 = FR;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort p2pc(ref UdpClient Socket, byte dim_x, byte dim_y)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            byte ID = this.Next_ID();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_P2PC;
            Command.seq = 0;
            Command.arg1 = (uint)((0x00 << 24) + (0x3e << 16) + (0x00 << 8) + ID);
            Command.arg2 = (uint)((dim_x << 24) + (dim_y << 16) + (0x00 << 8) + 0x00);
            Command.arg3 = (uint)((0x00 << 24) + (0x00 << 16) + (0x3f << 8) + 0xf8);

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }

        public  ushort mem_read(ref UdpClient Socket, uint Address, out byte Data)
        {
            Data = 0;

            byte[] DataArray;

            ushort RC = this.mem_read(ref Socket, Address, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }
        public  ushort mem_read(ref UdpClient Socket, uint Address, out ushort Data)
        {
            Data = 0;

            ushort[] DataArray;

            ushort RC = this.mem_read(ref Socket, Address, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }
        public  ushort mem_read(ref UdpClient Socket, uint Address, out uint Data)
        {
            Data = 0;

            uint[] DataArray;

            ushort RC = this.mem_read(ref Socket, Address, 1, out DataArray);

            if (RC == SDP.RC_OK)
            {
                Data = DataArray[0];
            }
            return RC;
        }

        public  ushort mem_read(ref UdpClient Socket, uint Address, uint NumberBytes, out byte[] Data)
        {
            Data = null;

            if (NumberBytes > 256)
            {
                return SDP.RC_ARG;
            }

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_READ;
            Command.seq = 0;
            Command.arg1 = Address;
            Command.arg2 = NumberBytes;
            Command.arg3 = SDP.TYPE_BYTE;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {
                Data = new byte[Command.data_inc_args.Length];

                Array.Copy(Command.data_inc_args, Data, Command.data_inc_args.Length);
            }

            return Command.cmd_rc;
        }
        public  ushort mem_read(ref UdpClient Socket, uint Address, uint NumberShorts, out ushort[] Data)
        {
            Data = null;

            if (NumberShorts > 128)
            {
                return SDP.RC_ARG;
            }

            byte[] DataBytes;
            uint NumberBytes = NumberShorts * 2;
            uint Mod_Address = (uint)(Address & (~0x01));

            ushort RC = this.mem_read(ref Socket, Mod_Address, NumberBytes, out DataBytes);

            if (RC == SDP.RC_OK)
            {
                Data = new ushort[(DataBytes.Length / 2)];

                for (uint i = 0; i < Data.Length; i++)
                {
                    Data[i] = (ushort)((DataBytes[(i * 2) + 1] << 8) + (DataBytes[(i * 2) + 0] << 0));
                }
            }

            return RC;
        }
        public  ushort mem_read(ref UdpClient Socket, uint Address, uint NumberWords, out uint[] Data)
        {
            Data = null;

            if (NumberWords > 64)
            {
                return SDP.RC_ARG;
            }

            byte[] DataBytes;
            uint NumberBytes = NumberWords * 4;
            uint Mod_Address = (uint)(Address & (~0x03));

            ushort RC = this.mem_read(ref Socket, Mod_Address, NumberBytes, out DataBytes);

            if (RC == SDP.RC_OK)
            {
                Data = new uint[(DataBytes.Length / 4)];

                for (uint i = 0; i < Data.Length; i++)
                {
                    Data[i] = (uint)((DataBytes[(i * 4) + 3] << 24) + (DataBytes[(i * 4) + 2] << 16) + (DataBytes[(i * 4) + 1] << 8) + (DataBytes[(i * 4) + 0] << 0));
                }
            }

            return RC;
        }

        public  ushort mem_write(ref UdpClient Socket, uint Address, byte Data)
        {
            byte[] DataArray = new byte[1];
            DataArray[0] = Data;

            return this.mem_write(ref Socket, Address, DataArray);
        }
        public  ushort mem_write(ref UdpClient Socket, uint Address, ushort Data)
        {
            ushort[] DataArray = new ushort[1];
            DataArray[0] = Data;

            return this.mem_write(ref Socket, Address, DataArray);
        }
        public  ushort mem_write(ref UdpClient Socket, uint Address, uint Data)
        {
            uint[] DataArray = new uint[1];
            DataArray[0] = Data;

            return this.mem_write(ref Socket, Address, DataArray);
        }

        public  ushort mem_write(ref UdpClient Socket, uint Address, byte[] Data)
        {
            uint NumberBytes = (uint)Data.Length;

            if (NumberBytes > 256)
            {
                return SDP.RC_ARG;
            }

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_WRITE;
            Command.seq = 0;
            Command.arg1 = Address;
            Command.arg2 = NumberBytes;
            Command.arg3 = SDP.TYPE_BYTE;

            Command.data = new byte[NumberBytes];

            Array.Copy(Data, Command.data, NumberBytes);

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort mem_write(ref UdpClient Socket, uint Address, ushort[] Data)
        {
            uint NumberShorts = (uint)Data.Length;

            if (NumberShorts > 128)
            {
                return SDP.RC_ARG;
            }


            uint NumberBytes = NumberShorts * 2;
            uint Mod_Address = (uint)(Address & (~0x01));
            byte[] databytes = new byte[NumberBytes];

            for (uint i = 0; i < NumberShorts; i++)
            {
                databytes[i * 2] = (byte)Data[i];
                databytes[(i * 2) + 1] = (byte)(Data[i] >> 8);
            }

            ushort RC = this.mem_write(ref Socket, Mod_Address, databytes);

            return RC;
        }
        public  ushort mem_write(ref UdpClient Socket, uint Address, uint[] Data)
        {
            uint NumberWords = (uint)Data.Length;

            if (NumberWords > 64)
            {
                return SDP.RC_ARG;
            }

            uint NumberBytes = NumberWords * 2;
            uint Mod_Address = (uint)(Address & (~0x01));
            byte[] databytes = new byte[NumberBytes];

            for (uint i = 0; i < NumberWords; i++)
            {
                databytes[i * 4] = (byte)Data[i];
                databytes[(i * 4) + 1] = (byte)(Data[i] >> 8);
                databytes[(i * 4) + 2] = (byte)(Data[i] >> 16);
                databytes[(i * 4) + 3] = (byte)(Data[i] >> 24);
            }

            ushort RC = this.mem_write(ref Socket, Mod_Address, databytes);

            return RC;
        }

        public  ushort sdump(ref UdpClient Socket, uint BaseAddress, uint Length, out byte[] Data)
        {
            Data = null;

            uint NumberChunks = Length / 256;
            uint Remainder = Length % 256;

            byte[][] DataChunks = Utility.Allocate256ByteBlockArray(Length);

            uint Address = BaseAddress;
            ushort RC = 0;

            for (uint i = 0; i < (uint)DataChunks.Length; i++)
            {
                byte[] DataTemp;

                RC = this.mem_read(ref Socket, Address, (uint)DataChunks[i].Length, out DataTemp);

                if (RC != SDP.RC_OK)
                {
                    break;
                }

                Array.Copy(DataTemp, DataChunks[i], DataChunks[i].Length);

                // Calculate the next address in the block
                Address += (uint)DataTemp.Length;
            }

            if (RC == SDP.RC_OK)
            {
                Utility.From256ByteBlocks(DataChunks, out Data);
            }

            return RC;
        }
        public  ushort sload(ref UdpClient Socket, uint BaseAddress, byte[] Data)
        {
            byte[][] DataChunks;

            Utility.To256ByteBlocks(Data, out DataChunks);

            uint Address = BaseAddress;
            ushort RC = 0;

            for (uint i = 0; i < DataChunks.Length; i++)
            {
                RC = this.mem_write(ref Socket, Address, DataChunks[i]);

                if (RC != SDP.RC_OK)
                {
                    break;
                }

                // Calculate the next address in the block
                Address += (uint)DataChunks[i].Length;
            }

            return RC;
        }

        public  ushort srom_erase(ref UdpClient Socket)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_SROM;
            Command.seq = 0;
            Command.arg1 = 0xc8;
            Command.arg2 = 0xc7000000;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort srom_read_ip(ref UdpClient Socket, out byte[] IP, out byte[] GW, out byte[] NM)
        {
            uint Offset = 16;

            IP = null;
            GW = null;
            NM = null;

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_SROM;
            Command.seq = 0;
            Command.arg1 = (12 * 65536) + 32;
            Command.arg2 = 0x03000000 + Offset;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {
                IP = new byte[4];
                GW = new byte[4];
                NM = new byte[4];

                IP[0] = (byte)Command.arg1;
                IP[1] = (byte)(Command.arg1 >> 8);
                IP[2] = (byte)(Command.arg1 >> 16);
                IP[3] = (byte)(Command.arg1 >> 24);

                GW[0] = (byte)Command.arg2;
                GW[1] = (byte)(Command.arg2 >> 8);
                GW[2] = (byte)(Command.arg2 >> 16);
                GW[3] = (byte)(Command.arg2 >> 24);

                NM[0] = (byte)Command.arg3;
                NM[1] = (byte)(Command.arg3 >> 8);
                NM[2] = (byte)(Command.arg3 >> 16);
                NM[3] = (byte)(Command.arg3 >> 24);
            }

            return Command.cmd_rc;
        }
        public  ushort srom_write_ip(ref UdpClient Socket, byte[] IP, byte[] GW, byte[] NM)
        {
            uint Offset = 16;

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_SROM;
            Command.seq = 0;
            Command.arg1 = (12 * 65536) + 0x1e0;
            Command.arg2 = 0x02000000 + Offset;
            Command.arg3 = 0;
            Command.data = new byte[12];

            Command.data[0] = IP[0];
            Command.data[1] = IP[1];
            Command.data[2] = IP[2];
            Command.data[3] = IP[3];

            Command.data[4] = GW[0];
            Command.data[5] = GW[1];
            Command.data[6] = GW[2];
            Command.data[7] = GW[3];

            Command.data[8] = NM[0];
            Command.data[9] = NM[1];
            Command.data[10] = NM[2];
            Command.data[11] = NM[3];

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort srom_read(ref UdpClient Socket, uint Address, out byte[] Data)
        {
            Data = null;

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_SROM;
            Command.seq = 0;
            Command.arg1 = (256 * 65536) + 32;
            Command.arg2 = 0x03000000 + Address;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {
                Data = new byte[Command.data.Length];
                Array.Copy(Command.data, Data, Command.data.Length);
            }

            return Command.cmd_rc;
        }
        public  ushort srom_write(ref UdpClient Socket, uint Address, byte[] Data)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            sdp_cmd_t Command = new sdp_cmd_t();

            byte[][] DataChunks;

            Utility.To256ByteBlocks(Data, out DataChunks);

            Address = 0x02000000 + Address;

            for (uint i = 0; i < DataChunks.Length; i++)
            {
                Command.cmd_rc = SDP.CMD_SROM;
                Command.seq = 0;
                Command.arg1 = ((uint)DataChunks[i].Length * 65536) + 0x1e0;
                Command.arg2 = Address;
                Command.arg3 = 0;

                Command.data = new byte[DataChunks[i].Length];

                Array.Copy(DataChunks[i], Command.data, DataChunks[i].Length);

                send(ref Socket, Header, Command);

                if (!receive(ref Socket, ref Header, ref Command))
                {
                    return SDP.RC_TIMEOUT;
                }

                if (Command.cmd_rc != SDP.RC_OK)
                {
                    break;
                }

                // Calculate the next address in the block
                Address += (uint)DataChunks[i].Length;
            }

            return Command.cmd_rc;
        }

        public  ushort srun(ref UdpClient Socket, uint Address, bool wait = false)
        {
            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_RUN;
            Command.seq = 0;
            Command.arg1 = Address;

            if (wait == true)
            {
                Command.arg2 = 0x0100;
            }
            else
            {
                Command.arg2 = 0x0101;
            }

            Command.arg3 = 0;

            send(ref Socket, Header, Command);

            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            return Command.cmd_rc;
        }
        public  ushort sver(ref UdpClient Socket, out sver_t version_data)
        {
            version_data = null;

            sdp_hdr_t Header = new sdp_hdr_t();
            sdp_cmd_t Command = new sdp_cmd_t();

            Header.flags = SDP.SDPF_REPLY | SDP.SDPF_LMASK;
            Header.tag = 255;
            Header.dest_cpu = this._cpu;
            Header.dest_port = 0;
            Header.srce_cpu = 31;
            Header.srce_port = 7;
            Header.dest_addr = (ushort)((this._chipx << 8) + this._chipy);
            Header.srce_addr = 0;

            Command.cmd_rc = SDP.CMD_VER;
            Command.seq = 0;
            Command.arg1 = 0;
            Command.arg2 = 0;
            Command.arg3 = 0;

            send(ref Socket, Header, Command);
            if (!receive(ref Socket, ref Header, ref Command))
            {
                return SDP.RC_TIMEOUT;
            }

            if (Command.cmd_rc == SDP.RC_OK)
            {

                byte[] temp = new byte[Command.length - 4];
                Array.Copy(Command.bytes, 4, temp, 0, (Command.length - 4));
                version_data = new sver_t();
                version_data.bytes = temp;
            }

            return Command.cmd_rc;
        }

        // Send/Receive Functions
        public  bool send(ref UdpClient Socket, sdp_hdr_t Header, sdp_cmd_t Command)
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
        public  void send_boot(ref UdpClient Socket, uint Op, uint Arg1, uint Arg2, uint Arg3, byte[] Data)
        {
            uint DataLength;

            if (Data == null)
            {
                DataLength = 0;
            }
            else
            {
                DataLength = (uint)Data.Length;
            }

            uint Length = 18 + DataLength;

            byte[] Packet = new byte[Length];

            Packet[0] = (byte)((SDP.BOOT_PROT_VER >> 8) & 0xFF);
            Packet[1] = (byte)((SDP.BOOT_PROT_VER & 0xFF));

            Packet[2] = (byte)((Op >> 24) & 0xFF);
            Packet[3] = (byte)((Op >> 16) & 0xFF);
            Packet[4] = (byte)((Op >> 8) & 0xFF);
            Packet[5] = (byte)(Op & 0xFF);

            Packet[6] = (byte)((Arg1 >> 24) & 0xFF);
            Packet[7] = (byte)((Arg1 >> 16) & 0xFF);
            Packet[8] = (byte)((Arg1 >> 8) & 0xFF);
            Packet[9] = (byte)(Arg1 & 0xFF);

            Packet[10] = (byte)((Arg2 >> 24) & 0xFF);
            Packet[11] = (byte)((Arg2 >> 16) & 0xFF);
            Packet[12] = (byte)((Arg2 >> 8) & 0xFF);
            Packet[13] = (byte)(Arg2 & 0xFF);

            Packet[14] = (byte)((Arg3 >> 24) & 0xFF);
            Packet[15] = (byte)((Arg3 >> 16) & 0xFF);
            Packet[16] = (byte)((Arg3 >> 8) & 0xFF);
            Packet[17] = (byte)(Arg3 & 0xFF);

            for (uint i = 0; i < DataLength; i = i + 4)
            {
                // Unpack into 32 bit little endian order
                byte b0 = Data[i];
                byte b1 = Data[i + 1];
                byte b2 = Data[i + 2];
                byte b3 = Data[i + 3];
                // Pack into 32 big endian order
                Data[i] = b3;
                Data[i + 1] = b2;
                Data[i + 2] = b1;
                Data[i + 3] = b0;
           }

            for (uint i = 0; i < DataLength; i++)
            {
                
                Packet[18 + i] = Data[i];
            }

            IPEndPoint Endpoint = Socket.Client.RemoteEndPoint as IPEndPoint;

            Endpoint.Port = (int)SDP.BOOT_PORT;

            Socket.Send(Packet, Packet.Length);

            Thread.Sleep((int)(SDP.BOOT_DELAY));
        }
        public  bool receive(ref UdpClient Socket, ref sdp_hdr_t ReplyHeader, ref sdp_cmd_t ReplyCommand)
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
