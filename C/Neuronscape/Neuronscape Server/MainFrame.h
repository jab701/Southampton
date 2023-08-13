#ifndef MAINFRAME_H
#define MAINFRAME_H

#include <vector>
#include <cstdlib>
#include <stdint.h>

#include <wx/wx.h>
#include <wx/socket.h>
#include <wx/stattext.h>
#include <wx/toolbar.h>
#include <wx/tglbtn.h>
#include <wx/statbox.h>
#include <wx/timer.h>

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#include "EventID.h"
#include "DBRecord_Client.h"
#include "DBRecord_Object.h"
#include "DB_Client.h"
#include "DB_Object.h"
#include "NetworkStackServer.h"
#include "Physics.h"

#include "ServerPacketProcessingThread.h"
#include "ServerPacketEvent.h"

class MainFrameControlsData
{
public:
	CartesianVector EnvDim;
	double Gravity;
	wxString NET_PORT;
	int PHYSTIME_INTERVAL;
};


class MainFrame : public wxFrame
{
public:
	/***********************************/
	/*** Mainframe Class Constructor ***/
	/***********************************/
	MainFrame(const wxString& title);
	/*************************************/
	/*** Mainframe Class Deconstructor ***/
	/*************************************/
	~MainFrame();
	/****************************************/
	/*** Layout the controls on the frame ***/
	/****************************************/
	void ControlLayout();
	void ControlLayout_PhysEnvControls(wxBoxSizer *Parent);
	void ControlLayout_ServerConfControls(wxBoxSizer *Parent);
	void ControlLayout_StatusControls(wxBoxSizer *Parent);
	void ControlLayout_ServerControls(wxBoxSizer *Parent);
	void LayoutLogTextCtrl(wxBoxSizer *TopLevel);
	/************************************************/
    /*** Mainframe Control Manipulation Functions ***/
	/************************************************/
	bool FetchTextCtrlData();
	void TextCtrlLock();
	void TextCtrlUnlock();
	/***************************************/
	/*** On Close Function for Mainframe ***/
	/***************************************/
	void OnClose(wxCloseEvent &event);
	/**********************************/
	/*** Control Callback Functions ***/
	/**********************************/
	/*** Network Button Callback Functions ***/
	void OnServerStartButton(wxCommandEvent &event);
	void OnServerRestartButton(wxCommandEvent &event);
	void OnServerStopButton(wxCommandEvent &event);

	void OnReceiveNetworkPacket(wxSocketEvent &event);
	void OnSendPacketEvent(ServerPacketEvent &event);
	void OnSendPacketToAllEvent(ServerPacketEvent &event);
	void OnPacketProcessEvent(wxCommandEvent &event);
	
	bool SystemStart();
	bool StartNetworkStack();
	int StartPhysicsSimulation();

	bool SystemStop();
	bool StopNetworkStack();
	bool StopPhysicsSimulation();

	void OnPhysicsTimerEvent(wxTimerEvent &event);	
	void CalculatePositionVelocity(double TimeStep, CartesianVector StartPosition, CartesianVector StartVelocity, CartesianVector MotorForce, CartesianVector ExternForce, CartesianVector &FinishPosition, CartesianVector &FinishVelocity, double &AvailableEnergy);
	bool IterateCalculatePositionVelocity(double OriginalTimeStep, double TimeStep, CartesianVector StartPosition, CartesianVector StartVelocity, CartesianVector MotorForce, CartesianVector ExternForce, CartesianVector &FinishPosition, CartesianVector &FinishVelocity, CartesianVector &Friction, double &AvailableEnergy);

	void CalculateRotation(double TimeStep, double EffRadius, double Torque, double StartTheta, double StartOmega, double &FinishTheta, double &FinishOmega, double &AvailableEnergy);
	void IterateCalculateRotation(double OriginalTimeStep, double TimeStep, double EffRadius, double Torque, double StartOmega, double &FinishOmega, double &AngularDisplacement, double &Friction, double &AvailableEnergy);

	void EnvBoundsCheck(CartesianVector &Position, CartesianVector &Velocity,double EffRadius);
	double CalculateMovementWorkDone(CartesianVector Displacement, CartesianVector MotorForce, CartesianVector Friction, CartesianVector ExternalForce);
	double CalculateRotationWorkDone(double Torque, double TorqueFriction, double Displacement);
	void OnPhysicsUpdate(PhysicsEvent &event);

private:
	bool m_SystemRunning;
	MainFrameControlsData m_ControlsData;

	ServerPacketProcessingThread *m_PacketProcessing;
	NetworkStackServer *m_NetworkStack;
	PhysicsThread *m_Physics;
	
	DB_Client m_ClientDB;
	DB_Object m_ObjectDB;

	wxLogTextCtrl *m_LogTextCtrl;
	DECLARE_EVENT_TABLE()

};

#endif
