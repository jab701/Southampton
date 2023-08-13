#include "MainFrame.h"

MainFrame::MainFrame(const wxString& title)
	: wxFrame(NULL, wxID_ANY, title, wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL,wxT("MainFrame"))
{
	this->LayoutControls();

	wxLog::SetActiveTarget(this->m_LogTextCtrl);

	this->m_NetworkStack = NULL;
    this->m_PendingSocketShutdown = false;
    this->m_PendingProgramClose = false;

	this->m_ClientID = 0;

	this->m_EnvParameters.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_NSTimer = NULL;

	this->m_NetworkStack = NULL;

	this->m_PacketProcessingThread = NULL;

	this->CreateStatusBar(2);
}
MainFrame::~MainFrame()
{
	this->m_NetworkStack = NULL;
    this->m_PendingSocketShutdown = false;
    this->m_PendingProgramClose = false;

	this->m_ClientID = 0;

	this->m_EnvParameters.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_NSTimer = NULL;

	this->m_NetworkStack = NULL;

	this->m_PacketProcessingThread = NULL;
}
bool MainFrame::FetchTextCtrlData()
{
	wxString RoleString;

	wxTextCtrl *TC_NH  = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKHOST",this);
	wxTextCtrl *TC_NP  = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKPORT",this);

	this->m_ControlsData.NetworkHost  = TC_NH->GetValue();
	this->m_ControlsData.NetworkPort  = TC_NP->GetValue();


	if ((this->m_ControlsData.NetworkHost == wxEmptyString)||(this->m_ControlsData.NetworkPort == wxEmptyString))
	{
		// Cannot have empty host/port strings
		return false;
	}

	if (!this->m_RemoteHost.Hostname(this->m_ControlsData.NetworkHost))
	{
		// Not a valid hostname
		return false;
	}

	if (!this->m_RemoteHost.Service(this->m_ControlsData.NetworkPort))
	{
		// Not a valid port
		return false;
	}

	return true;
}
void MainFrame::LayoutControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);	
	this->LayoutNetworkControls(TopLevelSizer);
	this->LayoutButtons(TopLevelSizer);
	this->LayoutLogTextCtrl(TopLevelSizer);
	this->SetSizer(TopLevelSizer);
	TopLevelSizer->Fit(this);
}
void MainFrame::LayoutNetworkControls(wxBoxSizer *TopLevel)
{
	// Network Settings Static Box
	wxStaticBox *NetworkStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Host Server Settings "),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *NetworkStaticBoxSizer = new wxStaticBoxSizer(NetworkStaticBox,wxVERTICAL);
	TopLevel->Add(NetworkStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxStaticText *ST_NetworkHost = new wxStaticText(this,wxID_ANY,wxT("Host"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NETWORKHOST"));
	wxTextCtrl   *TC_NetworkHost = new wxTextCtrl(this,wxID_ANY,wxT("localhost"),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_NETWORKHOST"));
	wxStaticText *ST_NetworkPort = new wxStaticText(this,wxID_ANY,wxT("Port"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NETWORKPORT"));
	wxTextCtrl   *TC_NetworkPort = new wxTextCtrl(this,wxID_ANY,wxT("12000"),wxDefaultPosition,wxSize((7*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_NETWORKPORT"));
	HSizer1->Add(ST_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);
	NetworkStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);
}
void MainFrame::LayoutButtons(wxBoxSizer *TopLevel)
{
	// Buttons Settings Static Box
	wxStaticBox *ButtonsStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Client Control"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *ButtonsStaticBoxSizer = new wxStaticBoxSizer(ButtonsStaticBox,wxVERTICAL);
	TopLevel->Add(ButtonsStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxButton *B_GoButton   = new wxButton(this,ID_GO,_T("Go"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,_T("B_GO"));
	wxButton *B_StopButton = new wxButton(this,ID_STOP,_T("Stop"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,_T("B_STOP"));

	HSizer1->Add(B_GoButton,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(B_StopButton,0,wxALIGN_CENTER_VERTICAL,0,0);

	ButtonsStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);
}
void MainFrame::LayoutLogTextCtrl(wxBoxSizer *TopLevel)
{
	wxStaticText *ST_RMessage = new wxStaticText(this,wxID_ANY,wxT("Log Messages"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_RMESSAGEE"));
	TopLevel->Add(ST_RMessage,0,wxALIGN_CENTER,0,0);
	TopLevel->AddSpacer(5);	

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);
	wxTextCtrl *TC_LogMessage = new wxTextCtrl(this,wxID_ANY,wxEmptyString,wxDefaultPosition,wxSize(wxDefaultSize.GetX(),(7*this->GetCharHeight())),wxTE_MULTILINE,wxDefaultValidator,wxT("TC_LOGMESSAGE"));
	HSizer1->AddSpacer(5);	
	HSizer1->Add(TC_LogMessage,1,wxEXPAND|wxALIGN_CENTER,50,0);
	HSizer1->AddSpacer(5);	
	TopLevel->Add(HSizer1,1,wxEXPAND,0,0);	
	TopLevel->AddSpacer(5);

	this->m_LogTextCtrl = new wxLogTextCtrl(TC_LogMessage);
}
void MainFrame::OnClose(wxCloseEvent &event)
{
	this->m_PendingProgramClose = true;
	// Check to see if we can veto the wxCloseEvent and check if memory has been allocated for the network stack
	// If we cant veto then we cannot cleanly destroy the networking stack
	// If no network stack exists we dont need to do any cleanup and we can exit.
	if ((!event.CanVeto())||(this->m_NetworkStack == NULL))
	{
		this->m_ObjectDb.Clear();
		event.Skip();
	}
	else
	{
		wxCommandEvent SocketStop;
		this->OnStop(SocketStop);
	}
}
void MainFrame::OnSocketEvent(wxSocketEvent &event)
{
	wxDatagramSocket *Socket = this->m_NetworkStack->GetSocket();

	wxIPV4address Peer;
	unsigned char RawData[MAX_PACKET_LENGTH];
	uint16_t DataLength = 0;
	wxString PacketData;
	unsigned BytesRead;
	std::vector<unsigned char> Data;

	int CNS_Status = 0;

	switch(event.GetSocketEvent())
	{
	case wxSOCKET_INPUT:
		if (this->m_NetworkStack == NULL)
		{
			Socket->Discard();
			return;
		}

		if (this->m_NetworkStack->IsOK() == false)
		{
			Socket->Discard();
			return;
		}

		if (!Socket->GetPeer(Peer))
		{
			wxLogError("UDP Socket Error: Failed to retreive Peer Data from socket, ignoring received packet");
			return;
		}


		Socket->Read(RawData, MAX_PACKET_LENGTH);
	    BytesRead = Socket->LastCount();

		for(unsigned i = 2; i < BytesRead; i++)
		{
			Data.push_back(RawData[i]);
		}

		this->m_PacketProcessingThread->PostPacket(Peer, Data); // Add the packet to the received queue

		//CNS_Status = this->m_NetworkStack->ProcessNetworkPacket(Peer, Data);
		//this->OnNetworkStackEvent(CNS_Status);
		break;

	default:
		// Another event occurred which should have
		wxLogMessage("Unexpected Event Occurred on Neuronscape Network Socket!");
		break;
	}
}
void MainFrame::OnGo(wxCommandEvent &event)
{
	this->FetchTextCtrlData();
	
	if (!this->StartPacketProcessing())
	{
		// Couldnt start Packet Processing
		return;
	}

	if (this->m_NetworkStack != NULL)
	{
		// network stack already exists. Return
		return;
	}

	this->m_NetworkStack = new NetworkStackClient();

	if (!this->m_NetworkStack->StartNetworkSocket(this->m_RemoteHost,this,ID_SOCKET_EVENT,&this->m_ObjectDb))
	{
		// failed to start network socket
		return;
	}

	if (!this->m_NetworkStack->IsOK())
	{
		// network socket is not properly initialised
		return;
	}

	// now we must send a connection request!
	this->m_NetworkStack->SendConnectionRequest(ROLE_VIEWER);

	// we must also start a one shot timer for 5 seconds (5000 ms).
	// if after 5 seconds we are not connected then we have a timeout situation
	this->m_NSTimer = new wxTimer(this,ID_TIMER_CONNECTIONTIMEOUT);
	this->m_NSTimer->Start(5000,true);

	this->m_ClientID = 0;
	return;
}
void MainFrame::OnStop(wxCommandEvent &event)
{
	// Networking is not initialised
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	// This if statement checks to see if the stop button has been pressed while we are already in the process of disconnecting.
	// It stops the user from sending multiple requests to disconnect whilst the system is already processing a disconnection.
	if ((event.GetId() == ID_STOP)&&(this->m_PendingSocketShutdown == true))
	{
		return;
	}

	// Grab the status of the network stack!
	uint16_t ClientID = this->m_PacketProcessingThread->GetAssignedClientID();
	uint16_t ObjectID = this->m_PacketProcessingThread->GetAssignedObjectID();

	// If the clientID is 0 then we are not connected to a server, we can delete the NetworkStack object and Exit
	if (ClientID == 0)
	{	
		this->StopPacketProcessing();

		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
		this->m_ObjectDb.Clear();
		this->m_PendingSocketShutdown = false;

		if (this->m_PendingProgramClose)
		{
			wxCloseEvent *Closing = new wxCloseEvent();
			this->OnClose(*Closing);
		}
	}
	// if both values are non-zero then we must remove the object first, then the client
	else
	{	
		this->m_PendingSocketShutdown = true;
		this->m_NetworkStack->SendDisconnectionRequest();
		// we must also start a one shot timer for 5 seconds (5000 ms).
		// if after 5 seconds we are not connected then we have a timeout situation
		this->m_NSTimer = new wxTimer(this,ID_TIMER_DISCONNECTIONTIMEOUT);
		this->m_NSTimer->Start(5000,true);
	}
}
void MainFrame::OnNetworkStackEvent(wxCommandEvent &event)
{
	ViewerFrame *Viewer;
	int EventCode = event.GetInt();

	// Find out which event occurred
	switch (EventCode)
	{
	case CLI_NS_OK:
		// If an event is triggered with this ID we ignore it.
		// Effectively a NOP
		break;
	case CLI_NS_CONNECTED:
		// A connection request was sucessful!
		// We have been assigned a Client ID
		this->OnNetworkStackConnectedEvent();
		break;
	case CLI_NS_DISCONNECTED:
		// We have been disconnected
		this->OnNetworkStackDisconnectedEvent();
		break;
	case CLI_NS_DISCONNECT_FORCED:
		// We have been disconnected forcefully by the server
		this->OnNetworkStackDisconnectedForcedEvent();
		break;
	case CLI_NS_ENUM:
		// We have been enumerated, we are ready to go
		this->OnNetworkStackEnumEvent();
		break;
	case CLI_NS_TEST_ECHO_REPLY:
		// Do nothing
		break;
	case CLI_NS_OBJECT_DATA_DIRTY:
		// The Object Information Database has been marked as dirty
		// We must re-evaluate all equations
		this->OnNetworkStackObjectDataDirtyEvent();
		break;
	case CLI_NS_KILL:
		// we have been forcefully disconnected, we must stop all processing and
		// reset to an initial unconnected state
		Viewer = this->FetchActiveViewerFrame();

		if (Viewer != NULL ) 
		{
			Viewer->Close(true);
		}

		// stop the network socket
		this->m_NetworkStack->StopNetworkSocket();
		// free memory used by Network stack object
		delete this->m_NetworkStack;
		// set pointer to network stack object to NULL
		this->m_NetworkStack = NULL;

		// Clear the Database of Objects
		this->m_ObjectDb.Clear();
		this->Close(true);
		break;
	case CLI_NS_ERROR:
		this->OnNetworkStackErrorEvent();
		break;
	default:
		// An unknown event occured, this should not occur!
		break;
	}
}
void MainFrame::OnNetworkStackConnectedEvent()
{
	// Stop the timeout timer!
	if (this->m_NSTimer != NULL)
	{
		this->m_NSTimer->Stop();
		delete this->m_NSTimer;
		this->m_NSTimer = NULL;
	}
	
	this->m_ClientID = this->m_PacketProcessingThread->GetAssignedClientID();
	wxLogMessage("Connected - Assigned ID: %d",this->m_ClientID);

	return;
}
void MainFrame::OnNetworkStackDisconnectedEvent()
{
	ViewerFrame * Viewer = this->FetchActiveViewerFrame();

	if (Viewer != NULL ) 
	{
		Viewer->Close(true);
	}

	this->m_NSTimer->Stop();
	delete this->m_NSTimer;
	this->m_NSTimer = NULL;

	this->m_PendingSocketShutdown = false;

	this->StopPacketProcessing();

	// stop the network socket
	this->m_NetworkStack->StopNetworkSocket();

	delete this->m_NetworkStack;

	this->m_NetworkStack = NULL;

	this->m_ObjectDb.Clear();

	wxLogMessage("Disconnected from server");

	if (this->m_PendingProgramClose == true)
	{
		this->Close();
	}
}
void MainFrame::OnNetworkStackDisconnectedForcedEvent()
{
    // we have been forcefully disconnected, we must stop all processing and
	// reset to an initial unconnected state
	ViewerFrame * Viewer = this->FetchActiveViewerFrame();

	if (Viewer != NULL ) 
	{
		Viewer->Close(true);
	}

	

	this->StopPacketProcessing();
	// stop the network socket
	this->m_NetworkStack->StopNetworkSocket();
	// free memory used by Network stack object
	delete this->m_NetworkStack;
	// set pointer to network stack object to NULL
	this->m_NetworkStack = NULL;

	// Clear the Database of Objects
	this->m_ObjectDb.Clear();

	wxLogMessage("Forcefully disconnected from server");

	return;
}
void MainFrame::OnNetworkStackEnumEvent()
{
	// Fetch the environmental parameters!
	this->m_PacketProcessingThread->GetEnvDimensions(this->m_EnvParameters.EnvDim);

	ViewerFrame *Viewer_Frame;
	Viewer_Frame = new ViewerFrame(this,wxT(""));
	Viewer_Frame->SetArguements(this->m_EnvParameters.EnvDim,this->m_NetworkStack,&this->m_ObjectDb);
    Viewer_Frame->Show();
}
void MainFrame::OnNetworkStackObjectDataDirtyEvent()
{
	this->m_ObjectDb.ClearDirtyBit();
}
void MainFrame::OnNetworkStackErrorEvent()
{
	// get the error flags from the network stack
	// handle error if possible
}
void MainFrame::OnNetworkTimeout(wxTimerEvent &event)
{
	wxMessageDialog *MD;

	// If network Stack Timer exists (which it should if we are here!)
	// Stop the Network Stack Timer
	// Delete the timer object
	// Set the Pointer to NetworkStack Timer Object equal to NULL
	if (this->m_NSTimer != NULL)
	{
		this->m_NSTimer->Stop();
		delete this->m_NSTimer;
		this->m_NSTimer = NULL;
	}

	switch (event.GetId())
	{
	case ID_TIMER_CONNECTIONTIMEOUT:
		// a connection attempt timed out, reset everything and display a message
		this->StopPacketProcessing();

		if (this->m_NetworkStack != NULL)
		{
			this->m_NetworkStack->StopNetworkSocket();
			delete this->m_NetworkStack;
			this->m_NetworkStack = NULL;
		}
		wxLogError("Error Connecting To Server: Timeout - No Route To Host or Host Does Not Exist");
		MD = new wxMessageDialog(this,_T("Error Connecting To Server: Timeout - No Route To Host or Host Does Not Exist"),_T("Connection Error"),wxOK|wxICON_ERROR,wxDefaultPosition);
		MD->ShowModal();
		delete MD;
		break;

	case ID_TIMER_DISCONNECTIONTIMEOUT:
		wxLogError("Error Disconnecting From Server: Timeout - Server unresponsive, Warning! Server Database may be inconsistent!");

		// notify object processing thread
		this->StopPacketProcessing();

		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;

		this->m_ObjectDb.Clear();

		this->m_PendingSocketShutdown = false;

		if (this->m_PendingProgramClose)
		{
			this->Close();
		}
		break;
	default:
		// Unknown case
		break;
	}

	return;
}
ViewerFrame* MainFrame::FetchActiveViewerFrame()
{
	ViewerFrame *Viewer  = (ViewerFrame*) this->FindWindowById(ID_VIEWERFRAME,this);

	return Viewer;
}
bool MainFrame::StartPacketProcessing()
{
	if (this->m_PacketProcessingThread != NULL)
	{
		// Client Processing Thread Already Exists
		return false;
	}

	this->m_PacketProcessingThread = new ClientPacketProcessThread(this);

	this->m_PacketProcessingThread->Initialize(&this->m_ObjectDb);

	if (this->m_PacketProcessingThread->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_PacketProcessingThread;
		this->m_PacketProcessingThread = NULL;
		return false;
	}

	if (this->m_PacketProcessingThread->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_PacketProcessingThread;
		this->m_PacketProcessingThread = NULL;
		return false;
	}

	return true;
}
void MainFrame::StopPacketProcessing()
{
	wxIPV4address BlankAddress;
	std::vector<unsigned char> EmptyVector;
	this->m_PacketProcessingThread->PostPacket(BlankAddress,EmptyVector);
	this->m_PacketProcessingThread->Delete();
	delete this->m_PacketProcessingThread;
	this->m_PacketProcessingThread = NULL;
}
/*** Event Table for MainFrame ***/
BEGIN_EVENT_TABLE(MainFrame, wxFrame)
	EVT_CLOSE(MainFrame::OnClose)
	EVT_SOCKET(ID_SOCKET_EVENT, MainFrame::OnSocketEvent)
	EVT_BUTTON(ID_GO,MainFrame::OnGo)
	EVT_BUTTON(ID_STOP,MainFrame::OnStop)
	EVT_TIMER(ID_TIMER_CONNECTIONTIMEOUT,MainFrame::OnNetworkTimeout)
	EVT_TIMER(ID_TIMER_DISCONNECTIONTIMEOUT,MainFrame::OnNetworkTimeout)
	EVT_COMMAND (ID_PROCESSPACKET, wxEVT_COMMAND_TEXT_UPDATED, MainFrame::OnNetworkStackEvent)
END_EVENT_TABLE()