#include "DB_Object.h"

DB_Object::DB_Object()
{
	this->m_DB_Mutex = new wxMutex(wxMUTEX_RECURSIVE);
	this->ClearDB();
	this->m_DirtyBit = false;
}
DB_Object::~DB_Object()
{
	this->ClearDB();
	this->m_DirtyBit = false;
	delete this->m_DB_Mutex;
}
// Utility Functions
void DB_Object::ClearDB()
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	if (this->m_ObjectDB_KEYID.size() != 0)
	{
		// Clear the associated Client ID Database
		this->m_ObjectDB_KEYASSOCIATEDCLIENTID.clear();

		for (DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin(); iter != this->m_ObjectDB_KEYID.end(); ++iter)
		{
			delete iter->second;
		}

		this->m_ObjectDB_KEYID.clear();
	}

	this->m_NextAvailableID = 1;
}
wxMutexError DB_Object::Lock()
{
	return this->m_DB_Mutex->Lock();
}
wxMutexError DB_Object::Unlock()
{
	return this->m_DB_Mutex->Unlock();
}
bool DB_Object::IsDirty()
{
	return this->m_DirtyBit;
}
void DB_Object::SetDirty()
{
	this->m_DirtyBit = true;
}
void DB_Object::ClearDirtyBit()
{
	this->m_DirtyBit = false;
}
// Select Record Functions
void DB_Object::FetchAll(std::vector<DBRecord_Object> &Records)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	Records.clear();
	// Loop through and remove all attached objects, free the memory
	for (DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin(); iter != this->m_ObjectDB_KEYID.end(); ++iter)
	{
		Records.push_back(*iter->second);
	}

	return;
}
void DB_Object::FetchAllMobile(std::vector<DBRecord_Object> &Records)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	Records.clear();
	// Loop through and remove all attached objects, free the memory
	for (DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin(); iter != this->m_ObjectDB_KEYID.end(); ++iter)
	{
		if ((iter->second->FLAGS & OBJFLAG_FIXED) == 0)
		{
			Records.push_back(*iter->second);
		}
	}

	return;
}
bool DB_Object::FindByID(uint32_t ID, DBRecord_Object &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter != this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		Record = *iter->second;
		return true;
	}
	else
	{
		return false;
	}
}
bool DB_Object::FindByAssociatedClientID(uint32_t ID, DBRecord_Object &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYASSOCIATEDCLIENTID.find(ID);

	if (iter != this->m_ObjectDB_KEYASSOCIATEDCLIENTID.end()) // If this is the case the object was found in the list
	{
		Record = *iter->second;
		return true;
	}
	else
	{
		return false;
	}
}
bool DB_Object::FindBetweenCoordinates(CartesianVector Point1, CartesianVector Point2, std::vector<DBRecord_Object> &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	double X1 = Point1.x;
	double Y1 = Point1.y;
	double Z1 = Point1.z;

	double X2 = Point2.x;
	double Y2 = Point2.y;
	double Z2 = Point2.z;

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin();

	for (DB_Object_KEYUINT::iterator i = this->m_ObjectDB_KEYID.begin(); i != this->m_ObjectDB_KEYID.end(); ++i)
	{
		DBRecord_Object CurrentRecord = *i->second;

		double ObjXmin = CurrentRecord.Position.x - RADIUS;
		double ObjYmin = CurrentRecord.Position.y - RADIUS;
		double ObjZmin = CurrentRecord.Position.z - RADIUS;

		double ObjXmax = CurrentRecord.Position.x + RADIUS;
		double ObjYmax = CurrentRecord.Position.y + RADIUS;
		double ObjZmax = CurrentRecord.Position.z + RADIUS;

		bool IntersectX = IntersectLines(X1, X2, ObjXmin, ObjXmax);
		bool IntersectY = IntersectLines(Y1, Y2, ObjYmin, ObjYmax);
		bool IntersectZ = IntersectLines(Z1, Z2, ObjZmin, ObjZmax);

		if (IntersectX & IntersectY & IntersectZ)
		{
			// If we get here then an object has been found
			Record.push_back(CurrentRecord);
		}
	}
	return true;
}
bool DB_Object::CollisionDetector(CartesianVector Obj, double Obj_RADIUS)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	bool Collision = false;

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin();

	for (DB_Object_KEYUINT::iterator i = this->m_ObjectDB_KEYID.begin(); i != this->m_ObjectDB_KEYID.end(); ++i)
	{
		DBRecord_Object CurrentRecord = *i->second;

		CartesianVector Position = CurrentRecord.Position;

		Collision = IntersectSpheres(Obj, Obj_RADIUS, Position, RADIUS);
	}
	return Collision;
}
void DB_Object::WithinLimits(CartesianVector &Position, CartesianVector Limits)
{
	if ((Position.x - RADIUS) <= 0.0)
	{
		Position.x = RADIUS;
	}

	if ((Position.x + RADIUS) >= Limits.x)
	{
		Position.x = Limits.x - RADIUS;
	}

	if ((Position.y - RADIUS) <= 0.0)
	{
		Position.y = RADIUS;
	}

	if ((Position.y + RADIUS) >= Limits.y)
	{
		Position.y = Limits.y - RADIUS;
	}

	if ((Position.z - RADIUS) <= 0.0)
	{
		Position.z = RADIUS;
	}

	if ((Position.z + RADIUS) >= Limits.z)
	{
		Position.z = Limits.z - RADIUS;
	}
}
// Insert Record Functions
bool DB_Object::InsertRecord(DBRecord_Object Record)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	if (this->m_NextAvailableID == 0)
	{
		return false;
	}

	// if any of the requested positions are negative (i.e., invalid) then place the new object uniformly at random
	if ((Record.Position.x < 0)||(Record.Position.y < 0)||(Record.Position.z < 0))
	{
		RandomlyGeneratePosition(this->m_EnvDimensions,Record.Position);
	}

	// Ensure object is within limits
	this->WithinLimits(Record.Position, this->m_EnvDimensions);

	bool Placed = false;

	if (this->CollisionDetector(Record.Position,RADIUS)) // If the new object collides with an exisiting one we must generate position
	{
		for (int i = 0; i < MaxPlacementAttempts; i++)
		{
			RandomlyGeneratePosition(this->m_EnvDimensions,Record.Position); // Generate new position

			// Ensure object is within limits
			this->WithinLimits(Record.Position, this->m_EnvDimensions);

			if (!this->CollisionDetector(Record.Position, RADIUS)) // Does it collide?
			{
				Placed = true;
				break; // No
			}
		}

		if (Placed == false)
		{
			return false;
		}
	}

	if (Record.Client_ID == 0)
		// Object is inanimate since it does not have an owner
	{
		DBRecord_Object *NewRecord = new DBRecord_Object(Record);
		NewRecord->ID = this->m_NextAvailableID;

		std::pair<DB_Object_KEYUINT::iterator,bool> ret1 = this->m_ObjectDB_KEYID.insert(std::pair<uint32_t, DBRecord_Object*>(NewRecord->ID, NewRecord));

		if (ret1.second == false)
		{
			delete NewRecord;
			return false;
		}
	}
	else
		// Object "Belongs" to an NEI Client
	{
		if (this->IsAnObjectAssignedToClient(Record.Client_ID) == true)
		{
			return false;
		}

		DBRecord_Object *NewRecord = new DBRecord_Object(Record);
		NewRecord->ID = this->m_NextAvailableID;

		std::pair<DB_Object_KEYUINT::iterator,bool> ret1 = this->m_ObjectDB_KEYID.insert(std::pair<uint32_t, DBRecord_Object*>(NewRecord->ID, NewRecord));
		std::pair<DB_Object_KEYUINT::iterator,bool> ret2 = this->m_ObjectDB_KEYASSOCIATEDCLIENTID.insert(std::pair<uint32_t, DBRecord_Object*>(NewRecord->Client_ID, NewRecord));

		if ((ret1.second == false)||(ret2.second == false))
		{
			// Database might be inconsistent, we must repair the database
			if (ret1.second == true)
			{
				this->m_ObjectDB_KEYID.erase(NewRecord->ID);
			}

			if (ret2.second == true)
			{
				this->m_ObjectDB_KEYASSOCIATEDCLIENTID.erase(NewRecord->Client_ID);
			}

			delete NewRecord;
			return false;
		}
	}

	this->m_NextAvailableID++;
	return true;
}
// Update Record Functions
bool DB_Object::UpdateRecord_Colour(uint32_t ID, unsigned char Red, unsigned char Green,unsigned char Blue, unsigned char Brightness)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->Red = Red;
	Record->Green = Green;
	Record->Blue = Blue;
	Record->Brightness = Brightness;

	return true;	
}
bool DB_Object::UpdateRecord_Energy(uint32_t ID, double Energy)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->Energy = Energy;

	return true;	
}
bool DB_Object::UpdateRecord_ExternForce(uint32_t ID, CartesianVector ExternalForce)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->ExternForce = ExternalForce;

	return true;	
}
bool DB_Object::UpdateRecord_MotorForce(uint32_t ID, CartesianVector MotorForce)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->MotorForce = MotorForce;

	return true;	
}
bool DB_Object::UpdateRecord_TorqueForces(uint32_t ID, double ThetaTorque, double PhiTorque)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->ThetaTorque = ThetaTorque;
	Record->PhiTorque = PhiTorque;

	return true;	
}
bool DB_Object::UpdateRecord_PositionVelocity(uint32_t ID, CartesianVector Position, CartesianVector Velocity)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->Position = Position;
	Record->Velocity = Velocity;

	return true;	
}
bool DB_Object::UpdateRecord_Theta_ThetaVelocity(uint32_t ID, double Theta, double ThetaVelocity)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->Theta = Theta;
	Record->ThetaVelocity = ThetaVelocity;

	return true;
}
bool DB_Object::UpdateRecord_Phi_PhiVelocity(uint32_t ID, double Phi, double PhiVelocity)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	DBRecord_Object *Record;

	if (ID == 0)
	{
		return false;
	}

	DB_Object_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->Phi = Phi;
	Record->PhiVelocity = PhiVelocity;

	return true;
}
// Delete Record Functions
bool DB_Object::DeleteRecordByID(uint32_t ID)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	DB_Object_KEYUINT::iterator iter1 = this->m_ObjectDB_KEYID.find(ID);

	if (iter1 == this->m_ObjectDB_KEYID.end()) 
		// Object was not found in the DB
	{
		return false;
	}

	// Get a pointer to the Record Data
	DBRecord_Object *Record = iter1->second;

	// Does the Record indicate an associated Client?
	if (Record->Client_ID != 0)
		// There is an attached client so we must scan the ClientID Map and remove the entry there
	{
		this->m_ObjectDB_KEYASSOCIATEDCLIENTID.erase(Record->Client_ID);
	}

	// Remove the Entry in the ID Map
	this->m_ObjectDB_KEYID.erase(Record->ID);

	// Now free the memory associated with the record
	delete Record;

	// Return true to indicate success
	return true;
}
bool DB_Object::DeleteRecordByAssociatedClientID(uint32_t ID)
{
	DBRecord_Object Record;
	if (!this->FindByAssociatedClientID(ID,Record))
	{
		return false;
	}
	return this->DeleteRecordByID(Record.ID);
}
// Private Functions
bool DB_Object::IsAnObjectAssignedToClient(uint32_t Client_ID)
{
	DBRecord_Object Record;

	if (this->FindByAssociatedClientID(Client_ID,Record) == true)
	{
		return true;
	}
	else
	{
		return false;
	}
}
