#include "SCP.h"

SCP::SCP(wxDatagramSocket *Socket)
{
	this->Socket = Socket;

	this->ChipX = 0;
	this->ChipY = 0;
	this->CPU = 0;
	this->NN_ID = 1;
}
SCP::~SCP()
{
	this->Socket = NULL;
}
void SCP::GetChip(unsigned char &ChipX, unsigned char &ChipY, unsigned char &CPU)
{
	ChipX = this->ChipX;
	ChipY = this->ChipY;
	CPU	  = this->CPU;
}
void SCP::SetChip(unsigned char ChipX, unsigned char ChipY, unsigned char CPU)
{
	this->ChipX = ChipX;
	this->ChipY = ChipY;
	this->CPU = CPU;
}
uint16_t SCP::aplx(wxIPV4address RemoteAddress, unsigned int Address)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(this->CPU);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = (uint16_t)((this->ChipX << 8) + this->ChipY);
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_APLX;
	Command.seq = 0;
	Command.arg1 = (unsigned int)Address;
	Command.arg2 = 0;
	Command.arg3 = 0;

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::iptag_clr(wxIPV4address RemoteAddress, unsigned int tag)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(0);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = 0;
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_IPTAG;
	Command.seq = 0;
	Command.arg1 = (IPTAG_CLR << 16) + (tag & 0xF);
	Command.arg2 = 0;
	Command.arg3 = 0;

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::iptag_set(wxIPV4address RemoteAddress, std::vector<unsigned char> IP, unsigned int port, unsigned int tag)
{
	if (IP.size() != 4)
	{
		return RC_ARG;
	}

	if (tag > 3)
	{
		return RC_ARG;
	}

	// Now Set the IPTAG
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(0);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = 0;
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_IPTAG;
	Command.seq = 0;
	Command.arg1 = (IPTAG_SET << 16) + tag;
	Command.arg2 = port;
	Command.arg3 = (IP[3] << 24) + (IP[2] << 16) + (IP[1] << 8) + IP[0];

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::led(wxIPV4address RemoteAddress, unsigned char led, unsigned char function)
{
	// Now Set the LED

	// Check arguements
	if (led > 3)
	{
		return RC_ARG;
	}

	if ((function == 0) || (function > LED_ON))
	{
		return RC_ARG;
	}

	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(this->CPU);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = (uint16_t)((this->ChipX << 8) + this->ChipY);
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_LED;
	Command.seq = 0;
	Command.arg1 = (unsigned int)(function << (led*2));
	Command.arg2 = 0;
	Command.arg3 = 0;

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::mem_dump(wxIPV4address RemoteAddress, unsigned int Address, unsigned int Length, std::vector<unsigned char>& Data)
{
	unsigned int AddressInc = Address;

	unsigned int NumberPackets = Length / 256;
	unsigned int Remainder = Length % 256;

	if (Remainder != 0)
	{
		NumberPackets++;
	}

	Data.clear();

	uint16_t RC = 0;
	
	for (unsigned i = 0; i < NumberPackets; i++)
	{
		std::vector<unsigned char> DataTemp;
		
		if ((Remainder != 0)&&(i == (NumberPackets - 1)))
		{
			RC = this->mem_read(RemoteAddress,AddressInc,Remainder,DataTemp);
		}
		else
		{
			RC = this->mem_read(RemoteAddress,AddressInc,256,DataTemp);
		}

		Data.insert(Data.end(),DataTemp.begin(),DataTemp.end());

		AddressInc += DataTemp.size();

		if (RC != RC_OK)
		{
			Data.clear();
			break;
		}
	}

	return RC;
}
uint16_t SCP::mem_load(wxIPV4address RemoteAddress, unsigned int Address, std::vector<unsigned char> Data)
{
	unsigned int AddressInc = Address;

	unsigned int Length = Data.size();

	unsigned int NumberPackets = Length / 256;
	unsigned int Remainder = Length % 256;

	if (Remainder != 0)
	{
		NumberPackets++;
	}

	Data.clear();

	uint16_t RC = 0;

	for (unsigned i = 0; i < NumberPackets; i++)
	{
		std::vector<unsigned char> DataTemp;
		DataTemp.clear();

		if ((Remainder != 0)&&(i == (NumberPackets - 1)))
		{
			DataTemp.insert(DataTemp.end(),(Data.begin() + (i*256)), (Data.begin() + (i*256) + Remainder));
		}
		else
		{
			DataTemp.insert(DataTemp.end(),(Data.begin() + (i*256)), (Data.begin() + (i*256) + 256));
		}

		RC = this->mem_write(RemoteAddress,AddressInc,DataTemp);

		if (RC != RC_OK)
		{
			Data.clear();
			break;
		}
		
		AddressInc += DataTemp.size();
	}
	return RC;
}
uint16_t SCP::mem_read(wxIPV4address RemoteAddress, unsigned int Address, unsigned int Length, std::vector<unsigned char>& Data)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	if (Length > 256)
	{
		return RC_ARG;
	}

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(this->CPU);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = (uint16_t)((this->ChipX << 8) + this->ChipY);
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_READ;
	Command.seq = 0;
	Command.arg1 = Address;
	Command.arg2 = Length;
	Command.arg3 = TYPE_BYTE;
	Command.data.clear();

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	if (Command.cmd_rc == RC_OK)
	{
		Data = Command.data_inc_args();
	}

	return Command.cmd_rc;
}
uint16_t SCP::mem_write(wxIPV4address RemoteAddress, unsigned int Address, std::vector<unsigned char> Data)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	if (Data.size() > 256)
	{
		return RC_ARG;
	}

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(this->CPU);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = (uint16_t)((this->ChipX << 8) + this->ChipY);
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_WRITE;
	Command.seq = 0;
	Command.arg1 = Address;
	Command.arg2 = Data.size();
	Command.arg3 = TYPE_BYTE;
	Command.data = Data;

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::p2pc(wxIPV4address RemoteAddress, unsigned char Dim_X, unsigned char Dim_Y)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	unsigned char ID = this->Next_ID();

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(this->CPU);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = (uint16_t)((this->ChipX << 8) + this->ChipY);
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_P2PC;
	Command.seq = 0;
	Command.arg1 = (unsigned int)((0x00 << 24) + (0x3e << 16) + (0x00 << 8) + ID);
	Command.arg2 = (unsigned int)((Dim_X << 24) + (Dim_Y << 16) + (0x00 << 8) + 0x00);
	Command.arg3 = (unsigned int)((0x00 << 24) + (0x00 << 16) + (0x3f << 8) + 0xf8);

	send(*this->Socket, RemoteAddress, Header, Command);

	receive(*this->Socket, Header, Command);

	return Command.cmd_rc;
}
uint16_t SCP::sver(wxIPV4address RemoteAddress, sver_t& version_data)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = SDPF_REPLY | SDPF_LMASK;
	Header.tag = 255;
	Header.set_dest_cpu(0);
	Header.set_dest_port(0);
	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.dest_addr = 0;
	Header.srce_addr = 0;

	Command.cmd_rc = CMD_VER;
	Command.seq = 0;
	Command.arg1 = 0;
	Command.arg2 = 0;
	Command.arg3 = 0;

	send(*this->Socket, RemoteAddress, Header, Command);

	if (!receive(*this->Socket, Header, Command))
	{
		return RC_TIMEOUT;
	}

	if (Command.cmd_rc == RC_OK)
	{
		std::vector<unsigned char>::const_iterator Start = Command.data.begin() + 4;
		std::vector<unsigned char>::const_iterator End   = Command.data.end();
		std::vector<unsigned char> Temp(Start,End);
		version_data.pack(Temp);
	}

	return Command.cmd_rc;
}
// Private Functions
bool SCP::send(wxDatagramSocket& Socket, wxIPV4address RemoteAddress, sdp_hdr_t Header, sdp_cmd_t Command)
{
	std::vector<unsigned char> HeaderBytes = Header.unpack();
	std::vector<unsigned char> CommandBytes = Command.unpack();

	unsigned PacketLength = HeaderBytes.size() + CommandBytes.size() + 2;
	unsigned char* Packet = new unsigned char[PacketLength];
	// Pad bytes
	Packet[0] = 0;
	Packet[1] = 0;


	for (unsigned i = 0; i < HeaderBytes.size(); i++)
	{
		Packet[2 + i] = HeaderBytes[i];
	}

	unsigned BaseAddress = 2 + HeaderBytes.size();

	for (unsigned i = 0; i < CommandBytes.size(); i++)
	{
		Packet[BaseAddress + i] = CommandBytes[i];
	}

	Socket.SendTo(RemoteAddress, Packet, PacketLength);

	delete [] Packet;
	return true;
}
bool SCP::receive(wxDatagramSocket& Socket, sdp_hdr_t& ReplyHeader, sdp_cmd_t& ReplyCommand)
{
	// Make a buffer big enough to hold whatever might be returning
	// sdp_header = 8 bytes
	// sdt_command = max size = 16 + SDP_BUF_SIZE

	unsigned char RawData[8 + 16 + SDP_BUF_SIZE];
	
	if (!Socket.WaitForRead(0,2000))
	{
		return false;
	}

	Socket.Read(RawData,(8 + 16 + SDP_BUF_SIZE));

	unsigned Count = Socket.LastCount();

	if (Count < (8 + 4))
	{
		return false;
	}

	std::vector<unsigned char> HeaderBytes(RawData, RawData + 7);

	std::vector<unsigned char> CommandBytes(RawData +10, RawData + (Count - 1));

	ReplyHeader.pack(HeaderBytes);
	ReplyCommand.pack(CommandBytes);
	return true;
}
