#include "ServerPacketProcessingThread.h"


// Constructor
ServerPacketProcessingThread::ServerPacketProcessingThread(wxFrame* Parent)  : wxThread(wxTHREAD_JOINABLE)
{
	this->m_StatusFlags = 0;
	this->m_ErrorFlags = 0;
	this->m_Enumerated = false;
	this->m_ClientID = 0;
	this->m_ObjectID = 0;
	this->m_TestsEchoReplyStr = std::string("");
	this->m_Env_Dim = CartesianVector(0.0,0.0,0.0);

	this->m_Parent = Parent;
	this->m_AddressMessageQueue.Clear();
	this->m_PacketMessageQueue.Clear();
	this->m_DB_Client = NULL;
	this->m_DB_Object = NULL;
	this->m_SystemStateVariableMutex = new wxMutex();
}
// Destructor
ServerPacketProcessingThread::~ServerPacketProcessingThread()
{	
	this->m_StatusFlags = 0;
	this->m_ErrorFlags = 0;
	this->m_Enumerated = false;
	this->m_ClientID = 0;
	this->m_ObjectID = 0;
	this->m_TestsEchoReplyStr = std::string("");
	this->m_Env_Dim = CartesianVector(0.0,0.0,0.0);

	this->m_Parent = NULL;
	this->m_AddressMessageQueue.Clear();
	this->m_PacketMessageQueue.Clear();

	this->m_DB_Client = NULL;
	this->m_DB_Object = NULL;

	delete this->m_SystemStateVariableMutex;
	this->m_SystemStateVariableMutex = NULL;
}
// Initialization Function
void ServerPacketProcessingThread::Initialize(DB_Client *ClientDB, DB_Object *ObjectDB, CartesianVector EnvDim)
{
	this->m_DB_Client = ClientDB;
	this->m_DB_Object = ObjectDB;
	this->m_EnvDim = EnvDim;
}
// Thread Messaging Functions
void ServerPacketProcessingThread::SendPacketToClient(wxIPV4address Address, std::string Payload)
{
	ServerPacketEvent event (nsSERVERPACKETPROCESSED, ID_FORWARDPACKETEVENT);
	event.SetAddress(Address);
	event.SetPayload(Payload);
	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
void ServerPacketProcessingThread::SendPacketToAllClients(std::string Payload)
{
	ServerPacketEvent event (nsSERVERPACKETPROCESSED, ID_FORWARDPACKETTOALLCLIENTSEVENT);
	event.SetPayload(Payload);
	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
void ServerPacketProcessingThread::SendEventToMain(uint32_t Data1, uint32_t Data2, std::string Text)
{
	wxCommandEvent event (wxEVT_COMMAND_TEXT_UPDATED, ID_PROCESSPACKETEVENT);
	event.SetInt(Data1);
	event.SetExtraLong(Data2);
	event.SetString(Text);
	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
// Post Packet Functions
void ServerPacketProcessingThread::PostPacket(wxIPV4address Peer, std::vector<unsigned char> Packet)
{
	if (wxThread::IsMain()) // Only the main thread can post messages!
	{
		this->m_AddressMessageQueue.Post(Peer);
		this->m_PacketMessageQueue.Post(Packet);
	}
}
// Processing Functions
int ServerPacketProcessingThread::PreProcessNetworkPacket(wxIPV4address Peer, std::vector<unsigned char> Data)
{
	if (Data.size() == 0)
	{
		// Zero Length Packet is not valid
		//		::wxLogMessage("Received Invalid Packet: Zero Payload Length Indicated - Packet Discarded");
		return -1;
	}

	if (Data.size()  > MAX_PACKET_LENGTH)
	{
		// Packet is too long
		//		::wxLogMessage("Received Invalid Packet: Payload Length > 1024 Bytes Indicated - Packet Discarded");
		return -2;
	}

	if (Data.size()  < 2)
	{
		// Packet is too short, minimum length must be 4 bytes!
		return -3;
	}

	DBRecord_Client Record;
	int ReturnCode = 0;

	// Search database to find client record
	if (!this->m_DB_Client->FindByIPV4Port(Peer,Record))
	{
		// No Matching Clients, Process as Unknown Client
		this->ProcessUnknownClientPacket(Peer,Data);
	}
	else
	{
		// Matching Client
		ReturnCode = this->ProcessNetworkPacket(Record,Data);
	}
	return ReturnCode;
}
int ServerPacketProcessingThread::ProcessNetworkPacket(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	int ReturnCode = 0;

	std::string Str;
	// Extract the first two bytes as the PACKET_ID bytes, save to PACKET_ID
	uint16_t PACKET_ID = uchar2ushort(SubVector(PacketData, 0, 2));
	// Remove the first two bytes and discard (these were the PACKET_ID Bytes we extracted already)
	PacketData = SubVector(PacketData, 2);

	// Process packet based on the packet_id
	switch(PACKET_ID)
	{
	case PKT_ACK:
		this->RecvAck(ClientRecord,PacketData);
		break;

	case PKT_ERROR:
		this->RecvError(ClientRecord,PacketData);
		break;

	case PKT_CONNECTION_REQ:
		// The client is already connected, report this to the client
		this->SendError(ClientRecord,PKT_CONNECTION_REQ,0);
		break;

	case PKT_DISCONNECTION_REQ:
		this->RecvDisconnectionReq(ClientRecord);
		break;

	case PKT_FORCEDISCONNECT: 
		// This is a server, cannot receive force disconnect!
		this->SendError(ClientRecord,PKT_FORCEDISCONNECT,0);		
		break;    

	case PKT_CLIENT_ENUMERATE:
		// This is a server, it should not be receiving client enumerate packets
		this->SendError(ClientRecord,PKT_CLIENT_ENUMERATE,0);
		break;    

	case PKT_REQ_ADD_OBJ:
		this->RecvAddObjectReq(ClientRecord, PacketData);
		break;         

	case PKT_UPDATE_OBJ:
		// Server should not be receiving object update packets!
		this->SendError(ClientRecord,PKT_UPDATE_OBJ,0);
		break;      

	case PKT_BULK_UPDATE_OBJ: 
		// Server should not be receiving Bulk Update Object Packets!
		this->SendError(ClientRecord,PKT_BULK_UPDATE_OBJ,0);
		break;  

	case PKT_DELETE_OBJ: 
		this->RecvDeleteObject(ClientRecord);
		break; 

	case PKT_DELETE_OBJ_ASGOD: 
		this->RecvDeleteObjectAsGod(ClientRecord, PacketData);
		break; 

	case PKT_FORCES_OBJ:
		this->RecvObjForces(ClientRecord,PacketData);
		break;

	case PKT_TORQUE_OBJ:
		this->RecvObjTorque(ClientRecord,PacketData);
		break;

	case PKT_COLOUR_OBJ:
		this->RecvObjColour(ClientRecord,PacketData);
		break;

	case PKT_ADDINANIMATE_OBJ:
		this->RecvAddInanimate(ClientRecord, PacketData);
		break;

	case PKT_EAT_OBJ:
		this->RecvEatObj(ClientRecord, PacketData);
		break;

	case PKT_KILL_SYSTEM:
		if (this->RecvKillSystem(ClientRecord,PacketData))
		{
			ReturnCode = SVR_NS_KILL;
		}
		break;

	case PKT_TEST_ECHO_REPLY:
		/*** Received an echo reply, test okay ***/
		/*** Do Nothing ***/
		break;

	case PKT_TEST_ECHO:
		Str.append(PacketData.begin(), PacketData.end());
		this->SendTestsEchoReply(ClientRecord,Str);
		break;

	default:
		// unknown packet, send error to client
		this->SendError(ClientRecord,0,0);
		break;
	}

	return ReturnCode;
}
bool ServerPacketProcessingThread::ProcessUnknownClientPacket(wxIPV4address ClientAddress, std::vector<unsigned char> PacketData)
{
	std::string Str;
	// Extract the first two bytes as the PACKET_ID bytes, save to PACKET_ID
	uint16_t PACKET_ID = uchar2ushort(SubVector(PacketData, 0, 2));
	// Remove the first two bytes and discard
	PacketData = SubVector(PacketData, 2); 
	// Check to see what the packet type is
	switch (PACKET_ID)
	{
	case PKT_CONNECTION_REQ: // is it a connection request?
		this->RecvConnectionReq(ClientAddress,PacketData);

		break;
	case PKT_TEST_ECHO:	// otherwise is it an echo (connection test) packet?
		Str.append(PacketData.begin(), PacketData.end());

		this->SendTestsEchoReply(ClientAddress,Str);
		break;

	default:
		// any other type of packet is not valid if the client it is not in the database, ignore and let function return
		break;
	}
	return true;
}
// Send Packet Functions
void ServerPacketProcessingThread::SendAck(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_ACK);
	std::vector<unsigned char> Data1_vec = ulong2uchar(Data1);
	std::vector<unsigned char> Data2_vec = ulong2uchar(Data2);

	Message.append(ID.begin(),ID.end());
	Message.append(Data1_vec.begin(),Data1_vec.end());
	Message.append(Data2_vec.begin(),Data2_vec.end());

	this->SendPacketToClient(ClientRecord.Addr,Message);
}
void ServerPacketProcessingThread::SendError(DBRecord_Client ClientRecord, uint32_t Data1, uint32_t Data2)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_ERROR);
	std::vector<unsigned char> Data1_vec = ulong2uchar(Data1);
	std::vector<unsigned char> Data2_vec = ulong2uchar(Data2);

	Message.append(ID.begin(),ID.end());
	Message.append(Data1_vec.begin(),Data1_vec.end());
	Message.append(Data2_vec.begin(),Data2_vec.end());

	this->SendPacketToClient(ClientRecord.Addr,Message);
}
void ServerPacketProcessingThread::SendError(wxIPV4address ClientAddress, uint32_t Data1, uint32_t Data2)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_ERROR);
	std::vector<unsigned char> Data1_vec = ulong2uchar(Data1);
	std::vector<unsigned char> Data2_vec = ulong2uchar(Data2);

	Message.append(ID.begin(),ID.end());
	Message.append(Data1_vec.begin(),Data1_vec.end());
	Message.append(Data2_vec.begin(),Data2_vec.end());

	this->SendPacketToClient(ClientAddress,Message);
}
void ServerPacketProcessingThread::SendClientEnum(DBRecord_Client ClientRecord)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_CLIENT_ENUMERATE);
	std::vector<unsigned char> X  = double2uchar(this->m_EnvDim.x);
	std::vector<unsigned char> Y  = double2uchar(this->m_EnvDim.y);
	std::vector<unsigned char> Z  = double2uchar(this->m_EnvDim.z);

	Message.append(ID.begin(),ID.end());
	Message.append(X.begin(), X.end());
	Message.append(Y.begin(), Y.end());
	Message.append(Z.begin(), Z.end());

	this->SendPacketToClient(ClientRecord.Addr,Message);
}
void ServerPacketProcessingThread::SendDeleteObject(DBRecord_Client ClientRecord, uint32_t ObjectID)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_DELETE_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());

	this->SendPacketToClient(ClientRecord.Addr,Message);
}
void ServerPacketProcessingThread::SendDeleteObjectToAllClients(uint32_t ObjectID)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_DELETE_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());

	std::vector<DBRecord_Client> Records;

	this->m_DB_Client->FetchAll(Records);

	this->SendPacketToAllClients(Message);
}
void ServerPacketProcessingThread::SendRemoveEatenObj(DBRecord_Client ClientRecord, uint32_t ObjectID, uint32_t ClientID)
{
	std::string Message;

	std::vector<unsigned char> ID  = ushort2uchar(PKT_REMOVE_EATEN_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);
	std::vector<unsigned char> CID = ulong2uchar(ClientID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());
	Message.append(CID.begin(), CID.end());

	this->SendPacketToClient(ClientRecord.Addr,Message);
}
void ServerPacketProcessingThread::SendRemoveEatenObjToAllClients(uint32_t ObjectID, uint32_t ClientID)
{
	std::string Message;

	std::vector<unsigned char> ID  = ushort2uchar(PKT_REMOVE_EATEN_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);
	std::vector<unsigned char> CID = ulong2uchar(ClientID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());
	Message.append(CID.begin(), CID.end());

	std::vector<DBRecord_Client> Records;

	this->m_DB_Client->FetchAll(Records);

	this->SendPacketToAllClients(Message);
}
void ServerPacketProcessingThread::SendKillSystemToAllClients(std::string PacketData)
{
	if (PacketData.size() > 32) // truncate to 32 bytes
	{
		PacketData = PacketData.substr(0, 32);
	}

	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_KILL_SYSTEM);

	Message.append(ID.begin(),ID.end());
	Message.append(PacketData);

	std::vector<DBRecord_Client> Records;

	this->m_DB_Client->FetchAll(Records);

	this->SendEventToMain(PKT_KILL_SYSTEM,0,"");
}
void ServerPacketProcessingThread::SendTestsEchoReply(DBRecord_Client ClientRecord, std::string PacketData)
{
	return this->SendTestsEchoReply(ClientRecord.Addr, PacketData);
}
void ServerPacketProcessingThread::SendTestsEchoReply(wxIPV4address ClientAddress, std::string PacketData)
{
	std::string Message;

	std::vector<unsigned char> Code = ushort2uchar(PKT_TEST_ECHO_REPLY);
	Message.append(Code.begin(), Code.end());

	Message.append(PacketData);

	this->SendPacketToClient(ClientAddress,Message);
}

