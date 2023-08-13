#include "Application.h"


IMPLEMENT_APP(SUSCANAV)

bool SUSCANAV::OnInit()
{
    Main = new MainFrame(wxT("SUSCAN USB Ethernet Connector"));
	Main->Show(true);
	return true;
}