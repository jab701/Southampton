#ifndef CLIENTPACKETPROCESSTHREAD_H
#define CLIENTPACKETPROCESSTHREAD_H

#include <wx/wx.h>
#include <stdint.h>
#include <wx/msgqueue.h>
#include <wx/socket.h>

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#ifdef NEURONSCAPE_NEI
#include "../Neuronscape NEI/EventID.h"
#elif NEURONSCAPE_VIEWER
#include "../Neuronscape Viewer 3d/EventID.h"
#else
#error ClientPacketProcessThread Source Only Valid For NEI and Viewer 
#endif


class ClientPacketProcessThread : public wxThread
{
public:
	// Public Functions
	// Default Constructor
	ClientPacketProcessThread(wxFrame* Parent);

	// Destructor
	~ClientPacketProcessThread();

	void Initialize(DB_ClientObject *ObjectDatabase);
	void PostPacket(wxIPV4address Peer, std::vector<unsigned char> Packet);

	// Get Functions
	uint32_t GetAssignedClientID();
	uint32_t GetAssignedObjectID();
	uint32_t GetStatus();
	bool GetEnvDimensions(CartesianVector &EnvDim);
	std::string GetTestsEchoReply();
	uint32_t GetError();

private:
	void SendEventToMain(uint32_t Data1, uint32_t Data2, std::string Text);
	// Private Functions
	// Receive Packet Functions
	void ProcessNetworkPacket(wxIPV4address Peer, std::vector<unsigned char> Data);
	int RecvAck(std::vector<unsigned char> Data);
	int RecvError(std::vector<unsigned char> Data);
	int RecvClientEnum(std::vector<unsigned char> Data);
	bool RecvBulkUpdateObj(std::vector<unsigned char> Data);
	uint32_t RecvDeleteObject(std::vector<unsigned char> Data);
	int RecvEnergyDelta(std::vector<unsigned char> Data);
	uint32_t RecvRemoveEatenObj(std::vector<unsigned char> Data);
	bool RecvKillSystem(std::vector<unsigned char> Data);
	bool RecvTestsEchoReply(std::vector<unsigned char> Data);
	bool RecvTestsEcho(std::vector<unsigned char> Data);
	// Thread Main
	virtual wxThread::ExitCode Entry();

private:
	wxFrame *m_Parent;
	DB_ClientObject *m_ObjectDb;

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