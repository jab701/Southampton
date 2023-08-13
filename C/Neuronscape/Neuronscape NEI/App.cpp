#include "App.h"


IMPLEMENT_APP(NEURONSCAPE_NEI_DEMO1)

bool NEURONSCAPE_NEI_DEMO1::OnInit()
{
	wxSocketBase::Initialize();
	this->m_MainFrame = new MainFrame(wxT("Neuronscape NEI"));
	this->m_MainFrame->Show(true);
	return(true);
}