#ifndef CONTROLFRAME_H
#define CONTROLFRAME_H

#include <wx/wx.h>
#include <wx/tglbtn.h>
#include <wx/event.h>
#include "../Common/EventID.h"
#include "MainFrame.h"


class ControlFrame : public wxFrame
{
public:

	ControlFrame (wxFrame *Parent,const wxString& title);
    void ButtonPress(wxCommandEvent &event);
	void EnableResetButton(wxCommandEvent &event);
	void DisableButtons(wxCommandEvent &event);
	~ControlFrame();


private:
	wxFrame *m_Parent;
	bool m_ButtonStatus[6];
	DECLARE_EVENT_TABLE()
};

DECLARE_EVENT_TYPE(ID_ENABLERESETBUTTON, ID_ENABLERESETBUTTONNUM)
DECLARE_EVENT_TYPE(ID_DISABLEBUTTONS, ID_DISABLEBUTTONSNUM)	

#endif