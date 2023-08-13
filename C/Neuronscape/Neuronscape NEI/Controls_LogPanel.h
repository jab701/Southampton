#ifndef _CONTROLSLOGPANEL_H_
#define _CONTROLSLOGPANEL_H_

#include <wx/wx.h>

#include <wx/wx.h>
#include <wx/stattext.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/spinctrl.h>
#include <wx/combobox.h>
#include <wx/log.h>

#include <stdint.h>

#include "EventID.h"
#include "../Common/Definitions.h"

class Controls_LogPanel : public wxPanel
{
public:
	Controls_LogPanel(wxFrame* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxTAB_TRAVERSAL, const wxString& name = "panel");
	~Controls_LogPanel();
	void LayoutControls();
private:
	wxLogTextCtrl *m_LogTextCtrl;
	DECLARE_EVENT_TABLE()
};


#endif
