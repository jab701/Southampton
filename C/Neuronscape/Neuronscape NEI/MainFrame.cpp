#include "MainFrame.h"
/**************************************************************/
/*** CLASS CONSTRUCTOR/DESTRUCTOR FUNCTION SECTION          ***/
/**************************************************************/
MainFrame::MainFrame(const wxString& title)
	: wxFrame(NULL, wxID_ANY, title, wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE & ~wxRESIZE_BORDER,wxT("MainFrame"))
{

	//wxWindow::SetBackgroundStyle(wxBG_STYLE_PAINT);
	this->LayoutControls();

	this->m_NetworkStack = NULL;
	this->m_ClientPacketProcessing = NULL;
	this->m_PendingSocketShutdown = false;
	this->m_PendingProgramClose = false;

	this->m_ClientID = 0;
	this->m_ObjectID = 0;

	this->m_EnvParameters.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_NSTimer = NULL;

	this->m_NetworkStack = NULL;
	this->m_MotorThread = NULL;
	this->m_RetinaThread = NULL;
	this->m_SpinnNetStack = NULL;

	this->m_Bitmap.Create(320,240,wxBITMAP_SCREEN_DEPTH);

	this->m_NeuronSpikeQueue = new NeuronSpikeQueue();
	this->m_NeuronSpikeQueueMutex = new wxMutex();
}
MainFrame::~MainFrame()
{
	this->m_NetworkStack = NULL;
	this->m_ClientPacketProcessing = NULL;
	this->m_PendingSocketShutdown = false;
	this->m_PendingProgramClose = false;

	this->m_ClientID = 0;
	this->m_ObjectID = 0;

	this->m_EnvParameters.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_NSTimer = NULL;
	this->m_SPTimer = NULL;

	this->m_NetworkStack = NULL;

	delete this->m_NeuronSpikeQueue;
	this->m_NeuronSpikeQueue = NULL;

	delete this->m_NeuronSpikeQueueMutex;
	this->m_NeuronSpikeQueueMutex = NULL;
}
/**************************************************************/
/*** UTILITY FUNCTION SECTION                               ***/
/**************************************************************/
bool MainFrame::FetchTextCtrlData()
{
	wxString RoleString;

	wxTextCtrl *TC_NH  = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKHOST",this);
	wxTextCtrl *TC_NP  = (wxTextCtrl*) this->FindWindowByName("TC_NETWORKPORT",this);
	wxTextCtrl *TC_SH  = (wxTextCtrl*) this->FindWindowByName("TC_SPINNAKERHOST",this);
	wxTextCtrl *TC_SP  = (wxTextCtrl*) this->FindWindowByName("TC_SPINNAKERPORT",this);

	wxSpinCtrl *SC_VISCHIPX = (wxSpinCtrl*) this->FindWindowByName("SP_SPINNAKERCHIPX",this);
	wxSpinCtrl *SC_VISCHIPY = (wxSpinCtrl*) this->FindWindowByName("SP_SPINNAKERCHIPY",this);
	wxSpinCtrl *SC_VISCPU   = (wxSpinCtrl*) this->FindWindowByName("SP_SPINNAKERCPU",this);
	wxSpinCtrl *SC_VISTAG   = (wxSpinCtrl*) this->FindWindowByName("SP_SPINNAKERTAG",this);

	wxSpinCtrl *SC_RETINAX = (wxSpinCtrl*) this->FindWindowByName("SP_RETINAX",this);
	wxSpinCtrl *SC_RETINAY = (wxSpinCtrl*) this->FindWindowByName("SP_RETINAY",this);

	wxCheckBox *CB_RETINAGREY = (wxCheckBox*) this->FindWindowByName("CB_RETINAGREY", this);

	this->m_ControlsData.NetworkHost  = TC_NH->GetValue();
	this->m_ControlsData.NetworkPort  = TC_NP->GetValue();

	this->m_ControlsData.SpinnakerHost = TC_SH->GetValue();
	this->m_ControlsData.SpinnakerPort = TC_SP->GetValue();


	this->m_ControlsData.Retinax = SC_RETINAX->GetValue();
	this->m_ControlsData.Retinay = SC_RETINAY->GetValue();
	this->m_ControlsData.RetinaGrey = CB_RETINAGREY->GetValue();
	this->m_ControlsData.InitialEnergy = INITIAL_ENERGY;

	this->m_ControlsData.VisualChipX = SC_VISCHIPX->GetValue();
	this->m_ControlsData.VisualChipY = SC_VISCHIPY->GetValue();
	this->m_ControlsData.VisualCPU = SC_VISCPU->GetValue();
	this->m_ControlsData.VisualTag = SC_VISTAG->GetValue();

	this->m_ControlsData.RewardChipX = SC_VISCHIPX->GetValue();
	this->m_ControlsData.RewardChipY = SC_VISCHIPY->GetValue();
	this->m_ControlsData.RewardCPU = SC_VISCPU->GetValue();
	this->m_ControlsData.RewardTag = SC_VISTAG->GetValue();

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

	if ((this->m_ControlsData.SpinnakerHost == wxEmptyString)||(this->m_ControlsData.SpinnakerPort == wxEmptyString))
	{
		// Cannot have empty host/port strings
		return false;
	}

	if (!this->m_SpinnakerHost.Hostname(this->m_ControlsData.SpinnakerHost))
	{
		// Not a valid hostname
		return false;
	}

	if (!this->m_SpinnakerHost.Service(this->m_ControlsData.SpinnakerPort))
	{
		// Not a valid port
		return false;
	}
	return true;
}
/**************************************************************/
/*** WINDOW CONTROL LAYOUT SECTION                          ***/
/**************************************************************/
void MainFrame::LayoutControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);

	wxBoxSizer *Row1Sizer = new wxBoxSizer(wxHORIZONTAL);

	SystemControlPanel *Controls = new SystemControlPanel(this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 524288L,"ControlPanel");

	Row1Sizer->Add(Controls,0,0,0,0);

	this->LayoutRight(Row1Sizer);

	TopLevelSizer->Add(Row1Sizer,1.0,wxEXPAND,0,0);

	//TopLevelSizer->AddSpacer(10);

	Controls_LogPanel *ControlsLogPanel = new Controls_LogPanel(this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 524288L, "LogPanel");
	TopLevelSizer->Add(ControlsLogPanel,0.0,wxEXPAND,0,0);

	this->SetSizer(TopLevelSizer);

	TopLevelSizer->Fit(this);
}

