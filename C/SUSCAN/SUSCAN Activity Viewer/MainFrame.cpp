#include "MainFrame.h"

WX_DEFINE_LIST(NeuronList)

	/***** MainFrame Constructor *****/
MainFrame::MainFrame(const wxString& title)	
: wxFrame(NULL, wxID_ANY, title, wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL,wxT("MainFrame"))
{
	this->m_NeuronList = NULL;

	this->InitMenuBar();
	this->LayoutControls();
	this->CreateStatusBar(1);

	// Center the frame on the screen
	this->Center();
	this->SetClientSize(this->GetClientAreaOrigin().x + 840, this->GetClientAreaOrigin().y + 580);
	wxWindow::SetBackgroundStyle(wxBG_STYLE_CUSTOM);

	/***** Set default values for internal variables *****/

	this->InitNeurons();

	/***** IMPORTANT NOTICE *****/
	// We do not issue a transmit neuron control data here because we
	// are not connected to the usb device server. This will be 
	// done when we next connect

	this->SetStopMotion(); // Set Motion to Stopped
	this->EnableAllNonDrivingNeurons(); // Enable All Normal Neurons
	this->ZeroAllNeuronActivity(); // Zeros Neuron Activity Buffer
	wxWindow::Refresh(); // Issue a Window Refresh
	wxWindow::Update(); // Issue a Window Update

	this->m_NetworkStack = NULL;
	this->m_Connected = false;
	this->m_Timer.SetOwner(this,ID_TIMER);
}
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

	/***** RoboElegans Data Capture Menu *****/

	/***** Help Menu *****/
	m_HelpMenu = new wxMenu();
	m_HelpMenu->Append(wxID_ABOUT, wxT("&About"));

	m_MenuBar->Append(m_HelpMenu, wxT("&Help"));

	/***** Init MenuBar *****/
	this->SetMenuBar(m_MenuBar);
}
void MainFrame::LayoutControls()
{
	wxToolBar *ToolBar = this->CreateToolBar(wxTB_HORIZONTAL|wxNO_BORDER,wxID_ANY,wxT("ToolBar"));
	wxStaticText *ST_ServerAddr = new wxStaticText(ToolBar,wxID_ANY,wxT("Server Address:"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ServerAddr"));
	wxStaticText *ST_ServerPort = new wxStaticText(ToolBar,wxID_ANY,wxT("Server Port:"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ServerPort"));
	wxTextCtrl *TC_ServerAddr = new wxTextCtrl(ToolBar,wxID_ANY,wxEmptyString,wxDefaultPosition,wxDefaultSize,wxTE_CENTRE,wxDefaultValidator,wxT("TC_ServerAddr"));
	wxTextCtrl *TC_ServerPort = new wxTextCtrl(ToolBar,wxID_ANY,wxEmptyString,wxDefaultPosition,wxDefaultSize,wxTE_CENTRE,wxDefaultValidator,wxT("TC_ServerPort"));

	wxToggleButton *TB_Connect = new wxToggleButton(ToolBar,ID_CONNECT,wxT("Connect..."),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Connect"));
	wxToggleButton *TB_Reset = new wxToggleButton(ToolBar,ID_RESET,wxT("Reset"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Reset"));
	wxToggleButton *TB_Forward = new wxToggleButton(ToolBar,ID_FORWARD,wxT("Forward"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Forward"));
	wxToggleButton *TB_Stop = new wxToggleButton(ToolBar,ID_STOP,wxT("Stop"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Stop"));
	wxToggleButton *TB_Backward = new wxToggleButton(ToolBar,ID_BACKWARD,wxT("Backward"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Backward"));
	wxToggleButton *TB_Coil = new wxToggleButton(ToolBar,ID_COIL,wxT("Coil"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("TB_Coil"));

	TB_Reset->Disable();
	TB_Forward->Disable();
	TB_Stop->Disable();
	TB_Backward->Disable();
	TB_Coil->Disable();

	//TC_ServerAddr->SetMaxLength(15);
	TC_ServerAddr->SetSize(TC_ServerPort->GetCharWidth()*17,wxDefaultSize.GetY());
	TC_ServerPort->SetMaxLength(5);
	TC_ServerPort->SetSize(TC_ServerPort->GetCharWidth()*7,wxDefaultSize.GetY());

	ToolBar->AddSeparator();
	ToolBar->AddControl(ST_ServerAddr);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TC_ServerAddr);
	ToolBar->AddSeparator();
	ToolBar->AddControl(ST_ServerPort);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TC_ServerPort);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Connect);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Reset);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Forward);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Stop);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Backward);
	ToolBar->AddSeparator();
	ToolBar->AddControl(TB_Coil);
	ToolBar->AddSeparator();

	ToolBar->Realize();
}
/***** Function Responsible For Displaying About Dialogue *****/
void MainFrame::MenuAbout(wxCommandEvent &event)
{

}
/***** Function Responsible For Closing The Program *****/
void MainFrame::MenuExit(wxCommandEvent &event)
{
	/***** Close this Frame and Exit *****/
	this->Close(true);
}
void MainFrame::InitNeurons()
{
	unsigned i;
	unsigned NeuronX;
	wxString NeuronName;

	/***** Relative Neuron X Start Position *****/
	unsigned InitNRTSDX = 0;
	unsigned InitMX = 100;
	unsigned InitBX = 70;
	unsigned InitAX = 130;
	unsigned InitDX = 100;
	unsigned InitAVX = 0;
	unsigned InitNRTSVX = 0;
	/***** Relative Neuron Y Positions *****/
	unsigned DMY = 0;
	unsigned DBY = 60;
	unsigned DAY = 120;
	unsigned DDY = 180;
	unsigned AVY = 240;
	unsigned VDY = 300;
	unsigned VAY = 360;
	unsigned VBY = 420;
	unsigned VMY = 480;
	/***** Distance Between Neurons Of Same Type *****/
	unsigned SeparationNRTSAV = 740;
	unsigned SeparationM = 60;
	unsigned SeparationB = 60;
	unsigned SeparationA = 60;
	unsigned SeparationD = 60;

	Neuron *NeuronListNode;

	this->m_NeuronEnabled[6] = true;
	this->m_NeuronEnabled[7] = true;

	this->m_NeuronList = new NeuronList;

	for (i=0;i<88;i++)
	{
		this->m_NeuronActivity[i] = false;
	}

	// Nerve Ring Neurons - NRD
	NeuronListNode = new Neuron(0);
	NeuronListNode->SetName("NRD");
	NeuronListNode->SetPosition(wxPoint(InitNRTSDX,DMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[0] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// Nerve Ring Neurons - NRV
	NeuronListNode = new Neuron(1);
	NeuronListNode->SetName("NRV");
	NeuronListNode->SetPosition(wxPoint(InitNRTSDX,VMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[1] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// AVB Neuron
	NeuronListNode = new Neuron(2);
	NeuronListNode->SetName("AVB");
	NeuronListNode->SetPosition(wxPoint(InitNRTSDX,AVY));
	// Set Colour To Orange (RGB 247 150 70)
	NeuronListNode->SetColour(wxColour(247,150,70));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[2] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// AVB Neuron
	NeuronListNode = new Neuron(3);
	NeuronListNode->SetName("AVA");
	NeuronListNode->SetPosition(wxPoint((InitNRTSDX+SeparationNRTSAV),AVY));
	// Set Colour To Orange (RGB 247 150 70)
	NeuronListNode->SetColour(wxColour(247,150,70));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[3] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// Nerve Ring Neurons - TSD
	NeuronListNode = new Neuron(4);
	NeuronListNode->SetName("TSD");
	NeuronListNode->SetPosition(wxPoint((InitNRTSDX+SeparationNRTSAV),DMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[4] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// Nerve Ring Neurons - TSV
	NeuronListNode = new Neuron(5);
	NeuronListNode->SetName("TSV");
	NeuronListNode->SetPosition(wxPoint((InitNRTSDX+SeparationNRTSAV),VMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	NeuronListNode->SetDisabled();
	this->m_NeuronEnabled[5] = false;
	this->m_NeuronList->Append(NeuronListNode);

	// Dummy Neuron
	NeuronListNode = new Neuron(6);
	NeuronListNode->SetName("");
	NeuronListNode->SetPosition(wxPoint((InitNRTSDX+SeparationNRTSAV),DMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	this->m_NeuronList->Append(NeuronListNode);

	// Dummy Neuron
	NeuronListNode = new Neuron(7);
	NeuronListNode->SetName("");
	NeuronListNode->SetPosition(wxPoint((InitNRTSDX+SeparationNRTSAV),VMY));
	// Set Colour To Green (RGB 0 176 80)
	NeuronListNode->SetColour(wxColour(0,176,80));
	this->m_NeuronList->Append(NeuronListNode);

	unsigned int TempInt = 0;

	for (i=0; i< 10; i++)
	{
		TempInt = (i * 8) + 8;

		// Create DM
		NeuronListNode = new Neuron(TempInt + 0);
		NeuronX = InitMX + (SeparationM*i);
		NeuronName.Empty();
		NeuronName.Printf("DM%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,DMY));
		// Set Colour To Yellow (RGB 255 255 0)
		NeuronListNode->SetColour(wxColour(255,255,0));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 0] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create DB
		NeuronListNode = new Neuron(TempInt + 1);
		NeuronX = InitBX + (SeparationB*i);
		NeuronName.Empty();
		NeuronName.Printf("DB%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,DBY));
		// Set Colour To Red (RGB 255 0 0)
		NeuronListNode->SetColour(wxColour(255,0,0));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 1] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create DA
		NeuronListNode = new Neuron(TempInt + 2);
		NeuronX = InitAX + (SeparationA*i);
		NeuronName.Empty();
		NeuronName.Printf("DA%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,DAY));
		// Set Colour To Purple (RGB 112 48 160)	
		NeuronListNode->SetColour(wxColour(112,48,160));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 2] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create DD
		NeuronListNode = new Neuron(TempInt + 3);
		NeuronX = InitDX + (SeparationD*i);
		NeuronName.Empty();
		NeuronName.Printf("DD%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,DDY));
		// Set Colour To Light Blue (RGB 85 142 210)	
		NeuronListNode->SetColour(wxColour(85,142,210));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 3] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create VM
		NeuronListNode = new Neuron(TempInt + 4);
		NeuronX = InitMX + (SeparationM*i);
		NeuronName.Empty();
		NeuronName.Printf("VM%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,VMY));
		// Set Colour To Yellow (RGB 255 255 0)
		NeuronListNode->SetColour(wxColour(255,255,0));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 4] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create VB
		NeuronListNode = new Neuron(TempInt + 5);
		NeuronX = InitBX + (SeparationB*i);
		NeuronName.Empty();
		NeuronName.Printf("VB%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,VBY));
		// Set Colour To Red (RGB 255 0 0)
		NeuronListNode->SetColour(wxColour(255,0,0));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 5] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create VA
		NeuronListNode = new Neuron(TempInt + 6);
		NeuronX = InitAX + (SeparationA*i);
		NeuronName.Empty();
		NeuronName.Printf("VA%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,VAY));
		// Set Colour To Purple (RGB 112 48 160)	
		NeuronListNode->SetColour(wxColour(112,48,160));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 6] = true;
		this->m_NeuronList->Append(NeuronListNode);

		// Create VD
		NeuronListNode = new Neuron(TempInt + 7);
		NeuronX = InitDX + (SeparationD*i);
		NeuronName.Empty();
		NeuronName.Printf("VD%u ", i );
		NeuronListNode->SetName(NeuronName);
		NeuronListNode->SetPosition(wxPoint(NeuronX,VDY));
		// Set Colour To Light Blue (RGB 85 142 210)	
		NeuronListNode->SetColour(wxColour(85,142,210));
		NeuronListNode->SetEnabled();
		this->m_NeuronEnabled[TempInt + 7] = true;
		this->m_NeuronList->Append(NeuronListNode);
	}
}
/***** Neuron Manipulation Functions *****/
void MainFrame::AssertDeviceReset()
{
	this->m_Timer.Stop(); // Stop the timer

	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	if (!this->m_Connected)
	{
		return;
	}
	
	this->m_NetworkStack->SendAssertReset();

	// Now we reset the Neuron Display and Send Reset Neuron Control Data
	this->ZeroAllNeuronActivity(); // Zeros Neuron Activity Buffer
	this->SetStopMotion(); // Set Motion to Stopped
	this->EnableAllNonDrivingNeurons(); // Enable All Normal Neurons
	this->SendNeuronControlPacket();
}
void MainFrame::DeassertDeviceReset()
{
	if (this->m_NetworkStack == NULL)
	{
		return;
	}

	if (!this->m_Connected)
	{
		return;
	}
	
	this->m_NetworkStack->SendReleaseReset();
	this->m_Timer.Start(17,false); // Timer runs at 17 ms interval 58.82 Hz
}
void MainFrame::SetNeuronEnabled(long NeuronID)
{
	this->m_NeuronList->Item(NeuronID)->GetData()->SetEnabled();
	this->m_NeuronEnabled[NeuronID] = true;
}
void MainFrame::SetNeuronDisabled(long NeuronID)
{
	this->m_NeuronList->Item(NeuronID)->GetData()->SetDisabled();
	this->m_NeuronEnabled[NeuronID] = false;
}
void MainFrame::SetForwardMotion()
{
	// Set All Forward Driving Neurons to enabled
	this->SetNeuronEnabled(0);
	this->SetNeuronEnabled(1);
	this->SetNeuronEnabled(2);
	// Set All Backward Driving Neurons to disabled
	this->SetNeuronDisabled(3);
	this->SetNeuronDisabled(4);
	this->SetNeuronDisabled(5);
	// Set Phase Offset for NRV & TSD to Enabled
	this->m_NeuronEnabled[6] = true; // NRV Phase
	this->m_NeuronEnabled[7] = true; // TSD Phase
}
void MainFrame::SetStopMotion()
{
	// Set All Forward Driving Neurons to disabled
	this->SetNeuronDisabled(0);
	this->SetNeuronDisabled(1);
	this->SetNeuronDisabled(2);
	// Set All Backward Driving Neurons to disabled
	this->SetNeuronDisabled(3);
	this->SetNeuronDisabled(4);
	this->SetNeuronDisabled(5);
	// Set Phase Offset for NRV & TSD to Enabled
	this->m_NeuronEnabled[6] = true; // NRV Phase
	this->m_NeuronEnabled[7] = true; // TSD Phase
}
void MainFrame::SetBackwardMotion()
{
	// Set All Forward Driving Neurons to disabled
	this->SetNeuronDisabled(0);
	this->SetNeuronDisabled(1);
	this->SetNeuronDisabled(2);
	// Set All Backward Driving Neurons to Enabled
	this->SetNeuronEnabled(3);
	this->SetNeuronEnabled(4);
	this->SetNeuronEnabled(5);
	// Set Phase Offset for NRV & TSD to Enabled
	this->m_NeuronEnabled[6] = true; // NRV Phase
	this->m_NeuronEnabled[7] = true; // TSD Phase
}
void MainFrame::SetCoilingMotion()
{
	// Set NRD & AVB Neurons to Enabled
	this->SetNeuronEnabled(0);
	this->SetNeuronEnabled(2);
	// Set NRV to Disabled
	this->SetNeuronDisabled(1);
	// Set TSD & AVA Neurons to Enabled
	this->SetNeuronEnabled(3);
	this->SetNeuronEnabled(4);
	// Set TSV to Disabled
	this->SetNeuronDisabled(5);
	// Set Phase Offset for NRV & TSD to Disabled
	this->m_NeuronEnabled[6] = false; // NRV Phase
	this->m_NeuronEnabled[7] = false; // TSD Phase
}
void MainFrame::EnableAllNonDrivingNeurons()
{
	int i;

	for (i=8; i < 88; i++)
	{
		this->SetNeuronEnabled(i);
	}
}
void MainFrame::ZeroAllNeuronActivity()
{
	int i;
	for (i=0; i < 88; i++)
	{
		this->m_NeuronActivity[i] = false;
	}
}
void MainFrame::ProcessNeuronDataPacket(unsigned char *NeuronData)
{
	int i;
	int k;
	unsigned char Bit;

	for(i=1;i<12;i++)
	{
		Bit = 1;

		for(k=0;k<8;k++)
		{
			if ((NeuronData[i])&(Bit))
			{   
				this->m_NeuronActivity[((i-1)*8)+k] = true;
			}
			else
			{
				this->m_NeuronActivity[((i-1)*8)+k] = false;
			}
			Bit = Bit << 1;
		}
	}
}
void MainFrame::ForceRepaintScreen(wxTimerEvent &event)
{
	wxWindow::Refresh();
	wxWindow::Update();
}
void MainFrame::ConnectToServer()
{

	wxTextCtrl *ServerAddress = (wxTextCtrl*) this->FindWindowByName(wxT("TC_ServerAddr"));
	wxTextCtrl *ServerPort = (wxTextCtrl*) this->FindWindowByName(wxT("TC_ServerPort"));

	wxIPV4address addr;

	if ((ServerAddress->IsEmpty() == true)||(ServerPort->IsEmpty() == true))
	{
		//wxMessageBox( wxT("Cannot have empty hostname and/or port number"), wxT("Connection Status"), wxICON_INFORMATION);
		::wxLogWarning("Cannot have empty hostname and/or port number");

		return; // Hostname or Port Textbox are empty
	}

	if (!addr.Hostname(ServerAddress->GetValue()))
	{   // Invalid Hostname/IpAddress
		return;
	}

	if (!addr.Service(ServerPort->GetValue()))
	{   // Invalid Port
		return;
	}

	if (this->m_NetworkStack != NULL)
	{
		return;
	}

	this->m_NetworkStack = new NetworkStack();

	if (this->m_NetworkStack == NULL)
	{	// Could not allocate memory for socket
		this->m_NetworkStack = NULL;
		return;
	}

	if (!this->m_NetworkStack->StartClientSocket(this,ID_SOCKET_EVENT))
	{
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
		return;
	}

	this->m_NetworkStack->SendConnectionRequest(addr);
}
void MainFrame::DisconnectFromServer()
{
	if (this->m_NetworkStack != NULL)
	{
		if (this->m_Connected)
		{
			this->m_NetworkStack->SendForceDisconnect();

		}
		this->m_Connected = false;
		this->m_NetworkStack->StopSocket();
		delete this->m_NetworkStack;
		this->m_NetworkStack = NULL;
	}

	// This zeros all buttons
	this->ResetAllButtonValues();

	this->SetButtonEnable(ID_RESET,false);
	this->SetButtonEnable(ID_FORWARD,false);
	this->SetButtonEnable(ID_STOP,false);
	this->SetButtonEnable(ID_BACKWARD,false);
	this->SetButtonEnable(ID_COIL,false);
	// Now we reset the Neuron Display and Send Reset Neuron Control Data
	this->ZeroAllNeuronActivity(); // Zeros Neuron Activity Buffer
}
/***** Drawing Context Functions *****/
void MainFrame::OnPaint(wxPaintEvent &event)
{
	wxBufferedPaintDC dc(this,wxBUFFER_CLIENT_AREA);

	wxPoint DrawingOffset(50,50);

	DrawingOffset = DrawingOffset + this->GetClientAreaOrigin();

	dc.SetBrush(*wxWHITE_BRUSH);
	dc.SetPen(*wxWHITE_PEN);

	dc.DrawRectangle(this->GetClientAreaOrigin(),this->GetClientSize());
	dc.SetBrush(wxNullBrush);
	dc.SetPen(wxNullPen);

	dc.SetDeviceOrigin(DrawingOffset.x,DrawingOffset.y);

	this->ReDraw_Neurons(&dc);
	this->SetSize(this->ClientToWindowSize(wxSize(840,580)));
	event.Skip();
}
void MainFrame::ReDraw_Neurons(wxBufferedPaintDC *dc)
{
	unsigned i;

	wxPoint NeuronOrigin;
	unsigned ObjectRadius = 25;
	unsigned Luminance;
	wxPen Pen;
	wxBrush Brush;
	wxColour Colour;

	wxSize TextSize;
	wxPoint TextPosition;

	NeuronList::compatibility_iterator NeuronListNode = this->m_NeuronList->GetFirst();

	if (this->m_NeuronList != NULL)
	{
		for (i=0;i< 88; i++)
		{
			if ((i == 6)||(i == 7))
			{
				continue; // Neurons 6/7 dont exisit, but are enable signals!
			}

			NeuronListNode = this->m_NeuronList->Item(i);

			Colour = NeuronListNode->GetData()->GetColour();

			if (this->m_NeuronActivity[i] == true)
			{
				Pen = wxPen(wxColour(255,0,128),1,wxSOLID);
				Colour = wxColour((~Colour.Red()),(~Colour.Green()),(~Colour.Blue()));
			}
			else
			{
				Pen = wxPen(wxColour(0,0,0),1,wxSOLID);
			}

			Brush = wxBrush(Colour,wxSOLID);
			dc->SetBrush(Brush);
			dc->SetPen(Pen);
			dc->DrawCircle(NeuronListNode->GetData()->GetPosition(),ObjectRadius);
			TextSize = dc->GetTextExtent(NeuronListNode->GetData()->GetName());

			TextPosition.x = (NeuronListNode->GetData()->GetPosition().x - TextSize.GetX()/2);
			TextPosition.y = (NeuronListNode->GetData()->GetPosition().y - TextSize.GetY()/2);

			Luminance = (unsigned) (0.3*(float)Colour.Red()) + (0.59*(float)Colour.Green()) + (0.11*(float)Colour.Blue());

			if (Luminance <= 120)
			{
				dc->SetTextForeground(wxColour(255,255,255));
			}
			else
			{
				dc->SetTextForeground(wxColour(0,0,0));
			}
			dc->DrawText(NeuronListNode->GetData()->GetName(),TextPosition.x,TextPosition.y);

			if (NeuronListNode->GetData()->IsEnabled() == false)
			{
				NeuronOrigin = NeuronListNode->GetData()->GetPosition();

				Pen = wxPen(wxColour(0,0,0),3,wxSOLID);
				dc->SetPen(Pen);
				dc->DrawLine(NeuronOrigin.x - 25, NeuronOrigin.y - 25, NeuronOrigin.x + 25, NeuronOrigin.y + 25);
				dc->DrawLine(NeuronOrigin.x - 25, NeuronOrigin.y + 25, NeuronOrigin.x + 25, NeuronOrigin.y - 25);
			}

		}
	}
}
void MainFrame::MouseButtons(wxMouseEvent &event)
{
	wxPoint MousePosition;
	wxPoint NeuronPosition;

	unsigned ObjectRadius = 25;
	wxPoint NeuronOffset = wxPoint(50,50);

	unsigned i;
	NeuronList::compatibility_iterator NeuronListNode;

	if (event.LeftDown())
	{
		MousePosition = event.GetPosition();

		for (i=0; i < this->m_NeuronList->GetCount(); i++)
		{
			if (i<88)
			{
				NeuronListNode = this->m_NeuronList->Item(i);
				NeuronPosition = NeuronListNode->GetData()->GetPosition();
				NeuronPosition = NeuronPosition + NeuronOffset;

				if ((MousePosition.x >= (NeuronPosition.x - 25))&&(MousePosition.x <= (NeuronPosition.x + 25)))
				{
					if ((MousePosition.y >= (NeuronPosition.y - 25))&&(MousePosition.y <= (NeuronPosition.y + 25)))
					{
						if (NeuronListNode->GetData()->IsEnabled() == false)
						{
							NeuronListNode->GetData()->SetEnabled();
							this->m_NeuronEnabled[i] = true;
						}
						else
						{
							NeuronListNode->GetData()->SetDisabled();
							this->m_NeuronEnabled[i] = false;
						}
						break;
					}
				}
			}
		}
		this->SendNeuronControlPacket();
	}
	else
	{
		event.Skip();
	}
}
/***** Toolbar Button Calback Functions *****/
void MainFrame::OnConnectClick(wxCommandEvent &event)
{
	// This zeros all buttons
	this->ResetAllButtonValues();

	if (this->m_Connected)
	{
		// This is a disconnection Request
		this->DisconnectFromServer();
	}
	else
	{
		// This is a connection request
		this->ConnectToServer();
	}

	return;
}
void MainFrame::OnResetClick(wxCommandEvent &event)
{
	if (this->GetButtonValue(ID_RESET) == true)
	{
    	this->SetButtonEnable(ID_FORWARD,false);
		this->SetButtonEnable(ID_STOP,false);
		this->SetButtonEnable(ID_BACKWARD,false);
		this->SetButtonEnable(ID_COIL,false);

		this->SetButtonValue(ID_FORWARD,false);
		this->SetButtonValue(ID_STOP,false);
		this->SetButtonValue(ID_BACKWARD,false);
		this->SetButtonValue(ID_COIL,false);
				
		this->AssertDeviceReset();

		wxWindow::Refresh(); // Issue a Window Refresh
		wxWindow::Update(); // Issue a Window Update

	}
	else
	{
    	this->SetButtonEnable(ID_FORWARD,true);
		this->SetButtonEnable(ID_STOP,true);
		this->SetButtonEnable(ID_BACKWARD,true);
		this->SetButtonEnable(ID_COIL,true);

		this->DeassertDeviceReset();
	}
}
void MainFrame::OnForwardClick(wxCommandEvent &event)
{
	this->SetButtonValue(ID_FORWARD,true);
	this->SetButtonValue(ID_STOP,false);
	this->SetButtonValue(ID_BACKWARD,false);
	this->SetButtonValue(ID_COIL,false);

	this->SetForwardMotion();
	this->SendNeuronControlPacket();
}
void MainFrame::OnStopClick(wxCommandEvent &event)
{
	this->SetButtonValue(ID_FORWARD,false);
	this->SetButtonValue(ID_STOP,true);
	this->SetButtonValue(ID_BACKWARD,false);
	this->SetButtonValue(ID_COIL,false);

	this->SetStopMotion();
	this->SendNeuronControlPacket();
}
void MainFrame::OnBackwardClick(wxCommandEvent &event)
{
	this->SetButtonValue(ID_FORWARD,false);
	this->SetButtonValue(ID_STOP,false);
	this->SetButtonValue(ID_BACKWARD,true);
	this->SetButtonValue(ID_COIL,false);


	this->SetBackwardMotion();
	this->SendNeuronControlPacket();
}
void MainFrame::OnCoilClick(wxCommandEvent &event)
{
	this->SetButtonValue(ID_FORWARD,false);
	this->SetButtonValue(ID_STOP,false);
	this->SetButtonValue(ID_BACKWARD,false);
	this->SetButtonValue(ID_COIL,true);


	this->SetCoilingMotion();
	this->SendNeuronControlPacket();
}
/***** Button Control *****/
void  MainFrame::ResetAllButtonValues()
{
	this->SetButtonValue(ID_CONNECT, false);
	this->SetButtonValue(ID_RESET, false);
	this->SetButtonValue(ID_FORWARD, false);
	this->SetButtonValue(ID_STOP, false);
	this->SetButtonValue(ID_BACKWARD, false);
	this->SetButtonValue(ID_COIL, false);
}

bool MainFrame::GetButtonValue(unsigned ID)
{
	wxToggleButton *Button = (wxToggleButton*) this->FindWindowById(ID);

	if (Button != NULL)
	{
		return Button->GetValue();
	}
	else
	{
		return false;
	}
}
void MainFrame::SetButtonValue(unsigned ID, bool Value)
{
	wxToggleButton *Button = (wxToggleButton*) this->FindWindowById(ID);

	if (Button != NULL)
	{
		return Button->SetValue(Value);
	}
}
void MainFrame::SetButtonEnable(unsigned ID, bool Value)
{
	wxToggleButton *Button = (wxToggleButton*) this->FindWindowById(ID);

	if (Button != NULL)
	{
		Button->Enable(Value);
	}
}
/***** GUI Function Callback Functions *****/
void MainFrame::OnClose(wxCloseEvent &event)
{
	this->m_Timer.Stop();

	this->DisconnectFromServer();

	// Clear The Neuron List
	if (this->m_NeuronList != NULL)
	{
		this->m_NeuronList->DeleteContents(true);
		this->m_NeuronList->Clear();
		delete this->m_NeuronList;
		this->m_NeuronList = NULL;
	}
	event.Skip();
}
/***** Network Functions *****/
// OnSocket Event Callback
void MainFrame::OnSocketEvent(wxSocketEvent &event)
{
	wxToggleButton *ConnectButton = (wxToggleButton*) this->FindWindowById(ID_CONNECT);
	wxSocketBase *sock = event.GetSocket();
	wxDatagramSocket *dgsock = (wxDatagramSocket*) sock;
	unsigned short ProcessPacketResponse = 0;
	wxString LogMessage;
	bool *NeuronActivity = NULL;

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
			this->SetButtonValue(ID_CONNECT,true);
			this->SetButtonEnable(ID_RESET,true);
			this->SetButtonValue(ID_RESET,true);

			this->SetButtonEnable(ID_FORWARD,false);
			this->SetButtonEnable(ID_STOP,false);
			this->SetButtonEnable(ID_BACKWARD,false);
			this->SetButtonEnable(ID_COIL,false);

			this->SetButtonValue(ID_FORWARD,false);
			this->SetButtonValue(ID_STOP,false);
			this->SetButtonValue(ID_BACKWARD,false);
			this->SetButtonValue(ID_COIL,false);
			this->m_Connected = true;
		    this->AssertDeviceReset();
			// Now we reset the Neuron Display and Send Reset Neuron Control Data
			this->ZeroAllNeuronActivity(); // Zeros Neuron Activity Buffer
			this->SetStopMotion(); // Set Motion to Stopped
			this->EnableAllNonDrivingNeurons(); // Enable All Normal Neurons
			break;

		case NS_DISCONNECT_FORCED:
			this->m_Connected = false;
	        // This zeros all buttons
	        this->ResetAllButtonValues();

			this->SetButtonEnable(ID_RESET,false);
			this->SetButtonEnable(ID_FORWARD,false);
			this->SetButtonEnable(ID_STOP,false);
			this->SetButtonEnable(ID_BACKWARD,false);
			this->SetButtonEnable(ID_COIL,false);
			// Now we reset the Neuron Display and Send Reset Neuron Control Data
			this->ZeroAllNeuronActivity(); // Zeros Neuron Activity Buffer
			this->SetStopMotion(); // Set Motion to Stopped
			this->EnableAllNonDrivingNeurons(); // Enable All Normal Neurons
			delete this->m_NetworkStack;
			this->m_NetworkStack = NULL;
			break;

		case NS_TEST_ECHO_REPLY:
			break;

		case NS_NAD_DATA_DIRTY:
			NeuronActivity = this->m_NetworkStack->GetNeuronActivity();

			for (unsigned i = 0; i < 88; i++)
			{
				this->m_NeuronActivity[i] = NeuronActivity[i];
			}

			delete [] NeuronActivity;
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
void MainFrame::SendNeuronControlPacket()
{
	wxString NeuronControlData;

	if (!this->m_Connected)
	{
		return;
	}

	for (unsigned i = 0; i < 11; i++)
	{
		bool TempData[8];
		for (unsigned j = 0; j < 8; j++)
		{
			TempData[j] = this->m_NeuronEnabled[(i*8)+j];
		}
		NeuronControlData.Append(Bit2Byte(TempData));
	}

	this->m_NetworkStack->SendNeuronControlData(NeuronControlData);
}
/*******************************/
/** Event Table For MainFrame **/
/*******************************/
BEGIN_EVENT_TABLE(MainFrame, wxFrame)
	EVT_MENU(wxID_ABOUT, MainFrame::MenuAbout)
	EVT_MENU(wxID_EXIT, MainFrame::MenuExit)
	EVT_PAINT(MainFrame::OnPaint)
	EVT_MOUSE_EVENTS(MainFrame::MouseButtons)
	EVT_TOGGLEBUTTON(ID_CONNECT,MainFrame::OnConnectClick)
	EVT_TOGGLEBUTTON(ID_RESET,MainFrame::OnResetClick)
	EVT_TOGGLEBUTTON(ID_FORWARD,MainFrame::OnForwardClick)
	EVT_TOGGLEBUTTON(ID_STOP,MainFrame::OnStopClick)
	EVT_TOGGLEBUTTON(ID_BACKWARD,MainFrame::OnBackwardClick)
	EVT_TOGGLEBUTTON(ID_COIL,MainFrame::OnCoilClick)
	EVT_SOCKET(ID_SOCKET_EVENT, MainFrame::OnSocketEvent)
	EVT_TIMER(ID_TIMER, MainFrame::ForceRepaintScreen)
	EVT_CLOSE(MainFrame::OnClose)
	END_EVENT_TABLE()