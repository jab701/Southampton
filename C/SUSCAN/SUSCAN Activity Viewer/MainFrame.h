#ifndef MAINFRAME_H
#define MAINFRAME_H
#include <wx/wx.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/toolbar.h>
#include <wx/dcclient.h>
#include <wx/dcbuffer.h>
#include <wx/log.h>
#include "../Common/EventID.h"
#include "Neuron.h"
#include <wx/timer.h>
#include "../Common/NetworkStack.h"
#include "../Common/Utilities.h"


class MainFrame : public wxFrame
{
public:
	/***** MainFrame Constructor *****/
	MainFrame(const wxString& title);
	/***** MainFrame Destructor *****/
	~MainFrame();
	void InitMenuBar();
	void LayoutControls();
	/***** Function Responsible For Displaying About Dialogue *****/
	void MenuAbout(wxCommandEvent &event);
	/***** Function Responsible For Closing The Program *****/
	void MenuExit(wxCommandEvent &event);

	/***** Set-up Neuron Layout *****/
	void InitNeurons();

	/***** Neuron Manipulation Functions *****/
	void AssertDeviceReset();
	void DeassertDeviceReset();
	void SetNeuronEnabled(long NeuronID);
	void SetNeuronDisabled(long NeuronID);
	void SetForwardMotion();
	void SetStopMotion();
	void SetBackwardMotion();
	void SetCoilingMotion();
	void EnableAllNonDrivingNeurons();
	void ZeroAllNeuronActivity();
	void ProcessNeuronDataPacket(unsigned char *NeuronData);
	void ForceRepaintScreen(wxTimerEvent &event);
	void ConnectToServer();
	void DisconnectFromServer();

	/***** Drawing Context Functions *****/
	void OnPaint(wxPaintEvent &event);
	void ReDraw_Neurons(wxBufferedPaintDC *dc);
	void MouseButtons(wxMouseEvent &event);
	void ControlPanelEvent(wxCommandEvent &event);
	
	/***** Toolbar Button Callback Functions *****/
	void OnConnectClick(wxCommandEvent &event);
	void OnResetClick(wxCommandEvent &event);
	void OnForwardClick(wxCommandEvent &event);
	void OnStopClick(wxCommandEvent &event);
	void OnBackwardClick(wxCommandEvent &event);
	void OnCoilClick(wxCommandEvent &event);
	/***** Button Control *****/
	void ResetAllButtonValues();
	bool GetButtonValue(unsigned ID);
	void SetButtonValue(unsigned ID, bool Value);
	void SetButtonEnable(unsigned ID, bool Value);
	/***** GUI Function Callback Functions *****/
	void  OnClose(wxCloseEvent &event);
	/***** Network Functions *****/
	// OnSocket Event Callback
	void OnSocketEvent(wxSocketEvent &event);
	void SendNeuronControlPacket();

private:
    wxFrame *m_ControlFrame;
	wxMenuBar *m_MenuBar;
    wxMenu *m_FileMenu;
	wxMenu *m_HelpMenu;
	wxTimer m_Timer;

	/***** List Of Neurons *****/
	NeuronList *m_NeuronList;

	NetworkStack *m_NetworkStack;

	/***** List Of Neuron Activity *****/
	bool m_NeuronActivity[88];
	bool m_NeuronEnabled[88];

	bool m_Connected;

	wxDateTime m_CaptureBegin;

	DECLARE_EVENT_TABLE()
};

#endif