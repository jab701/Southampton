#include "MainFrame.h"

MainFrame::MainFrame(const wxString& title)
	: wxFrame(NULL, wxID_ANY, title, wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL,wxT("MainFrame"))
{
	// Initialize variables
	this->m_ClientDB.ClearDB();
	this->m_ObjectDB.ClearDB();

	this->m_NetworkStack = NULL;
	this->m_PacketProcessing = NULL;
	this->m_Physics = NULL;
	this->m_SystemRunning = false;

	// Initialization functions
	this->ControlLayout();
	wxLog::SetActiveTarget(this->m_LogTextCtrl);

	// Initialise SRAND
	wxDateTime DT;
	unsigned TicksSinceEpoch = DT.Now().GetTicks();
	std::srand(TicksSinceEpoch);
}
MainFrame::~MainFrame()
{
	this->m_ClientDB.ClearDB();
	this->m_ObjectDB.ClearDB();

	this->StopNetworkStack();

	this->StopPhysicsSimulation();
}
void MainFrame::ControlLayout()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);	
	this->SetSizer(TopLevelSizer);


	wxBoxSizer *ConfigStatusSizer = new wxBoxSizer(wxHORIZONTAL);
	TopLevelSizer->Add(ConfigStatusSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	wxBoxSizer *ConfigSizer = new wxBoxSizer(wxVERTICAL);
	wxBoxSizer *StatusSizer = new wxBoxSizer(wxVERTICAL);
	ConfigStatusSizer->Add(ConfigSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);
	ConfigStatusSizer->Add(StatusSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);	

	// Physics Environment Controls
	this->ControlLayout_PhysEnvControls(ConfigSizer);

	// Server Configuration Controls
	this->ControlLayout_ServerConfControls(ConfigSizer);
	// Server Status
	//this->ControlLayout_StatusControls(StatusSizer);
	// Server Control
	this->ControlLayout_ServerControls(TopLevelSizer);

	this->LayoutLogTextCtrl(TopLevelSizer);

	TopLevelSizer->Fit(this);
	this->SetMinSize(this->GetBestSize());
}
void MainFrame::ControlLayout_PhysEnvControls(wxBoxSizer *Parent)
{
	wxStaticBox *PhysEnvStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Physics Environment Configuration"),wxDefaultPosition,wxDefaultSize,0,wxT("PhysicsEnv"));
	wxStaticBoxSizer *PhysEnvStaticBoxSizer = new wxStaticBoxSizer(PhysEnvStaticBox,wxVERTICAL);
	Parent->Add(PhysEnvStaticBoxSizer);

	// Row 1
	wxBoxSizer *PhysEnvRow1Sizer = new wxBoxSizer(wxHORIZONTAL);

	PhysEnvStaticBoxSizer->AddSpacer(10);
	PhysEnvStaticBoxSizer->Add(PhysEnvRow1Sizer,1,wxALIGN_CENTER|wxEXPAND,0,0);
	PhysEnvStaticBoxSizer->AddSpacer(10);

	wxBoxSizer *PhysEnvRow1Col1Sizer = new wxBoxSizer(wxVERTICAL);
	wxBoxSizer *PhysEnvRow1Col2Sizer = new wxBoxSizer(wxVERTICAL);

	//PhysEnvRow1Sizer->AddStretchSpacer(1);
	PhysEnvRow1Sizer->AddSpacer(10);
	PhysEnvRow1Sizer->Add(PhysEnvRow1Col1Sizer,1,wxEXPAND,0,0);
	PhysEnvRow1Sizer->AddSpacer(10);
	PhysEnvRow1Sizer->Add(PhysEnvRow1Col2Sizer,1,wxEXPAND,0,0);
	PhysEnvRow1Sizer->AddSpacer(10);
	//PhysEnvRow1Sizer->AddStretchSpacer(1);

	// Row 1 Col 1
	wxStaticText *ST_ENVX = new wxStaticText(this,wxID_ANY,wxT("Environment X"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ENVX"));
	wxStaticText *ST_ENVY = new wxStaticText(this,wxID_ANY,wxT("Environment Y"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ENVY"));
	wxStaticText *ST_ENVZ = new wxStaticText(this,wxID_ANY,wxT("Environment Z"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ENVZ"));
	wxStaticText *ST_GRAVITY = new wxStaticText(this,wxID_ANY,wxT("Acceleration due to Gravity (m/s^2)"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_GRAVITY"));
	wxStaticText *ST_UPDATERATE = new wxStaticText(this,wxID_ANY,wxT("Environment Update Period (milliseconds)"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_UPDATERATE"));

	PhysEnvRow1Col1Sizer->AddSpacer(3);
	PhysEnvRow1Col1Sizer->Add(ST_ENVX,0,0,0,0);
	PhysEnvRow1Col1Sizer->AddSpacer(5);
	PhysEnvRow1Col1Sizer->AddStretchSpacer(1);
	PhysEnvRow1Col1Sizer->Add(ST_ENVY,0,0,0,0);
	PhysEnvRow1Col1Sizer->AddSpacer(5);
	PhysEnvRow1Col1Sizer->AddStretchSpacer(1);
	PhysEnvRow1Col1Sizer->Add(ST_ENVZ,0,0,0,0);
	PhysEnvRow1Col1Sizer->AddSpacer(5);
	PhysEnvRow1Col1Sizer->AddStretchSpacer(1);
	PhysEnvRow1Col1Sizer->Add(ST_GRAVITY,0,0,0,0);
	PhysEnvRow1Col1Sizer->AddSpacer(5);
	PhysEnvRow1Col1Sizer->AddStretchSpacer(1);
	PhysEnvRow1Col1Sizer->Add(ST_UPDATERATE,0,0,0,0);
	PhysEnvRow1Col1Sizer->AddSpacer(3);
	// Row 1 Col 2
	wxTextCtrl *TC_ENVX = new wxTextCtrl(this,wxID_ANY,wxT("1000.0"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_ENVX"));
	wxTextCtrl *TC_ENVY = new wxTextCtrl(this,wxID_ANY,wxT("1000.0"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_ENVY"));
	wxTextCtrl *TC_ENVZ = new wxTextCtrl(this,wxID_ANY,wxT("1000.0"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_ENVZ"));
	wxTextCtrl *TC_GRAVITY = new wxTextCtrl(this,wxID_ANY,wxT("9.81"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_GRAVITY"));
	wxTextCtrl *TC_UPDATERATE = new wxTextCtrl(this,wxID_ANY,wxT("17"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_UPDATERATE"));

	PhysEnvRow1Col2Sizer->Add(TC_ENVX,0,0,0,0);
	PhysEnvRow1Col2Sizer->AddSpacer(5);
	PhysEnvRow1Col2Sizer->Add(TC_ENVY,0,0,0,0);
	PhysEnvRow1Col2Sizer->AddSpacer(5);
	PhysEnvRow1Col2Sizer->Add(TC_ENVZ,0,0,0,0);
	PhysEnvRow1Col2Sizer->AddSpacer(5);
	PhysEnvRow1Col2Sizer->Add(TC_GRAVITY,0,0,0,0);
	PhysEnvRow1Col2Sizer->AddSpacer(5);
	PhysEnvRow1Col2Sizer->Add(TC_UPDATERATE,0,0,0,0);
}
void MainFrame::ControlLayout_ServerConfControls(wxBoxSizer *Parent)
{
	wxStaticBox *ServerConfigStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Server Configuration"),wxDefaultPosition,wxDefaultSize,0,wxT("ServerConf"));
	wxStaticBoxSizer *ServerConfigStaticBoxSizer = new wxStaticBoxSizer(ServerConfigStaticBox,wxVERTICAL);
	Parent->Add(ServerConfigStaticBoxSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	wxBoxSizer *ServerConfigRow1Sizer = new wxBoxSizer(wxHORIZONTAL);

	ServerConfigStaticBoxSizer->AddSpacer(10);
	ServerConfigStaticBoxSizer->Add(ServerConfigRow1Sizer,1,wxALIGN_CENTER|wxEXPAND,0,0);
	ServerConfigStaticBoxSizer->AddSpacer(10);

	wxBoxSizer *ServerConfigRow1Col1Sizer = new wxBoxSizer(wxVERTICAL);
	wxBoxSizer *ServerConfigRow1Col2Sizer = new wxBoxSizer(wxVERTICAL);

	ServerConfigRow1Sizer->AddSpacer(10);
	ServerConfigRow1Sizer->Add(ServerConfigRow1Col1Sizer,1,wxEXPAND,0,0);
	ServerConfigRow1Sizer->AddSpacer(10);
	ServerConfigRow1Sizer->Add(ServerConfigRow1Col2Sizer,1,wxEXPAND,0,0);
	ServerConfigRow1Sizer->AddSpacer(10);


	// Row 1 Col 1
	wxStaticText *ST_NETWORKPORT = new wxStaticText(this,wxID_ANY,wxT("Listen for connections on port:"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NETWORKPORT"));

	ServerConfigRow1Col1Sizer->AddSpacer(3);
	ServerConfigRow1Col1Sizer->Add(ST_NETWORKPORT,0,0,0,0);
	ServerConfigRow1Col1Sizer->AddSpacer(5);
	ServerConfigRow1Col1Sizer->AddStretchSpacer(1);
	//
	ServerConfigRow1Col1Sizer->AddSpacer(3);

	// Row 1 Col 2
	wxTextCtrl *TC_NETWORKPORT = new wxTextCtrl(this,wxID_ANY,wxT("12000"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TC_NETWORKPORT"));

	ServerConfigRow1Col2Sizer->Add(TC_NETWORKPORT,0,0,0,0);
	//ServerConfigRow1Col2Sizer->AddSpacer(5);
	//ServerRow1Col2Sizer->Add(TC_UPDATERATE,0,0,0,0);

}
void MainFrame::ControlLayout_StatusControls(wxBoxSizer *Parent)
{
	wxStaticBox *ServerStatusStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Server Status"),wxDefaultPosition,wxDefaultSize,0,wxT("ServerStatus"));
	wxStaticBoxSizer *ServerStatusStaticBoxSizer = new wxStaticBoxSizer(ServerStatusStaticBox,wxVERTICAL);
	Parent->Add(ServerStatusStaticBoxSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	wxBoxSizer *Row1Sizer = new wxBoxSizer(wxHORIZONTAL);
	ServerStatusStaticBoxSizer->Add(Row1Sizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	wxBoxSizer *Row1Col1Sizer = new wxBoxSizer(wxVERTICAL);
	Row1Sizer->Add(Row1Col1Sizer,0,wxALIGN_CENTER|wxEXPAND,0,0);
	wxBoxSizer *Row1Col2Sizer = new wxBoxSizer(wxVERTICAL);
	Row1Sizer->Add(Row1Col2Sizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	// Row1Col1
	wxStaticText *ST_ServerStatus = new wxStaticText(this,wxID_ANY,wxT("Status:"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ServerStatus"));
	Row1Col1Sizer->Add(ST_ServerStatus,0,0,0,0);
	// Row1Col2
	wxTextCtrl *TC_ServerStatus = new wxTextCtrl(this,wxID_ANY,wxEmptyString,wxDefaultPosition,wxDefaultSize,wxTE_READONLY,wxDefaultValidator,wxT("TC_ServerStatus"));
	Row1Col2Sizer->Add(TC_ServerStatus,0,0,0,0);
}
void MainFrame::ControlLayout_ServerControls(wxBoxSizer *Parent)
{
	wxStaticBox *ServerControlStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Server Control"),wxDefaultPosition,wxDefaultSize,0,wxT("ServerCont"));
	wxStaticBoxSizer *ServerControlStaticBoxSizer = new wxStaticBoxSizer(ServerControlStaticBox,wxVERTICAL);
	Parent->Add(ServerControlStaticBoxSizer,0,wxALIGN_CENTER|wxEXPAND,0,0);

	wxBoxSizer* ServerControlRow1Sizer = new wxBoxSizer(wxHORIZONTAL);

	ServerControlStaticBoxSizer->Add(ServerControlRow1Sizer,0,wxEXPAND,0,0);

	wxButton  *BTN_START = new wxButton(this,ID_SERVERSTART,wxT("Start Server"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("BTN_START"));
	wxButton  *BTN_RESTART = new wxButton(this,ID_SERVERRESTART,wxT("Restart Server"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("BTN_RESTART"));
	wxButton  *BTN_STOP = new wxButton(this,ID_SERVERSTOP,wxT("Stop Server"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("BTN_STOP"));

	BTN_START->SetDefault();
	BTN_STOP->Enable(false);
	ServerControlRow1Sizer->AddStretchSpacer(1);
	ServerControlRow1Sizer->Add(BTN_START,0,0,0,0);
	ServerControlRow1Sizer->AddSpacer(5);
	ServerControlRow1Sizer->Add(BTN_RESTART,0,0,0,0);
	ServerControlRow1Sizer->AddSpacer(5);
	ServerControlRow1Sizer->Add(BTN_STOP,0,0,0,0);
	ServerControlRow1Sizer->AddStretchSpacer(1);
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
/*** Control Manipulation Functions ***/
bool MainFrame::FetchTextCtrlData()
{
	wxTextCtrl *TC_ENVX = (wxTextCtrl*) this->FindWindowByName("TC_ENVX",this);
	wxTextCtrl *TC_ENVY = (wxTextCtrl*) this->FindWindowByName("TC_ENVY",this);
	wxTextCtrl *TC_ENVZ = (wxTextCtrl*) this->FindWindowByName("TC_ENVZ",this);
	wxTextCtrl *TC_GRAVITY = (wxTextCtrl*) this->FindWindowByName("TC_GRAVITY",this);
	wxTextCtrl *TC_PHYTIMER = (wxTextCtrl*) this->FindWindowByName("TC_UPDATERATE",this);
	wxTextCtrl *TC_NETWORKPORT = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKPORT",this);

	wxString STR_ENVX		= TC_ENVX->GetValue();
	wxString STR_ENVY		= TC_ENVY->GetValue();
	wxString STR_ENVZ		= TC_ENVZ->GetValue();
	wxString STR_GRAVITY	= TC_GRAVITY->GetValue();
	wxString STR_UPDATERATE = TC_PHYTIMER->GetValue();

	double X;
	double Y;
	double Z;

	if (!STR_ENVX.ToDouble(&X))
	{
		return false;
	}

	if (!STR_ENVY.ToDouble(&Y))
	{
		return false;

	}

	if (!STR_ENVZ.ToDouble(&Z))
	{
		return false;

	}

	this->m_ControlsData.EnvDim = CartesianVector(X,Y,Z);

	STR_GRAVITY.ToDouble(&this->m_ControlsData.Gravity);

	unsigned long Temp;

	if (!STR_UPDATERATE.ToULong(&Temp,10))
	{
		return false;
	}

	this->m_ControlsData.PHYSTIME_INTERVAL = Temp;

	//this->m_ControlsData.EnvX = STR_ENVX.
	this->m_ControlsData.NET_PORT = TC_NETWORKPORT->GetValue();

	// Temporary default value until control option is given
	// Timer fires every 10 ms
	return true;
	
}
void MainFrame::TextCtrlLock()
{
	wxTextCtrl *TC_NETWORKPORT = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKPORT",this);

	TC_NETWORKPORT->Disable();
}
void MainFrame::TextCtrlUnlock()
{
	wxTextCtrl *TC_NETWORKPORT = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKPORT",this);

	TC_NETWORKPORT->Enable();
}
void MainFrame::OnClose(wxCloseEvent &event)
{
	if (this->m_SystemRunning)
	{
		this->SystemStop();
	}
	event.Skip();
}
/*** Control Callback Functions ***/
void MainFrame::OnServerStartButton(wxCommandEvent &event)
{
	wxButton *B_START = (wxButton*) this->FindWindowByName("BTN_START");
	wxButton *B_STOP  = (wxButton*) this->FindWindowByName("BTN_STOP");

	if (!this->SystemStart())
	{
		// System did not start successfully
	}
	else
	{
		// System did start successfully
		B_START->Enable(false);
		B_STOP->Enable(true);
	}
}
void MainFrame::OnServerRestartButton(wxCommandEvent &event)
{
	this->SystemStop();
	this->SystemStart();
}
void MainFrame::OnServerStopButton(wxCommandEvent &event)
{
	wxButton *B_START = (wxButton*) this->FindWindowByName("BTN_START");
	wxButton *B_STOP  = (wxButton*) this->FindWindowByName("BTN_STOP");
	B_START->Enable(true);
	B_STOP->Enable(false);
	this->SystemStop();
}
/*** Network Socket Events ***/
void MainFrame::OnReceiveNetworkPacket(wxSocketEvent &event)
{
	//int ReturnCode;
	unsigned char RawData[MAX_PACKET_LENGTH];
	wxDatagramSocket *udpsocket = this->m_NetworkStack->GetSocket();
	wxIPV4address Peer;
	unsigned BytesRead;
	std::vector<unsigned char> Data;

	switch (event.GetSocketEvent())
	{
	case wxSOCKET_INPUT: // Received Data On The Socket

		udpsocket->Read(RawData, MAX_PACKET_LENGTH); 

		if (!udpsocket->GetPeer(Peer))
		{
			wxLogError("Server UDP Socket Error: Failed to retreive Peer Data from socket, ignoring received packet");
			break;
		}

		BytesRead = udpsocket->LastCount();

		for(unsigned i = 2; i < BytesRead; i++)
		{
			Data.push_back(RawData[i]);
		}

		this->m_PacketProcessing->PostPacket(Peer, Data);
		break;

	default: // We should not receive any other events on this socket, since it is UDP there is no "connection"
		wxLogError("Server UDP Socket Error: An inappropriate event occurred on the socket");
		break;
	}
}
void MainFrame::OnSendPacketEvent(ServerPacketEvent &event)
{
	this->m_NetworkStack->SendString(event.GetAddress(), event.GetPayload());
}
void MainFrame::OnSendPacketToAllEvent(ServerPacketEvent &event)
{
	this->m_NetworkStack->SendStringToAllClients(event.GetPayload());
}
void MainFrame::OnPacketProcessEvent(wxCommandEvent &event)
{

}
bool MainFrame::SystemStart()
{
	this->TextCtrlLock();

	if (!this->FetchTextCtrlData())
	{
		wxLogMessage("Neuronscape Server Failed to Start (Invalid Parameters Provided)");
		this->TextCtrlUnlock();
		return false;
	}

	this->m_ClientDB.ClearDB();
	this->m_ObjectDB.ClearDB();
	this->m_ObjectDB.SetEnvDimensions(this->m_ControlsData.EnvDim);

	if (!this->StartNetworkStack())
	{
		wxLogMessage("Neuronscape Server Failed to Start (Network Stack Error, maybe port is already in use?)");
		this->TextCtrlUnlock();
		return false;
	}

	if (this->StartPhysicsSimulation() != 0)
	{
		wxLogMessage("Neuronscape Server Failed to Start (Physics Simulation Error)");
		this->StopNetworkStack();
		this->TextCtrlUnlock();
		return false;
	}

	// All started successfully
	// All ready to go!
	this->m_SystemRunning = true;
	wxLogMessage("Neuronscape Server Started");
	return true;
}
bool MainFrame::StartNetworkStack()
{
	this->m_PacketProcessing = new ServerPacketProcessingThread(this);

	this->m_PacketProcessing->Initialize(&this->m_ClientDB, &this->m_ObjectDB, this->m_ControlsData.EnvDim);

	if (this->m_PacketProcessing->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_PacketProcessing;
		this->m_PacketProcessing = NULL;
		return false;
	}

	if (this->m_PacketProcessing->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't run the thread!");
		delete this->m_PacketProcessing;
		this->m_PacketProcessing = NULL;
		return false;
	}

	// Open Network Socket
	this->m_NetworkStack = new NetworkStackServer;

	if (this->m_NetworkStack == NULL)
	{
		wxLogError("Could not start network stack");
		this->m_NetworkStack = NULL;
		return false;
	}

	if (!this->m_NetworkStack->SetDbConnection(&this->m_ClientDB,&this->m_ObjectDB))
	{
		// Invalid Database Connection
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
		return false;
	}

	wxIPV4address ServerAddress;

	ServerAddress.AnyAddress();

	if (!ServerAddress.Service(this->m_ControlsData.NET_PORT))
	{
		// Invalid Network Service/Port
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
		return false;
	}

	if (!this->m_NetworkStack->StartNetworkSocket(ServerAddress,this,ID_SERVERSOCKET, this->m_ControlsData.EnvDim))
	{
		// Could not start the network socket
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
		this->TextCtrlUnlock();
		return false;
	}
	return true;
}
int MainFrame::StartPhysicsSimulation()
{
	this->m_Physics = new PhysicsThread(this);

	this->m_Physics->Initialize(&this->m_ClientDB, &this->m_ObjectDB, this->m_ControlsData.PHYSTIME_INTERVAL, this->m_ControlsData.Gravity, this->m_ControlsData.EnvDim);

	if (this->m_Physics->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_Physics;
		this->m_Physics = NULL;
		return 2;
	}

	if (this->m_Physics->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't run the thread!");
		delete this->m_Physics;
		this->m_Physics = NULL;
		return 3;
	}

	return 0;
}
bool MainFrame::SystemStop()
{
	//this->StopPhysicsThread();
	this->StopPhysicsSimulation();
	this->StopNetworkStack();

	this->m_ClientDB.ClearDB();
	this->m_ObjectDB.ClearDB();

	this->TextCtrlUnlock();
	this->m_SystemRunning = false;

	wxLogMessage("Neuronscape Server Stopped");
	return false;
}
bool MainFrame::StopNetworkStack()
{
	if (this->m_NetworkStack != NULL)
	{
		std::vector<DBRecord_Client> Clients;

		this->m_ClientDB.FetchAll(Clients);

		if (Clients.size() != 0)
		{
			this->m_NetworkStack->SendBulkForceDisconnect(Clients);
		}

		// Close Network Connection
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
	}

	if (this->m_PacketProcessing != NULL)
	{
		wxIPV4address Address;
		std::vector<unsigned char> Data;

		Address.Hostname("0.0.0.0");
		Address.Service(0);

		this->m_PacketProcessing->PostPacket(Address, Data);
		this->m_PacketProcessing->Delete();
		delete this->m_PacketProcessing;
		this->m_PacketProcessing = NULL;
	}

	return true;
}
bool MainFrame::StopPhysicsSimulation()
{
	if (this->m_Physics == NULL)
	{
		return false;
	}

	this->m_Physics->Delete();

	delete this->m_Physics;

	this->m_Physics = NULL;

	return true;
}
void MainFrame::OnPhysicsUpdate(PhysicsEvent &event)
{

	//*************************************************
	// send updates to clients
	//*************************************************
	this->m_NetworkStack->SendMultipleStringsToMultipleClients(event.GetAddresses(), event.GetPayload());
}

/*** Event Table for MainFrame ***/
BEGIN_EVENT_TABLE(MainFrame, wxFrame)
	EVT_CLOSE(MainFrame::OnClose)
	EVT_BUTTON(ID_SERVERSTART,MainFrame::OnServerStartButton)
	EVT_BUTTON(ID_SERVERRESTART,MainFrame::OnServerRestartButton)
	EVT_BUTTON(ID_SERVERSTOP,MainFrame::OnServerStopButton)
	EVT_SOCKET(ID_SERVERSOCKET,MainFrame::OnReceiveNetworkPacket)
	EVT_PHYSICSBULKUPDATE (ID_PHYSICSSENDBULKEVENT, MainFrame::OnPhysicsUpdate)
	EVT_COMMAND (ID_PROCESSPACKETEVENT, wxEVT_COMMAND_TEXT_UPDATED, MainFrame::OnPacketProcessEvent)
	EVT_SERVERPACKETPROCESSED(ID_FORWARDPACKETEVENT, MainFrame::OnSendPacketEvent)
	EVT_SERVERPACKETPROCESSED(ID_FORWARDPACKETTOALLCLIENTSEVENT, MainFrame::OnSendPacketToAllEvent)
	END_EVENT_TABLE()