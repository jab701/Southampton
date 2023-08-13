#ifndef _SDP_DEFS_H
#define _SDP_DEFS_H

#include <vector>
#include <stdint.h>

#define  SDP_BUF_SIZE   256
// SDP Flags
#define  SDPF_REPLY     0x80 // Reply Expected
#define  SDPF_xxx_40    0x40 // Spare
#define  SDPF_SUM		0x20 // Checksum before routing
#define  SDPF_DP2P	    0x10 // Disable P2P check in routing
#define  SDPF_DLINK		0x08 // Disable Lin Check In Routing
#define  SDPF_LMASK     0x07 // Link Bits Mask
// SDP Commands
#define  CMD_VER		 0
#define  CMD_RUN   		 1
#define  CMD_READ   	 2
#define  CMD_WRITE  	 3
#define  CMD_APLX  		 4
#define  CMD_LED  		 5
#define  CMD_xxx_6		 6
#define  CMD_xxx_7		 7
#define  CMD_AP_MAX		 7
#define  CMD_LINK_PROBE  8
#define  CMD_LINK_READ   9
#define  CMD_LINK_WRITE  10
#define  CMD_xxx_11 	 11
#define  CMD_NNP  		 12
#define  CMD_P2PC 		 13
#define  CMD_PING  		 14
#define  CMD_FFD 		 15
#define  CMD_xxx_16 	 16
#define  CMD_xxx_17 	 17
#define  CMD_IPTAG 		 18
#define  CMD_SROM  		 19

#define  CMD_TUBE  		 64

#define  NN_CMD_SIG0      0
#define  NN_CMD_RTRC      1
#define  NN_CMD_LTPC      2
#define  NN_CMD_SP_3      3
#define  NN_CMD_SIG1      4
#define  NN_CMD_P2PC      5
#define  NN_CMD_FFS       6
#define  NN_CMD_SP_7      7
#define  NN_CMD_PING      8
#define  NN_CMD_P2PB      9
#define  NN_CMD_SDP       10
#define  NN_CMD_SP_11     11
#define  NN_CMD_FBS       12
#define  NN_CMD_FBD       13
#define  NN_CMD_FBE       14
#define  NN_CMD_FFE       15

#define  TYPE_BYTE	0
#define  TYPE_HALF  1
#define  TYPE_WORD  2

// IPTAG definitions
#define  IPTAG_NEW		 0
#define  IPTAG_SET		 1
#define  IPTAG_GET		 2
#define  IPTAG_CLR		 3
#define  IPTAG_AUTO	     4
#define  IPTAG_MAX		 IPTAG_AUTO

// Return Codes
#define  RC_OK				0x80	            // Command completed OK
#define  RC_LEN				0x81	        // Bad packet length
#define  RC_SUM				0x82	        // Bad checksum
#define  RC_CMD				0x83	        // Bad/invalid command
#define  RC_ARG				0x84	        // Invalid arguments
#define  RC_PORT			0x85	        // Bad port number
#define  RC_TIMEOUT			0x86	    // Timeout
#define  RC_ROUTE			0x87	        // No P2P route
#define  RC_CPU				0x88	        // Bad CPU number
#define  RC_DEAD			0x89	        // SHM dest dead
#define  RC_BUF				0x8a	        // No free SHM buffers
#define  RC_P2P_NOREPLY		0x8b	// No reply to open
#define  RC_P2P_REJECT		0x8c	    // Open rejected
#define  RC_P2P_BUSY		0x8d	    // Dest busy
#define  RC_P2P_TIMEOUT		0x8e	// Dest died?
#define  RC_PKT_TX			0x8f     	// Pkt Tx failed

// LED Commands
#define  LED_ON     0x03
#define  LED_OFF    0x02
#define  LED_INV    0x01

