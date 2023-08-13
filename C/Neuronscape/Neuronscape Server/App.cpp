#include "App.h"


IMPLEMENT_APP(BIMPA_SERVER_KERNEL)

bool BIMPA_SERVER_KERNEL::OnInit()
{
	wxCmdLineParser Parse;
	
	Parse.SetCmdLine(this->argc,this->argv);
	Parse.SetDesc(cmdLineDesc);

	int RC = Parse.Parse(true);

	if ((RC == -1)||(RC > 0))
	{
		return false;
	}

	wxSocketBase::Initialize();
	this->m_MainFrame = new MainFrame(wxT("BIMPA Environment Server"));


	this->m_MainFrame->Show(true);
	return(true);
}

int BIMPA_SERVER_KERNEL::OnExit()
{
	wxSocketBase::Shutdown();

	return(0);
}

