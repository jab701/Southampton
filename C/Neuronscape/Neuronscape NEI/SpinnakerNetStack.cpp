#include "SpinnakerNetStack.h"

SpinnakerNetStack::SpinnakerNetStack()
{
	this->m_SocketMutex = new wxMutex();
	this->m_Socket = NULL;
	this->m_SpinnakerAddress.Clear();

    this->m_Visual_ChipX = 0;
	this->m_Visual_ChipY = 0;
	this->m_Visual_CPU = 0;
	this->m_Visual_Port = 0;
	this->m_Visual_Command = 0;

    this->m_Reward_ChipX = 0;
	this->m_Reward_ChipY = 0;
	this->m_Reward_CPU = 0;
	this->m_Reward_Port = 0;
	this->m_Reward_Command = 0;
}
SpinnakerNetStack::~SpinnakerNetStack()
{
	this->StopNetworkSocket();
	delete this->m_SocketMutex;
	this->m_SocketMutex = NULL;
	this->m_Socket = NULL;

    this->m_Visual_ChipX = 0;
	this->m_Visual_ChipY = 0;
	this->m_Visual_CPU = 0;
	this->m_Visual_Port = 0;
	this->m_Visual_Command = 0;
}
// Control Functions
bool SpinnakerNetStack::StartNetworkSocket(wxIPV4address RemoteAddress, wxFrame *EventHandler, int SOCKET_EVENT_ID)
{
	wxMutexLocker lock(*this->m_SocketMutex);

	wxIPV4address LocalAddress;
	LocalAddress.AnyAddress();
	LocalAddress.Service(0);

	this->m_SpinnakerAddress = RemoteAddress;

	this->m_Socket = new wxDatagramSocket(LocalAddress,wxSOCKET_NONE);

	if (this->m_Socket == NULL)
	{
		return(false);
	}

	if (!this->m_Socket->IsOk())
	{
		this->m_Socket->Destroy();
		return(false);
	}

	this->m_Socket->SetEventHandler(*EventHandler,SOCKET_EVENT_ID);

	this->m_Socket->SetNotify(wxSOCKET_INPUT_FLAG);

	this->m_Socket->Notify(true);
	wxString Msg;
	//bool GetLocal(wxSockAddress& addr) const
	//Msg.Printf("Spinnaker network port is: %d", m_Socket->GetLocal());
	//wxLogMessage(Msg);
	return true;
}
bool SpinnakerNetStack::StopNetworkSocket()
{
	if (this->m_Socket == NULL)
	{
		return false;
	}

	this->m_Socket->Notify(false);
	this->m_Socket->Discard();

	this->m_Socket->Destroy();
	this->m_Socket = NULL;

	this->m_SpinnakerAddress.Clear();
	return true;
}
// Setup Functions
bool SpinnakerNetStack::SetVisualTarget(unsigned ChipX, unsigned ChipY, unsigned CPU, unsigned Port, unsigned Command)
{
	if (CPU > 31)
	{
		return false;
	}
	
	if ((Port > 7)||(Port < 1))
	{
		return false;
	}

	this->m_Visual_ChipX = ChipX;
	this->m_Visual_ChipY = ChipY;
	this->m_Visual_CPU = CPU;
	this->m_Visual_Port = Port;
	this->m_Visual_Command = Command;

	return true;
}
bool SpinnakerNetStack::SetRewardTarget(unsigned ChipX, unsigned ChipY, unsigned CPU, unsigned Port, unsigned Command)
{
	if (CPU > 31)
	{
		return false;
	}
	
	if ((Port > 7)||(Port < 1))
	{
		return false;
	}

	this->m_Reward_ChipX = ChipX;
	this->m_Reward_ChipY = ChipY;
	this->m_Reward_CPU = CPU;
	this->m_Reward_Port = Port;
	this->m_Reward_Command = Command;

	return true;
}
// Fetch Functions
// Checking Functions
bool SpinnakerNetStack::IsOK()
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
bool SpinnakerNetStack::Test(uint32_t Tag)
{
	// This function sends an sver command to spinnaker 0,0,0 and waits for a response.
	// If a timeout occurs then the remote host does not exist

	SCP CMD(this->m_Socket);
	CMD.SetChip(0,0,0);

	sver_t Version; 

	uint16_t RC = CMD.sver(this->m_SpinnakerAddress, Version);

	if (RC == RC_OK)
	{

		wxIPV4address Local;
		
		this->m_Socket->GetLocal(Local);
		Local.Hostname(wxGetFullHostName());
		
		wxString LocalIP = Local.IPAddress();
		
		std::vector<unsigned char> Bytes;

		IPStringToBytes(LocalIP, Bytes);
		


		uint16_t Service = Local.Service();
		CMD.iptag_set(this->m_SpinnakerAddress, Bytes, Service,  Tag);
		return true;
	}
	else
	{
		return false;
	}
}
// Packet Processing Flow
SNS_STAT SpinnakerNetStack::ProcessNetworkPacket(wxDatagramSocket *Socket)
{
	SNS_STAT ReturnStatus;
	ReturnStatus.Status = SPIN_NS_OK;
	wxString Msg;

	unsigned char Bytes[MAX_TOTAL_SDP_LENGTH];

	Socket->Read(Bytes, MAX_TOTAL_SDP_LENGTH);

	unsigned Count = Socket->LastCount();

	Msg.Printf("packet received, length is %d)", Count); 
	wxLogMessage(Msg);

	if (Count < (8 + 4))
	{
		return ReturnStatus;
	}

	std::vector<unsigned char> HeaderBytes(Bytes+2, Bytes + 10);

	std::vector<unsigned char> CommandBytes(Bytes + 10, Bytes + Count);

	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.pack(HeaderBytes);	
	Command.pack(CommandBytes);

	uint16_t ReturnCode = SPIN_NS_OK;

	

	// We cannot use a switch-case statement here because the values of command codes are
	// not set at compile time but by the user at run time. Instead we use if-else if-else statements
	
	Msg.Printf("packet received, shortly to send a spike (dependent on the cmd_rc=%d (spike command is %d))", Command.cmd_rc, this->m_Spike_Command); 
	wxLogMessage(Msg);
	if (Command.cmd_rc == this->m_Spike_Command) // A spike Packet has arrived
	{
		if (this->RecvNeuronSpike(Header,Command, ReturnStatus))
		{
			ReturnStatus.Status = SPIN_NS_SPIKE;
		}
	}
	else if (Command.cmd_rc == this->m_State_Command)
	{
		if (this->RecvNeuronState(Header,Command))
		{
			ReturnCode = SPIN_NS_STATE;
		}
	}
	else // If we get here it is an unknown command
	{

	}
	return ReturnStatus;
}
// Send packet Functions
bool SpinnakerNetStack::SendVisualData(unsigned char *Red, unsigned char *Green, unsigned char *Blue, unsigned Length, unsigned rows, bool Greyscale)
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = 0x07;
	Header.tag = 255;

	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.set_dest_chip(this->m_Visual_ChipX,this->m_Visual_ChipY);

	Header.set_dest_cpu(this->m_Visual_CPU);
	Header.set_dest_port(this->m_Visual_Port);
	Header.srce_addr = 0;

	Command.cmd_rc = this->m_Visual_Command;
	Command.seq = 0;
	// send out enough information to work out the shape of the image
	Command.arg1 = Length;	// number of pixels (regardless of color/greyscale)
	Command.arg3 = rows;    // number of rows the data is in (so Len/rows=#cols)

	if (Greyscale)
	{
		Command.arg2 = RETINA_GRAYSCALE;
	}
	else
	{
		Command.arg2 = RETINA_RGB;
	}

	Command.data.clear();

	for (unsigned i = 0; i < Length; i++)
	{
		if (Greyscale)
		{
			Command.data.push_back(Green[i]);
		}
		else
		{
			Command.data.push_back(Red[i]);
			Command.data.push_back(Green[i]);
			Command.data.push_back(Blue[i]);
		}
	}

	SCP CMD(this->m_Socket);

	wxMutexLocker lock(*this->m_SocketMutex);
	CMD.send(*this->m_Socket, this->m_SpinnakerAddress, Header, Command);

	return true;
}
bool SpinnakerNetStack::SendReward()
{
	sdp_hdr_t Header;
	sdp_cmd_t Command;

	Header.flags = 0x07;
	Header.tag = 255;

	Header.set_srce_cpu(31);
	Header.set_srce_port(7);
	Header.set_dest_chip(this->m_Reward_ChipX,this->m_Reward_ChipY);

	Header.set_dest_cpu(this->m_Reward_CPU);
	Header.set_dest_port(this->m_Reward_Port);
	Header.srce_addr = 0;

	Command.cmd_rc = this->m_Reward_Command;
	Command.seq = 0;
	// send out enough information to work out the shape of the image
	Command.arg1 = 0;	// number of pixels (regardless of color/greyscale)
	Command.arg2 = 0;
	Command.arg3 = 0;    // number of rows the data is in (so Len/rows=#cols)
	Command.data.clear();

	SCP CMD(this->m_Socket);

	wxMutexLocker lock(*this->m_SocketMutex);
	CMD.send(*this->m_Socket, this->m_SpinnakerAddress, Header, Command);

	return true;
}
bool SpinnakerNetStack::SetNeuronSpike(unsigned Command)
{
	this->m_Spike_Command = Command;
	return true;
}
void SpinnakerNetStack::SetSpikeQueue(NeuronSpikeQueue *Queue, wxMutex *NeuronSpikeQueueMutex)
{
	this->m_NeuronSpikeQueue = Queue;
	this->m_NeuronSpikeQueueMutex = NeuronSpikeQueueMutex;
}
// Receive Packet Functions
bool SpinnakerNetStack::RecvNeuronSpike(sdp_hdr_t Header, sdp_cmd_t Command, SNS_STAT &ReturnStatus)
{
	if (this->m_NeuronSpikeQueue == NULL)
	{
		return false;
	}

	//NeuronSpike NewSpike;

	uint16_t Srce_Addr = Header.srce_addr;

	ReturnStatus.Spike.ChipX = (Srce_Addr >> 8);
	ReturnStatus.Spike.ChipY = Srce_Addr;
	ReturnStatus.Spike.CPU = Header.get_srce_cpu();
	ReturnStatus.Spike.NeuronNumber = Command.arg1;

	wxString Msg;
	Msg.Printf("Neuron %d Fired", ReturnStatus.Spike.NeuronNumber);
	wxLogMessage(Msg);

	//wxMutexLocker lock(*this->m_NeuronSpikeQueueMutex);
	//this->m_NeuronSpikeQueue->push(NewSpike);

	return true;
}
bool SpinnakerNetStack::RecvNeuronState(sdp_hdr_t Header, sdp_cmd_t Command)
{
	if (this->m_NeuronStateQueue == NULL)
	{
		return false;
	}

	uint16_t Srce_Addr = Header.srce_addr;

	NeuronState NewState;

	NewState.ChipX  = (Srce_Addr >> 8);
	NewState.ChipY = Srce_Addr;
	NewState.CPU = Header.get_srce_cpu();
	NewState.NeuronNumber = Command.arg1;
	
	uint32_t FracBits = Command.arg2;

	FixedToFloatingPoint(Command.arg3, (unsigned char) Command.arg2, NewState.MembraneVoltage);

	return true;

}