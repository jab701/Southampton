#ifndef _SYSTEMCONTROLPANEL_H_
#define _SYSTEMCONTROLPANEL_H_

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

class SystemControlPanel : public wxPanel
{
public:
	SystemControlPanel(wxFrame* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxTAB_TRAVERSAL, const wxString& name = "panel");
	~SystemControlPanel();
	void LayoutControls();
	void LayoutNeuronscapeNetworkControls(wxBoxSizer *TopLevel);
	void LayoutSpinnakerNetworkControls(wxBoxSizer *TopLevel);
	void LayoutSpinnakerVisualSettings(wxBoxSizer *TopLevel);
	void LayoutRetinaSettings(wxBoxSizer *TopLevel);
	void LayoutControlButtons(wxBoxSizer *TopLevel);

private:
	DECLARE_EVENT_TABLE()
};


#endif
