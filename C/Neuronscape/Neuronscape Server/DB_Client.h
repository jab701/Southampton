#ifndef DB_CLIENT_H
#define DB_CLIENT_H

#include <numeric>
#include <map>
#include <vector>
#include <stdint.h>

#include <wx/wx.h>
#include <wx/socket.h>

#include "DBRecord_Client.h"

#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

typedef std::map<uint32_t, DBRecord_Client*> DB_Client_KEYUINT;
typedef std::map<wxString, uint32_t> DB_Client_KEYIPV4;

class DB_Client
{
public: 
	DB_Client();
	~DB_Client();
	// Utility Functions
	void ClearDB();
	wxMutexError Lock();
	wxMutexError Unlock();
//	bool GetDirtyBit();
//	bool ClearDirtyBit();
	// Select Record Functions
	void FetchAll(std::vector<DBRecord_Client> &Records);
	bool FindByID(uint32_t ID, DBRecord_Client &Record);
	bool FindByIPV4Port(wxIPV4address IPAddress, DBRecord_Client &Record);
	// Insert Record Functions
	bool InsertRecord(DBRecord_Client Record);
	// Update Record Functions
	bool UpdateRecord(DBRecord_Client Record);
	// Delete Record Functions
	bool DeleteRecordByID(uint32_t ID);
	bool DeleteRecordByIPV4Port(wxIPV4address IPAddress);
private:
	unsigned int m_NextAvailableID;
	DB_Client_KEYUINT m_ClientDB_KEYID;
	DB_Client_KEYIPV4 m_ClientDB_KEYIP;
//	bool m_DirtyBit;
	wxMutex *m_DB_Mutex;
};


#endif