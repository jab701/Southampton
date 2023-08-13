#include "ClientPacketProcessThread.h"

// Constructor
ClientPacketProcessThread::ClientPacketProcessThread(wxFrame* Parent)  : wxThread(wxTHREAD_JOINABLE)
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
	this->m_ObjectDb = NULL;
	this->m_SystemStateVariableMutex = new wxMutex();
}
// Destructor
ClientPacketProcessThread::~ClientPacketProcessThread()
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
	this->m_ObjectDb = NULL;

	delete this->m_SystemStateVariableMutex;
	this->m_SystemStateVariableMutex = NULL;
}

void ClientPacketProcessThread::Initialize(DB_ClientObject *ObjectDatabase)
{
	this->m_ObjectDb = ObjectDatabase;
}
void ClientPacketProcessThread::PostPacket(wxIPV4address Peer, std::vector<unsigned char> Packet)
{
	if (wxThread::IsMain()) // Only the main thread can post messages!
	{
		this->m_AddressMessageQueue.Post(Peer);
		this->m_PacketMessageQueue.Post(Packet);
	}
}
// Get Functions
uint32_t  ClientPacketProcessThread::GetAssignedClientID()
{
	return this->m_ClientID;
}
uint32_t  ClientPacketProcessThread::GetAssignedObjectID()
{
	return this->m_ObjectID;
}
uint32_t  ClientPacketProcessThread::GetStatus()
{
	return this->m_StatusFlags;
}
bool  ClientPacketProcessThread::GetEnvDimensions(CartesianVector &EnvDim)
{
	if ((this->m_Env_Dim.x == 0.0)||(this->m_Env_Dim.y == 0.0)||(this->m_Env_Dim.z == 0.0))
	{
		return false;
	}

	EnvDim = this->m_Env_Dim;
	return true;
}
uint32_t  ClientPacketProcessThread::GetError()
{
	return this->m_ErrorFlags;
}
std::string ClientPacketProcessThread::GetTestsEchoReply()
{
	return this->m_TestsEchoReplyStr;
}
// Private Functions
void ClientPacketProcessThread::SendEventToMain(uint32_t Data1, uint32_t Data2, std::string Text)
{
	wxCommandEvent event (wxEVT_COMMAND_TEXT_UPDATED, ID_PROCESSPACKET);
	event.SetInt(Data1);
	event.SetExtraLong(Data2);
	event.SetString(Text);
	this->m_Parent->GetEventHandler()->AddPendingEvent(event);
}
// Receive Packet Functions
// Packet Processing Flow
void ClientPacketProcessThread::ProcessNetworkPacket(wxIPV4address Peer, std::vector<unsigned char> Data)
{
	// Did the packet come from the connected server?
	//if ((Peer.IPAddress() != this->m_ServerAddress.IPAddress())||(Peer.Service() != this->m_ServerAddress.Service()))
	//{
		// No? Just ignore and return.
	//	return CLI_NS_OK;
	//}

	if (Data.size() == 0)
	{
		// Zero Length Packet is not valid
		//		::wxLogMessage("Received Invalid Packet: Zero Payload Length Indicated - Packet Discarded");
		return;
	}

	if (Data.size()  > MAX_PACKET_LENGTH)
	{
		// Packet is too long
		//		::wxLogMessage("Received Invalid Packet: Payload Length > 1024 Bytes Indicated - Packet Discarded");
		return;
	}

	if (Data.size()  < 2)
	{
		// Packet is too short, minimum length must be 4 bytes!
		return;
	}

	// Extract the first two bytes as the PACKET_ID bytes, save to PACKET_ID
	uint16_t PACKET_ID = uchar2ushort(SubVector(Data,0,2));
	// Remove the first two bytes and discard (these were the PACKET_ID Bytes we extracted already)
	Data = SubVector(Data,2);

	int ReturnCode = CLI_NS_OK;

	switch(PACKET_ID)
	{
	case PKT_ACK:
		ReturnCode = this->RecvAck(Data);
		break;

	case PKT_ERROR:
		ReturnCode = this->RecvError(Data);
		break;

	case PKT_FORCEDISCONNECT:
		this->SendEventToMain(CLI_NS_DISCONNECT_FORCED, 0, "");
		break;    

	case PKT_CLIENT_ENUMERATE:
		ReturnCode = this->RecvClientEnum(Data);
		break;    

	case PKT_BULK_UPDATE_OBJ: 
		if ((this->m_Enumerated == false)||(this->m_ClientID == 0))
		{
			// Report error to server!
		}
		else
		{
			this->RecvBulkUpdateObj(Data);

			if (this->m_ObjectDb->IsDirty())
			{
				this->SendEventToMain(CLI_NS_OBJECT_DATA_DIRTY, 0, "");
			}
		}

		break;  

	case PKT_DELETE_OBJ: 
		if (this->m_Enumerated == false)
		{
			// Report error to server!
		}
		else
		{
			ReturnCode = this->RecvDeleteObject(Data);

		}

		break; 

	case PKT_REMOVE_EATEN_OBJ:
		ReturnCode = this->RecvRemoveEatenObj(Data);
		break;

	case PKT_KILL_SYSTEM:
		if (this->RecvKillSystem(Data))
		{
			this->SendEventToMain(CLI_NS_KILL, 0, "");
		}
		break;

	case PKT_TEST_ECHO_REPLY:
		this->RecvTestsEchoReply(Data);
		break;

	case PKT_TEST_ECHO:
		this->RecvTestsEcho(Data);
		break;

	default:
		// unknown packet, send error to server
		this->SendEventToMain(CLI_NS_BADBACKETID, 0, "");
		break;
	}

	if (ReturnCode != CLI_NS_OK) // If returncode is not CLI_NS_OK then the packet needs attention from main thread
	{
		this->SendEventToMain(ReturnCode, 0, "");
	}

	return;
}
int ClientPacketProcessThread::RecvAck(std::vector<unsigned char> Data)
{
	if (Data.size() != 8)
	{
		// Ignore the packet!
		return CLI_NS_OK;
	}

	uint32_t ACK_TYPE = uchar2ulong(SubVector(Data,0,4));
	uint32_t ACK_CODE = uchar2ulong(SubVector(Data,4,4));
	int ReturnCode = CLI_NS_OK;

	// Process packet based on the packet_id
	switch(ACK_TYPE)
	{
	case PKT_CONNECTION_REQ:
		if (this->m_ClientID == 0)
		{
			this->m_ClientID = ACK_CODE;
			this->m_Enumerated = false;
			ReturnCode = CLI_NS_CONNECTED;
		}

		break;

	case PKT_DISCONNECTION_REQ:
		if (this->m_ClientID != 0)
		{
			this->m_ClientID = 0;
			this->m_Enumerated = false;
			ReturnCode = CLI_NS_DISCONNECTED;
		}

		break;

	case PKT_REQ_ADD_OBJ:
		if (this->m_ObjectID == 0)
		{
			this->m_ObjectID = ACK_CODE;
			ReturnCode = CLI_NS_ASSIGNED_OBJECT;
		}

		break;         

	case PKT_DELETE_OBJ:
		if (this->m_ObjectID != 0)
		{
			this->m_ObjectID = 0;
			ReturnCode = CLI_NS_ASSIGNED_OBJECT_REMOVED;
		}

		break; 

	case PKT_ADDINANIMATE_OBJ:
		// TODO:
		break;

	default:
		// unknown packet acknowledge, ignore
		ReturnCode = CLI_NS_OK;
		break;
	}

	return ReturnCode;
}
int ClientPacketProcessThread::RecvError(std::vector<unsigned char> Data)
{
	if (Data.size() != 8)
	{
		// Ignore the packet!
		return false;
	}

	uint32_t ERROR_TYPE = uchar2ulong(SubVector(Data,0,4));
	uint32_t ERROR_CODE = uchar2ulong(SubVector(Data,4,4));

	int ReturnCode = CLI_NS_ERROR;
	// Process packet based on the packet_id
	switch(ERROR_TYPE)
	{
	case GENERAL_ERROR: // General Error

		break;

	case PKT_CONNECTION_REQ:

		break;

	case PKT_DISCONNECTION_REQ:

		break;

	case PKT_CLIENT_ENUMERATE:

		break;    

	case PKT_REQ_ADD_OBJ:

		break;         

	case PKT_DELETE_OBJ: 

		break; 

	case PKT_FORCES_OBJ:

		break;

	case PKT_TEST_ECHO_REPLY:

		break;

	case PKT_TEST_ECHO:

		break;

	default:
		// Unknown Error Type, ignore
		ReturnCode = CLI_NS_OK;
		break;
	}
	return ReturnCode;
}
int ClientPacketProcessThread::RecvClientEnum(std::vector<unsigned char> Data)
{
	// Check to see if client is already enumerated
	if (this->m_Enumerated == true)
	{
		return CLI_NS_OK;
	}

	if (Data.size() != 24)
	{
		return CLI_NS_OK;
	}

	double x = uchar2double(SubVector(Data,0,8));
	double y = uchar2double(SubVector(Data,8,8));
	double z = uchar2double(SubVector(Data,16,8));

	if ((x <= 0.0)||(y <= 0.0)||(z <= 0.0))
	{
		// Environment dimensions cannot be zero or negative!
		// Report Error to Server
		return CLI_NS_OK;
	}
	this->m_Env_Dim = CartesianVector(x,y,z);
	// Send Ack
	//this->SendAck(PKT_CLIENT_ENUMERATE,0);
	this->m_Enumerated = true;

	return CLI_NS_ENUM;
}
bool ClientPacketProcessThread::RecvBulkUpdateObj(std::vector<unsigned char> Data)
{
	if (Data.size() < 2) // Packet cant be valid - discard!
	{
		return false;
	}

	uint32_t NumObjects = uchar2ulong(SubVector(Data,0,4));
	Data = SubVector(Data,4);

	if (Data.size() != (NumObjects*UPDATE_OBJ_LENGTH)) // Packet is not the correct length for the number of objects - discard
	{
		return false;
	}

	for (uint16_t i = 0; i < NumObjects; i++)
	{
		unsigned Start = UPDATE_OBJ_LENGTH*i;

		std::vector<unsigned char> SingleObject = SubVector(Data,Start,UPDATE_OBJ_LENGTH);

		uint32_t ObjectID = uchar2ulong(SubVector(SingleObject,0,4));
		double x = uchar2double(SubVector(SingleObject,4,8));
		double y = uchar2double(SubVector(SingleObject,12,8));
		double z = uchar2double(SubVector(SingleObject,20,8));
		double theta = uchar2double(SubVector(SingleObject,28,8));
		double phi = uchar2double(SubVector(SingleObject,36,8));
		unsigned char Red = SingleObject[44];
		unsigned char Green = SingleObject[45];
		unsigned char Blue = SingleObject[46];
		unsigned char Brightness = SingleObject[47];
		double Energy = uchar2double(SubVector(SingleObject,48,8)); 
		uint16_t Flags = uchar2ushort(SubVector(SingleObject, 56, 2));

		CartesianVector Position = CartesianVector(x,y,z);

		this->m_ObjectDb->AddUpdateObject(ObjectID,Position,theta,phi,Red,Green,Blue,Brightness,Energy,Flags);
	}

	return true;
}
uint32_t ClientPacketProcessThread::RecvDeleteObject(std::vector<unsigned char> Data)
{
	if (Data.size() != 4)
	{
		return CLI_NS_OK;
	}

	uint32_t ObjectID = uchar2ulong(SubVector(Data,0,4));

	this->m_ObjectDb->DeleteObject(ObjectID);

	int ReturnCode = CLI_NS_OBJECT_DATA_DIRTY; // By default deleting an object marks the DB as dirty

	if (ObjectID == this->m_ObjectID)
	{
		this->m_ObjectID = 0;
		ReturnCode = CLI_NS_ASSIGNED_OBJECT_REMOVED; // If it was our object then change the return code to reflect that fact
	}

	return ReturnCode;
}
uint32_t ClientPacketProcessThread::RecvRemoveEatenObj(std::vector<unsigned char> Data)
{
	if (Data.size() != 8)
	{
		return CLI_NS_OK;
	}

	uint32_t ObjectID = uchar2ulong(SubVector(Data,0,4));
	uint32_t ClientID = uchar2ulong(SubVector(Data,4,4));

	this->m_ObjectDb->DeleteObject(ObjectID);

	int ReturnCode = CLI_NS_OBJECT_DATA_DIRTY; // By default deleting an object marks the DB as dirty

	if (ObjectID == this->m_ObjectID)
	{
		this->m_ObjectID = 0;
		ReturnCode = CLI_NS_OBJECT_EATEN; // If it was our object then change the return code to reflect that fact
	}

	this->SendEventToMain(ReturnCode, ClientID, "");

	return CLI_NS_OK;
}
bool ClientPacketProcessThread::RecvKillSystem(std::vector<unsigned char> Data)
{
	// TODO: ? There might be code to double check the kill code one day since the kill code would be 
	// included in the client enumerate packet. - JAB 19/03/2012
	return true;
}
bool ClientPacketProcessThread::RecvTestsEchoReply(std::vector<unsigned char> Data)
{
	this->m_TestsEchoReplyStr.clear();
	this->m_TestsEchoReplyStr.append(Data.begin(),Data.end());

	this->SendEventToMain(CLI_NS_TEST_ECHO_REPLY, 0, this->m_TestsEchoReplyStr);
	return true;
}
bool ClientPacketProcessThread::RecvTestsEcho(std::vector<unsigned char> Data)
{
	// Recv test Echo Packet must be less than 1022 bytes
	if (Data.size() > MAX_PACKET_LENGTH)
	{
		//this->SendError(PKT_TEST_ECHO, 0, 0);
		Data.erase(Data.begin()+1022, Data.end());
	}

	std::string Str;
	Str.append(Data.begin(),Data.end());
	
	this->SendEventToMain(CLI_NS_TEST_ECHO, 0, Str);
	return true;
}
// Thread Main
wxThread::ExitCode ClientPacketProcessThread::Entry()
{
	wxIPV4address Peer;
	std::vector<unsigned char> Packet;
	bool Quit = false;

	while (!Quit)
	{
		this->m_AddressMessageQueue.Receive(Peer);
		this->m_PacketMessageQueue.Receive(Packet);

		if (Packet.size() == 0) // A zero length packet indicates we should exit
		{
			Quit = true;
		}
		else
		{
			this->ProcessNetworkPacket(Peer, Packet);
		}
	}
	return (0);
}