#include "DB_ClientObject.h"

DB_ClientObject::DB_ClientObject()
{
	this->m_DB_Mutex = new wxMutex(wxMUTEX_RECURSIVE);
	this->Clear();
	this->m_DirtyBit = false;
}
DB_ClientObject::~DB_ClientObject()
{
	this->Clear();
	delete this->m_DB_Mutex;
}
void DB_ClientObject::Clear()
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	if (this->m_ObjectDB_KEYID.size() != 0)
	{
		DBRecord_ClientObject *Record;
		// Loop through and remove all attached objects, free the memory
		for (DBClientObject_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin(); iter != this->m_ObjectDB_KEYID.end(); ++iter)
		{
			Record = iter->second;
			delete Record;
		}
		// Clear the entire list
		this->m_ObjectDB_KEYID.clear();
	}
}
void DB_ClientObject::ClearDirtyBit()
{
	this->m_DirtyBit = false;
}
bool DB_ClientObject::IsDirty()
{
	return this->m_DirtyBit;
}
uint32_t DB_ClientObject::GetNumberOfObjects()
{
	return this->m_ObjectDB_KEYID.size();
}
void DB_ClientObject::FetchAll(std::vector<DBRecord_ClientObject> &Records)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	if (this->m_ObjectDB_KEYID.size() != 0)
	{
		for (DBClientObject_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.begin(); iter != this->m_ObjectDB_KEYID.end(); ++iter)
		{
			Records.push_back(*iter->second);
		}
	}
	return;
}
bool DB_ClientObject::FindByID(uint32_t ID, DBRecord_ClientObject &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	if (ID == 0)
	{
		return false;
	}

	DBClientObject_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

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
bool DB_ClientObject::AddObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	DBRecord_ClientObject Record;

	if (this->FindByID(ID, Record))
	{
		return false;
	}

	DBRecord_ClientObject *NewRecord = new DBRecord_ClientObject(ID,Position,theta,phi,Red,Green,Blue,Brightness,Energy,Flags);

	std::pair<DBClientObject_KEYUINT::iterator,bool> ret = this->m_ObjectDB_KEYID.insert(std::pair<uint32_t, DBRecord_ClientObject*>(ID,NewRecord));

	if (ret.second == false)
	{
		delete NewRecord;
		return false;
	}

	this->m_DirtyBit = true;
	return true;
}
bool DB_ClientObject::UpdateObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	DBRecord_ClientObject *Record = NULL;

	DBClientObject_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Record = iter->second;

	Record->ID = ID;
	Record->Position = Position;
	Record->Theta = theta;
	Record->Phi = phi;
	Record->Red = Red;
	Record->Green = Green;
	Record->Blue = Blue;
	Record->Brightness = Brightness;
	Record->Energy = Energy;
	Record->Flags = Flags;

	this->m_DirtyBit = true;
	return true;
}
bool DB_ClientObject::AddUpdateObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	DBRecord_ClientObject Record;

	if (this->FindByID(ID,Record))
	{
		this->UpdateObject(ID,Position,theta,phi,Red,Green,Blue,Brightness, Energy, Flags);
	}
	else
	{
		this->AddObject(ID,Position,theta,phi,Red,Green,Blue,Brightness, Energy, Flags);
	}

	return true;
}
bool DB_ClientObject::DeleteObject(uint32_t ID)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	DBRecord_ClientObject *Record = NULL;

	DBClientObject_KEYUINT::iterator iter = this->m_ObjectDB_KEYID.find(ID);

	if (iter == this->m_ObjectDB_KEYID.end()) // If this is the case the object was not found in the list
	{
		return false;
	}

	Record = iter->second;

	this->m_ObjectDB_KEYID.erase(ID);

	delete Record;

	this->m_DirtyBit = true;

	return true;
}
