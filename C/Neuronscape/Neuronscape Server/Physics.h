#ifndef PHYSICS_H
#define PHYSICS_H

#include <wx/wx.h>
#include <wx/socket.h>
#include <stdint.h>
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "DB_Object.h"
#include "DB_Client.h"
#include "DBRecord_Client.h"
#include "DBRecord_Object.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#include "PhysicsEvent.h"
#include "EventID.h"

class PhysicsThread : public wxThread
{
public:
	// Public Functions
	// Default Constructor
	PhysicsThread(wxFrame* Parent);

	// Destructor
	~PhysicsThread();

	void Initialize(DB_Client *ClientDatabase, DB_Object *ObjectDatabase, unsigned PhysTimeInterval, double Gravity, CartesianVector EnvDim);
private:
	// Private Functions
	virtual wxThread::ExitCode Entry();

	void CalculatePositionVelocity(double TimeStep, CartesianVector StartPosition, CartesianVector StartVelocity, CartesianVector MotorForce, CartesianVector ExternForce, CartesianVector &FinishPosition, CartesianVector &FinishVelocity, double &AvailableEnergy);
	void Coasting_PV(double TimeStep, double Mass, double Radius, double U, double &V, double &S);
	void Powered_PV(double TimeStep, double Mass, double Radius, double Force, double U, double &V, double &S, double &Friction);

	void CalculateRotation(double TimeStep, double EffRadius, double Torque, double StartTheta, double StartOmega, double &FinishTheta, double &FinishOmega, double &AvailableEnergy);
    void Coasting_Rotation(double TimeStep, double Mass, double Radius, double U, double &V, double &S);
    void Powered_Rotation(double TimeStep, double Mass, double Radius, double Force, double U, double &V, double &S, double &Friction);

	void EnvBoundsCheck(CartesianVector &Position, CartesianVector &Velocity, double Radius, CartesianVector Bounds);
	double CalculateMovementWorkDone(CartesianVector Displacement, CartesianVector MotorForce, CartesianVector Friction, CartesianVector ExternalForce, double Mass);
	double CalculateRotationWorkDone(double Torque, double TorqueFriction, double Displacement);

	bool PrepareBulkUpdatePacket(std::string *PacketData, uint32_t NumObjects, DBRecord_Object ObjectRecords[]);

private:
	wxFrame *m_Parent;
	DB_Object *m_ObjectDB;
	DB_Client *m_ClientDB;
	unsigned m_PhysTimeInterval;
	double m_Gravity;
	CartesianVector m_EnvDim;
};

#endif