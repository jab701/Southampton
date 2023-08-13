#ifndef NETWORKSTACKSERVER_H
#define NETWORKSTACKSERVER_H


#include <wx/wx.h>
#include <wx/socket.h>
#include "DBRecord_Client.h"
#include "DBRecord_Object.h"
#include "DB_Client.h"
#include "DB_Object.h"
#include "EventID.h"
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include <stdint.h>

#include <vector>

class NetworkStackServer
{
public:
	// Default Constructor
	NetworkStackServer();
	// Destructor
	~NetworkStackServer();
	wxDatagramSocket *GetSocket()
	{
		return this->m_ServerSocket;
	}
	void SetKillCode(std::string KillCode);
	bool SetDbConnection(DB_Client *ClientDB, DB_Object *ObjectDB);
	bool StartNetworkSocket(wxIPV4address ServerAddress, wxEvtHandler *EventHandler, EVENTS EVENT_ID, CartesianVector EnvDim);
	bool StopNetworkSocket();
	// Get Functions
	// Checking Functions
	bool IsOK();
	// Prepare Packet Functions
	bool PrepareBulkUpdatePacket(std::string *PacketData, uint32_t NumObjects, DBRecord_Object ObjectRecords[]);
	// Packet Processing Flow
    int PreProcessNetworkPacket(wxIPV4address Peer, std::vector<unsigned char> Data);
	int ProcessNetworkPacket(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool ProcessUnknownClientPacket(wxIPV4address ClientAddress, std::vector<unsigned char>PacketData);
	// Function to send a data string 
	bool SendString(wxIPV4address ClientAddress, std::string PacketData);
	bool SendString(DBRecord_Client ClientRecord, std::string PacketData);
	bool SendStringToMultipleClients(std::vector<DBRecord_Client> ClientRecords, std::string PacketData);
	bool SendStringToAllClients(std::string PacketData);
	bool SendMultipleStringsToMultipleClients(std::vector<wxIPV4address> Addresses,std::vector<std::string> PacketData);
	// Send packet Functions
	bool SendAck(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2);
	bool SendError(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2);
	bool SendError(wxIPV4address ClientAddress, uint32_t Data1, uint32_t Data2);
	bool SendForceDisconnect(DBRecord_Client ClientRecord);
    bool SendBulkForceDisconnect(std::vector<DBRecord_Client> ClientRecords);
	bool SendClientEnum(DBRecord_Client ClientRecord);
	bool SendUpdateObjectPosition(DBRecord_Client ClientRecord, uint16_t ObjectID, double x, double y, double z, double Theta, double Phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags);
	bool SendUpdateObjectPosition(DBRecord_Client ClientRecord, DBRecord_Object ObjectRecord);
	bool SendBulkUpdateObjects(std::vector<DBRecord_Client> ClientRecords,  std::vector<DBRecord_Object> ObjectRecords);
	bool SendDeleteObject(DBRecord_Client ClientRecord, uint32_t ObjectID);
	bool SendDeleteObjectToAllClients(uint32_t ObjectID);
	bool SendRemoveEatenObj(DBRecord_Client ClientRecord, uint32_t ObjectID);
	bool SendRemoveEatenObjToAllClients(uint32_t ObjectID);
	bool SendKillSystemToAllClients(std::string PacketData);
	bool SendTestsEchoReply(DBRecord_Client ClientRecord, std::string PacketData);
	bool SendTestsEchoReply(wxIPV4address ClientAddress, std::string PacketData);
	bool SendTestsEcho(DBRecord_Client ClientRecord, std::string PacketData);
	// Receive Packet Functions
	bool RecvAck(DBRecord_Client &ClientRecord,  std::vector<unsigned char> PacketData);
	bool RecvError(DBRecord_Client &ClientRecord,  std::vector<unsigned char> PacketData);
	bool RecvConnectionReq(wxIPV4address ClientAddress, std::vector<unsigned char> PacketData);
	bool RecvDisconnectionReq(DBRecord_Client &ClientRecord);
	bool RecvAddObjectReq(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvDeleteObject(DBRecord_Client &ClientRecord);
	bool RecvObjForces(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvObjTorque(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvObjColour(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvAddInanimate(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvEatObj(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvKillSystem(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvTestsEcho(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	void DisplayNetworkSocketError(wxDatagramSocket *socket);
private:
	std::string m_KillCode;
	CartesianVector m_EnvDim;
	wxDatagramSocket *m_ServerSocket;
	
	DB_Client *m_DB_Client;
	DB_Object *m_DB_Object;
};

#endif