#include "MainFrame.h"

#define VID 0x04B4
#define PID 0x3081

DEFINE_EVENT_TYPE(ID_USB_RCV)

/***** MainFrame Constructor *****/
MainFrame::MainFrame(const wxString& title)	
: wxFrame(NULL, wxID_ANY, title, wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL,wxT("MainFrame"))
{
	// Center the frame on the screen
	this->Center();

	// Set the background colour of the frame to white
	//this->SetBackgroundColour(wxColour(128,128,128));
	
	this->InitMenuBar();
	this->LayoutWindowControls();
	// Create the status bar
	this->CreateStatusBar(1);

	this->m_USBInterface = NULL;
	this->m_ServerPort = 12000;
	this->m_NetworkStack = NULL;
}
/***** MainFrame Destructor *****/
MainFrame::~MainFrame()
{

}
void MainFrame::InitMenuBar()
{
	/***** Menu Bar *****/
	m_MenuBar = new wxMenuBar();

	/***** File Menu *****/
	m_FileMenu = new wxMenu();
	m_FileMenu->Append(wxID_EXIT, wxT("&Quit"));

	m_MenuBar->Append(m_FileMenu, wxT("&File"));

	/***** USB Data Capture Menu *****/
	m_USBDeviceControlMenu = new wxMenu();
	m_USBDeviceControlMenu->Append(ID_DEVICECONNECT, wxT("Connect to USB Device"));
    m_USBDeviceControlMenu->Append(ID_DEVICEDISCONNECT, wxT("Disconnect from USB Device"));
	this->m_USBDeviceControlMenu->Enable(ID_DEVICEDISCONNECT,false);
	m_MenuBar->Append(m_USBDeviceControlMenu,wxT("Device Control"));

	/***** Server Menu *****/
	m_ServerControlMenu = new wxMenu();
	m_ServerControlMenu->Append(ID_SERVERCONNECT, wxT("Start Listening for Connections"));
	m_ServerControlMenu->Append(ID_SERVERDISCONNECT, wxT("Stop Listening for Connections"));
	this->m_ServerControlMenu->Enable(ID_SERVERDISCONNECT,false);
	m_ServerControlMenu->Append(ID_SERVERLISTENPORT, wxT("Change Server Port"));
    m_MenuBar->Append(m_ServerControlMenu,wxT("Server Control"));

	/***** Help Menu *****/
	m_HelpMenu = new wxMenu();
	m_HelpMenu->Append(wxID_ABOUT, wxT("&About"));

	m_MenuBar->Append(m_HelpMenu, wxT("&Help"));

	/***** Init MenuBar *****/
	this->SetMenuBar(m_MenuBar);


}
void MainFrame::LayoutWindowControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);	
	wxBoxSizer *HSizer = new wxBoxSizer(wxHORIZONTAL);
	wxBoxSizer *VSizer1 = new wxBoxSizer(wxVERTICAL);
    wxBoxSizer *VSizer2 = new wxBoxSizer(wxVERTICAL);

	TopLevelSizer->AddStretchSpacer(1);
	TopLevelSizer->AddSpacer(20);
	TopLevelSizer->Add(HSizer,0,wxALIGN_CENTER,5);
	TopLevelSizer->AddSpacer(20);
	TopLevelSizer->AddStretchSpacer(1);
	
	HSizer->AddStretchSpacer(1);
	HSizer->AddSpacer(40);
	HSizer->Add(VSizer1,0,wxALIGN_CENTER,5);
	HSizer->AddSpacer(10);
	HSizer->Add(VSizer2,0,wxALIGN_CENTER,5);
	HSizer->AddSpacer(40);
	HSizer->AddStretchSpacer(1);

	wxStaticText *ST_NetworkListeningPort1 = new wxStaticText(this,wxID_ANY,wxT("Listening on TCP Port:"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	VSizer1->Add(ST_NetworkListeningPort1,0,wxALIGN_LEFT);
    wxStaticText *ST_USBDeviceStatus1 = new wxStaticText(this,wxID_ANY,wxT("USB Device Status:"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	VSizer1->Add(ST_USBDeviceStatus1,0,wxALIGN_LEFT);	
    wxStaticText *ST_USBClientStatus1 = new wxStaticText(this,wxID_ANY,wxT("Network Client Status:"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	VSizer1->Add(ST_USBClientStatus1,0,wxALIGN_LEFT);		
	
	wxStaticText *ST_NetworkListeningPort2 = new wxStaticText(this,wxID_ANY,wxT("Not Listening"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NetworkListeningPort"));
	VSizer2->Add(ST_NetworkListeningPort2,0,wxALIGN_LEFT);
	wxStaticText *ST_USBDeviceStatus2 = new wxStaticText(this,wxID_ANY,wxT("Not Connected"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_USBDeviceStatus"));
	VSizer2->Add(ST_USBDeviceStatus2,0,wxALIGN_LEFT);
    wxStaticText *ST_USBClientStatus2 = new wxStaticText(this,wxID_ANY,wxT("Not Connected"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ClientStatus"));
	VSizer2->Add(ST_USBClientStatus2,0,wxALIGN_LEFT);		

	this->SetSizer(TopLevelSizer);
	TopLevelSizer->Fit(this);

}
/***** File Menu Event Handlers *****/
/***** Function Responsible For Closing The Program *****/
void MainFrame::MenuExit(wxCommandEvent &event)
{
	/***** Close this Frame and Exit *****/
	this->Close(true);
}
/***** USB Device Control Menu Event Handlers *****/
/***** Function Responsible For Connecting to the USB Device *****/
void MainFrame::ConnectToUSB(wxCommandEvent &event)
{
	// Define NeuronControlData array & Initilize all values to zero
	unsigned char NeuronControlData[12] = {0}; 

	// Create a new instance of the NeuronUSBInterface
	this->m_USBInterface = new NeuronUSBInterface(this);
	// Send an open command to the new instance of NeuronUSBInterface (using VID & PID)
	if (!this->m_USBInterface->OpenUSBDevice(VID,PID))
	{   // If we fail to open the device, delete the instance and report the error
		delete this->m_USBInterface;
		this->m_USBInterface = NULL;
		return;
	}
	// Assert the System Reset on the NeuronUSBInterface
	if (!this->m_USBInterface->AssertSystemReset())
	{   // If we fail to assert the reset we must delete the instance and report the error
		delete this->m_USBInterface;
		this->m_USBInterface = NULL;
		return;
	}
	// Send 12 Zero Bytes on the Neuron Control interface to disable all the neurons
	if (!this->m_USBInterface->TransmitNeuronControlData(12,NeuronControlData))
	{	// If we fail to send the inital neuron control data we must delete the instance and report the error
		delete this->m_USBInterface;
		this->m_USBInterface = NULL;
		return;
	}
	// Start the thread for receiving USB data
	if (!this->m_USBInterface->EnableReceieveNeuronData())
	{
		// Could not start receive data thread
		return;
	}

	this->UpdateStatusLabel("ST_USBDeviceStatus","Connected");

	// Disable the Connect to USB Device Menu Entry
	this->m_USBDeviceControlMenu->Enable(ID_DEVICECONNECT,false);
	// Enable the Disconnect from USB Device Menu Entry
	this->m_USBDeviceControlMenu->Enable(ID_DEVICEDISCONNECT,true);
}
/***** Function Responsible For Disconnecting from the USB Device *****/
void MainFrame::DisconnectFromUSB(wxCommandEvent &event)
{
	// Define NeuronControlData array & Initilize all values to zero
	unsigned char NeuronControlData[12] = {0}; 

	// Check that an instance of the NeuronUSBInterface
	if (this->m_USBInterface == NULL)
	{	// We are not connected to the NeuronUSBInterface since the handle = NULL
		// Enable the Connect to USB Device Menu Entry
		this->m_USBDeviceControlMenu->Enable(ID_DEVICECONNECT,true);
		// Disable the Disconnect from USB Device Menu Entry
		this->m_USBDeviceControlMenu->Enable(ID_DEVICEDISCONNECT,false);
		return;
	}
	// Assert the System Reset on the NeuronUSBInterface
	if (!this->m_USBInterface->AssertSystemReset())
	{   // If we fail to assert the reset we must report the error
		return;
	}
	// Send 12 Zero Bytes on the Neuron Control interface to disable all the neurons
	if (!this->m_USBInterface->TransmitNeuronControlData(12,NeuronControlData))
	{	// If we fail to send the neuron control data we must report the error
		return;
	}
	// Attempt to Close the Handle to NeuronUSBInterface
	if (!this->m_USBInterface->CloseUSBDevice())
	{   // Failed to Close NeuronUSBInterface, Report Error
		return;
	}
	// Free the memory used by NeuronUSBInterface & Set Pointer to NULL
	delete this->m_USBInterface;
	this->m_USBInterface = NULL;

	this->UpdateStatusLabel("ST_USBDeviceStatus","Not Connected");
	// Enable the Connect to USB Device Menu Entry
	this->m_USBDeviceControlMenu->Enable(ID_DEVICECONNECT,true);
	// Disable the Disconnect from USB Device Menu Entry
	this->m_USBDeviceControlMenu->Enable(ID_DEVICEDISCONNECT,false);
}
/***** Server Control Menu Event Handlers *****/
/***** Function To Start listening for network connections *****/
void MainFrame::StartNetworkServer(wxCommandEvent &event)
{
	if (this->m_NetworkStack != NULL)
	{
		return;
	}
	
	wxString PortString;

	this->m_NetworkStack = new NetworkStack();

	if (!this->m_NetworkStack->StartServerSocket(this,ID_SOCKET_EVENT,this->m_ServerPort))
	{
		return;
	}

	PortString.Printf("%u",this->m_ServerPort);
	this->UpdateStatusLabel("ST_NetworkListeningPort",PortString);

	// Disable the Start Network Server Menu Entry
	this->m_ServerControlMenu->Enable(ID_SERVERCONNECT,false);
	// Enable the Stop Network Server Menu Entry
	this->m_ServerControlMenu->Enable(ID_SERVERDISCONNECT,true);
}
/***** Function To Stop listening for network connections *****/
void MainFrame::StopNetworkServer(wxCommandEvent &event)
{
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	delete this->m_NetworkStack;
	this->m_NetworkStack = NULL;

	this->UpdateStatusLabel("ST_NetworkListeningPort","Not Listening");
	this->UpdateStatusLabel("ST_ClientStatus","Not Connected");

	// Disable the Start Network Server Menu Entry
	this->m_ServerControlMenu->Enable(ID_SERVERCONNECT,true);
	// Enable the Stop Network Server Menu Entry
	this->m_ServerControlMenu->Enable(ID_SERVERDISCONNECT,false);
}
/***** Function Responsible For changing the port for listening for connections *****/
void MainFrame::ChangeNetworkPort(wxCommandEvent &event)
{
	long NewPort = 0;
	// This NewEvent Variable is a Dummy Variable Which Allows Us to Call Start/Stop Network
	// server functions directly.
	wxCommandEvent NewEvent(wxID_ANY);
	wxString Message = "";
	wxString Caption = "Change the Server Port";
	wxString Prompt = "Enter a new port number between 1024 and 65536: ";

	NewPort = ::wxGetNumberFromUser(Message,Prompt,Caption,this->m_ServerPort,1024,65536,this,wxDefaultPosition);

	if (NewPort != -1)
	{
		// Is a client already connected?
		if (this->m_Connected)
		{
			// If we are connected to a client, display a warning message, 
			// allow user to decide if we should proceed.

		}
		// Are we already listening for connections?
		if (this->m_NetworkStack != NULL)
		{
			// If we are listening then we should stop listening, change the
			// port number and resume listening on the new port
			this->StopNetworkServer(NewEvent);
			this->m_ServerPort = NewPort;
			this->StartNetworkServer(NewEvent);
		}
		else
		{   
			// Otherwise just change the port number
			this->m_ServerPort = NewPort;
		}
	}
}
/***** Help Menu Event Handlers *****/
/***** Function Responsible For Displaying About Dialogue *****/
void MainFrame::MenuAbout(wxCommandEvent &event)
{
    wxAboutDialogInfo info;
    info.SetName(_("SUSCAN USB Ethernet Interface"));
    info.SetVersion(_("0.0.1 Beta"));
    info.SetDescription(_(""));
    info.SetCopyright(_T("(C) 2010 Julian Bailey <jab@ecs.soton.ac.uk>"));

	::wxAboutBox(info);
}
/***** Socket Events *****/
void MainFrame::OnSocketEvent(wxSocketEvent &event)
{
	wxSocketBase *sock = event.GetSocket();
	wxDatagramSocket *dgsock = (wxDatagramSocket*) sock;
	unsigned short ProcessPacketResponse = 0;
	wxString LogMessage;
	wxString NeuronControlData;

	switch(event.GetSocketEvent())
	{
	case wxSOCKET_INPUT:
		if (this->m_NetworkStack == NULL)
		{
			sock->Discard();
			return;
		}

		if (this->m_NetworkStack->IsOK() == false)
		{
			sock->Discard();
			return;
		}

		ProcessPacketResponse = this->m_NetworkStack->ProcessNetworkPacket(dgsock);


		switch (ProcessPacketResponse)
		{
		case NS_NOP:
			break;
		case NS_CONNECTED:
			this->m_Connected = true;
			this->UpdateStatusLabel("ST_ClientStatus","Connected");
			break;

		case NS_DISCONNECT_FORCED:
			this->m_Connected = false;
			this->UpdateStatusLabel("ST_ClientStatus","Not Connected");
			this->m_USBInterface->AssertSystemReset();
			this->m_USBInterface->DisableReceiveNeuronData();

			break;

		case NS_TEST_ECHO_REPLY:
			break;

		case NS_NCD_DATA_DIRTY:
			NeuronControlData = this->m_NetworkStack->GetNeuronControl();
			this->m_USBInterface->TransmitNeuronControlData(NeuronControlData);
			break;

		case NS_RESET_DATA_DIRTY:
			if (this->m_NetworkStack->GetReset())
			{
				this->m_USBInterface->AssertSystemReset();
				this->m_USBInterface->DisableReceiveNeuronData();
			}
			else
			{
				this->m_USBInterface->EnableReceieveNeuronData();
				this->m_USBInterface->DeassertSystemReset();
			}
			break;

		case NS_ERROR:
			break;

		default:
			break;

		}
		break;

	default:
		// Another event occurred which should have
		LogMessage.Append("Unexpected Event Occurred on Network Socket!");
		::wxLogMessage(LogMessage.c_str());
		break;
	}
}
/***** On USB Neuron Data Received *****/
void MainFrame::OnUSBDeviceReceiveData(wxCommandEvent &event)
{
	long i;
	long DataLength = 0;
	bool DirtyBit = false;
	wxString NeuronActivityData;

	unsigned char NeuronActivity[12];
	// Get the new neuron data
	this->m_USBInterface->ReceievedNeuronData(&DataLength,NeuronActivity);

	for (i=1; i < 12; i++)
	{
		this->m_NeuronActivity[i-1] = NeuronActivity[i];
	}

	for (i=0; i < 11; i++)
	{
		// If Current and Old Neuron Activity Data do not match then
		// set the DirtyBit.
		if (this->m_OldNeuronActivity[i] != this->m_NeuronActivity[i])
		{
			DirtyBit = true;
		}
	}

	// Check to see if the DirtyBit is Set
	if (DirtyBit == true)
	{
		// Copy the Current Neuron Activity Data Array to the Old Neuron Activity Data Array
		for (i=0; i < 11; i++)
		{
			this->m_OldNeuronActivity[i] = this->m_NeuronActivity[i];
			NeuronActivityData.Append(this->m_NeuronActivity[i]);
		}

		// Check to see if Client Socket Exists
		if (this->m_NetworkStack == NULL)
		{
			// If Client does not exist then do not continue, return
			return;
		}
		if (this->m_Connected)
		{
		// Send the new neuron data to the client
		this->m_NetworkStack->SendNeuronActivityData(NeuronActivityData);
		}
	}
}
/***** On Application Close Events *****/
void MainFrame::OnClose(wxCloseEvent &event)
{
	wxCommandEvent NewEvent(wxID_ANY);

	if (this->m_USBInterface != NULL)
	{
		this->DisconnectFromUSB(NewEvent);
	}

	if (this->m_NetworkStack != NULL)
	{
		this->StopNetworkServer(NewEvent);
	}

	event.Skip();
}

void MainFrame::UpdateStatusLabel(wxString ControlName, wxString Text)
{
	wxStaticText *LabelControl = (wxStaticText*) this->FindWindowByName(ControlName,this);

	if (LabelControl != NULL)
	{
		LabelControl->SetLabel(Text);
	}
}
/*******************************/
/** Event Table For MainFrame **/
/*******************************/
BEGIN_EVENT_TABLE(MainFrame, wxFrame)
// File Menu Events
EVT_MENU(wxID_EXIT, MainFrame::MenuExit)
// Device Control Menu Events
EVT_MENU(ID_DEVICECONNECT, MainFrame::ConnectToUSB)
EVT_MENU(ID_DEVICEDISCONNECT, MainFrame::DisconnectFromUSB)
// Server Control Menu Events
EVT_MENU(ID_SERVERCONNECT, MainFrame::StartNetworkServer)
EVT_MENU(ID_SERVERDISCONNECT, MainFrame::StopNetworkServer)
EVT_MENU(ID_SERVERLISTENPORT, MainFrame::ChangeNetworkPort)
// Help Menu Events
EVT_MENU(wxID_ABOUT, MainFrame::MenuAbout)
// Socket Events
EVT_SOCKET(ID_SOCKET_EVENT, MainFrame::OnSocketEvent)
// USB Receive Data Event
EVT_COMMAND(wxID_ANY,ID_USB_RCV,MainFrame::OnUSBDeviceReceiveData)
// Application Close Event
EVT_CLOSE(MainFrame::OnClose)
END_EVENT_TABLE()