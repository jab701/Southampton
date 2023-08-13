#ifndef SPINNAKERNETSTACK_H
#define SPINNAKERNETSTACK_H

#include <wx/wx.h>
#include <wx/socket.h>
#include <stdint.h>
#include "../Common/Definitions.h"
#include "../Common/Utilities.h"

#include "SpinnakerTypes.h"


#include "SDP_defs.h"
#include "SCP.h"

#include "NeuronSpikeQueue.h"
#include "NeuronStateQueue.h"

#define SPINNCOMMANDSETMAJOR 0
#define SPINNCOMMANDSETMINOR 0

class SNS_STAT
{
public:
	uint32_t Status;
	NeuronSpike Spike;
};

class SpinnakerNetStack
{
public:
	SpinnakerNetStack();
	~SpinnakerNetStack();
	// Control Functions
	bool StartNetworkSocket(wxIPV4address RemoteAddress, wxFrame *EventHandler, int SOCKET_EVENT_ID);
	bool StopNetworkSocket();
	// Setup Functions
	bool SetVisualTarget(unsigned ChipX, unsigned ChipY, unsigned CPU, unsigned Port, unsigned Command);
	bool SetRewardTarget(unsigned ChipX, unsigned ChipY, unsigned CPU, unsigned Port, unsigned Command);
	bool SetNeuronSpike(unsigned Command);
	void SetSpikeQueue(NeuronSpikeQueue *Queue, wxMutex *NeuronSpikeQueueMutex);
	// Fetch Functions
	// Checking Functions
	bool IsOK();
	bool Test(uint32_t Tag);
	// Packet Processing Flow
    SNS_STAT ProcessNetworkPacket(wxDatagramSocket *Socket);
	// Send packet Functions
	bool SendVisualData(unsigned char *Red, unsigned char *Green, unsigned char*Blue, unsigned Length, unsigned rows, bool Grey);
	bool SendReward();
	// Receive Packet Functions
	bool RecvNeuronSpike(sdp_hdr_t Header, sdp_cmd_t Command, SNS_STAT &ReturnStatus);
	bool RecvNeuronState(sdp_hdr_t Header, sdp_cmd_t Command);
private:
	wxDatagramSocket *m_Socket;
	wxMutex *m_SocketMutex;

	NeuronSpikeQueue *m_NeuronSpikeQueue;
	wxMutex *m_NeuronSpikeQueueMutex;

	NeuronStateQueue *m_NeuronStateQueue;
	wxMutex *m_NeuronStateQueueMutex;

	wxIPV4address m_SpinnakerAddress;

	// Visual Data Setup
	unsigned m_Visual_ChipX;
	unsigned m_Visual_ChipY;
	unsigned m_Visual_CPU;
	unsigned m_Visual_Port;
	unsigned m_Visual_Command;

	// Neuron Spike Setup
	unsigned m_Spike_Command;

	// Neuron State Setup
	unsigned m_State_Command;

    // Reward Data Setup
	unsigned m_Reward_ChipX;
	unsigned m_Reward_ChipY;
	unsigned m_Reward_CPU;
	unsigned m_Reward_Port;
	unsigned m_Reward_Command;

	// Subscribe To Neuron Spike Setup
	unsigned m_NeuronSpikeSubscribe_ChipX;
	unsigned m_NeuronSpikeSubscribe_ChipY;
	unsigned m_NeuronSpikeSubscribe_CPU;
	unsigned m_NeuronSpikeSubscribe_Port;
	unsigned m_NeuronSpikeSubscribe_Command;

	// Subscribe to Neuron State Setup
	unsigned m_NeuronStateSubscribe_ChipX;
	unsigned m_NeuronStateSubscribe_ChipY;
	unsigned m_NeuronStateSubscribe_CPU;
	unsigned m_NeuronStateSubscribe_Port;
	unsigned m_NeuronStateSubscribe_Command;

	
};

#endif