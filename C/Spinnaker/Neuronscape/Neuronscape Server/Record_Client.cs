using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;

namespace Neuronscape_Server
{
    class Record_Client
    {
        public UInt32 ID;
        public IPEndPoint Addr;
        public byte Role;
        public UInt16 Command_Major;
        public UInt16 Command_Minor;
        public UInt16 Status;

        public Record_Client()
        {
            this.ID = 0;
            this.Addr = new IPEndPoint(0,0);
            this.Role = 0;
            this.Command_Major = 0;
            this.Command_Minor = 0;
            this.Status = 0;

        }
        public Record_Client(UInt32 ID, IPAddress Addr, UInt16 Port, byte Role, UInt16 Command_Major, UInt16 Command_Minor)
        {
            this.ID = ID;
            this.Addr = new IPEndPoint(Addr, Port);
            this.Role = Role;
            this.Command_Major = Command_Major;
            this.Command_Minor = Command_Minor;
            this.Status = 0;
        }

    }
}
