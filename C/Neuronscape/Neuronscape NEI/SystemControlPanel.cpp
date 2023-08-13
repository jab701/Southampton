#include "SystemControlPanel.h"

SystemControlPanel::SystemControlPanel(wxFrame* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style, const wxString& name) :
wxPanel(parent,id,pos,size,style,name)
{
	this->LayoutControls();
}
SystemControlPanel::~SystemControlPanel()
{

}
void SystemControlPanel::LayoutControls()
{
	wxBoxSizer *TopLevelSizer = new wxBoxSizer(wxVERTICAL);

	this->LayoutNeuronscapeNetworkControls(TopLevelSizer);

	this->LayoutSpinnakerNetworkControls(TopLevelSizer);

	this->LayoutSpinnakerVisualSettings(TopLevelSizer);

	this->LayoutRetinaSettings(TopLevelSizer);

	this->LayoutControlButtons(TopLevelSizer);	

	wxStaticText *ST_Energy = new wxStaticText(this,wxID_ANY,wxT("Energy Left: N/A"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_ENERGY"));

	TopLevelSizer->Add(ST_Energy);

	this->SetSizer(TopLevelSizer);
	TopLevelSizer->Fit(this);
}
void SystemControlPanel::LayoutNeuronscapeNetworkControls(wxBoxSizer *TopLevel)
{
	// Network Settings Static Box
	wxStaticBox *NetworkStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Host Server Settings "),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *NetworkStaticBoxSizer = new wxStaticBoxSizer(NetworkStaticBox,wxVERTICAL);
	TopLevel->Add(NetworkStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxStaticText *ST_NetworkHost = new wxStaticText(this,wxID_ANY,wxT("Host"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NETWORKHOST"));
	wxTextCtrl   *TC_NetworkHost = new wxTextCtrl(this,wxID_ANY,wxT(NEI_DEFAULT_SERVERHOST),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_NETWORKHOST"));
	wxStaticText *ST_NetworkPort = new wxStaticText(this,wxID_ANY,wxT("Port"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_NETWORKPORT"));
	wxTextCtrl   *TC_NetworkPort = new wxTextCtrl(this,wxID_ANY,wxT(NEI_DEFAULT_SERVERPORT),wxDefaultPosition,wxSize((7*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_NETWORKPORT"));
	HSizer1->Add(ST_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);
	NetworkStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);
}
void SystemControlPanel::LayoutSpinnakerNetworkControls(wxBoxSizer *TopLevel)
{
	wxStaticBox *NetworkStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Spinnaker Board Network Settings"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *NetworkStaticBoxSizer = new wxStaticBoxSizer(NetworkStaticBox,wxVERTICAL);
	TopLevel->Add(NetworkStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxStaticText *ST_NetworkHost = new wxStaticText(this,wxID_ANY,wxT("Host"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERHOST"));
	wxTextCtrl   *TC_NetworkHost = new wxTextCtrl(this,wxID_ANY,wxT(NEI_DEFAULT_SPINNHOST),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_SPINNAKERHOST"));
	wxStaticText *ST_NetworkPort = new wxStaticText(this,wxID_ANY,wxT("Port"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERPORT"));
	wxTextCtrl   *TC_NetworkPort = new wxTextCtrl(this,wxID_ANY,wxT(NEI_DEFAULT_SPINNPORT),wxDefaultPosition,wxSize((7*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_SPINNAKERPORT"));
	HSizer1->Add(ST_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkHost,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(TC_NetworkPort,0,wxALIGN_CENTER_VERTICAL,0,0);

	NetworkStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);
}
void SystemControlPanel::LayoutSpinnakerVisualSettings(wxBoxSizer *TopLevel)
{
	// Network Settings Static Box
	wxStaticBox *SpinnakerVisualStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Spinnaker Visual CPU Target"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *SpinnakerVisualStaticBoxSizer = new wxStaticBoxSizer(SpinnakerVisualStaticBox,wxVERTICAL);
	TopLevel->Add(SpinnakerVisualStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxStaticText *ST_SpinnakerChipX = new wxStaticText(this,wxID_ANY,wxT("Chip X"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERCHIPX"));
	wxSpinCtrl   *SC_SpinnakerChipX = new wxSpinCtrl(this, wxID_ANY, wxT("0"), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 0, SPIN_CHIPMAX, 0, wxT("SP_SPINNAKERCHIPX"));
	//(this,wxID_ANY,wxT("0"),wxDefaultPosition,wxSize((5*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_SPINNAKERCHIPX"));

	wxStaticText *ST_SpinnakerChipY = new wxStaticText(this,wxID_ANY,wxT("Chip Y"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERCHIPY"));
	wxSpinCtrl   *SC_SpinnakerChipY = new wxSpinCtrl(this, wxID_ANY, wxT("0"), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 0, SPIN_CHIPMAX, 0, wxT("SP_SPINNAKERCHIPY"));

	wxStaticText *ST_SpinnakerCPU = new wxStaticText(this,wxID_ANY,wxT("CPU"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERCPU"));
	wxSpinCtrl   *SC_SpinnakerCPU = new wxSpinCtrl(this, wxID_ANY, wxT("1"), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 0, SPIN_CPUMAX, 0, wxT("SP_SPINNAKERCPU"));

	wxStaticText *ST_SpinnakerTag = new wxStaticText(this,wxID_ANY,wxT("TAG"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_SPINNAKERTAG"));
	wxSpinCtrl   *SC_SpinnakerTag = new wxSpinCtrl(this, wxID_ANY, wxT("1"), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 0, SPIN_TAGMAX, 0, wxT("SP_SPINNAKERTAG"));

	HSizer1->Add(ST_SpinnakerChipX,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerChipX,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_SpinnakerChipY,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerChipY,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_SpinnakerCPU,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerCPU,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_SpinnakerTag,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerTag,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);

	SpinnakerVisualStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);
}
void SystemControlPanel::LayoutRetinaSettings(wxBoxSizer *TopLevel)
{
	wxStaticBox *SpinnakerVisualStaticBox = new wxStaticBox(this,wxID_ANY,wxT("Retina Size"),wxDefaultPosition,wxDefaultSize,0,wxT(""));
	wxStaticBoxSizer *SpinnakerVisualStaticBoxSizer = new wxStaticBoxSizer(SpinnakerVisualStaticBox,wxVERTICAL);
	TopLevel->Add(SpinnakerVisualStaticBoxSizer,0,wxEXPAND|wxALIGN_CENTER|wxALIGN_CENTER_VERTICAL|wxALL,5,0);

	wxBoxSizer *HSizer1 = new wxBoxSizer(wxHORIZONTAL);

	wxStaticText *ST_SpinnakerChipX = new wxStaticText(this,wxID_ANY,wxT("Retina Size X"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_RETINAX"));
	wxSpinCtrl   *SC_SpinnakerChipX = new wxSpinCtrl(this, wxID_ANY, wxT(NEI_DEFAULT_RETINA_ROWS), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 1, RETINA_X_MAX, 1, wxT("SP_RETINAX"));
	//(this,wxID_ANY,wxT("0"),wxDefaultPosition,wxSize((5*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_SPINNAKERCHIPX"));

	wxStaticText *ST_SpinnakerChipY = new wxStaticText(this,wxID_ANY,wxT("Retina Size Y"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_RETINAY"));
	wxSpinCtrl   *SC_SpinnakerChipY = new wxSpinCtrl(this, wxID_ANY, wxT(NEI_DEFAULT_RETINA_COLS), wxDefaultPosition, wxSize((8*this->GetCharWidth()),wxDefaultSize.GetY()), wxSP_ARROW_KEYS|wxSP_WRAP, 1, RETINA_Y_MAX, 1, wxT("SP_RETINAY"));

	HSizer1->Add(ST_SpinnakerChipX,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerChipX,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(ST_SpinnakerChipY,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);
	HSizer1->Add(SC_SpinnakerChipY,0,wxALIGN_CENTER_VERTICAL,0,0);
	HSizer1->AddSpacer(5);

	SpinnakerVisualStaticBoxSizer->Add(HSizer1,0,wxALIGN_CENTER,0,0);

	wxBoxSizer *HSizer2 = new wxBoxSizer(wxHORIZONTAL);

	wxCheckBox   *CB_wxCheckBoxGreyScale = new wxCheckBox(this, wxID_ANY, wxT("Greyscale Retina"), wxDefaultPosition, wxDefaultSize, 0, wxDefaultValidator, wxT("CB_RETINAGREY"));
	CB_wxCheckBoxGreyScale->SetValue(true);
	HSizer2->Add(CB_wxCheckBoxGreyScale,0,wxALIGN_CENTER_VERTICAL,0,0);

	SpinnakerVisualStaticBoxSizer->AddSpacer(5);
	SpinnakerVisualStaticBoxSizer->Add(HSizer2,0,wxALIGN_CENTER,0,0);
}
void SystemControlPanel::LayoutControlButtons(wxBoxSizer *TopLevel)
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

BEGIN_EVENT_TABLE(SystemControlPanel, wxPanel)

END_EVENT_TABLE()