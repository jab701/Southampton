#ifndef NETWORKSTACK_H
#define NETWORKSTACK_H

#include <wx/wx.h>
#include <wx/socket.h>

#include "EventID.h"

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"

class NetworkStack
{
public:
	// Default Constructor
	NetworkStack();

	// Destructor
	~NetworkStack();

	// Control Functions
	bool StartClientSocket(wxFrame *MainFrame, EVENTS SOCKET_EVENT_ID);
	bool StartServerSocket(wxFrame *MainFrame, EVENTS SOCKET_EVENT_ID, unsigned short Port);
	bool StopSocket();

	// Get Functions
	bool GetConnectionStatus();
	bool *GetNeuronActivity();
	wxString GetNeuronControl() const;
	bool GetReset();
	wxString GetTestsEchoReply();

	// Checking Functions
	bool IsOK();

	// Packet Processing Flow
	unsigned short ProcessNetworkPacket(wxDatagramSocket *Socket);

	// Function to send a data string 
	bool SendString(wxString Data);
	// Send packet Functions
	bool SendConnectionAck();
	bool SendConnectionRequest(wxIPV4address RemoteHost);
	bool SendForceDisconnect();
	bool SendNeuronActivityData(wxString NeuronActivityData);
	bool SendNeuronControlData(wxString NeuronControlData);
	bool SendAssertReset();
	bool SendReleaseReset();
	bool SendTestsEchoReply(wxString Data);
	bool SendTestsEcho(wxString Data);

	// Receive Packet Functions
	bool RecvNeuronActivityData(wxString Data);
	bool RecvNeuronControlData(wxString Data);
	void RecvTestsEchoReply(wxString Data);
	void RecvTestsEcho(wxString Data);

private:
	wxIPV4address m_LocalAddress;
	wxIPV4address m_RemoteAddress;

	unsigned char m_Role;

	wxDatagramSocket *m_Socket;

	bool m_Reset;
	
	bool m_NeuronActivity[88];
	wxString m_NeuronControl;

	wxString m_TestsEchoReplyStr;
};

#endif