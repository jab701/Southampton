#ifndef NEURONSPIKEQUEUE_H
#define NEURONSPIKEQUEUE_H

#include <wx/wx.h>
#include <queue>
#include <stdint.h>

struct NeuronSpike
{
	unsigned char ChipX;
	unsigned char ChipY;
	uint16_t CPU;
	uint32_t NeuronNumber;
};

typedef std::queue<NeuronSpike> NeuronSpikeQueue;


#endif