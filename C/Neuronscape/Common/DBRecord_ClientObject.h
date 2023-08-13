#ifndef DBRECORD_CLIENTOBJECT_H
#define DBRECORD_CLIENTOBJECT_H

#include <wx/wx.h>
#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"
#include <numeric>
#include <stdint.h>

class DBRecord_ClientObject
{
public: 
	DBRecord_ClientObject();
	DBRecord_ClientObject(uint32_t ID, CartesianVector Position, double Theta, double Phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags);
	~DBRecord_ClientObject();

	uint32_t ID;
	CartesianVector Position;
	double Theta;
	double Phi;
	unsigned char Red;
	unsigned char Green;
	unsigned char Blue;
	unsigned char Brightness;
	double Energy;
	uint16_t Flags;
};

#endif