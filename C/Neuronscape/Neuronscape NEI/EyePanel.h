#ifndef _EYEPANEL_H_
#define _EYEPANEL_H_

#include <wx/wx.h>
#include <wx/dcbuffer.h>
#include <wx/display.h>
#include <stdint.h>

#include "../Common/View3D.h"
#include "RetinaThread.h"
#include "EventID.h"

class EyePanel : public wxPanel
{
public:
	EyePanel(wxFrame* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = wxTAB_TRAVERSAL, const wxString& name = "panel");
	~EyePanel();
	void LayoutControls();
	void SetArguements(CartesianVector EnvDimensions, DB_ClientObject *ObjectDb);
	void SetRetinaThread(RetinaThread *Retina);
	void SetObjectID(uint32_t ID);
	void OnPaint( wxPaintEvent& event );
	void OnTimerEvent(wxTimerEvent &event);
	void FullScreenMode(bool Mode = false);

private:
	bool m_FullScreenMode;
	View3D *m_Eye;

	RetinaThread *m_Retina;
	wxTimer *m_Timer;

	wxBitmap m_image;
	DECLARE_EVENT_TABLE()
};


#endif
