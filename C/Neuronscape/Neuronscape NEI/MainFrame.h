#ifndef MAINFRAME_H
#define MAINFRAME_H

#include <wx/wx.h>
#include <wx/stattext.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/spinctrl.h>
#include <wx/combobox.h>
#include <wx/log.h>
#include <wx/glcanvas.h>
#include <GL/glu.h>
#include <GL/gl.h>
#include <stdint.h>

#include "EventID.h"
#include "MotorThread.h"
#include "RetinaThread.h"

#include "EyePanel.h"
#include "SystemControlPanel.h"
#include "Controls_LogPanel.h"

#include "SpinnakerTypes.h"
#include "SpinnakerNetStack.h"

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/NetworkStackClient.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"
#include "../Common/EnvParameters.h"
#include "../Common/ClientPacketProcessThread.h"

#include "NeuronSpikeQueue.h"
#include "NeuronStateQueue.h"

#include "TransmitThreadNetworkPacketEvent.h"
#include "ClientPacketEvent.h"

class ControlsData
{
public:
	wxString NetworkHost;
	wxString NetworkPort;

	wxString SpinnakerHost;
	wxString SpinnakerPort;

	double InitialEnergy;

	unsigned int VisualChipX;
	unsigned int VisualChipY;
	unsigned int VisualCPU;
	unsigned int VisualTag;

	unsigned int RewardChipX;
	unsigned int RewardChipY;
	unsigned int RewardCPU;
	unsigned int RewardTag;

	unsigned int Retinax;
	unsigned int Retinay;
	bool RetinaGrey;
};

class MainFrame : public wxFrame
{
public:
	/**************************************************************/
	/*** CLASS CONSTRUCTOR/DESTRUCTOR FUNCTION SECTION          ***/
	/**************************************************************/
	/*** Constructor ***/
	MainFrame(const wxString& title);
	/*** Deconstructor ***/
	~MainFrame();
	/**************************************************************/
	/*** UTILITY FUNCTION SECTION                               ***/
	/**************************************************************/
	bool FetchTextCtrlData();
	/**************************************************************/
	/*** WINDOW CONTROL LAYOUT SECTION                          ***/
	/**************************************************************/
	void LayoutControls();
	void LayoutLeft(wxBoxSizer *TopLevel);
	void LayoutRight(wxBoxSizer *TopLevel);
	void LayoutNeuronscapeNetworkControls(wxBoxSizer *TopLevel);
	void LayoutSpinnakerNetworkControls(wxBoxSizer *TopLevel);
	void LayoutSpinnakerVisualSettings(wxBoxSizer *TopLevel);
	void LayoutRetinaSettings(wxBoxSizer *TopLevel);
	void LayoutControlButtons(wxBoxSizer *TopLevel);
	void LayoutLogTextCtrl(wxBoxSizer *TopLevel);
	void ShowHideControls(bool Show);
	/**************************************************************/
	/***	EVENT HANDLER SECTION                               ***/
	/**************************************************************/
	void OnSize(wxSizeEvent& event);
	/*** On Window Close Function ***/
	void OnClose(wxCloseEvent &event);
	/*** GUI GO/STOP OnButton Click Event Handlers ***/
	void OnGo(wxCommandEvent &event);
	void OnStop(wxCommandEvent &event);
	/***** Neuronscape Network Socket & Stack Event Handlers *****/
	void OnNSSocketEvent(wxSocketEvent &event);
	void OnNSNetworkStackEvent(wxCommandEvent &event);
	void OnNSNetworkStackConnectedEvent();
	void OnNSNetworkStackDisconnectedEvent();
	void OnNSNetworkStackDisconnectedForcedEvent();
	void OnNSNetworkStackEnumEvent();
	void OnNSNetworkStackAssignedObjectEvent();
	void OnNSNetworkStackAssignedObjectRemovedEvent();
	void OnNSNetworkStackObjectDataDirtyEvent();
	void OnNSNetworkStackRemoveEatenObj();
	void OnNSNetworkStackErrorEvent();
	void OnNSNetworkStackTimeout(wxTimerEvent &event);
	/***** Spinnaker Network Socket & Stack Event Handlers *****/
	void OnSPSocketEvent(wxSocketEvent &event);
	void OnSPNetworkStackEvent(SNS_STAT Status);
	void OnSPNetworkStackErrorEvent();
	void OnSPNetworkStackTimeout(wxTimerEvent &event);
	//
	void OnMotorForceUpdate(TransmitThreadNetworkPacketEvent &event);
	void OnRetinaUpdate(wxCommandEvent &event);
	/***********************************************************/
	/*** Start/Stop Functions for Each of System Components  ***/
	/***********************************************************/
	// Start/Stop Neuronscape Network Stack
	bool StartNeuronscapeNetwork();
	void StopNeuronscapeNetwork();
	// Start/Stop Neuronscape Client Packet Process Thread
	bool StartClientPacketProcessing();
	void StopClientPacketProcessing();
	// Start/Stop Spinnaker Network Stack
	bool StartSpinnakerNetwork();
	void StopSpinnakerNetwork();
	// Start/Stop Motor Thread
	int StartMotorThread();
	void StopMotorThread();
	// Start/Stop Retina Thread
	int StartRetinaThread();
	void StopRetinaThread();

	void UpdateEnergyST(double Energy)
	{
		wxString EnergyText;
		EnergyText.Printf("Energy Available: %lf", Energy);

		wxStaticText *ST_E  = (wxStaticText*) this->FindWindowByName("ST_ENERGY",this);

		if (ST_E != NULL)
		{
			ST_E->SetLabel(EnergyText);
		}
	}

private:
	NeuronSpikeQueue *m_NeuronSpikeQueue;
	wxMutex *m_NeuronSpikeQueueMutex;

	bool m_PendingSocketShutdown;
	bool m_PendingProgramClose;
	uint16_t m_ClientID;
	uint16_t m_ObjectID;
	EnvParameters m_EnvParameters;
	wxTimer *m_NSTimer;
	wxTimer *m_SPTimer;

	wxIPV4address m_RemoteHost;
	wxIPV4address m_SpinnakerHost;
	NetworkStackClient *m_NetworkStack;
	wxLogTextCtrl *m_LogTextCtrl;
	ControlsData m_ControlsData;
	DB_ClientObject m_ObjectDb;
	MotorThread *m_MotorThread;
	RetinaThread *m_RetinaThread;
	ClientPacketProcessThread *m_ClientPacketProcessing;

	SpinnakerNetStack *m_SpinnNetStack;
	wxBitmap m_Bitmap;

	wxPanel *LeftControls;
	
	DECLARE_EVENT_TABLE()
};
#endif
