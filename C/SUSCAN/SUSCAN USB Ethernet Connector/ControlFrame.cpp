#include "ControlFrame.h"

DEFINE_EVENT_TYPE(ID_ENABLERESETBUTTON)
DEFINE_EVENT_TYPE(ID_DISABLEBUTTONS)


/***** MainFrame Constructor *****/
ControlFrame::ControlFrame(wxFrame* Parent,const wxString& title)
: wxFrame(Parent, wxID_ANY, title, wxDefaultPosition, wxSize(800,600),
		  wxCAPTION | wxCLIP_CHILDREN | wxFRAME_FLOAT_ON_PARENT)
{
	int i;

	this->SetBackgroundColour(wxColour(225,225,225));
	this->m_Parent = Parent;

	/***** Top Level Sizer *****/
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);
	this->SetSizer(TopLevelSizer);

	/***** Second Level Sizer to Give More Space (Border 5px) *****/
	wxBoxSizer *SecondLevelSizer = new wxBoxSizer(wxVERTICAL);
	TopLevelSizer->Add(SecondLevelSizer,1,wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALL, 5);

    wxStaticText *StatusText = new wxStaticText(this,ID_STATUS,wxT("Disconnected"));
	SecondLevelSizer->Add(StatusText,0,wxALIGN_CENTER);
	/***** Go Button *****/
	wxToggleButton *Connect = new wxToggleButton(this,ID_CONNECT,wxT("Connect..."));
	wxToggleButton *Reset = new wxToggleButton(this,ID_RESET,wxT("Reset"));
	wxToggleButton *Forward = new wxToggleButton(this,ID_FORWARD,wxT("Forward"));
	wxToggleButton *Backward = new wxToggleButton(this,ID_BACKWARD,wxT("Backward"));
	wxToggleButton *Coil = new wxToggleButton(this,ID_COIL,wxT("Coil"));
	wxToggleButton *Stop = new wxToggleButton(this,ID_STOP,wxT("STOP!"));
	SecondLevelSizer->Add(5,10,0);

	SecondLevelSizer->Add(Connect,0,wxALIGN_CENTER);
	SecondLevelSizer->Add(Reset,0,wxALIGN_CENTER);
	SecondLevelSizer->Add(Forward,0,wxALIGN_CENTER);
	SecondLevelSizer->Add(Backward,0,wxALIGN_CENTER);
	SecondLevelSizer->Add(Coil,0,wxALIGN_CENTER);
	SecondLevelSizer->Add(Stop,0,wxALIGN_CENTER);

	/***** These functions set the window to the perfect size *****/
	/***** for the controls inside and fix the maximum and    *****/
	/***** the minimum size to this value.                    *****/

	/***** Fit the windows around the controls *****/
	this->Fit();
	/***** Set the minimum size to the current size *****/
	this->SetMinSize(this->GetSize());
	/***** Set the maximum size to the current size *****/
	this->SetMaxSize(this->GetSize());

	for(i=0;i<6;i++)
	{
		this->m_ButtonStatus[i] = false;
	}

	Reset->Disable();
	Forward->Disable();
	Backward->Disable();
	Coil->Disable();
	Stop->Disable();
}

