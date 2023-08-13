#ifndef NETWORKSTACKCLIENT_H
#define NETWORKSTACKCLIENT_H

#include <wx/wx.h>
#include <wx/socket.h>
#include <stdint.h>
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"

#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/CartesianVector.h"

#define COMMANDSETMAJOR 0
#define COMMANDSETMINOR 0

class NetworkStackClient
{
public:
	// Default Constructor
	NetworkStackClient();

	// Destructor
	~NetworkStackClient();

	// Control Functions
	bool StartNetworkSocket(wxIPV4address ServerAddress, wxFrame *EventHandler, int SOCKET_EVENT_ID, DB_ClientObject *ObjectDb);
	bool StopNetworkSocket();
	wxDatagramSocket *GetSocket()
	{
		return this->m_ClientSocket;
	}

	// Set Functions

	// Checking Functions
	bool IsOK();

	// Function to send a data string 
	bool SendString(std::string PacketData);

	// Send packet Functions
	bool SendAck(uint32_t Data1, uint32_t Data2);
	bool SendError(uint32_t Data1, uint32_t Data2);
	bool SendConnectionRequest(unsigned char ROLE);
	bool SendDisconnectionRequest();
	bool SendAddObjectRequest(double InitialEnergy);
	bool SendAddObjectRequest(double InitialEnergy, CartesianVector Position);
	bool SendDeleteObject(uint32_t ObjectID);
	bool SendObjectForces(uint32_t ForceObjId, CartesianVector Force);
	bool SendObjectTorque(uint32_t ForceObjId, double ThetaTorque, double PhiTorque);
	bool SendObjectColour(uint32_t ObjectID, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness);
	bool SendAddInanimateObj(double X, double Y, double Z, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, float Energy, uint16_t Flags);
	bool SendEatObject(uint32_t ObjectID);
	bool SendKillSystem(std::string KillCode);
	bool SendTestsEchoReply(std::string Data);
	bool SendTestsEcho(std::string Data);

	// Display Error Functions
	void DisplayNetworkSocketError(wxDatagramSocket *socket);

private:
	wxIPV4address m_ServerAddress;

	wxDatagramSocket *m_ClientSocket;

};

#endif