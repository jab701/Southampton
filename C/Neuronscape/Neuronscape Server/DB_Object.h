#ifndef DB_OBJECT_H
#define DB_OBJECT_H

#include <numeric>
#include <map>
#include <vector>

#include <wx/wx.h>
#include <wx/socket.h>
#include <stdint.h>

#include "DBRecord_Object.h"

#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"
#include "../Common/Utilities.h"

typedef std::map<uint32_t, DBRecord_Object*> DB_Object_KEYUINT;

class DB_Object
{
public: 
	DB_Object();
	~DB_Object();
	void SetEnvDimensions(CartesianVector EnvDim)
	{
		this->m_EnvDimensions = EnvDim;
	}
	// Utility Functions
	void ClearDB();
	wxMutexError Lock();
	wxMutexError Unlock();
	bool IsDirty();
	void SetDirty();
	void ClearDirtyBit();
	// Select Record Functions
	void FetchAll(std::vector<DBRecord_Object> &Records);
	void FetchAllMobile(std::vector<DBRecord_Object> &Records);
	bool FindByID(uint32_t ID, DBRecord_Object &Record);
	bool FindByAssociatedClientID(uint32_t ID, DBRecord_Object &Record);
	bool FindBetweenCoordinates(CartesianVector Point1, CartesianVector Point2, std::vector<DBRecord_Object> &Record);
	bool CollisionDetector(CartesianVector Obj, double Obj_Radius);
	void WithinLimits(CartesianVector &Position, CartesianVector Limits);

	// Insert Record Functions
	bool InsertRecord(DBRecord_Object Record);
	// Update Record Functions
	bool UpdateRecord_Colour(uint32_t ID, unsigned char Red, unsigned char Green,unsigned char Blue, unsigned char Brightness);
	bool UpdateRecord_Energy(uint32_t ID, double Energy);
	bool UpdateRecord_ExternForce(uint32_t ID, CartesianVector ExternalForce);
	bool UpdateRecord_MotorForce(uint32_t ID, CartesianVector MotorForce);
	bool UpdateRecord_TorqueForces(uint32_t ID, double ThetaTorque, double PhiTorque);
	bool UpdateRecord_PositionVelocity(uint32_t ID, CartesianVector Position, CartesianVector Velocity);
	bool UpdateRecord_Theta_ThetaVelocity(uint32_t ID, double Theta, double ThetaVelocity);
	bool UpdateRecord_Phi_PhiVelocity(uint32_t ID, double Phi, double PhiVelocity);
	// Delete Record Functions
	bool DeleteRecordByID(uint32_t ID);
	bool DeleteRecordByAssociatedClientID(uint32_t ID);
private:
	CartesianVector m_EnvDimensions;
	bool IsAnObjectAssignedToClient(uint32_t Client_ID);
	uint32_t m_NextAvailableID;
	DB_Object_KEYUINT m_ObjectDB_KEYID;
	DB_Object_KEYUINT m_ObjectDB_KEYASSOCIATEDCLIENTID;
	bool m_DirtyBit;
	wxMutex *m_DB_Mutex;
};

#endif