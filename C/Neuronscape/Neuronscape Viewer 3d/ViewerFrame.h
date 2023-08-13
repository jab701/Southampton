#ifndef VIEWERFRAME_H
#define VIEWERFRAME_H

#include <wx/wx.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/toolbar.h>
#include <wx/dcclient.h>
#include <wx/dcbuffer.h>
#include <wx/timer.h>
#include <wx/display.h>
#include <wx/glcanvas.h>
#include <wx/combobox.h>
#include <wx/notebook.h>
#include <wx/spinctrl.h>
#include <stdint.h>

#include "EventID.h"
#include "../Common/EnvParameters.h"
#include "../Common/View3D.h"
#include "KeyboardMap.h"

#include "../Common/DB_ClientObject.h"
#include "../Common/Utilities.h"
#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/NetworkStackClient.h"

class ViewerFrame : public wxFrame
{
public:
	/***** MainFrame Constructor *****/
	ViewerFrame(wxWindow *Parent, const wxString& title);
	/***** MainFrame Destructor *****/
	~ViewerFrame();
	/***** Layout controls *****/
	void LayoutControls();
	void LayoutSidePanelControls(wxBoxSizer *TopLevelSizer);
	wxPanel *LayoutObjectInfoPane(wxNotebook *Notebook);
	wxPanel *LayoutObjectForcePane(wxNotebook *Notebook);
	wxPanel *LayoutAddInanimateObjectPane(wxNotebook *Notebook);

	void LayoutViewPane(wxBoxSizer *TopLevelSizer);
	void DrawForceDiagram();
	/***** Set Arguements *****/
	bool SetArguements(CartesianVector EnvDimensions, NetworkStackClient *NetworkStack, DB_ClientObject *ObjectDatabase);
	/***** Drawing Context Functions *****/
	void OnPaint(wxPaintEvent &event);
	void OnRedrawTimer(wxTimerEvent &event); 
	void OnKeyDownEvent(wxKeyEvent &event);
	/***** GUI Function Callback Functions *****/
	void OnClose(wxCloseEvent &event);
	/***** On ObjectDatabase Change *****/
	void OnObjectDatabaseChange();
	/***** On Object Combo Selected *****/
	void OnObjectComboSelect(wxCommandEvent &event);
	/***** On View Combo Selected *****/
	void OnViewComboSelect(wxCommandEvent &event);
	/***** On Add Inanimate Object *****/
	void OnAddInanimateObject(wxCommandEvent &event);
	/***** On Apply Force Click *****/
	void OnApplyForceClick(wxCommandEvent &event);
	void OnForceTimerExpired(wxTimerEvent &event);

	void KeyboardDown(wxKeyEvent &event);
	void KeyboardUp(wxKeyEvent &event);

private:
	wxTimer *m_RefreshTimer;
	wxTimer *m_ForceTimer;
	EnvParameters m_EnvDimensions;
    NetworkStackClient *m_NetworkStack;
	DB_ClientObject *m_ObjectDb;
	CartesianVector m_Min;
	CartesianVector m_Max;

	View3D *Frame3DView;

	KeyboardMap m_KeyboardMap;

	double m_CameraThetaRotate;

	uint32_t SelectedObject;

	DECLARE_EVENT_TABLE()
};

#endif
