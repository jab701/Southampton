#ifndef DBRECORD_CLIENT_H
#define DBRECORD_CLIENT_H

#include <wx/wx.h>
#include <wx/socket.h>

#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"
#include <numeric>
#include <stdint.h>

class DBRecord_Client
{
public: 
	DBRecord_Client();
	DBRecord_Client(uint32_t ID, wxIPV4address Addr, unsigned char Role, uint16_t Command_Ver_Major, uint16_t Command_Ver_Minor, uint16_t Status);
	~DBRecord_Client();

	uint32_t ID;
	wxIPV4address Addr;
	unsigned char Role;
	uint16_t Command_Ver_Major;
	uint16_t Command_Ver_Minor;
	uint16_t Status;
};

#endif