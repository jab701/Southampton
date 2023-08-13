#ifndef MOTORTHREAD_H
#define MOTORTHREAD_H

#include <wx/wx.h>
#include <stdint.h>
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/NetworkStackClient.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#include "EventID.h"

#include "NeuronSpikeQueue.h"

#include "TransmitThreadNetworkPacketEvent.h"

class MotorThread : public wxThread
{
public:
	// Public Functions
	// Default Constructor
	MotorThread(wxFrame* Parent);

	// Destructor
	~MotorThread();

	void CalcMotorForces(DBRecord_ClientObject Record);
	void CalcTorqueForces();
	void DecayForces();
	void ForwardBackwardMuscle(bool Backwards);
	double GetEnergy();
	void Initialize(wxIPV4address ServerAddress, DB_ClientObject *DB, uint32_t ObjectID, int TimeStepMs);
	void UpdateAvailableEnergy(double WorkDone);
	void RotateTheta(bool AntiClockwise);
	void SidewaysMuscle(bool Left);

	void GetObjectForces(unsigned &ObjectID, CartesianVector &MotorForce);
	void GetObjectTorque(unsigned &ObjectID, double &TorqueForce);

	void ForceUpdateMessage();
	void TorqueUpdateMessage();

private:
	// Private Functions
	virtual wxThread::ExitCode Entry();

private:
	wxFrame *m_Parent;
	wxMutex *m_Mutex;

	CartesianVector m_CurrentMotorForce;
	double m_CurrentTorque;

	double m_MuscleForce_Forward;
	double m_MuscleForce_Backward;
	double m_MuscleForce_Sideways;
	double m_MuscleForce_Rotate;

	// RM: some state variables for the impulse muscle model
	int m_MuscleFwd_Ctr;
	int m_MuscleSdw_Ctr;
	int m_MuscleRot_Ctr;

	double m_ForceInForwardDirection;
	double m_ForceInSidewayDirection;
	double m_ThetaTorque;
	double m_PhiTorque;

	double m_LastResultant;
	double m_LastThetaTorque;
	double m_LastPhiTorque;

	wxIPV4address m_ServerAddress;
	NetworkStackClient* m_NetworkStack;

	DB_ClientObject *m_DB;

	uint32_t m_ObjectID;
	
	int m_TimeStepMs;
	double m_TimeConst1;
	double m_TimeConst2;
};

#endif