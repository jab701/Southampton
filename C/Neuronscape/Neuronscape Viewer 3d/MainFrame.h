#ifndef MAINFRAME_H
#define MAINFRAME_H

#include <wx/wx.h>
#include <wx/stattext.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/combobox.h>
#include <wx/log.h>
#include <wx/notebook.h>
#include <stdint.h>
#include "ViewerFrame.h"
#include "EventID.h"
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/NetworkStackClient.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/CartesianVector.h"

#include "../Common/EnvParameters.h"
#include "../Common/ClientPacketProcessThread.h"

class ControlsData
{
public:
	wxString NetworkHost;
	wxString NetworkPort;
};

class MainFrame : public wxFrame
{
public:
	/*** Constructor ***/
	MainFrame(const wxString& title);
	/*** Deconstructor ***/
	~MainFrame();

	bool FetchTextCtrlData();

	void LayoutControls();
	void LayoutNetworkControls(wxBoxSizer *TopLevel);
	void LayoutButtons(wxBoxSizer *TopLevel);
	void LayoutLogTextCtrl(wxBoxSizer *TopLevel);

	/*** On Window Close Function ***/
	void OnClose(wxCloseEvent &event);

	void OnSocketEvent(wxSocketEvent &event);

	void OnGo(wxCommandEvent &event);
	void OnStop(wxCommandEvent &event);

	void OnNetworkStackEvent(wxCommandEvent &event);

	void OnNetworkStackConnectedEvent();
	void OnNetworkStackDisconnectedEvent();
	void OnNetworkStackDisconnectedForcedEvent();
	void OnNetworkStackEnumEvent();
	void OnNetworkStackObjectDataDirtyEvent();
	void OnNetworkStackErrorEvent();

	void OnNetworkTimeout(wxTimerEvent &event);

	void OnObjectProcessComplete(wxCommandEvent &event);

	ViewerFrame* FetchActiveViewerFrame();

	bool StartPacketProcessing();
	void StopPacketProcessing();
	
private:
	bool m_PendingSocketShutdown;
	bool m_PendingProgramClose;

	ClientPacketProcessThread *m_PacketProcessingThread;

	uint16_t m_ClientID;

	EnvParameters m_EnvParameters;

	wxTimer *m_NSTimer;

	wxIPV4address m_RemoteHost;

	NetworkStackClient *m_NetworkStack;

	wxLogTextCtrl *m_LogTextCtrl;

	ControlsData m_ControlsData;

	DB_ClientObject m_ObjectDb;

	// Testing
	double minx, miny, minz;
	double maxx, maxy, maxz;

	DECLARE_EVENT_TABLE()

};


#endif