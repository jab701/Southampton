#include "NetworkStack.h"

// Default Constructor
NetworkStack::NetworkStack()
{
	this->m_LocalAddress.Clear();
	this->m_RemoteAddress.Clear();
	this->m_RemoteAddress.Hostname(_T("0.0.0.0"));

	this->m_Role = ROLE_UNDEF;

	this->m_Socket = NULL;
	
	for (unsigned short i = 0; i < 88; i++)
	{
		this->m_NeuronActivity[i] = false;
	}

	this->m_NeuronControl.Clear();

	this->m_TestsEchoReplyStr.Clear();
}

// Destructor
NetworkStack::~NetworkStack()
{
	this->StopSocket();

	this->m_LocalAddress.Clear();

	this->m_Role = ROLE_UNDEF;
	
	for (unsigned short i = 0; i < 88; i++)
	{
		this->m_NeuronActivity[i] = false;
	}
	this->m_NeuronControl.Clear();
	this->m_TestsEchoReplyStr.Clear();
}

// Control Functions
bool NetworkStack::StartClientSocket(wxFrame *MainFrame, EVENTS SOCKET_EVENT_ID)
{
	if (SOCKET_EVENT_ID == wxID_ANY)
	{
		return false;
	}

	if (MainFrame == NULL)
	{
		return false;
	}

	if (this->m_Socket != NULL)
	{
		return false;
	}

	this->m_LocalAddress.AnyAddress();
	this->m_LocalAddress.Service(0);

    this->m_Socket = new wxDatagramSocket(this->m_LocalAddress,wxSOCKET_NONE);

	if (this->m_Socket == NULL)
	{
		return(false);
	}

	if (!this->m_Socket->IsOk())
	{
		this->m_Socket->Destroy();
		this->m_Socket = NULL;
		return(false);
	}

	this->m_Socket->SetEventHandler(*MainFrame,SOCKET_EVENT_ID);

	this->m_Socket->SetNotify(wxSOCKET_INPUT_FLAG);

	this->m_Socket->Notify(true);
	this->m_Role = ROLE_VIEWER;
	return true;
}
bool NetworkStack::StartServerSocket(wxFrame *MainFrame, EVENTS SOCKET_EVENT_ID, unsigned short Port)
{
	if (SOCKET_EVENT_ID == wxID_ANY)
	{
		return false;
	}

	if (MainFrame == NULL)
	{
		return false;
	}

	if (this->m_Socket != NULL)
	{
		return false;
	}

	this->m_LocalAddress.AnyAddress();
	this->m_LocalAddress.Service(Port);

    this->m_Socket = new wxDatagramSocket(this->m_LocalAddress,wxSOCKET_NONE);

	if (this->m_Socket == NULL)
	{
		return(false);
	}

	if (!this->m_Socket->IsOk())
	{
		this->m_Socket->Destroy();
		this->m_Socket = NULL;
		return(false);
	}

	this->m_Socket->SetEventHandler(*MainFrame,SOCKET_EVENT_ID);

	this->m_Socket->SetNotify(wxSOCKET_INPUT_FLAG);

	this->m_Socket->Notify(true);

	this->m_Role = ROLE_SERVER;
	return true;
}
bool NetworkStack::StopSocket()
{
	if (this->m_Socket != NULL)
	{
		if (this->m_RemoteAddress.Hostname() != _T("0.0.0.0"))
		{
			this->SendForceDisconnect();
			this->m_RemoteAddress.Clear();
			this->m_RemoteAddress.Hostname(_T("0.0.0.0"));
		}
		this->m_Socket->Notify(false);
		this->m_Socket->Discard();
		this->m_Socket->Destroy();
		this->m_Socket = NULL;
	}
	return true;
}
// Get Functions
bool NetworkStack::GetConnectionStatus()
{
	if (this->m_RemoteAddress.IPAddress() == _T("0.0.0.0"))
	{
		return false;
	}
	else
	{
		return true;
	}
}
bool *NetworkStack::GetNeuronActivity()
{
	bool *NeuronActivity = new bool[88];

	for (unsigned i = 0; i < 88; i++)
	{
		NeuronActivity[i] = this->m_NeuronActivity[i];
	}
	return NeuronActivity;
}
wxString NetworkStack::GetNeuronControl() const
{
	return this->m_NeuronControl;
}
bool NetworkStack::GetReset()
{
	return this->m_Reset;
}
wxString NetworkStack::GetTestsEchoReply()
{
	return this->m_TestsEchoReplyStr;
}
// Checking Functions
bool NetworkStack::IsOK()
{
	if (this->m_Socket == NULL)
	{
		return false;
	}

	if (!this->m_Socket->IsOk())
	{
		return false;
	}
	return true;
}
// Packet Processing Flow
unsigned short NetworkStack::ProcessNetworkPacket(wxDatagramSocket *Socket)
{
	wxIPV4address RemoteAddress;
	unsigned char RawData[1024];
	unsigned short DataLength = 0;
	wxString PacketData;
	unsigned short ReturnValue = NS_NOP;

	// Read the Data From the Socket, Getting the ClientAddress data, PacketData
	Socket->RecvFrom(RemoteAddress,RawData,1024); // Try to read 1024 bytes from the socket into the buffer

	// Right now extract the length fo the data in the packet from the first two bytes of the packet
	DataLength = uchar2ushort(RawData[0],RawData[1]);

	if (DataLength == 0)
	{
		return NS_NOP;
	}

	if (DataLength > 1024)
	{
		return NS_NOP;
	}

	if (DataLength < 2)
	{
		return NS_NOP;
	}

	// Now read the data into a wxString Object
	// The is easier to manipulate than an array of chars!
	// We start two bytes in since we dont want to read the packet length again
	for (unsigned short i=2; i < DataLength+2; i++)
	{
		// Byte by Byte we copy the data into the wxString PacketDataStr object
		// This is the safest way to do it, some of the "quciker" functions are a bit tempremental
		PacketData.Append(RawData[i]);
	}

	// Extract the first two bytes as the PACKET_ID bytes, save to PACKET_ID
	unsigned short PACKET_ID = uchar2ushort(PacketData.GetChar(0),PacketData.GetChar(1));
	// Remove the first two bytes and discard (these were the PACKET_ID Bytes we extracted already)
	PacketData = PacketData.Mid(2,wxSTRING_MAXLEN); 

	// Are we connected?
	if (!this->GetConnectionStatus())
	{
		// We are Not Connected
		switch(PACKET_ID)
		{
		case PKT_CONNECTION_ACK:
			if (this->m_Role == ROLE_VIEWER)
			{
				this->m_RemoteAddress = RemoteAddress;
				ReturnValue = NS_CONNECTED;
			}
			break;

		case PKT_CONNECTION_REQ:
			if (this->m_Role == ROLE_SERVER)
			{
				this->m_RemoteAddress = RemoteAddress;
				this->SendConnectionAck();
				ReturnValue = NS_CONNECTED;
			}
			break;

		default:
			// unknown packet, send error to server
			// Do nothing, Ignore the Packet
			break;
		}
	}
	else
	{
		// We are Connected
		// Did the packet come from the connected server?
		if ((RemoteAddress.IPAddress() != this->m_RemoteAddress.IPAddress())||(RemoteAddress.Service() != this->m_RemoteAddress.Service()))
		{
			// No? Just ignore and return.
		}
		else
		{
			switch(PACKET_ID)
			{
			case PKT_FORCEDISCONNECT:
				this->m_RemoteAddress.Hostname(_T("0.0.0.0"));
				ReturnValue = NS_DISCONNECT_FORCED;
				break;

			case PKT_NEURON_CTRL:
				if (this->m_Role == ROLE_SERVER)
				{
					if (this->RecvNeuronControlData(PacketData))
					{
						ReturnValue = NS_NCD_DATA_DIRTY;
					}
				}
				break;

			case PKT_NEURON_DATA:
				if (this->m_Role == ROLE_VIEWER)
				{
					if (this->RecvNeuronActivityData(PacketData))
					{
						ReturnValue = NS_NAD_DATA_DIRTY;
					}
				}
				break;
			case PKT_SET_RESET:
				this->m_Reset = true;
				ReturnValue = NS_RESET_DATA_DIRTY;
				break;

			case PKT_UNSET_RESET:
				this->m_Reset = false;
				ReturnValue = NS_RESET_DATA_DIRTY;
				break;

			case PKT_TEST_ECHO_REPLY:
				this->RecvTestsEchoReply(PacketData);
				ReturnValue = NS_TEST_ECHO_REPLY;
				break;

			case PKT_TEST_ECHO:
				this->RecvTestsEcho(PacketData);
				break;

			default:
				// unknown packet, send error to server
				break;
			}
		}
	}
	return ReturnValue;
}
// Function to send a data string 
bool NetworkStack::SendString(wxString Data)
{
	wxString DataToSend;

	if (Data.Len() > 1022) // Packet limit is 1024 bytes including the packet length bytes (x2)
	{
		// Packet is too long!
		return false;
	}

	if (this->IsOK() == false)
	{
		return false;
	}

	DataToSend.Append(ushort2uchar(Data.Len())[0]);
	DataToSend.Append(ushort2uchar(Data.Len())[1]);
	DataToSend.Append(Data);

	this->m_Socket->SendTo(this->m_RemoteAddress,DataToSend.c_str(),DataToSend.Len());

	if (this->m_Socket->LastCount() != DataToSend.Len())
	{
		return false;
	}

	if (this->m_Socket->Error())
	{
		return false;
	}
	return true;
}
// Send packet Functions
bool NetworkStack::SendConnectionAck()
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_CONNECTION_ACK)[0]);
	Message.Append(ushort2uchar(PKT_CONNECTION_ACK)[1]);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendConnectionRequest(wxIPV4address RemoteHost)
{
	if (this->m_Role != ROLE_VIEWER)
	{
		return false;
	}

	wxString Data;

	Data.Append(ushort2uchar(PKT_CONNECTION_REQ)[0]);
	Data.Append(ushort2uchar(PKT_CONNECTION_REQ)[1]);

	wxString DataToSend;

	if (Data.Len() > 1022) // Packet limit is 1024 bytes including the packet length bytes (x2)
	{
		// Packet is too long!
		return false;
	}

	if (this->IsOK() == false)
	{
		return false;
	}

	DataToSend.Append(ushort2uchar(Data.Len())[0]);
	DataToSend.Append(ushort2uchar(Data.Len())[1]);
	DataToSend.Append(Data);

	this->m_Socket->SendTo(RemoteHost,DataToSend.c_str(),DataToSend.Len());

	if (this->m_Socket->LastCount() != DataToSend.Len())
	{
		return false;
	}

	if (this->m_Socket->Error())
	{
		return false;
	}
	return true;
}
bool NetworkStack::SendForceDisconnect()
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_FORCEDISCONNECT)[0]);
	Message.Append(ushort2uchar(PKT_FORCEDISCONNECT)[1]);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendNeuronActivityData(wxString NeuronActivityData)
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_NEURON_DATA)[0]);
	Message.Append(ushort2uchar(PKT_NEURON_DATA)[1]);

	Message.Append(NeuronActivityData);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendNeuronControlData(wxString NeuronControlData)
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_NEURON_CTRL)[0]);
	Message.Append(ushort2uchar(PKT_NEURON_CTRL)[1]);

	Message.Append(NeuronControlData);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendAssertReset()
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_SET_RESET)[0]);
	Message.Append(ushort2uchar(PKT_SET_RESET)[1]);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendReleaseReset()
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_UNSET_RESET)[0]);
	Message.Append(ushort2uchar(PKT_UNSET_RESET)[1]);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendTestsEchoReply(wxString Data)
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_TEST_ECHO_REPLY)[0]);
	Message.Append(ushort2uchar(PKT_TEST_ECHO_REPLY)[1]);

	Message.Append(Data);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
