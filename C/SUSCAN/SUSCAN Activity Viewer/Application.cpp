#include "Application.h"


IMPLEMENT_APP(SUSCANAV)

bool SUSCANAV::OnInit()
{
    Main = new MainFrame(wxT("SUSCAN Activity Viewer"));
	Main->Show(true);
	return true;
}