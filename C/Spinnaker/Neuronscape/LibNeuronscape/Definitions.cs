using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Neuronscape
{
    public class Versions
    {
        public const string Server = "1.0.0.0";
    }
    public class Constants
    {
        public const double PI = 3.1415926535897932384626433832795;
        public const double mu_static = 1.0;// Dry rubber and concrete -- wikipedia
        public const double mu_kinetic = 1.0;
        public const double phystimestep = 10e-3;
        public const UInt16 MaxPlacementAttempts = 10;
        public const double Mass = 1.0; // equiv to one kilo!
        public const double Radius = 10.0;
        public const double EatingRange = 5.0;

        public const Int32 NetworkTimeout = 5000;

        public const UInt16 MAX_PACKET_LENGTH = 1000;
        public const UInt16 UPDATE_OBJ_LENGTH = 58;
        public const UInt16 MAX_OBJ_BULK_PKT = (MAX_PACKET_LENGTH / UPDATE_OBJ_LENGTH);
    }

    public class PacketTypes
    {
        public const UInt16 PKT_ACK = 0x0000;
        public const UInt16 PKT_ERROR = 0x0001;
        public const UInt16 PKT_CONNECTION_REQ = 0x0002;
        public const UInt16 PKT_DISCONNECTION_REQ = 0x0003;
        public const UInt16 PKT_FORCEDISCONNECT = 0x0004;
        public const UInt16 PKT_CLIENT_ENUMERATE = 0x0005;
        public const UInt16 PKT_REQ_ADD_OBJ = 0x0006;
        // UPDATE_OBJ IS DEPRECATED
        public const UInt16 PKT_UPDATE_OBJ = 0x0007;
        public const UInt16 PKT_BULK_UPDATE_OBJ = 0x0008;
        public const UInt16 PKT_DELETE_OBJ = 0x0009;
        public const UInt16 PKT_FORCES_OBJ = 0x000A;
        public const UInt16 PKT_TORQUE_OBJ = 0x000B;
        // ENERGYDELTA IS DEPRECATED
        public const UInt16 PKT_ENERGYDELTA = 0x000C;
        public const UInt16 PKT_COLOUR_OBJ = 0x000D;
        public const UInt16 PKT_ADDINANIMATE_OBJ = 0x000E;
        public const UInt16 PKT_EAT_OBJ = 0x000F;
        public const UInt16 PKT_REMOVE_EATEN_OBJ = 0x0010;
        public const UInt16 PKT_KILL_SYSTEM = 0x0011;

        public const UInt16 PKT_TEST_ECHO_REPLY = 0xFFFE;
        public const UInt16 PKT_TEST_ECHO = 0xFFFF;
    }

    public class PacketErrors
    {
        // Error Codes 0 - 63 are for system errors
        public const UInt32 UNDEF = 0;
        public const UInt32 INVALID = 1;
        public const UInt32 DEPRICATED = 2;
        public const UInt32 LENGTH = 3;
        public const UInt32 SERVERBUSY = 4;
        public const UInt32 SERVERDB = 5;
        public const UInt32 SERVERDBVERIFY = 6;
        public const UInt32 SERVERFULL = 7;

        // Error Codes >= 64 for all other errors
        public const UInt32 INVALIDROLE = 64;
        public const UInt32 SERVERROLE = 65;
        public const UInt32 COMMANDSET = 66;
        public const UInt32 NOTSERVER = 67;
        public const UInt32 NOTNEI = 68;
        public const UInt32 NOTINTER = 69;
        public const UInt32 NOTCNTRL = 70;
        public const UInt32 NOTNEIORINT = 71;
        public const UInt32 OWNSOBJ = 72;
        public const UInt32 NOTOWNOBJ = 73;
        public const UInt32 OBJNOTEXIST = 74;
        public const UInt32 BADPASS = 75;
        public const UInt32 KILLDIS = 76;
    }

    public class Roles
    {
        public const byte UNDEF  = 0x00;
        public const byte SERVER = 0x01;
        public const byte VIEWER = 0x02;
        public const byte NEUENV = 0x03;
        public const byte CONTRL = 0x04;
    }

    public class ServerDefinitions
    {
        public const double Defaults_EnvX = 1000.0;
        public const double Defaults_EnvY = 1000.0;
        public const double Defaults_EnvZ = 1000.0;
        public const double Defaults_Gravity = 9.8;
        public const UInt32 Defaults_IntegrationTime = 17;
        public const UInt16 Defaults_Port = 12000;
    }

    public class ObjectFlags
    {
        public const UInt16 OBJFLAG_FIXED = 0x0001;
        public const UInt16 OBJFLAG_EDIBLE = 0x0002;
        public const UInt16 OBJFLAG_NOCOLLIDE = 0x0004;
        public const UInt16 OBJFLAG_INANIMATE = 0x0008;
        public const UInt16 OBJFLAG_0010 = 0x0010;
        public const UInt16 OBJFLAG_0020 = 0x0020;
        public const UInt16 OBJFLAG_0040 = 0x0040;
        public const UInt16 OBJFLAG_0080 = 0x0080;
        public const UInt16 OBJFLAG_0100 = 0x0100;
        public const UInt16 OBJFLAG_0200 = 0x0200;
        public const UInt16 OBJFLAG_0400 = 0x0400;
        public const UInt16 OBJFLAG_0800 = 0x0800;
        public const UInt16 OBJFLAG_1000 = 0x1000;
        public const UInt16 OBJFLAG_2000 = 0x2000;
        public const UInt16 OBJFLAG_4000 = 0x4000;
        public const UInt16 OBJFLAG_8000 = 0x8000;
    }

    public class ClientStatus
    {
        // Client Status
        public const UInt16 OK = 0x0000;
        public const UInt16 ENUM = 0x0001;
        public const UInt16 INIT = 0x0002;
        public const UInt16 CONNECTED = 0x0003;
        public const UInt16 DISCONNECTED = 0x0004;
        public const UInt16 DISCONNECT_FORCED = 0x0005;
        public const UInt16 OBJECT_DB_DIRTY = 0x0006;
        public const UInt16 ASSIGNED_OBJECT = 0x0007;
        public const UInt16 ASSIGNED_OBJECT_REMOVED = 0x0008;
        public const UInt16 TESTS_ECHO_REPLY = 0x0009;
    }
}
