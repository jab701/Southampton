#include "NetworkStackClient.h"

// Default Constructor
NetworkStackClient::NetworkStackClient()
{
	this->m_ServerAddress.Clear();
	this->m_ClientSocket = NULL;
}
// Destructor
NetworkStackClient::~NetworkStackClient()
{
	this->m_ServerAddress.Clear();
	this->m_ClientSocket = NULL;
}
// Control Functions
bool NetworkStackClient::StartNetworkSocket(wxIPV4address ServerAddress, wxFrame *EventHandler, int SOCKET_EVENT_ID, DB_ClientObject *ObjectDb)
{
	if (ObjectDb == NULL)
	{
		return false;
	}

	if (EventHandler == NULL)
	{
		return false;
	}

	if (SOCKET_EVENT_ID == wxID_ANY)
	{
		return false;
	}

	wxIPV4address ClientAddress;
	ClientAddress.AnyAddress();
	ClientAddress.Service(0);

	this->m_ClientSocket = new wxDatagramSocket(ClientAddress,wxSOCKET_NONE);

	if (this->m_ClientSocket == NULL)
	{
		return(false);
	}

	if (!this->m_ClientSocket->IsOk())
	{
		this->m_ClientSocket->Destroy();
		return(false);
	}

	this->m_ClientSocket->SetEventHandler(*EventHandler,SOCKET_EVENT_ID);

	this->m_ClientSocket->SetNotify(wxSOCKET_INPUT_FLAG);

	this->m_ClientSocket->Notify(true);

	this->m_ServerAddress = ServerAddress;

	return true;
}
bool NetworkStackClient::StopNetworkSocket()
{
	if (this->m_ClientSocket == NULL)
	{
		return false;
	}

	this->m_ClientSocket->Notify(false);
	this->m_ClientSocket->Discard();

	this->m_ClientSocket->Destroy();
	this->m_ClientSocket = NULL;

	this->m_ServerAddress.Clear();

	this->m_ClientSocket = NULL;

	return true;
}
// Set Functions
// Checking Functions
bool NetworkStackClient::IsOK()
{
	if (this->m_ClientSocket == NULL)
	{
		return false;
	}

	if (!this->m_ClientSocket->IsOk())
	{
		return false;
	}

	return true;
}
// Function to send a data string 
bool NetworkStackClient::SendString(std::string Data)
{
	std::string DataToSend;

	if (Data.length() > (MAX_PACKET_LENGTH-2)) // Packet limit is 1024 bytes including the packet length bytes (x2)
	{
		// Packet is too long!
		return false;
	}

	if (this->IsOK() == false)
	{
		return false;
	}

	std::vector<unsigned char> LenVec = ushort2uchar(Data.length());
	DataToSend.append(LenVec.begin(),LenVec.end());

	DataToSend.append(Data);

	this->m_ClientSocket->SendTo(this->m_ServerAddress,DataToSend.c_str(),DataToSend.length());

	if (this->m_ClientSocket->LastCount() != DataToSend.length())
	{
		return false;
	}

	if (this->m_ClientSocket->Error())
	{
		return false;
	}
	return true;
}
// Send packet Functions
bool NetworkStackClient::SendAck(uint32_t Data1, uint32_t Data2)
{
	std::string Message;
	wxIPV4address ClientAddress;

	std::vector<unsigned char> ID =	ushort2uchar(PKT_ACK);
	std::vector<unsigned char> Data1vec = ulong2uchar(Data1);
	std::vector<unsigned char> Data2vec = ulong2uchar(Data2); 

	Message.append(ID.begin(),ID.end());
	Message.append(Data1vec.begin(),Data1vec.end());
	Message.append(Data2vec.begin(),Data2vec.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendError(uint32_t Data1, uint32_t Data2)
{
	std::string Message;

	wxIPV4address ClientAddress;

	std::vector<unsigned char> ID =	ushort2uchar(PKT_ERROR);
	std::vector<unsigned char> Data1vec = ulong2uchar(Data1);
	std::vector<unsigned char> Data2vec = ulong2uchar(Data2); 

	Message.append(ID.begin(),ID.end());
	Message.append(Data1vec.begin(),Data1vec.end());
	Message.append(Data2vec.begin(),Data2vec.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendConnectionRequest(unsigned char ROLE)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_CONNECTION_REQ);
	std::vector<unsigned char> CSMA = ushort2uchar(COMMANDSETMAJOR);
	std::vector<unsigned char> CSMI = ushort2uchar(COMMANDSETMINOR);
	
	Message.append(ID.begin(),ID.end());
	Message.push_back(ROLE);
	Message.append(CSMA.begin(),CSMA.end());
	Message.append(CSMI.begin(),CSMI.end());


	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendDisconnectionRequest()
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_DISCONNECTION_REQ);
	
	Message.append(ID.begin(),ID.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendAddObjectRequest(double InitialEnergy)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_REQ_ADD_OBJ);
	std::vector<unsigned char> Evec = double2uchar(InitialEnergy);

	Message.append(ID.begin(), ID.end());
	Message.append(Evec.begin(), Evec.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendAddObjectRequest(double InitialEnergy, CartesianVector Position)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_REQ_ADD_OBJ);
	std::vector<unsigned char> Evec = double2uchar(InitialEnergy);
	std::vector<unsigned char> Xvec = double2uchar(Position.x);
	std::vector<unsigned char> Yvec = double2uchar(Position.y);
	std::vector<unsigned char> Zvec = double2uchar(Position.z);

	Message.append(ID.begin(), ID.end());
	Message.append(Evec.begin(), Evec.end());
	Message.append(Xvec.begin(), Xvec.end());
	Message.append(Yvec.begin(), Yvec.end());
	Message.append(Zvec.begin(), Zvec.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendDeleteObject(uint32_t ObjectID)
{
	std::string Message;
	std::vector<unsigned char> ID = ushort2uchar(PKT_DELETE_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);
	
	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(), OID.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendObjectForces(uint32_t ForceObjId, CartesianVector Force)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_FORCES_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ForceObjId);
	std::vector<unsigned char> X = double2uchar(Force.x);
	std::vector<unsigned char> Y = double2uchar(Force.y);
	std::vector<unsigned char> Z = double2uchar(Force.z);

	Message.append(ID.begin(), ID.end());
	Message.append(OID.begin(), OID.end());
	Message.append(X.begin(), X.end());
	Message.append(Y.begin(), Y.end());
	Message.append(Z.begin(), Z.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendObjectTorque(uint32_t ForceObjId, double ThetaTorque, double PhiTorque)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_TORQUE_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ForceObjId);
	std::vector<unsigned char> T = double2uchar(ThetaTorque);
	std::vector<unsigned char> P = double2uchar(PhiTorque);
	
	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());
	Message.append(T.begin(),T.end());
	Message.append(P.begin(),P.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendObjectColour(uint32_t ObjectID, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_COLOUR_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(),OID.end());

	Message.push_back(Red);

	Message.push_back(Green);

	Message.push_back(Blue);

	Message.push_back(Brightness);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendAddInanimateObj(double X, double Y, double Z, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, float Energy, uint16_t Flags)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_ADDINANIMATE_OBJ);
	std::vector<unsigned char> Xvec = double2uchar(X);
	std::vector<unsigned char> Yvec = double2uchar(Y);
	std::vector<unsigned char> Zvec = double2uchar(Z);
	std::vector<unsigned char> E = float2uchar(Energy);
	std::vector<unsigned char> F = ushort2uchar(Flags);

	Message.append(ID.begin(),ID.end());

	Message.append(Xvec.begin(),Xvec.end());

	Message.append(Yvec.begin(),Yvec.end());

	Message.append(Zvec.begin(),Zvec.end());

	Message.push_back(Red);

	Message.push_back(Green);

	Message.push_back(Blue);

	Message.push_back(Brightness);

	Message.append(E.begin(),E.end());

	Message.append(F.begin(),F.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendEatObject(uint32_t ObjectID)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_EAT_OBJ);
	std::vector<unsigned char> OID = ulong2uchar(ObjectID);

	Message.append(ID.begin(),ID.end());
	Message.append(OID.begin(), OID.end());

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendKillSystem(std::string KillCode)
{
	if (KillCode.size() > 32) // truncate to 32 bytes
	{
		KillCode = KillCode.substr(0, 32);
	}

	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_KILL_SYSTEM);

	Message.append(ID.begin(),ID.end());
	Message.append(KillCode);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendTestsEchoReply(std::string Data)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_TEST_ECHO_REPLY);

	Message.append(ID.begin(), ID.end()); 

	Message.append(Data);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStackClient::SendTestsEcho(std::string Data)
{
	std::string Message;

	std::vector<unsigned char> ID = ushort2uchar(PKT_TEST_ECHO);

	Message.append(Data);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
// Display Error Functions
void NetworkStackClient::DisplayNetworkSocketError(wxDatagramSocket *socket)
{
	switch(socket->LastError())
	{
	case wxSOCKET_NOERROR:
		wxLogError("Socket Error: No Error Occurred");
		break;
	case wxSOCKET_INVOP:
		wxLogError("Socket Error: Invalid Operation");
		break;
	case wxSOCKET_IOERR:
		wxLogError("Socket Error: Input/Output Error");
		break;
	case wxSOCKET_INVADDR:
		wxLogError("Socket Error: Invalid Address Passed To Socket");
		break;
	case wxSOCKET_INVSOCK:
		wxLogError("Socket Error: Invalid Socket (Uninitialized)");
		break;
	case wxSOCKET_NOHOST:
		wxLogError("Socket Error: No Corresponding Host");
		break;
	case wxSOCKET_INVPORT:
		wxLogError("Socket Error: Invalid Port Specified");
		break;
	case wxSOCKET_WOULDBLOCK:
		wxLogError("Socket Error: The Socket Is Non-Blocking, requested operation would block socket");
		break;
	case wxSOCKET_TIMEDOUT:
		wxLogError("Socket Error: Socket Timeout");
		break;
	case wxSOCKET_MEMERR:
		wxLogError("Socket Error: Memory Exhausted");
		break;
	}
	return;
}