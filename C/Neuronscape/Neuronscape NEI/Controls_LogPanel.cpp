#include "Controls_LogPanel.h"

Controls_LogPanel::Controls_LogPanel(wxFrame* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style, const wxString& name) :
wxPanel(parent,id,pos,size,style,name)
{
	this->LayoutControls();
	wxLog::SetActiveTarget(this->m_LogTextCtrl);
}
Controls_LogPanel::~Controls_LogPanel()
{

}
void Controls_LogPanel::LayoutControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);

	TopLevelSizer->AddSpacer(5);
	wxStaticText *ST_RMessage = new wxStaticText(this,wxID_ANY,wxT("Log Messages"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_RMESSAGEE"));
	TopLevelSizer->Add(ST_RMessage,0,wxALIGN_CENTER,0,0);
	TopLevelSizer->AddSpacer(5);	

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);
	wxTextCtrl *TC_LogMessage = new wxTextCtrl(this,wxID_ANY,wxEmptyString,wxDefaultPosition,wxSize(wxDefaultSize.GetX(),(7*this->GetCharHeight())),wxTE_MULTILINE,wxDefaultValidator,wxT("TC_LOGMESSAGE"));
	HSizer1->AddSpacer(5);	
	HSizer1->Add(TC_LogMessage,1.0,wxEXPAND|wxALIGN_CENTER,50,0);
	HSizer1->AddSpacer(5);	
	TopLevelSizer->Add(HSizer1,1.0,wxEXPAND,0,0);	
	TopLevelSizer->AddSpacer(5);

	this->SetSizer(TopLevelSizer);
	TopLevelSizer->Fit(this);

	this->m_LogTextCtrl = new wxLogTextCtrl(TC_LogMessage);
}

BEGIN_EVENT_TABLE(Controls_LogPanel, wxPanel)

END_EVENT_TABLE()