// Receive Packet Functions
bool ServerPacketProcessingThread::RecvAck(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 8)
	{
		// Ignore the packet!
		return false;
	}

	uint32_t ACK_TYPE = uchar2ulong(SubVector(PacketData,0,4));
	uint32_t ACK_CODE = uchar2ulong(SubVector(PacketData,4,4));

	// Process packet based on the packet_id
	switch(ACK_TYPE)
	{
	case PKT_ACK:

		break;

	case PKT_ERROR:

		break;

	case PKT_CONNECTION_REQ:

		break;

	case PKT_DISCONNECTION_REQ:

		break;

	case PKT_FORCEDISCONNECT: 

		break;    

	case PKT_CLIENT_ENUMERATE:

		break;    

	case PKT_REQ_ADD_OBJ:

		break;         

	case PKT_UPDATE_OBJ:

		break;      

	case PKT_BULK_UPDATE_OBJ: 

		break;  

	case PKT_DELETE_OBJ: 

		break; 

	case PKT_FORCES_OBJ:

		break;

	case PKT_TEST_ECHO:

		break;

	default:
		// unknown packet, send error to client
		break;
	}
	return true;
}
bool ServerPacketProcessingThread::RecvError(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 8)
	{
		// Ignore the packet!
		return false;
	}

	uint32_t ERROR_TYPE = uchar2ulong(SubVector(PacketData,0,4));
	uint32_t ERROR_CODE = uchar2ulong(SubVector(PacketData,4,4));

	// Process packet based on the packet_id
	switch(ERROR_TYPE)
	{
	case PKT_ACK:

		break;

	case PKT_ERROR:

		break;

	case PKT_CONNECTION_REQ:

		break;

	case PKT_DISCONNECTION_REQ:

		break;

	case PKT_FORCEDISCONNECT: 

		break;    

	case PKT_CLIENT_ENUMERATE:

		break;    

	case PKT_REQ_ADD_OBJ:

		break;         

	case PKT_UPDATE_OBJ:

		break;      

	case PKT_BULK_UPDATE_OBJ: 

		break;  

	case PKT_DELETE_OBJ: 

		break; 

	case PKT_FORCES_OBJ:

		break;

	case PKT_TEST_ECHO:

		break;

	default:
		// unknown packet, send error to client
		break;
	}
	return true;
}
bool ServerPacketProcessingThread::RecvConnectionReq(wxIPV4address ClientAddress, std::vector<unsigned char> PacketData)
{
	unsigned char Role;
	uint16_t CommandSetMajor;
	uint16_t CommandSetMinor;

	DBRecord_Client Record;

	// Connection Request must be 5 bytes
	if (PacketData.size() != 5)
	{
		// Report an error has occurred
		// Pakcet is incorrect length!
		this->SendError(ClientAddress,PKT_CONNECTION_REQ,0);
		return false;
	}

	Role = PacketData[0];
	CommandSetMajor = uchar2ushort(SubVector(PacketData,1,2));
	CommandSetMinor = uchar2ushort(SubVector(PacketData,3,2));

	Record.Addr = ClientAddress;
	Record.ID = 0;
	Record.Role = Role;
	Record.Command_Ver_Major = CommandSetMajor;
	Record.Command_Ver_Minor = CommandSetMinor;
	// The Client is currently in enumeration phase 1
	// This means the client should not participate in normal network behaviour
	Record.Status = CLI_STATUS_ENUM;

	if (!this->m_DB_Client->InsertRecord(Record))
	{
		// Error has Occurred, Database error has occurred
		this->SendError(ClientAddress,PKT_CONNECTION_REQ,0);
		return false;
	}

	// Now read back the record from the database
	if (!this->m_DB_Client->FindByIPV4Port(ClientAddress, Record))
	{
		// Error has occurred, Database Error has occurred
		this->SendError(ClientAddress,PKT_CONNECTION_REQ,0);
		return false;		
	}

	// Acknowledge that client has been added successfully
	this->SendAck(Record,PKT_CONNECTION_REQ,Record.ID);
	// Send Enumeration Information
	this->SendClientEnum(Record);

	this->m_DB_Object->SetDirty();

	// Return true to indicate functions completed successfully
	wxString LogMessage;
	LogMessage.Printf("New Client Connected, id = %d", Record.ID);
	wxLogMessage(LogMessage);
	return true;
}
bool ServerPacketProcessingThread::RecvDisconnectionReq(DBRecord_Client &ClientRecord)
{
	if (!this->m_DB_Client->DeleteRecordByID(ClientRecord.ID))
	{
		// Delete Record failed!
		// Indicate an error has occurred to the client
		this->SendError(ClientRecord,PKT_DISCONNECTION_REQ,0);
		return false;
	}

	// Acknowledge that the client has been removed
	this->SendAck(ClientRecord,PKT_DISCONNECTION_REQ,ClientRecord.ID);

	wxString LogMsg;
	LogMsg.Printf("Client %d - Request Disconnection",ClientRecord.ID);
	wxLogMessage(LogMsg);
	return true;
}
bool ServerPacketProcessingThread::RecvAddObjectReq(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
    double InitialX;
	double InitialY;
	double InitialZ;
	double InitialEnergy;

	if (PacketData.size() == 8)
	{
		InitialX = -1.0;
		InitialY = -1.0;
		InitialZ = -1.0;
		InitialEnergy = uchar2double(SubVector(PacketData,0,8));
	}
	else if (PacketData.size() == 32)
	{
		InitialEnergy = uchar2double(SubVector(PacketData,0,8));
		InitialX = uchar2double(SubVector(PacketData,8,8));
		InitialY = uchar2double(SubVector(PacketData,16,8));
		InitialZ = uchar2double(SubVector(PacketData,24,8));
	}
	else
	{
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_REQ_ADD_OBJ,1);
	}

	DBRecord_Object ObjectRecord;

	// First check, what is the client identified as? Viewer or NEI?
	// Only Neuron-Environment Interfaces can  request add objects
	if (ClientRecord.Role != ROLE_NEUENV)
	{
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_REQ_ADD_OBJ,2);
		return false;
	}
	// Does the Client already own an object?
	if (this->m_DB_Object->FindByAssociatedClientID(ClientRecord.ID, ObjectRecord))
		// if return value is true then Clients already owns an object
	{
		// report and return
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_REQ_ADD_OBJ,3);
		return false;
	}

	DBRecord_Object NewObjectRecord;

	NewObjectRecord.Client_ID = ClientRecord.ID;
	NewObjectRecord.Position = CartesianVector(InitialX,InitialY,InitialZ);
	NewObjectRecord.Energy = InitialEnergy;
	NewObjectRecord.FLAGS = 0;

	if (!this->m_DB_Object->InsertRecord(NewObjectRecord))
	{
		// report error to server
		wxLogError("Failed to add object to the database");
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_REQ_ADD_OBJ,4);
		return false;
	}

	if (!this->m_DB_Object->FindByAssociatedClientID(ClientRecord.ID, ObjectRecord))
	{
		// No object could be found, report and return false
		// report error to server
		wxLogError("Failed to verify object was added to database, warning database may be inconsistent!");
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_REQ_ADD_OBJ,5);
		return false;
	}

	// Acknowledge successful object creation
	this->SendAck(ClientRecord,PKT_REQ_ADD_OBJ,ObjectRecord.ID);
	
	wxString LogMessage;
	LogMessage.Printf("New Object (id = %ld) assigned to Client (id = %ld)", ObjectRecord.ID, ClientRecord.ID);
	wxLogMessage(LogMessage);
	return true;
}
bool ServerPacketProcessingThread::RecvDeleteObject(DBRecord_Client &ClientRecord)
{
	// Is the client an NEI?
	if (ClientRecord.Role != ROLE_NEUENV)
	{
		// report error
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_DELETE_OBJ ,1);
		return false;
	}

	DBRecord_Object ObjectRecord;
	
	// find the object that is owned by the client
	if (!this->m_DB_Object->FindByAssociatedClientID(ClientRecord.ID,ObjectRecord))
		// Was the fetch object by Associated Client ID Successful?
	{
		// No, Client doesn't own an object
		// Report error
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_DELETE_OBJ ,2);
		return false;
	}

	// Try to delete the object
	if (!this->m_DB_Object->DeleteRecordByID(ObjectRecord.ID))
	{
		// Report Delete failed
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_DELETE_OBJ ,3);
		return false;
	}

	// Acknowledge successful object creation
	this->SendAck(ClientRecord,PKT_DELETE_OBJ,ObjectRecord.ID);

	this->SendDeleteObjectToAllClients(ObjectRecord.ID);

	wxString LogMsg;
	LogMsg.Printf("Client %d - Request Delete Object %d",ClientRecord.ID, ObjectRecord.ID);
	wxLogMessage(LogMsg);

	return true;
}
bool ServerPacketProcessingThread::RecvDeleteObjectAsGod(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{	// Function to allow removal of food objects by a "manipulator" client -- it connects as a viewer client
	// RM Aug 2012. 

	if (PacketData.size() != 4){ // Packet is incorrect length -- report error to client
		this->SendError(ClientRecord,PKT_DELETE_OBJ_ASGOD,1);
		return false;
	}
	if (ClientRecord.Role != ROLE_VIEWER){ // client must be a viewer, else report error report phase - report error to client
		this->SendError(ClientRecord, PKT_DELETE_OBJ_ASGOD, 2);
		return false;
	}
	uint32_t ObjectID = uchar2ulong(SubVector(PacketData,0,4)); // extract the obj ID from the packet (it's an int, so 4 bytes)
	DBRecord_Object ObjectRecord; // details of the object that was requested to delete

	if(!this->m_DB_Object->FindByID(ObjectID, ObjectRecord)){ // does the object exist?
		// should also check the object flags as to whether it's inanimate (else don't allow deletion in this manner)
		this->SendError(ClientRecord, PKT_DELETE_OBJ_ASGOD, 3); // 
		return false;
	}
	if (!this->m_DB_Object->DeleteRecordByID(ObjectRecord.ID)){ // Try to delete the object
		this->SendError(ClientRecord, PKT_DELETE_OBJ_ASGOD, 4); // if delete failed report error to client
		return false;
	}

	// Acknowledge successful object creation, and tell all clients an object was removed.
	this->SendAck(ClientRecord, PKT_DELETE_OBJ_ASGOD, ObjectRecord.ID);
	this->SendDeleteObjectToAllClients(ObjectRecord.ID);

	wxString LogMsg;
	LogMsg.Printf("Client %d - Request Delete Object %d",ClientRecord.ID, ObjectRecord.ID);
	wxLogMessage(LogMsg);

	return true;
}
bool ServerPacketProcessingThread::RecvObjForces(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 28)
	{
		// Packet is incorrect length
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_FORCES_OBJ,1);
		return false;
	}

	uint32_t ObjectID = uchar2ulong(SubVector(PacketData,0,4));

	double Force_x   = uchar2double(SubVector(PacketData,4,8));
	double Force_y   = uchar2double(SubVector(PacketData,12,8));
	double Force_z   = uchar2double(SubVector(PacketData,20,8));
	CartesianVector Force = CartesianVector(Force_x,Force_y,Force_z);

	if (Force != Force) // Check for indeterminate numbers, 1.#IND or -1.#IND
	{
		Force = CartesianVector(0.0,0.0,0.0);
	}

	// Is client an NEI or a Viewer
	if ((ClientRecord.Role != ROLE_VIEWER)&&(ClientRecord.Role != ROLE_NEUENV))
	{
		// report phase - Error, Client not supported
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_FORCES_OBJ,2);
		return false;
	}

	DBRecord_Object ObjectRecord;

	if (!this->m_DB_Object->FindByID(ObjectID,ObjectRecord))
	{
		// No such object exists with the given ID
		// Report phase - Error!
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_FORCES_OBJ,3);
		return false;
	}

	if (ClientRecord.Role == ROLE_VIEWER) // if it is Viewer then update external force
	{
		this->m_DB_Object->UpdateRecord_ExternForce(ObjectRecord.ID,Force);
	}
	else if (ClientRecord.Role == ROLE_NEUENV) // if it is a NEI and the object belongs to the client update Locomotion force
	{
		// Does the object belong to the client?
		if (ClientRecord.ID != ObjectRecord.Client_ID)
		{
			// NEI Client does not own object, cannot apply loco force
			// Report phase - Error
			// report phase - report error to client
			this->SendError(ClientRecord,PKT_FORCES_OBJ,4);
			return false;
		}

		this->m_DB_Object->UpdateRecord_MotorForce(ObjectRecord.ID,Force);
	}

	//	if (!this->m_NS_DB->UpdateObjectRecordByID(ObjectRecord))
	//	{
	// Database Error
	// Report Error, Free Memory & Return false;
	// report phase - report error to client
	//this->SendError(ClientRecord,PKT_FORCES_OBJ,0);
	//		delete ObjectRecord;
	//		return false;
	//	}

	// Acknowledge The Force Update
	this->SendAck(ClientRecord,PKT_FORCES_OBJ,0);
	// Return true
	return true;
}
bool ServerPacketProcessingThread::RecvObjTorque(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 20)
	{
		// Packet is incorrect length
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_TORQUE_OBJ,1);
		return false;
	}

	uint32_t ObjectID = uchar2ulong(SubVector(PacketData,0,4));	
	double ThetaTorque   = uchar2double(SubVector(PacketData,4,8));
	double PhiTorque    = uchar2double(SubVector(PacketData,12,8));

	// Is client an NEI
	if (ClientRecord.Role != ROLE_NEUENV)
	{
		// report phase - Error, Client not supported
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_TORQUE_OBJ,2);
		return false;
	}

	DBRecord_Object ObjectRecord;

	if (!this->m_DB_Object->FindByID(ObjectID,ObjectRecord))
	{
		// No such object exists with the given ID
		// Report phase - Error!
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_TORQUE_OBJ,3);
		return false;
	}

	// if it is a NEI and the object belongs to the client update Locomotion force

	// Does the object belong to the client?
	if (ClientRecord.ID != ObjectRecord.Client_ID)
	{
		// NEI Client does not own object, cannot apply loco force
		// Report phase - Error
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_TORQUE_OBJ,4);
		return false;
	}

	this->m_DB_Object->UpdateRecord_TorqueForces(ObjectRecord.ID,ThetaTorque,PhiTorque);

	// Acknowledge The Force Update
	this->SendAck(ClientRecord,PKT_TORQUE_OBJ,0);
	// Return true
	return true;
}
bool ServerPacketProcessingThread::RecvObjColour(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 8)
	{
		// Packet is incorrect length
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_COLOUR_OBJ,1);
		return false;
	}

	uint32_t ObjectID = uchar2ulong(SubVector(PacketData,0,4));	
	unsigned char Red   = PacketData[4];
	unsigned char Green = PacketData[5];
	unsigned char Blue  = PacketData[6];
	unsigned char Brightness = PacketData[7];

	// Is client an NEI
	if (ClientRecord.Role != ROLE_NEUENV)
	{
		// report phase - Error, Client not supported
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_COLOUR_OBJ,2);
		return false;
	}

	DBRecord_Object ObjectRecord;

	if (!this->m_DB_Object->FindByID(ObjectID,ObjectRecord))
	{
		// No such object exists with the given ID
		// Report phase - Error!
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_COLOUR_OBJ,3);
		return false;
	}

	// if it is a NEI and the object belongs to the client update Locomotion force

	// Does the object belong to the client?
	if (ClientRecord.ID != ObjectRecord.Client_ID)
	{
		// NEI Client does not own object, cannot apply loco force
		// Report phase - Error
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_COLOUR_OBJ,4);
		return false;
	}

	this->m_DB_Object->UpdateRecord_Colour(ObjectID,Red,Green,Blue,Brightness);

	// Acknowledge The Force Update
	this->SendAck(ClientRecord,PKT_COLOUR_OBJ,0);
	// Return true
	return true;
}
bool ServerPacketProcessingThread::RecvAddInanimate(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 34)
	{
		// Packet is incorrect length
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_ADDINANIMATE_OBJ,1);
		return false;
	}

	double X = uchar2double(SubVector(PacketData,0,8));
	double Y = uchar2double(SubVector(PacketData,8,8));
	double Z = uchar2double(SubVector(PacketData,16,8));
	unsigned char Red   = PacketData[24];
	unsigned char Green = PacketData[25];
	unsigned char Blue  = PacketData[26];
	unsigned char Brightness = PacketData[27];
	float Energy = uchar2float(SubVector(PacketData,28,4));
	uint16_t FLAGS = uchar2ushort(SubVector(PacketData,32,2));

	// Is client a Viewer
	if (ClientRecord.Role != ROLE_VIEWER)
	{
		// report phase - Error, Client not supported
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_ADDINANIMATE_OBJ,2);
		return false;
	}

	DBRecord_Object NewObjectRecord;

	NewObjectRecord.Client_ID = 0;
	NewObjectRecord.Position = CartesianVector(X,Y,Z);
	NewObjectRecord.Red = Red;
	NewObjectRecord.Green = Green;
	NewObjectRecord.Blue = Blue;
	NewObjectRecord.Brightness = Brightness;
	NewObjectRecord.Energy = Energy;
	NewObjectRecord.FLAGS = FLAGS|OBJFLAG_INANIMATE;

	if (!this->m_DB_Object->InsertRecord(NewObjectRecord))
	{
		// report error
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_ADDINANIMATE_OBJ,3);
		return false;
	}

	// Acknowledge successful object creation
	this->SendAck(ClientRecord,PKT_ADDINANIMATE_OBJ,NewObjectRecord.ID);
	this->m_DB_Object->SetDirty(); // Force whole database to be sent on next physics update
	wxLogMessage("Add Inanimate Object");
	// Return true
	return true;
}
bool ServerPacketProcessingThread::RecvEatObj(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (PacketData.size() != 4)
	{
		// Packet is incorrect length
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_EAT_OBJ,1);
		return false;
	}

	// Find object associated with Client
	DBRecord_Object Clients_Object;

	if (!this->m_DB_Object->FindByAssociatedClientID(ClientRecord.ID, Clients_Object))
	{
		// CLient does not own an object!
		// report phase - report error to client
		this->SendError(ClientRecord,PKT_EAT_OBJ,2);
		return false;
	}


	// Find the object directly in front of the object for EatingRange!

	// Edge of Object
	// Find Edge of object directly in front
	SphericalVector EdgeOfObject_S = SphericalVector(RADIUS,Clients_Object.Theta,PI/2.0);

	CartesianVector EdgeOfObject_C = Clients_Object.Position + CartesianVector(EdgeOfObject_S);

	// Find Point 0.5m directly infront of where object is facing
	SphericalVector InFront_S = SphericalVector(EatingRange,Clients_Object.Theta,PI/2.0);

	CartesianVector InFront_C = EdgeOfObject_C + CartesianVector(InFront_S);

	std::vector<DBRecord_Object> FoundObjects;

	this->m_DB_Object->FindBetweenCoordinates(EdgeOfObject_C, InFront_C, FoundObjects);

	if (FoundObjects.size() > 1) // If some objects were found
	{
		// Find the Closest
		CartesianVector CliObjPosition = Clients_Object.Position;

		unsigned Start_I = 0;
		DBRecord_Object NearestObject;
		SphericalVector Nearest;

		if (FoundObjects[0].ID == Clients_Object.ID)
		{
			NearestObject = FoundObjects[1];
			Nearest = FoundObjects[1].Position - Clients_Object.Position;
			Start_I = 2;
		}
		else
		{
			NearestObject = FoundObjects[0];
			Nearest = FoundObjects[0].Position - Clients_Object.Position;
			Start_I = 1;
		}

		for (unsigned i = Start_I; i < FoundObjects.size(); i++)
		{
			if (FoundObjects[i].ID != Clients_Object.ID)
			{
				DBRecord_Object Current = FoundObjects[i];
				SphericalVector Distance = FoundObjects[i].Position - Clients_Object.Position;

				if (Distance.Mag < Nearest.Mag)
				{
					NearestObject = FoundObjects[i];
					Nearest = Distance;
				}
			}
		}

		// Ok Now we have our nearest objject that is directly in front of us and less than EatingRange Away

		// Is it edible?
		if ((NearestObject.FLAGS && OBJFLAG_EDIBLE) != 0)
		{
			// Read the energy used and send it to the client
			this->m_DB_Object->UpdateRecord_Energy(Clients_Object.ID,(Clients_Object.Energy + NearestObject.Energy));

			// Tell Clients it has been eaten
			this->SendRemoveEatenObjToAllClients(NearestObject.ID, ClientRecord.ID);

			// Remove it from the environment
			this->m_DB_Object->DeleteRecordByID(NearestObject.ID);
		}
	}
	return true;
}
bool ServerPacketProcessingThread::RecvKillSystem(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	if (this->m_KillCode.size() == 0)
	{
		// No Kill Code Set So Kill System is disabled
		this->SendError(ClientRecord,PKT_KILL_SYSTEM,4);
		return false;
	}

	if (PacketData.size() != 32)
	{
		// Packet is not the right length
		this->SendError(ClientRecord,PKT_KILL_SYSTEM,1);
		return false;
	}

	if (ClientRecord.Role != ROLE_CNTRL)
	{
		// Client Sending the packet is not a Remote Control
		this->SendError(ClientRecord,PKT_KILL_SYSTEM,2);
		return false;
	}

	std::string KillCode;

	KillCode.append(PacketData.begin(),PacketData.end());

	int Match = KillCode.compare(this->m_KillCode);

	if (Match == 0)
	{
		// Kill Code is correct, Send acknowledge
		this->SendAck(ClientRecord,PKT_KILL_SYSTEM,0);
		// Kill Code is correct, broadcast it out to all clients
		this->SendKillSystemToAllClients(KillCode);
		return true;		
	}
	else
	{
		// Kill code was incorrect, send back an error to the client
		this->SendError(ClientRecord,PKT_KILL_SYSTEM,3);
		return false;
	}
}
bool ServerPacketProcessingThread::RecvTestsEcho(DBRecord_Client &ClientRecord, std::vector<unsigned char> PacketData)
{
	// Recv test Echo Packet must be less than 1022 bytes
	if (PacketData.size() > 1022)
	{
		this->SendError(ClientRecord,PKT_TEST_ECHO,0);
		return false;
	}

	std::string Str(PacketData.begin(), PacketData.end());
	this->SendTestsEchoReply(ClientRecord,Str);

	return true;
}
// Thread Main
wxThread::ExitCode ServerPacketProcessingThread::Entry()
{
	wxIPV4address Peer;
	std::vector<unsigned char> Packet;
	bool Quit = false;

	while (!Quit)
	{
		this->m_AddressMessageQueue.Receive(Peer);
		this->m_PacketMessageQueue.Receive(Packet);

		if ((Packet.size() == 0)&&(Peer.IPAddress() == wxString("0.0.0.0"))) // A zero length packet indicates we should exit
		{
			Quit = true;
			wxLogMessage("Packet Processing Stopping");
		}
		else
		{
			this->PreProcessNetworkPacket(Peer, Packet);
		}
	}
	wxLogMessage("Packet Processing Exit");
	return (0);
}