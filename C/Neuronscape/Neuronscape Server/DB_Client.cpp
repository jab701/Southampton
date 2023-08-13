#include "DB_Client.h"

DB_Client::DB_Client()
{
	this->m_DB_Mutex = new wxMutex(wxMUTEX_RECURSIVE);
	this->ClearDB();
}
DB_Client::~DB_Client()
{
	this->ClearDB();
	delete this->m_DB_Mutex;
}
// Utility Functions
void DB_Client::ClearDB()
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	if (this->m_ClientDB_KEYID.size() != 0)
	{
		DBRecord_Client *Record;
		// Loop through and remove all attached objects, free the memory
		for (DB_Client_KEYUINT::iterator iter = this->m_ClientDB_KEYID.begin(); iter != this->m_ClientDB_KEYID.end(); ++iter)
		{
			Record = iter->second;
			delete Record;
		}
		// Clear the entire list
		this->m_ClientDB_KEYID.clear();
		this->m_ClientDB_KEYIP.clear();
	}

	this->m_NextAvailableID = 1;
}
wxMutexError DB_Client::Lock()
{
	return this->m_DB_Mutex->Lock();
}
wxMutexError DB_Client::Unlock()
{
	return this->m_DB_Mutex->Unlock();
}
// Select Record Functions
void DB_Client::FetchAll(std::vector<DBRecord_Client> &Records)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	Records.clear();
	// Loop through and remove all attached objects, free the memory
	for (DB_Client_KEYUINT::iterator iter = this->m_ClientDB_KEYID.begin(); iter != this->m_ClientDB_KEYID.end(); ++iter)
	{
		Records.push_back(*iter->second);
	}

	return;
}
bool DB_Client::FindByID(uint32_t ID, DBRecord_Client &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);
	if (ID == 0)
	{
		return false;
	}

	DB_Client_KEYUINT::iterator iter = this->m_ClientDB_KEYID.find(ID);

	if (iter != this->m_ClientDB_KEYID.end()) // If this is the case the object was found in the list
	{
		Record = *iter->second;
		return true;
	}
	else
	{
		return false;
	}
}
bool DB_Client::FindByIPV4Port(wxIPV4address IPAddress, DBRecord_Client &Record)
{
	wxMutexLocker Lock(*this->m_DB_Mutex);

	wxString IP = IPAddress.IPAddress();
	wxString Port;
	Port.Printf(":%d",IPAddress.Service());
	IP.Append(Port);

	DB_Client_KEYIPV4::iterator iter = this->m_ClientDB_KEYIP.find(IP);

	if (iter != this->m_ClientDB_KEYIP.end()) // If this is the case the object was found in the list
	{
		unsigned int ID = iter->second;
		return this->FindByID(ID,Record);
	}
	else
	{
		return false;
	}
}
// Insert Record Functions
bool DB_Client::InsertRecord(DBRecord_Client Record)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	wxString IPAddress;
	wxString Port;
	DBRecord_Client ExistingRecord;

	IPAddress.Append(Record.Addr.IPAddress());
	Port.Printf(":%d",Record.Addr.Service());

	IPAddress.Append(Port);

	if (this->FindByIPV4Port(Record.Addr, ExistingRecord))
	{
		// IP + Port Combination already in database;
		return false;
	}

	if (this->m_NextAvailableID == 0)
	{
		return false;
	}

	// Find next free ID
	DBRecord_Client *NewRecord = new DBRecord_Client(Record);
	NewRecord->ID = this->m_NextAvailableID;
	
	std::pair<DB_Client_KEYUINT::iterator,bool> ret1 = this->m_ClientDB_KEYID.insert(std::pair<uint32_t, DBRecord_Client*>(NewRecord->ID, NewRecord));
	std::pair<DB_Client_KEYIPV4::iterator,bool> ret2 = this->m_ClientDB_KEYIP.insert(std::pair<std::string, uint32_t>(IPAddress.ToStdString(), NewRecord->ID));

	if ((ret1.second == false)||(ret2.second == false))
	{
		// Database might be inconsistent, we must repair the database
		if (ret1.second == true)
		{
			this->m_ClientDB_KEYID.erase(NewRecord->ID);
		}

		if (ret2.second == true)
		{
			this->m_ClientDB_KEYIP.erase(IPAddress);
		}

		delete NewRecord;
		return false;
	}

	this->m_NextAvailableID++;
	return true;
}
// Update Record Function
bool DB_Client::UpdateRecord(DBRecord_Client Record)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	DBRecord_Client *Stored_Record;

	if (Record.ID == 0)
	{
		return false;
	}

	DB_Client_KEYUINT::iterator iter = this->m_ClientDB_KEYID.find(Record.ID);

	if (iter == this->m_ClientDB_KEYID.end()) // If this is the case the object was found in the list
	{
		return false;
	}

	Stored_Record = iter->second;

	Stored_Record->Addr = Record.Addr;
	Stored_Record->Role = Record.Role;
	Stored_Record->Command_Ver_Major = Record.Command_Ver_Major;
	Stored_Record->Command_Ver_Minor = Record.Command_Ver_Minor;
	Stored_Record->Status = Record.Status;

	return true;
}
// Delete Record Functions
bool DB_Client::DeleteRecordByID(uint32_t ID)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	DB_Client_KEYUINT::iterator iter1 = this->m_ClientDB_KEYID.find(ID);

	if (iter1 != this->m_ClientDB_KEYID.end()) // If this is the case the object was found in the list
	{
		DBRecord_Client *Record = iter1->second;
		wxString IP = Record->Addr.IPAddress();
		wxString Port;
		Port.Printf(":%d",Record->Addr.Service());
		IP.Append(Port);

		this->m_ClientDB_KEYID.erase(ID);
		this->m_ClientDB_KEYIP.erase(IP);

		delete Record;
		return true;
	}

	return false;
}
bool DB_Client::DeleteRecordByIPV4Port(wxIPV4address IPAddress)
{
	wxMutexLocker lock(*this->m_DB_Mutex);

	wxString IP = IPAddress.IPAddress();
	wxString Port;
	Port.Printf(":%d",IPAddress.Service());
	IP.Append(Port);

	DB_Client_KEYIPV4::iterator iter1 = this->m_ClientDB_KEYIP.find(IP);

	if (iter1 != this->m_ClientDB_KEYIP.end()) // If this is the case the object was found in the list
	{
		DB_Client_KEYUINT::iterator iter2 = this->m_ClientDB_KEYID.find(iter1->second);

		if (iter2 != this->m_ClientDB_KEYID.end()) // If this is the case the object was found in the list
		{
			DBRecord_Client *Record = iter2->second;
			this->m_ClientDB_KEYID.erase(Record->ID);
			delete Record;
		}

		this->m_ClientDB_KEYIP.erase(IP);

		return true;
	}

	return false;
}
