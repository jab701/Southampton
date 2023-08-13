#ifndef DBRECORD_OBJECT_H
#define DBRECORD_OBJECT_H

#include <wx/wx.h>
#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"
#include <numeric>
#include <stdint.h>

class DBRecord_Object
{
public: 
	DBRecord_Object();
	DBRecord_Object(uint32_t ID, uint32_t Client_ID, CartesianVector Position, double Theta, double Phi, CartesianVector MotorForce, double ThetaTorque, double PhiTorque, CartesianVector ExternForce, CartesianVector Velocity, double ThetaVelocity, double PhiVelocity, double Energy, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, uint16_t FLAGS);
	~DBRecord_Object();

	uint32_t ID;
	uint32_t Client_ID;
	CartesianVector Position;
	double Theta;
	double Phi;
	CartesianVector MotorForce;
	double ThetaTorque;
	double PhiTorque;
	CartesianVector ExternForce;
	CartesianVector Velocity;
	double ThetaVelocity;
	double PhiVelocity;
	double Energy;
	unsigned char Red;
	unsigned char Green;
	unsigned char Blue;
	unsigned char Brightness;
	uint16_t FLAGS;

};

#endif