// SDP Header
class sdp_hdr_t
{
public:
	sdp_hdr_t()
	{
		this->flags = 0;
		this->tag = 0;
		this->dest_cpu_port = 0;
		this->srce_cpu_port = 0;
		this->dest_addr = 0;
		this->srce_addr = 0;
	}
	~sdp_hdr_t()
	{
		this->flags = 0;
		this->tag = 0;
		this->dest_cpu_port = 0;
		this->srce_cpu_port = 0;
		this->dest_addr = 0;
		this->srce_addr = 0;
	}
	unsigned char get_dest_cpu()
	{
		return (unsigned char)(this->dest_cpu_port & 0x1F);
	}
	unsigned char get_dest_port()
	{
		return (unsigned char)(this->dest_cpu_port >> 5);
	}
	unsigned char get_srce_cpu()
	{
		return (unsigned char)(this->srce_cpu_port & 0x1F);
	}
	unsigned char get_srce_port()
	{
		return (unsigned char)(this->srce_cpu_port >> 5);
	}
	void set_dest_cpu(unsigned char cpu)
	{
		this->dest_cpu_port &= (unsigned char)(~0x1F);
		this->dest_cpu_port |= (cpu & 0x1F);
	}
	void set_dest_port(unsigned char port)
	{
		port = (unsigned char)(port << 5);
		this->dest_cpu_port &= (unsigned char)(~0xE0);
		this->dest_cpu_port |= port;
	}
	void set_dest_chip(unsigned char chipx, unsigned char chipy)
	{
		chipx = (chipx & 0x000000ff); // Knock out everything but last byte
		chipy = (chipy & 0x000000ff); // Knock out everything but last byte
		this->dest_addr = (chipx << 8) + chipy;
	}
	void set_srce_cpu(unsigned char cpu)
	{
		this->srce_cpu_port &= (unsigned char)(~0x1F);
		this->srce_cpu_port |= (cpu & 0x1F);
	}
	void set_srce_port(unsigned char port)
	{
		port = (unsigned char)(port << 5);
		this->srce_cpu_port &= (unsigned char)(~0xE0);
		this->srce_cpu_port |= port;
	}
	void set_srce_chip(unsigned char chipx, unsigned char chipy)
	{
		chipx = (chipx & 0x000000ff); // Knock out everything but last byte
		chipy = (chipy & 0x000000ff); // Knock out everything but last byte
		this->srce_addr = (chipx << 8) + chipy;
	}
	void pack(std::vector<unsigned char> bytes)
	{
		if (bytes.size() != 8)
		{
			return;
		}

		this->flags = bytes[0];
		this->tag   = bytes[1];
		this->dest_cpu_port = bytes[2];
		this->srce_cpu_port = bytes[3];
		this->dest_addr = (uint16_t)((bytes[5] << 8) | bytes[4]);
		this->srce_addr = (uint16_t)((bytes[7] << 8) | bytes[6]);
	}
	std::vector<unsigned char> unpack()
	{
		std::vector<unsigned char> Data;

		Data.push_back(this->flags);
		Data.push_back(this->tag);
		Data.push_back(this->dest_cpu_port);
		Data.push_back(this->srce_cpu_port);
		Data.push_back((unsigned char)this->dest_addr); // lower byte
		Data.push_back((unsigned char)(this->dest_addr >> 8)); // upper byte
		Data.push_back((unsigned char)this->srce_addr); // lower byte
		Data.push_back((unsigned char)(this->srce_addr >> 8)); // upper byte

		return Data;
	}
	unsigned Length()
	{
		return 8;
	}
public:
	unsigned char flags;
	unsigned char tag;
	uint16_t dest_addr;
	uint16_t srce_addr;
private:
	unsigned char dest_cpu_port;
	unsigned char srce_cpu_port;
};
// SDP Command
class sdp_cmd_t
{
public:
	sdp_cmd_t()
	{
		this->cmd_rc = 0;
		this->seq = 0;
		this->arg1 = 0;
		this->arg2 = 0;
		this->arg3 = 0;
		this->data.clear();
	}
	~sdp_cmd_t()
	{
		this->cmd_rc = 0;
		this->seq = 0;
		this->arg1 = 0;
		this->arg2 = 0;
		this->arg3 = 0;
		this->data.clear();
	}
	void pack(std::vector<unsigned char> bytes)
	{
		if (bytes.size() >= 4)
		{
			this->cmd_rc = (uint16_t)((bytes[1] << 8) | bytes[0]);
			this->seq = (uint16_t)((bytes[3] << 8) | bytes[2]);
		}

		if (bytes.size() >= 8)
		{
			this->arg1 = (unsigned int)((bytes[7] << 24) | (bytes[6] << 16) | (bytes[5] << 8) | bytes[4]);
		}
		else
		{
			this->arg1 = 0;
		}

		if (bytes.size() >= 12)
		{
			this->arg2 = (unsigned int)((bytes[11] << 24) | (bytes[10] << 16) | (bytes[9] << 8) | bytes[8]);
		}
		else
		{
			this->arg2 = 0;
		}

		if (bytes.size() >= 16)
		{
			this->arg3 = (unsigned int)((bytes[15] << 24) | (bytes[14] << 16) | (bytes[13] << 8) | bytes[12]);
		}
		else
		{
			this->arg3 = 0;
		}

		if (bytes.size() <= 16)
		{
			this->data.clear();
		}
		else
		{
			unsigned Size = bytes.size() - 16;

			if (Size > SDP_BUF_SIZE)
			{
				Size = SDP_BUF_SIZE;
				this->data.resize(SDP_BUF_SIZE);
			}

			for (unsigned i = 0; i < Size; i++)
			{
				this->data.push_back(bytes[16 + i]);
			}
		}

		return;
	}
	std::vector<unsigned char> unpack()
	{
		if (this->data.size() > SDP_BUF_SIZE)
		{
			this->data.resize(SDP_BUF_SIZE);
		}

		std::vector<unsigned char> bytes;

		bytes.push_back((unsigned char)this->cmd_rc);
		bytes.push_back((unsigned char)(this->cmd_rc >> 8));

		bytes.push_back((unsigned char)this->seq);
		bytes.push_back((unsigned char)(this->seq >> 8));

		bytes.push_back((unsigned char)this->arg1);
		bytes.push_back((unsigned char)(this->arg1 >> 8));
		bytes.push_back((unsigned char)(this->arg1 >> 16));
		bytes.push_back((unsigned char)(this->arg1 >> 24));

		bytes.push_back((unsigned char)this->arg2);
		bytes.push_back((unsigned char)(this->arg2 >> 8));
		bytes.push_back((unsigned char)(this->arg2 >> 16));
		bytes.push_back((unsigned char)(this->arg2 >> 24));

		bytes.push_back((unsigned char)this->arg3);
		bytes.push_back((unsigned char)(this->arg3 >> 8));
		bytes.push_back((unsigned char)(this->arg3 >> 16));
		bytes.push_back((unsigned char)(this->arg3 >> 24));

		if (this->data.size() != 0)
		{
			bytes.insert(bytes.end(),data.begin(),data.end());
		}

		return bytes;
	}
	std::vector<unsigned char> data_inc_args()
	{
		if (this->data.size() > SDP_BUF_SIZE)
		{
			this->data.resize(SDP_BUF_SIZE);
		}

		std::vector<unsigned char> bytes;

		bytes.push_back((unsigned char)this->arg1);
		bytes.push_back((unsigned char)(this->arg1 >> 8));
		bytes.push_back((unsigned char)(this->arg1 >> 16));
		bytes.push_back((unsigned char)(this->arg1 >> 24));

		bytes.push_back((unsigned char)this->arg2);
		bytes.push_back((unsigned char)(this->arg2 >> 8));
		bytes.push_back((unsigned char)(this->arg2 >> 16));
		bytes.push_back((unsigned char)(this->arg2 >> 24));

		bytes.push_back((unsigned char)this->arg3);
		bytes.push_back((unsigned char)(this->arg3 >> 8));
		bytes.push_back((unsigned char)(this->arg3 >> 16));
		bytes.push_back((unsigned char)(this->arg3 >> 24));

		if (this->data.size() != 0)
		{
			bytes.insert(bytes.end(),data.begin(),data.end());
		}

		return bytes;
	}
	unsigned Length()
	{
		return 16 + data.size();
	}
public:
	uint16_t cmd_rc; // Command/Return COde
	uint16_t seq; // Sequence Number
	uint32_t arg1; // Argument 1
	uint32_t arg2; // Argument 2
	uint32_t arg3; // Argument 3
	std::vector<unsigned char> data;
};
// iptag returned data structure
class iptag_t
{
public:
	iptag_t()
	{
		this->IP = new unsigned char[4];
		this->MAC = new unsigned char[6];
	}
	~iptag_t()
	{
		delete [] this->IP;
		delete [] this->MAC;

		this->IP = NULL;
		this->MAC = NULL;
	}
	void pack(std::vector<unsigned char> bytes)
	{
		if (bytes.size() != 16)
		{
			return;
		}

		this->IP[0] = bytes[0];
		this->IP[1] = bytes[1];
		this->IP[2] = bytes[2];
		this->IP[3] = bytes[3];

		this->MAC[0] = bytes[4];
		this->MAC[1] = bytes[5];
		this->MAC[2] = bytes[6];
		this->MAC[3] = bytes[7];
		this->MAC[4] = bytes[8];
		this->MAC[5] = bytes[9];

		this->Port	  = (uint16_t)((bytes[11] << 8) | bytes[10]);
		this->Timeout = (uint16_t)((bytes[13] << 8) | bytes[12]);
		this->Flags   = (uint16_t)((bytes[15] << 8) | bytes[14]);
	}
public:
	unsigned char* IP;
	unsigned char* MAC;
	uint16_t Port;
	uint16_t Timeout;
	uint16_t Flags;
};
// sver returned data structure
class sver_t
{
public:
	sver_t()
	{
		this->v_cpu = 0;
		this->p_cpu = 0;
		this->chip_y = 0;
		this->chip_x = 0;
		this->size = 0;
		this->ver_num = 0;
		this->time = 0;
		this->ver_string.clear();
	}
	~sver_t()
	{
		this->v_cpu = 0;
		this->p_cpu = 0;
		this->chip_y = 0;
		this->chip_x = 0;
		this->size = 0;
		this->ver_num = 0;
		this->time = 0;
		this->ver_string.clear();
	}
	void pack(std::vector<unsigned char> bytes)
	{
		if (bytes.size() < 12)
		{
			return;
		}

		this->v_cpu  = bytes[0];
		this->p_cpu	 = bytes[1];
		this->chip_y = bytes[2];
		this->chip_x = bytes[3];

		this->size    = (uint16_t)((bytes[5] << 8) | bytes[4]);
		this->ver_num = (uint16_t)((bytes[7] << 8) | bytes[6]);

		this->time = (unsigned int)((bytes[11] << 24) | (bytes[10] << 16) | (bytes[9] << 8) | bytes[8]);

		if ((bytes.size() - 12) > 0)
		{
			unsigned String_Length = (unsigned int)(bytes.size() - 12);

			char *string = new char[String_Length];

			for (unsigned i = 0; i < String_Length; i++)
			{
				this->ver_string += bytes[(12 + i)];
			}
		}
		else
		{
			this->ver_string.clear();
		}
	}
public:
	unsigned char v_cpu;
	unsigned char p_cpu;
	unsigned char chip_y;
	unsigned char chip_x;
	uint16_t size;
	uint16_t ver_num;
	unsigned int time;
	std::string ver_string;
};

#endif
