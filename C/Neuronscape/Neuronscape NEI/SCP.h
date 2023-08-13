#ifndef _SCP_H
#define _SCP_H

// Standard Headers
#include <vector>
#include <stdint.h>

// WX Headers
#include <wx/wx.h>
#include <wx/socket.h>

// Neuronscape Headers
#include "SDP_defs.h"

// This class contains constant definitions for the SDP Packet Type
class SCP
{
public:
	SCP(wxDatagramSocket *Socket);
	~SCP();

	void GetChip(unsigned char &ChipX, unsigned char &ChipY, unsigned char &CPU);
	void SetChip(unsigned char ChipX, unsigned char ChipY, unsigned char CPU);

	uint16_t aplx(wxIPV4address RemoteAddress, unsigned int Address);

	uint16_t iptag_clr(wxIPV4address RemoteAddress, unsigned int tag = 0);
	uint16_t iptag_set(wxIPV4address RemoteAddress, std::vector<unsigned char> IP, unsigned int port, unsigned int tag = 0);
	uint16_t iptag_auto(wxIPV4address RemoteAddress, unsigned int port);

	uint16_t led(wxIPV4address RemoteAddress, unsigned char led, unsigned char function);

	uint16_t mem_dump(wxIPV4address RemoteAddress, unsigned int Address, unsigned int Length, std::vector<unsigned char>& Data);
	uint16_t mem_load(wxIPV4address RemoteAddress, unsigned int Address, std::vector<unsigned char> Data);
	uint16_t mem_read(wxIPV4address RemoteAddress, unsigned int Address, unsigned int Length, std::vector<unsigned char>& Data);
	uint16_t mem_write(wxIPV4address RemoteAddress, unsigned int Address, std::vector<unsigned char> Data);

	uint16_t p2pc(wxIPV4address RemoteAddress, unsigned char Dim_X, unsigned char Dim_Y);
	uint16_t sver(wxIPV4address RemoteAddress, sver_t& version_data);

	bool send(wxDatagramSocket& Socket, wxIPV4address RemoteAddress, sdp_hdr_t Header, sdp_cmd_t Command);
	bool receive(wxDatagramSocket& Socket, sdp_hdr_t& ReplyHeader, sdp_cmd_t& ReplyCommand);

private:
	unsigned char Next_ID()
	{
		this->NN_ID = (unsigned char)(this->NN_ID + 1);

		if (this->NN_ID > 127)
		{
			this->NN_ID = 1;
		}

		return (unsigned char)(2 * this->NN_ID);
	}

	wxDatagramSocket *Socket;
	unsigned char ChipX;
	unsigned char ChipY;
	unsigned char CPU;
	unsigned char NN_ID;


};
#endif