#include "App.h"


IMPLEMENT_APP(NEURONSCAPE_NEI_DEMO1)

bool NEURONSCAPE_NEI_DEMO1::OnInit()
{
	wxSocketBase::Initialize();
	this->m_MainFrame = new MainFrame(wxT("Neuronscape Viewer - V1.0"));
	this->m_MainFrame->Show(true);
	//this->m_ViewerFrame = new ViewerFrame(NULL,"Neuronscape 3D Viewer");
	//this->m_ViewerFrame->Show(true);
	return(true);
}