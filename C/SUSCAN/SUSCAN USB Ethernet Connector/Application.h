#include <wx/wx.h>
#include "MainFrame.h"
class SUSCANAV : public wxApp
{
  public:
    virtual bool OnInit();
	MainFrame *Main;
};