void ControlFrame::ButtonPress(wxCommandEvent &event)
{
	wxCommandEvent *NewEvent;
	wxToggleButton *Button;
	wxStaticText *Text;

	switch(event.GetId())
	{
	case ID_CONNECT:

		break;

	case ID_RESET:
		Button = (wxToggleButton*) this->FindWindow(ID_RESET);

		if (Button->GetValue())
		{
			Text = (wxStaticText*) this->FindWindow(ID_STATUS);
			Text->SetLabel(wxT("Connected\nSystem Reset"));

			Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
			Button->Disable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
			Button->Disable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
			Button->Disable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
			Button->Disable();
			Button->SetValue(false);
		}
		else
		{
			Text = (wxStaticText*) this->FindWindow(ID_STATUS);
			Text->SetLabel(wxT("Connected to Device\nSystem Ready"));

			Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
			Button->Enable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
			Button->Enable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
			Button->Enable();
			Button->SetValue(false);
			Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
			Button->Enable();
			Button->SetValue(true);
		}
		break;

	case ID_FORWARD:
		Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);

		Text = (wxStaticText*) this->FindWindow(ID_STATUS);
		Text->SetLabel(wxT("Connected to Device\nMoving Forwards"));

		Button->SetValue(true);
		Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
		Button->SetValue(false);

		break;

	case ID_BACKWARD:
		Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);

		Text = (wxStaticText*) this->FindWindow(ID_STATUS);
		Text->SetLabel(wxT("Connected to Device\nMoving Backwards"));

		Button->SetValue(true);
		Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
		Button->SetValue(false);

		break;

	case ID_COIL:
		Button = (wxToggleButton*) this->FindWindow(ID_COIL);

		Text = (wxStaticText*) this->FindWindow(ID_STATUS);
		Text->SetLabel(wxT("Connected to Device\nCoiling"));

		Button->SetValue(true);
		Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
		Button->SetValue(false);

		break;

	case ID_STOP:
		Button = (wxToggleButton*) this->FindWindow(ID_STOP);

		Text = (wxStaticText*) this->FindWindow(ID_STATUS);
		Text->SetLabel(wxT("Connected to Device\nStopped"));

		Button->SetValue(true);
		Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
		Button->SetValue(false);
		Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
		Button->SetValue(false);

		break;

	default:
		break;

	}

	NewEvent = new wxCommandEvent(ID_CONTROLPANELEVENT);
	NewEvent->SetInt(event.GetId());
	this->m_Parent->AddPendingEvent(*NewEvent);
	delete NewEvent;
}

void ControlFrame::EnableResetButton(wxCommandEvent &event)
{
	wxToggleButton *Button;
	wxStaticText *Text;

	Text = (wxStaticText*) this->FindWindow(ID_STATUS);
	Text->SetLabel(wxT("Connected to Device\nSystem in Reset"));
	
	Button = (wxToggleButton*) this->FindWindow(ID_CONNECT);
	Button->SetLabel(wxT("Disconnect"));


	Button = (wxToggleButton*) this->FindWindow(ID_RESET);
	Button->Enable();
	Button->SetValue(true);
	Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
	Button->Disable();
	Button->SetValue(false);
	event.StopPropagation();
}

void ControlFrame::DisableButtons(wxCommandEvent &event)
{
	wxToggleButton *Button;
	wxStaticText *Text;

	Text = (wxStaticText*) this->FindWindow(ID_STATUS);
	Text->SetLabel(wxT("Disconnected"));

	Button = (wxToggleButton*) this->FindWindow(ID_CONNECT);
	Button->SetLabel(wxT("Connect"));
	Button->SetValue(false);

	Button = (wxToggleButton*) this->FindWindow(ID_RESET);
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_FORWARD);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_BACKWARD);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_COIL);	
	Button->Disable();
	Button->SetValue(false);
	Button = (wxToggleButton*) this->FindWindow(ID_STOP);	
	Button->Disable();
	Button->SetValue(false);
	event.StopPropagation();
}

ControlFrame::~ControlFrame()
{
}
/*******************************/
/** Event Table For MainFrame **/
/*******************************/
BEGIN_EVENT_TABLE(ControlFrame, wxFrame)
EVT_TOGGLEBUTTON(ID_CONNECT, ControlFrame::ButtonPress)
EVT_TOGGLEBUTTON(ID_RESET, ControlFrame::ButtonPress)
EVT_TOGGLEBUTTON(ID_FORWARD, ControlFrame::ButtonPress)
EVT_TOGGLEBUTTON(ID_BACKWARD, ControlFrame::ButtonPress)
EVT_TOGGLEBUTTON(ID_COIL, ControlFrame::ButtonPress)
EVT_TOGGLEBUTTON(ID_STOP, ControlFrame::ButtonPress)
EVT_COMMAND(wxID_ANY,ID_ENABLERESETBUTTON,ControlFrame::EnableResetButton)
EVT_COMMAND(wxID_ANY,ID_DISABLEBUTTONS,ControlFrame::DisableButtons)

END_EVENT_TABLE()