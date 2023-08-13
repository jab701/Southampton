#ifndef DBCLIENTOBJECT_H
#define DBCLIENTOBJECT_H

#include <wx/wx.h>
#include <map>
#include <vector>
#include <stdint.h>
#include "DBRecord_ClientObject.h"

typedef std::map<uint32_t, DBRecord_ClientObject*> DBClientObject_KEYUINT;

class DB_ClientObject
{
public:
	DB_ClientObject();
	~DB_ClientObject();
	void Clear();
	void ClearDirtyBit();
	bool IsDirty();
	uint32_t GetNumberOfObjects();
	void FetchAll(std::vector<DBRecord_ClientObject> &Records);

	bool FindByID(uint32_t ID, DBRecord_ClientObject &Record);

	bool AddObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags);
	bool UpdateObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags);
	bool AddUpdateObject(uint32_t ID, CartesianVector Position, double theta, double phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags);
	bool DeleteObject(uint32_t ID);

private:
	bool m_DirtyBit;
	DBClientObject_KEYUINT m_ObjectDB_KEYID;
	wxMutex *m_DB_Mutex;
};

#endif