#ifndef NEURONSTATEQUEUE_H
#define NEURONSTATEQUEUE_H

#include <wx/wx.h>
#include <queue>
#include <stdint.h>

struct NeuronState
{
	uint16_t ChipX;
	uint16_t ChipY;
	uint16_t CPU;
	uint16_t NeuronNumber;

	float MembraneVoltage;
};

typedef std::queue<NeuronState> NeuronStateQueue;


#endif