#ifndef SERVERPACKETPROCESSTHREAD_H
#define SERVERPACKETPROCESSTHREAD_H

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
#include <wx/msgqueue.h>
#include <wx/socket.h>

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#include "ServerPacketEvent.h"
#include "EventID.h"


class ServerPacketProcessingThread : public wxThread
{
public:
	// Public Functions
	// Default Constructor
	ServerPacketProcessingThread(wxFrame* Parent);

	// Destructor
	~ServerPacketProcessingThread();

	void Initialize(DB_Client *ClientDB, DB_Object *ObjectDB, CartesianVector EnvDim);
	void PostPacket(wxIPV4address Peer, std::vector<unsigned char> Packet);

	// Get Functions
	uint32_t GetStatus();
	std::string GetTestsEchoReply();
	uint32_t GetError();

private:
	// Packet Processing Flow
    int PreProcessNetworkPacket(wxIPV4address Peer, std::vector<unsigned char> Data);
	int ProcessNetworkPacket(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool ProcessUnknownClientPacket(wxIPV4address ClientAddress, std::vector<unsigned char>PacketData);

	void SendPacketToClient(wxIPV4address Address, std::string Payload);
	void SendPacketToAllClients(std::string Payload);
	void SendEventToMain(uint32_t Data1, uint32_t Data2, std::string Text);
	// Private Functions
	// Send Packet Functions
	void SendAck(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2);
	void SendError(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2);	
	void SendError(wxIPV4address ClientAddress, uint32_t Data1, uint32_t Data2);
	void SendDeleteObject(DBRecord_Client ClientRecord, uint32_t ObjectID);
	void SendDeleteObjectToAllClients(uint32_t ObjectID);
	void SendRemoveEatenObj(DBRecord_Client ClientRecord, uint32_t ObjectID, uint32_t ClientID);
	void SendRemoveEatenObjToAllClients(uint32_t ObjectID, uint32_t ClientID);
	void SendClientEnum(DBRecord_Client ClientRecord);
	void SendKillSystemToAllClients(std::string PacketData);
	void SendTestsEchoReply(DBRecord_Client ClientRecord, std::string PacketData);
	void SendTestsEchoReply(wxIPV4address ClientAddress, std::string PacketData);
	// Receive Packet Functions
	bool RecvAck(DBRecord_Client &ClientRecord,  std::vector<unsigned char> PacketData);
	bool RecvError(DBRecord_Client &ClientRecord,  std::vector<unsigned char> PacketData);
	bool RecvConnectionReq(wxIPV4address ClientAddress, std::vector<unsigned char> PacketData);
	bool RecvDisconnectionReq(DBRecord_Client &ClientRecord);
	bool RecvAddObjectReq(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvDeleteObject(DBRecord_Client &ClientRecord);
	bool RecvDeleteObjectAsGod(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvObjForces(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvObjTorque(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvObjColour(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvAddInanimate(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvEatObj(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvKillSystem(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	bool RecvTestsEcho(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData);
	// Thread Main
	virtual wxThread::ExitCode Entry();

private:
	wxFrame *m_Parent;
	std::string m_KillCode;
	CartesianVector m_EnvDim;
	wxDatagramSocket *m_ServerSocket;
	
	DB_Client *m_DB_Client;
	DB_Object *m_DB_Object;

	wxMutex *m_SystemStateVariableMutex;

	// System State Variables
	unsigned m_StatusFlags;
	unsigned m_ErrorFlags;
	bool m_Enumerated;
	uint32_t m_ClientID;
	uint32_t m_ObjectID;
	std::string m_TestsEchoReplyStr;
	CartesianVector m_Env_Dim;

	wxMessageQueue<wxIPV4address> m_AddressMessageQueue;
	wxMessageQueue<std::vector<unsigned char>> m_PacketMessageQueue;	
};


#endif