bool NetworkStack::SendTestsEcho(wxString Data)
{
	wxString Message;

	Message.Append(ushort2uchar(PKT_TEST_ECHO)[0]);
	Message.Append(ushort2uchar(PKT_TEST_ECHO)[1]);

	Message.Append(Data);

	if (!this->SendString(Message))
	{
		return false;
	}

	return true;
}
// Receive Packet Functions
bool NetworkStack::RecvNeuronActivityData(wxString Data)
{
	bool NeuronActivityData[88];
	bool ReturnValue = false;

	if (Data.Len() != 11)
	{
		return false;
	}

	for (unsigned short i = 0; i < 11; i++)
	{
		unsigned char bit = 1;
		unsigned char byte = Data.GetChar(i);
		for (unsigned short j = 0; i < 8; j++)
		{
			unsigned short BitIndex = (i*8)+j;
			if (bit & byte)
			{
				NeuronActivityData[BitIndex] = true;
			}
			else
			{
				NeuronActivityData[BitIndex] = false;
			}
		}
	}

	for (unsigned short i = 0; i < 88; i++)
	{
		if (NeuronActivityData[i] != this->m_NeuronActivity[i])
		{
			this->m_NeuronActivity[i] = !this->m_NeuronActivity[i];
			ReturnValue = true;
		}
	}
	return ReturnValue;
}
bool NetworkStack::RecvNeuronControlData(wxString Data)
{
	bool ReturnValue = false;

	if (Data.Len() != 11)
	{
		return false;
	}

	if (this->m_NeuronControl != Data)
	{
		ReturnValue = true;
		this->m_NeuronControl = Data;
	}
	return ReturnValue;
}
void NetworkStack::RecvTestsEchoReply(wxString Data)
{
	this->m_TestsEchoReplyStr.Clear();
	this->m_TestsEchoReplyStr.Append(Data);
	return;
}
void NetworkStack::RecvTestsEcho(wxString Data)
{
	this->SendTestsEchoReply(Data);
	return;
}
