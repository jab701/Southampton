using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SDP
{
    // This class contains a data structure and methods for the sdp packet header
    public class sdp_hdr_t
    {
        // Variables
        private byte _flags;
        private byte _tag;
        private byte _dest_cpu_port;
        private byte _srce_cpu_port;
        private ushort _dest_addr;
        private ushort _srce_addr;
        // Propeties for getting/setting variables/data
        public byte flags
        {
            get
            {
                return this._flags;
            }
            set
            {
                this._flags = value;
            }
        }
        public byte tag
        {
            get
            {
                return this._tag;
            }
            set
            {
                this._tag = value;
            }
        }
        public byte dest_cpu
        {
            get
            {
                byte cpu = (byte)(this._dest_cpu_port & 0x1F);
                return cpu;
            }
            set
            {
                byte cpu = (byte)(value & 0x1F);
                unchecked
                {
                    this._dest_cpu_port &= (byte)(~0x1F);
                    this._dest_cpu_port |= cpu;
                }
            }
        }
        public byte dest_port
        {
            get
            {
                byte port = (byte)(this._dest_cpu_port >> 5);
                return port;
            }
            set
            {
                byte port = (byte)(value << 5);
                unchecked
                {
                    this._dest_cpu_port &= (byte)(~0xE0);
                    this._dest_cpu_port |= port;
                }
            }
        }
        public byte srce_cpu
        {
            get
            {
                byte cpu = (byte)(this._srce_cpu_port & 0x1F);
                return cpu;
            }
            set
            {
                byte cpu = (byte)(value & 0x1F);
                unchecked
                {
                    this._srce_cpu_port &= (byte)(~0x1F);
                    this._srce_cpu_port |= cpu;
                }
            }
        }
        public byte srce_port
        {
            get
            {
                byte port = (byte)(this._srce_cpu_port >> 5);
                return port;
            }
            set
            {
                byte port = (byte)(value << 5);
                unchecked
                {
                    this._srce_cpu_port &= (byte)(~0xE0);
                    this._srce_cpu_port |= port;
                }
            }
        }
        public ushort dest_addr
        {
            get
            {
                return this._dest_addr;
            }
            set
            {
                this._dest_addr = value;
            }
        }
        public ushort srce_addr
        {
            get
            {
                return this._srce_addr;
            }
            set
            {
                this._srce_addr = value;
            }
        }
        public byte[] bytes
        {
            get
            {
                byte[] Data = new byte[8];

                Data[0] = this._flags;
                Data[1] = this._tag;
                Data[2] = this._dest_cpu_port;
                Data[3] = this._srce_cpu_port;
                Data[4] = (byte)this._dest_addr; // lower byte
                Data[5] = (byte)(this._dest_addr >> 8); // upper byte
                Data[6] = (byte)this._srce_addr; // lower byte
                Data[7] = (byte)(this._srce_addr >> 8); // upper byte

                return Data;
            }
            set
            {
                if (value.Length != 8)
                {
                    return;
                }

                this._flags = value[0];
                this._tag = value[1];
                this._dest_cpu_port = value[2];
                this._srce_cpu_port = value[3];
                this._dest_addr = (ushort)((value[5] << 8) | value[4]);
                this._srce_addr = (ushort)((value[7] << 8) | value[6]);
            }
        }
        public uint length
        {
            get
            {
                return 8;
            }
        }
        // Methods
        public sdp_hdr_t()
        {
            this._flags = 0;
            this._tag = 0;
            this._dest_cpu_port = 0;
            this._srce_cpu_port = 0;
            this._dest_addr = 0;
            this._srce_addr = 0;
        }
    };
    // This class contains a data structure and methods for the sdp command type
    public class sdp_cmd_t
    {
        // Variables
        public ushort cmd_rc;
        public ushort seq;
        public uint arg1;
        public uint arg2;
        public uint arg3;
        public byte[] data = new byte[0];
        // Propeties for getting/setting variables/data
        public byte[] bytes
        {
            get
            {

                if (this.data.Length > SDP.SDP_BUF_SIZE)
                {
                    this.data = this.data.Take((int)SDP.SDP_BUF_SIZE).ToArray();
                }

                byte[] byte_data = new byte[16 + data.Length];

                byte_data[0] = (byte)this.cmd_rc;
                byte_data[1] = (byte)(this.cmd_rc >> 8);

                byte_data[2] = (byte)this.seq;
                byte_data[3] = (byte)(this.seq >> 8);

                byte_data[4] = (byte)this.arg1;
                byte_data[5] = (byte)(this.arg1 >> 8);
                byte_data[6] = (byte)(this.arg1 >> 16);
                byte_data[7] = (byte)(this.arg1 >> 24);

                byte_data[8] = (byte)this.arg2;
                byte_data[9] = (byte)(this.arg2 >> 8);
                byte_data[10] = (byte)(this.arg2 >> 16);
                byte_data[11] = (byte)(this.arg2 >> 24);

                byte_data[12] = (byte)this.arg3;
                byte_data[13] = (byte)(this.arg3 >> 8);
                byte_data[14] = (byte)(this.arg3 >> 16);
                byte_data[15] = (byte)(this.arg3 >> 24);

                for (uint i = 0; i < this.data.Length; i++)
                {
                    byte_data[16 + i] = data[i];
                }

                return byte_data;
            }
            set
            {
                // Set Return code and sequence bytes
                if (value.Length >= 4)
                {
                    this.cmd_rc = (ushort)((value[1] << 8) | value[0]);
                    this.seq = (ushort)((value[3] << 8) | value[2]);
                }

                // Arg1 Return bytes
                if (value.Length == 5)
                {
                    this.arg1 = (byte)value[4];
                }
                else if (value.Length >= 8)
                {
                    this.arg1 = (uint)((value[7] << 24) | (value[6] << 16) | (value[5] << 8) | value[4]);
                }
                else
                {
                    this.arg1 = 0;
                }

                // Arg2 Return bytes
                if (value.Length == 9)
                {
                    this.arg2 = (byte)value[8];
                }
                else if (value.Length >= 12)
                {
                    this.arg2 = (uint)((value[11] << 24) | (value[10] << 16) | (value[9] << 8) | value[8]);
                }
                else
                {
                    this.arg2 = 0;
                }

                // Arg3 Return bytes
                if (value.Length == 13)
                {
                    this.arg3 = (byte)value[12];
                }
                else if (value.Length >= 16)
                {
                    this.arg3 = (uint)((value[15] << 24) | (value[14] << 16) | (value[13] << 8) | value[12]);
                }
                else
                {
                    this.arg3 = 0;
                }

                if (value.Length <= (uint)16)
                {
                    this.data = new byte[0];
                }
                else
                {
                    this.data = new byte[value.Length - 16];

                    for (uint i = 0; i < this.data.Length; i++)
                    {
                        data[i] = value[16 + i];
                    }
                }

                return;
            }
        }
        public byte[] data_inc_args
        {
            get
            {
                byte[] byte_data = new byte[12 + data.Length];

                byte_data[0] = (byte)this.arg1;
                byte_data[1] = (byte)(this.arg1 >> 8);
                byte_data[2] = (byte)(this.arg1 >> 16);
                byte_data[3] = (byte)(this.arg1 >> 24);

                byte_data[4] = (byte)this.arg2;
                byte_data[5] = (byte)(this.arg2 >> 8);
                byte_data[6] = (byte)(this.arg2 >> 16);
                byte_data[7] = (byte)(this.arg2 >> 24);

                byte_data[8] = (byte)this.arg3;
                byte_data[9] = (byte)(this.arg3 >> 8);
                byte_data[10] = (byte)(this.arg3 >> 16);
                byte_data[11] = (byte)(this.arg3 >> 24);

                Array.Copy(this.data, 0, byte_data, 12, this.data.Length);

                return byte_data;
            }
        }
        public uint length
        {
            get
            {
                if (this.data == null)
                {
                    return (uint)(16);
                }

                if (this.data.Length > SDP.SDP_BUF_SIZE)
                {
                    this.data = this.data.Take((int)SDP.SDP_BUF_SIZE).ToArray();
                }

                return (uint)(16 + data.Length);
            }
        }
    };
    // Data Structures for returned data
    // iptag returned data structure
    public class iptag_t
    {
        public byte[] IP = new byte[4];
        public byte[] MAC = new byte[6];
        public ushort Port;
        public ushort Timeout;
        public ushort Flags;
        public byte[] bytes
        {
            set
            {
                if (value.Length != 16)
                {
                    return;
                }

                this.IP[0] = value[0];
                this.IP[1] = value[1];
                this.IP[2] = value[2];
                this.IP[3] = value[3];

                this.MAC[0] = value[4];
                this.MAC[1] = value[5];
                this.MAC[2] = value[6];
                this.MAC[3] = value[7];
                this.MAC[4] = value[8];
                this.MAC[5] = value[9];

                this.Port = (ushort)((value[11] << 8) | value[10]);
                this.Timeout = (ushort)((value[13] << 8) | value[12]);
                this.Flags = (ushort)((value[15] << 8) | value[14]);
            }
        }
    }
    // sver returned data structure
    public class sver_t
    {
        public byte v_cpu;
        public byte p_cpu;
        public byte chip_y;
        public byte chip_x;
        public ushort size;
        public double ver_num;
        public uint time;
        public byte[] ver_string = new byte[0];
        public byte[] bytes
        {
            set
            {
                if (value.Length < 12)
                {
                    return;
                }

                this.v_cpu = value[0];
                this.p_cpu = value[1];
                this.chip_y = value[2];
                this.chip_x = value[3];

                this.size = (ushort)((value[5] << 8) | value[4]);

                ushort TempVersion = (ushort)((value[7] << 8) | value[6]);
                this.ver_num = (TempVersion / 100.0);

                this.time = (uint)((value[11] << 24) | (value[10] << 16) | (value[9] << 8) | value[8]);

                uint String_Length = (uint)(value.Length - 12);

                this.ver_string = new byte[String_Length];

                Array.Copy(value, 12, this.ver_string, 0, String_Length);
            }
        }
    }
}
