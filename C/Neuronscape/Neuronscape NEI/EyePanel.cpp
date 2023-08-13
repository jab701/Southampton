#include "EyePanel.h"

EyePanel::EyePanel(wxFrame* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style, const wxString& name) :
wxPanel(parent,id,pos,wxSize(320,480),style,name)
{
	wxDisplay Display;

	int RefreshRate = Display.GetCurrentMode().refresh;
	//int RefreshRate = 0;
	if (RefreshRate == 0 || NEI_USE_MANUAL_REFRESH_RATE==1) // If display refresh rate is unknown(0) then set it to 50Hz
		// RM: want to be able to slow down the data rates so this is controlled from defns (later will add a runtime-edit textbox)
	{
		RefreshRate = NEI_MANUAL_REFRESH_RATE;
	}

	double RefreshPeriod = 1.0/ (double) RefreshRate;
	int RefreshPeriodInt = ceil(RefreshPeriod/1E-3); 
	wxString Msg;
	Msg.Printf("Set NEI refresh rate to %d fps (period=%d ms)", RefreshRate,  RefreshPeriodInt);
	wxLogMessage(Msg);

	this->m_image = wxBitmap(size.GetWidth(),size.GetHeight(),24);
	wxWindow::SetBackgroundStyle(wxBG_STYLE_PAINT);

	this->LayoutControls();

	this->m_Timer = new wxTimer(this, ID_EYEPANELPAINT_TIMER);
	this->m_Timer->Start(RefreshPeriodInt,false);

	this->m_Retina = NULL;
	this->m_FullScreenMode = false;
}
EyePanel::~EyePanel()
{
	this->m_Retina = NULL;

	this->m_Timer->Stop();

	delete this->m_Timer;
}
void EyePanel::LayoutControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);	

	int args[] = {WX_GL_RGBA, WX_GL_DOUBLEBUFFER, WX_GL_DEPTH_SIZE, 16, 0}; 

	this->m_Eye = new View3D(this,wxT("Eye"),args);
	//this->m_Eye->InitGL();

	//wxASSERT(this->m_Eye != NULL);

	TopLevelSizer->Add(this->m_Eye,1.0,wxEXPAND,0,0);
	TopLevelSizer->AddSpacer(10);

	this->SetSizer(TopLevelSizer);
	TopLevelSizer->Fit(this); // IMPORTANT - RHEL6 SEGFAULT HERE
}
void EyePanel::SetArguements(CartesianVector EnvDimensions, DB_ClientObject *ObjectDb)
{
	this->m_Eye->SetArguements(EnvDimensions, ObjectDb);
}
void EyePanel::SetRetinaThread(RetinaThread *Retina)
{
	this->m_Retina = Retina;
	this->m_Eye->SetRetina(Retina);
}
void EyePanel::SetObjectID(uint32_t ID)
{
	this->m_Eye->SetObjectID(ID);
}
void EyePanel::OnPaint( wxPaintEvent& event )
{
	if (!this->m_FullScreenMode)
	{
		wxBufferedPaintDC dc(this);
		dc.DrawBitmap(this->m_image, 0, 240, false );
	}
}
void EyePanel::OnTimerEvent(wxTimerEvent &event)
{
	if (this->m_Retina != NULL)
	{
		wxBitmap* Bitmap = this->m_Retina->FetchRetinaMap();

		if (Bitmap != NULL)
		{
			this->m_image = *Bitmap;
			delete Bitmap;
		}
	}

	wxWindow::Refresh();
	wxWindow::Update();
}

void EyePanel::FullScreenMode(bool Mode)
{
	this->m_FullScreenMode = Mode;

	if (Mode)
	{
		this->m_Eye->FullScreen(true);
	}
	else
	{
		this->m_Eye->FullScreen(false);
	}
}
BEGIN_EVENT_TABLE(EyePanel, wxPanel)
// catch paint events
EVT_PAINT(EyePanel::OnPaint)
EVT_TIMER(ID_EYEPANELPAINT_TIMER,EyePanel::OnTimerEvent)
END_EVENT_TABLE()