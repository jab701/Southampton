using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SDP
{
    public class SDP
    {
        public const uint SDP_BUF_SIZE = 256;
        // SDP Flags
        public const byte SDPF_REPLY = 0x80; // Reply Expected
        public const byte SDPF_xxx_40 = 0x40; // Spare
        public const byte SDPF_SUM = 0x20; // Checksum before routing
        public const byte SDPF_DP2P = 0x10; // Disable P2P check in routing
        public const byte SDPF_DLINK = 0x08; // Disable Lin Check In Routing
        public const byte SDPF_LMASK = 0x07; // Link Bits Mask
        // SDP Commands
        public const ushort CMD_VER = 0;
        public const ushort CMD_RUN = 1;
        public const ushort CMD_READ = 2;
        public const ushort CMD_WRITE = 3;
        public const ushort CMD_APLX = 4;
        public const ushort CMD_LED = 5;
        public const ushort CMD_xxx_6 = 6;
        public const ushort CMD_xxx_7 = 7;
        public const ushort CMD_AP_MAX = 7;
        public const ushort CMD_LINK_PROBE = 8;
        public const ushort CMD_LINK_READ = 9;
        public const ushort CMD_LINK_WRITE = 10;
        public const ushort CMD_xxx_11 = 11;
        public const ushort CMD_NNP = 12;
        public const ushort CMD_P2PC = 13;
        public const ushort CMD_PING = 14;
        public const ushort CMD_FFD = 15;
        public const ushort CMD_AS = 16;
        public const ushort CMD_xxx_17 = 17;
        public const ushort CMD_IPTAG = 18;
        public const ushort CMD_SROM = 19;

        public const ushort CMD_TUBE = 64;

        public const ushort NN_CMD_SIG0 = 0;
        public const ushort NN_CMD_RTRC = 1;
        public const ushort NN_CMD_LTPC = 2;
        public const ushort NN_CMD_SP_3 = 3;
        public const ushort NN_CMD_SIG1 = 4;
        public const ushort NN_CMD_P2PC = 5;
        public const ushort NN_CMD_FFS = 6;
        public const ushort NN_CMD_SP_7 = 7;
        public const ushort NN_CMD_PING = 8;
        public const ushort NN_CMD_P2PB = 9;
        public const ushort NN_CMD_SDP = 10;
        public const ushort NN_CMD_SP_11 = 11;
        public const ushort NN_CMD_FBS = 12;
        public const ushort NN_CMD_FBD = 13;
        public const ushort NN_CMD_FBE = 14;
        public const ushort NN_CMD_FFE = 15;

        public const byte TYPE_BYTE = 0;
        public const byte TYPE_HALF = 1;
        public const byte TYPE_WORD = 2;

        // IPTAG definitions
        public const byte IPTAG_NEW = 0;
        public const byte IPTAG_SET = 1;
        public const byte IPTAG_GET = 2;
        public const byte IPTAG_CLR = 3;
        public const byte IPTAG_AUTO = 4;
        public const byte IPTAG_MAX = IPTAG_AUTO;

        // Return Codes
        public const byte RC_OK = 0x80;	            // Command completed OK
        public const byte RC_LEN = 0x81;	        // Bad packet length
        public const byte RC_SUM = 0x82;	        // Bad checksum
        public const byte RC_CMD = 0x83;	        // Bad/invalid command
        public const byte RC_ARG = 0x84;	        // Invalid arguments
        public const byte RC_PORT = 0x85;	        // Bad port number
        public const byte RC_TIMEOUT = 0x86;	    // Timeout
        public const byte RC_ROUTE = 0x87;	        // No P2P route
        public const byte RC_CPU = 0x88;	        // Bad CPU number
        public const byte RC_DEAD = 0x89;	        // SHM dest dead
        public const byte RC_BUF = 0x8a;	        // No free SHM buffers
        public const byte RC_P2P_NOREPLY = 0x8b;	// No reply to open
        public const byte RC_P2P_REJECT = 0x8c;	    // Open rejected
        public const byte RC_P2P_BUSY = 0x8d;	    // Dest busy
        public const byte RC_P2P_TIMEOUT = 0x8e;	// Dest died?
        public const byte RC_PKT_TX = 0x8f;     	// Pkt Tx failed

        // LED Commands
        public const byte LED_ON = 0x03;
        public const byte LED_OFF = 0x02;
        public const byte LED_INV = 0x01;

        // Boot Settings
        public const uint BLOCKS_SIZE = 256; // 256 Words, 1024 bytes
        public const uint MAX_BLOCKS = 32;   // 32k limit in DTCM
        public const uint BOOT_PROT_VER = 1;
        public const uint BOOT_PORT = 54321;
        public const uint BOOT_DELAY = 1; // Delay between boot commands in milliseconds


        public static string ParseResponseCode(uint Code)
        {
            string Response = "";
            switch (Code)
            {
                case RC_OK:
                    Response = string.Format("Command Ok (0x{0:x2})", RC_OK);
                    break;
                case RC_LEN:
                    Response = string.Format("Bad packet length (0x{0:x2})", Code);
                    break;
                case RC_SUM:
                    Response = string.Format("Bad checksum (0x{0:x2})", Code);
                    break;
                case RC_CMD:
                    Response = string.Format("Bad or invalid command (0x{0:x2})", Code);
                    break;
                case RC_ARG:
                    Response = string.Format("Invalid arguments (0x{0:x2})", Code);
                    break;
                case RC_PORT:
                    Response = string.Format("Bad port number (0x{0:x2})", Code);
                    break;
                case RC_TIMEOUT:
                    Response = string.Format("Timeout (0x{0:x2})", Code);
                    break;
                case RC_ROUTE:
                    Response = string.Format("No P2P route (0x{0:x2})", Code);
                    break;
                case RC_CPU:
                    Response = string.Format("Bad CPU number (0x{0:x2})", Code);
                    break;
                case RC_DEAD:
                    Response = string.Format("SHM dest dead (0x{0:x2})", Code);
                    break;
                case RC_BUF:
                    Response = string.Format("No free SHM buffers (0x{0:x2})", Code);
                    break;
                case RC_P2P_NOREPLY:
                    Response = string.Format("No reply to open (0x{0:x2})", Code); ;
                    break;
                case RC_P2P_REJECT:
                    Response = string.Format("Open rejected (0x{0:x2})", Code);
                    break;
                case RC_P2P_BUSY:
                    Response = string.Format("Dest busy (0x{0:x2})", Code);
                    break;
                case RC_P2P_TIMEOUT:
                    Response = string.Format("Dest died? (0x{0:x2})", Code);
                    break;
                case RC_PKT_TX:
                    Response = string.Format("Pkt Tx failed (0x{0:x2})", Code);
                    break;
                default:
                    Response = string.Format("Unrecognized Response Code (0x{0:x2})", Code);
                    break;
            }

            return Response;
        }
    }
}