void MainFrame::LayoutRight(wxBoxSizer *TopLevel)
{
	wxBoxSizer *RightSizer = new wxBoxSizer(wxVERTICAL);

	EyePanel* Eye = new EyePanel(this, wxID_ANY, wxDefaultPosition, wxSize(320,240),524288L,"EyePanel");

	//RightSizer->AddSpacer(10);
	RightSizer->Add(Eye,1.0,wxEXPAND,0,0);

	TopLevel->Add(RightSizer,1.0,wxEXPAND,0,0);
}

void MainFrame::ShowHideControls(bool Show)
{
	SystemControlPanel *SCP  = (SystemControlPanel*) this->FindWindowByName("ControlPanel",this);

	SCP->Show(Show);
}
/**************************************************************/
/***	EVENT HANDLER SECTION                               ***/
/**************************************************************/
void MainFrame::OnSize(wxSizeEvent& event)
{
	SystemControlPanel *SCP  = (SystemControlPanel*) this->FindWindowByName("ControlPanel",this);
	Controls_LogPanel *CLP = (Controls_LogPanel*) this->FindWindowByName("LogPanel", this);
	EyePanel* Eye = (EyePanel*) this->FindWindowByName("EyePanel",this);

	if (this->IsMaximized())
	{
		SCP->Show(false);
		CLP->Show(false);
		Eye->FullScreenMode(true);
	}
	else
	{
		SCP->Show(true);
		CLP->Show(true);
		Eye->FullScreenMode(false);
	}
	event.Skip();
}
/*** On Window Close Function ***/
void MainFrame::OnClose(wxCloseEvent &event)
{
	//if (this->m_RefreshTimer != NULL)
	//{
	//	this->m_RefreshTimer->Stop();
	//	delete this->m_RefreshTimer;
	//	this->m_RefreshTimer = NULL;
	//}

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
/*** GUI GO/STOP OnButton Click Event Handlers ***/
void MainFrame::OnGo(wxCommandEvent &event)
{
	if (!this->FetchTextCtrlData())
	{
		// invalid text control data
		return;
	}

	if (!this->StartSpinnakerNetwork())
	{
		// Failed to start Neuronscape Network
		this->StopSpinnakerNetwork();
		return;
	}

	if (!this->StartClientPacketProcessing())
	{
		// Failed to start Packet Processing
		this->StopClientPacketProcessing();
		this->StopSpinnakerNetwork();
	}

	if (!this->StartNeuronscapeNetwork())
	{
		// Failed to start Neuronscape Network
		this->StopClientPacketProcessing();
		this->StopSpinnakerNetwork();
		this->StopNeuronscapeNetwork();
		return;
	}



	return;
}
void MainFrame::OnStop(wxCommandEvent &event)
{

	// This if statement checks to see if the stop button has been pressed while we are already in the process of disconnecting.
	// It stops the user from sending multiple requests to disconnect whilst the system is already processing a disconnection.
	if ((event.GetId() == ID_STOP)&&(this->m_PendingSocketShutdown == true))
	{
		return;
	}
	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetRetinaThread(NULL);

	this->StopMotorThread();
	this->StopRetinaThread();
	this->StopNeuronscapeNetwork();
	this->StopSpinnakerNetwork();
	return;
}
/***** Neuronscape Network Socket & Stack Event Handlers *****/
void MainFrame::OnNSSocketEvent(wxSocketEvent &event)
{
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

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

		//CNS_Status = this->m_NetworkStack->ProcessNetworkPacket(Peer, Data);
		//this->OnNSNetworkStackEvent(CNS_Status);
		this->m_ClientPacketProcessing->PostPacket(Peer, Data);
		break;

	default:
		// Another event occurred which should have
		wxLogMessage("Unexpected Event Occurred on Neuronscape Network Socket!");
		break;
	}
}
void MainFrame::OnNSNetworkStackEvent(wxCommandEvent &event)
{
	EyePanel *Eye;
	int EventCode = event.GetInt();
	int SecondCode = event.GetExtraLong();

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
		this->OnNSNetworkStackConnectedEvent();
		break;
	case CLI_NS_DISCONNECTED:
		// We have been disconnected
		this->OnNSNetworkStackDisconnectedEvent();
		break;
	case CLI_NS_DISCONNECT_FORCED:
		// We have been disconnected forcefully by the server
		this->OnNSNetworkStackDisconnectedForcedEvent();
		break;
	case CLI_NS_ENUM:
		// We have been enumerated, we are ready to go
		this->OnNSNetworkStackEnumEvent();
		break;
	case CLI_NS_ASSIGNED_OBJECT:
		// We have been assigned an object, now the recptor & muscle modelling can begin
		this->OnNSNetworkStackAssignedObjectEvent();
		break;
	case CLI_NS_TEST_ECHO_REPLY:
		// Do nothing
		break;
	case CLI_NS_ASSIGNED_OBJECT_REMOVED:
		// The assigned object has been removed, stop receptor & muscle modelling
		this->OnNSNetworkStackAssignedObjectRemovedEvent();
		break;
	case CLI_NS_OBJECT_DATA_DIRTY:
		// The Object Information Database has been marked as dirty
		// We must re-evaluate all equations
		if (SecondCode == this->m_ClientID) // Then this NEI was the client eating the object
		{
			this->m_SpinnNetStack->SendReward();
		}
		this->OnNSNetworkStackObjectDataDirtyEvent();
		break;
	case CLI_NS_OBJECT_EATEN:
		this->OnNSNetworkStackRemoveEatenObj();
		break;
	case CLI_NS_KILL:
		Eye = (EyePanel*) this->FindWindowByName("EyePanel");
		Eye->SetArguements(CartesianVector(0.0,0.0,0.0),NULL);
		Eye->SetRetinaThread(NULL);
		Eye->SetObjectID(0);

		this->StopRetinaThread();

		// we have been forcefully disconnected, we must stop all processing and
		// reset to an initial unconnected state
		this->StopMotorThread();
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
		this->OnNSNetworkStackErrorEvent();
		break;
	default:
		// An unknown event occured, this should not occur!
		break;
	}
}
void MainFrame::OnNSNetworkStackConnectedEvent()
{
	// Stop the timeout timer!
	if (this->m_NSTimer != NULL)
	{
		this->m_NSTimer->Stop();
		delete this->m_NSTimer;
		this->m_NSTimer = NULL;
	}

	this->m_ClientID = this->m_ClientPacketProcessing->GetAssignedClientID();
	wxLogMessage("Connected - Assigned ID: %d",this->m_ClientID);
	return;
}
void MainFrame::OnNSNetworkStackDisconnectedEvent()
{
	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetArguements(CartesianVector(0.0,0.0,0.0),NULL);
	Eye->SetRetinaThread(NULL);
	Eye->SetObjectID(0);

	this->StopRetinaThread();

	this->m_NSTimer->Stop();
	delete this->m_NSTimer;
	this->m_NSTimer = NULL;
	this->StopMotorThread();
	this->m_PendingSocketShutdown = false;

	this->StopClientPacketProcessing();
	// stop the object processing thread
	// delete the object processing thread
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
void MainFrame::OnNSNetworkStackDisconnectedForcedEvent()
{
	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetArguements(CartesianVector(0.0,0.0,0.0),NULL);
	Eye->SetRetinaThread(NULL);
	Eye->SetObjectID(0);

	this->StopRetinaThread();
	this->StopClientPacketProcessing();
	// we have been forcefully disconnected, we must stop all processing and
	// reset to an initial unconnected state
	this->StopMotorThread();
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
void MainFrame::OnNSNetworkStackEnumEvent()
{
	// Fetch the environmental parameters!
	this->m_ClientPacketProcessing->GetEnvDimensions(this->m_EnvParameters.EnvDim);

	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetArguements(this->m_EnvParameters.EnvDim,&this->m_ObjectDb);

	// Now request to add an object
	this->m_NetworkStack->SendAddObjectRequest(this->m_ControlsData.InitialEnergy);
}
void MainFrame::OnNSNetworkStackAssignedObjectEvent()
{
	// notify object processing thread
	this->m_ObjectID = this->m_ClientPacketProcessing->GetAssignedObjectID();
	wxLogMessage("Assigned Object: %d",this->m_ObjectID);

	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetObjectID(this->m_ObjectID);

	this->StartMotorThread();

	this->StartRetinaThread();

	Eye->SetRetinaThread(this->m_RetinaThread);
}
void MainFrame::OnNSNetworkStackAssignedObjectRemovedEvent()
{
	// notify object processing thread
	//this->StopObjectThread();
	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetRetinaThread(NULL);
	Eye->SetObjectID(0);

	this->StopRetinaThread();

	this->StopMotorThread();

	this->m_ObjectID =	this->m_ClientPacketProcessing->GetAssignedObjectID();

	// If we are trying to shutdown the socket then the object removal event was
	// the first step, we must now ask the server if we can disconnect.
	if (this->m_PendingSocketShutdown)
	{
		this->m_NetworkStack->SendDisconnectionRequest();
	}
	return;
}
void MainFrame::OnNSNetworkStackObjectDataDirtyEvent()
{
	this->m_ObjectDb.ClearDirtyBit();

	DBRecord_ClientObject Record;

	uint32_t ID = this->m_ClientPacketProcessing->GetAssignedObjectID();

	if (this->m_ObjectDb.FindByID(ID,Record))
	{
		if (Record.Energy != Record.Energy)
		{
			wxLogError("Fault, Reported Energy NAN");
			
			return;
			// This if statement checks to see if the stop button has been pressed while we are already in the process of disconnecting.
			// It stops the user from sending multiple requests to disconnect whilst the system is already processing a disconnection.
			if (this->m_PendingSocketShutdown == true)
			{
				return;
			}
			EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
			Eye->SetRetinaThread(NULL);

			this->StopMotorThread();
			this->StopRetinaThread();
			this->StopNeuronscapeNetwork();
			this->StopSpinnakerNetwork();

		}

		this->UpdateEnergyST(Record.Energy);
	}

}
void MainFrame::OnNSNetworkStackRemoveEatenObj()
{

}
void MainFrame::OnNSNetworkStackErrorEvent()
{
	// get the error flags from the network stack
	// handle error if possible
}
void MainFrame::OnNSNetworkStackTimeout(wxTimerEvent &event)
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
	case ID_TIMER_NSCONNECTIONTIMEOUT:
		this->StopClientPacketProcessing();
		// a connection attempt timed out, reset everything and display a message
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

		this->StopSpinnakerNetwork();
		break;

	case ID_TIMER_NSDISCONNECTIONTIMEOUT:
		wxLogError("Error Disconnecting From Server: Timeout - Server unresponsive, Warning! Server Database may be inconsistent!");
		this->StopClientPacketProcessing();
		// notify object processing thread
		this->StopMotorThread();
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
/***** Spinnaker Network Socket & Stack Event Handlers *****/
void MainFrame::OnSPSocketEvent(wxSocketEvent &event)
{
	wxSocketBase *sock = event.GetSocket();

	wxDatagramSocket *dgsock = (wxDatagramSocket*) sock;
	int Spin_NS_Status = 0;
	wxString LogMessage;
	wxString Msg;
	Msg.Printf("spinnaker net sock activated");
	wxLogMessage(Msg);
	SNS_STAT Status;

	switch(event.GetSocketEvent())
	{
	case wxSOCKET_INPUT:
		if (this->m_SpinnNetStack == NULL)
		{
			sock->Discard();
			return;
		}

		if (this->m_SpinnNetStack->IsOK() == false)
		{
			sock->Discard();
			return;
		}

		Status = this->m_SpinnNetStack->ProcessNetworkPacket(dgsock);
		Msg.Printf("  and packet processed");
		wxLogMessage(Msg);
		this->OnSPNetworkStackEvent(Status);
		break;

	default:
		// Another event occurred which should have
		LogMessage.Append("Unexpected Event Occurred on Neuronscape Network Socket!");
		wxLogMessage(LogMessage.c_str());
		break;
	}
}
void MainFrame::OnSPNetworkStackEvent(SNS_STAT Status)
{
	switch (Status.Status)
	{
	case SPIN_NS_SPIKE:

		switch (Status.Spike.NeuronNumber)
		{
		case 1:
			this->m_MotorThread->ForwardBackwardMuscle(false);
			break;

		case 2:
			this->m_MotorThread->RotateTheta(true);
			break;

		case 3:
			this->m_MotorThread->RotateTheta(false);
			break;

		case 4:
			this->m_NetworkStack->SendEatObject(0);
			break;

		default:
			break;
		}
		break;

	default:
		break;
	}
}
void MainFrame::OnSPNetworkStackErrorEvent()
{

}
void MainFrame::OnSPNetworkStackTimeout(wxTimerEvent &event)
{

}
//
void MainFrame::OnMotorForceUpdate(TransmitThreadNetworkPacketEvent &event)
{
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	this->m_NetworkStack->SendString(event.GetPayload());
}
void MainFrame::OnRetinaUpdate(wxCommandEvent &event)
{
	unsigned RetinaSize = this->m_ControlsData.Retinax*this->m_ControlsData.Retinay;
	//unsigned char *Red = new unsigned char[RetinaSize];

	//unsigned char *Blue = NULL;

	// want the green data regardless (this is the plane where greyscale data is stored if it has been downmixed)
	this->m_RetinaThread->LockMutex();
	unsigned char *Green = this->m_RetinaThread->GetGreenData();
	this->m_RetinaThread->UnlockMutex();

	unsigned Length = this->m_RetinaThread->GetLength();

	if(this->m_ControlsData.RetinaGrey)
	{
		this->m_SpinnNetStack->SendVisualData(NULL, Green, NULL, Length, this->m_ControlsData.Retinay, this->m_ControlsData.RetinaGrey);
	} 
	else
	{
		// need to find red and blue channels as well
		this->m_RetinaThread->LockMutex();
		unsigned char *Blue = this->m_RetinaThread->GetBlueData();
		unsigned char *Red  = this->m_RetinaThread->GetRedData();
		this->m_RetinaThread->UnlockMutex();
		// send full colour data
		this->m_SpinnNetStack->SendVisualData(Red, Green, Blue, Length, this->m_ControlsData.Retinay, this->m_ControlsData.RetinaGrey);
		// clean up
		if (Red   != NULL){	delete [] Red; }
		if (Blue  != NULL){	delete [] Blue; }
	}
	if (Green != NULL){	delete [] Green; }



}
/***********************************************************/
/*** SYSTEM COMPONENT CONTROL FUNCTION SECTION           ***/
/***********************************************************/
// Start/Stop Neuronscape Network Stack
bool MainFrame::StartNeuronscapeNetwork()
{
	if (this->m_NetworkStack != NULL)
	{
		// network stack already exists. Return
		return false;
	}

	this->m_NetworkStack = new NetworkStackClient();

	if (!this->m_NetworkStack->StartNetworkSocket(this->m_RemoteHost,this,(int) ID_NSSOCKET_EVENT,&this->m_ObjectDb))
	{
		// failed to start network socket
		return false;
	}

	if (!this->m_NetworkStack->IsOK())
	{
		// network socket is not properly initialised
		return false;
	}

	// now we must send a connection request!
	this->m_NetworkStack->SendConnectionRequest(ROLE_NEUENV);

	// we must also start a one shot timer for 5 seconds (5000 ms).
	// if after 5 seconds we are not connected then we have a timeout situation
	this->m_NSTimer = new wxTimer(this,ID_TIMER_NSCONNECTIONTIMEOUT);
	this->m_NSTimer->Start(5000,true);

	this->m_ClientID = 0;

	return true;
}
void MainFrame::StopNeuronscapeNetwork()
{
	wxLogMessage("Stop Button Pressed!");
	// Networking is not initialised
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	// Grab the status of the network stack!
	uint16_t ClientID = this->m_ClientPacketProcessing->GetAssignedClientID();
	uint16_t ObjectID = this->m_ClientPacketProcessing->GetAssignedObjectID();

	// If the clientID is 0 then we are not connected to a server, we can delete the NetworkStack object and Exit
	if (ClientID == 0)
	{
		this->StopClientPacketProcessing();

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
	// if the ObjectID is Zero but the clientID is not then we must disconnect from the server first
	else if (ObjectID == 0)
	{	
		this->m_PendingSocketShutdown = true;
		this->m_NetworkStack->SendDisconnectionRequest();
		// we must also start a one shot timer for 5 seconds (5000 ms).
		// if after 5 seconds we are not connected then we have a timeout situation
		this->m_NSTimer = new wxTimer(this,ID_TIMER_NSDISCONNECTIONTIMEOUT);
		this->m_NSTimer->Start(10000,true);
	}
	// if both values are non-zero then we must remove the object first, then the client
	else
	{	
		this->StopMotorThread();
		this->m_PendingSocketShutdown = true;
		this->m_NetworkStack->SendDeleteObject(ObjectID);
		// we must also start a one shot timer for 5 seconds (5000 ms).
		// if after 5 seconds we are not connected then we have a timeout situation
		this->m_NSTimer = new wxTimer(this,ID_TIMER_NSDISCONNECTIONTIMEOUT);
		this->m_NSTimer->Start(10000,true);
	}
}
// Start/Stop Neuronscape Client Packet Process Thread
bool MainFrame::StartClientPacketProcessing()
{
	if (this->m_ClientPacketProcessing != NULL)
	{
		// Thread already exists
		return false;
	}


	this->m_ClientPacketProcessing = new ClientPacketProcessThread(this);

	this->m_ClientPacketProcessing->Initialize(&this->m_ObjectDb);

	if (this->m_ClientPacketProcessing->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_ClientPacketProcessing;
		this->m_ClientPacketProcessing = NULL;
		return false;
	}

	if (this->m_ClientPacketProcessing->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_ClientPacketProcessing;
		this->m_ClientPacketProcessing = NULL;
		return false;
	}

	return true;
}
void MainFrame::StopClientPacketProcessing()
{
	wxIPV4address BlankAddress;
	std::vector<unsigned char> EmptyVector;
	this->m_ClientPacketProcessing->PostPacket(BlankAddress,EmptyVector);
	this->m_ClientPacketProcessing->Delete();
	delete this->m_ClientPacketProcessing;
	this->m_ClientPacketProcessing = NULL;
}
// Start/Stop Spinnaker Network Stack
bool MainFrame::StartSpinnakerNetwork()
{
	if (this->m_SpinnNetStack != NULL)
	{
		// network stack already exists. Return
		return false;
	}

	this->m_SpinnNetStack = new SpinnakerNetStack();

	if (!this->m_SpinnNetStack->StartNetworkSocket(this->m_SpinnakerHost, (this), ID_SPSOCKET_EVENT))
	{
		// failed to start network socket
		return false;
	}

	if (!this->m_SpinnNetStack->IsOK())
	{
		// network socket is not properly initialised
		return false;
	}

	if (!this->m_SpinnNetStack->Test(this->m_ControlsData.VisualTag))
	{
		wxLogError("Failed to connect with Spinnaker Board, Please check the board and try again");
		return false;
	}
	this->m_SpinnNetStack->SetVisualTarget(this->m_ControlsData.VisualChipX,this->m_ControlsData.VisualChipY,this->m_ControlsData.VisualCPU,1,1);
	this->m_SpinnNetStack->SetRewardTarget(this->m_ControlsData.RewardChipX,this->m_ControlsData.RewardChipY,this->m_ControlsData.RewardCPU,1,5);
	this->m_SpinnNetStack->SetNeuronSpike(NEI_SPIKE_COMMAND_RC); // want this to be a #defined parameter. RM
	// above sets m_Spike_Command; also need to set m_State_Command here. RM
	this->m_SpinnNetStack->SetSpikeQueue(this->m_NeuronSpikeQueue, this->m_NeuronSpikeQueueMutex);

	return true;
}
void MainFrame::StopSpinnakerNetwork()
{
	delete this->m_SpinnNetStack;
	this->m_SpinnNetStack = NULL;
}
// Start/Stop Motor Thread
int MainFrame::StartMotorThread()
{
	this->m_MotorThread = new MotorThread(this);

	this->m_MotorThread->Initialize(this->m_RemoteHost,&this->m_ObjectDb,this->m_ObjectID,17);

	if (this->m_MotorThread->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_MotorThread;
		this->m_MotorThread = NULL;
		return 2;
	}

	if (this->m_MotorThread->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_MotorThread;
		this->m_MotorThread = NULL;
		return 3;
	}

	return 0;
}
void MainFrame::StopMotorThread()
{
	if (this->m_MotorThread == NULL)
	{
		return;
	}

	this->m_MotorThread->Delete();

	delete this->m_MotorThread;
	this->m_MotorThread = NULL;
}
// Start/Stop Retina Thread
int MainFrame::StartRetinaThread()
{
	this->m_RetinaThread = new RetinaThread(this);

	wxSize RetinaSize = wxSize(this->m_ControlsData.Retinax,this->m_ControlsData.Retinay);
	this->m_RetinaThread->Initialize(RetinaSize,this->m_ControlsData.RetinaGrey);

	if (this->m_RetinaThread->Create() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_RetinaThread;
		this->m_RetinaThread = NULL;
		return 2;
	}

	if (this->m_RetinaThread->Run() != wxTHREAD_NO_ERROR )
	{
		wxLogError("Can't create the thread!");
		delete this->m_RetinaThread;
		this->m_RetinaThread = NULL;
		return 3;
	}

	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetRetinaThread(this->m_RetinaThread);
	return 0;
}
void MainFrame::StopRetinaThread()
{

	if (this->m_RetinaThread == NULL)
	{
		return;
	}

	EyePanel *Eye = (EyePanel*) this->FindWindowByName("EyePanel");
	Eye->SetRetinaThread(NULL);

	this->m_RetinaThread->Exit();
	this->m_RetinaThread->Delete();

	delete this->m_RetinaThread;
	this->m_RetinaThread = NULL;
}
/***********************************************************/
/*** EVENT TABLE SECTION FOR MAINFRAME CLASS             ***/
/***********************************************************/
BEGIN_EVENT_TABLE(MainFrame, wxFrame)
	EVT_CLOSE(MainFrame::OnClose)
	EVT_SOCKET(ID_NSSOCKET_EVENT, MainFrame::OnNSSocketEvent)
	EVT_SOCKET(ID_SPSOCKET_EVENT, MainFrame::OnSPSocketEvent)
	EVT_BUTTON(ID_GO,MainFrame::OnGo)
	EVT_BUTTON(ID_STOP,MainFrame::OnStop)
	EVT_TIMER(ID_TIMER_NSCONNECTIONTIMEOUT,MainFrame::OnNSNetworkStackTimeout)
	EVT_TIMER(ID_TIMER_NSDISCONNECTIONTIMEOUT,MainFrame::OnNSNetworkStackTimeout)
	EVT_TIMER(ID_TIMER_SPCONNECTIONTIMEOUT,MainFrame::OnSPNetworkStackTimeout)
	EVT_TIMER(ID_TIMER_SPDISCONNECTIONTIMEOUT,MainFrame::OnSPNetworkStackTimeout)
	EVT_TXMOTORFORCEUPDATE (ID_MOTOR_FORCE_UPDATE, MainFrame::OnMotorForceUpdate)
	EVT_COMMAND (ID_RETINA_UPDATE, wxEVT_COMMAND_TEXT_UPDATED, MainFrame::OnRetinaUpdate)
	EVT_COMMAND (ID_PROCESSPACKET, wxEVT_COMMAND_TEXT_UPDATED, MainFrame::OnNSNetworkStackEvent)
	EVT_SIZE(MainFrame::OnSize)
	END_EVENT_TABLE()