#include "DBRecord_Object.h"

DBRecord_Object::DBRecord_Object()
{
	this->ID = 0;
	this->Client_ID = 0;
	this->Position = CartesianVector(0.0,0.0,0.0);
	this->Theta = 0.0;
	this->Phi = 0.0;
	this->MotorForce = CartesianVector(0.0,0.0,0.0);
	this->ThetaTorque = 0.0;
	this->PhiTorque = 0.0;
	this->ExternForce = CartesianVector(0.0,0.0,0.0);
	this->Velocity = CartesianVector(0.0,0.0,0.0);
	this->Energy = 0.0;
	this->ThetaVelocity = 0.0;
	this->PhiVelocity = 0.0;
	this->Red = 255;
	this->Green = 255;
	this->Blue = 255;
	this->Brightness = 255;
}
DBRecord_Object::DBRecord_Object(uint32_t ID, uint32_t Client_ID, CartesianVector Position, double Theta, double Phi, CartesianVector MotorForce, double ThetaTorque, double PhiTorque, CartesianVector ExternForce, CartesianVector Velocity, double ThetaVelocity, double PhiVelocity, double Energy, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, uint16_t FLAGS)
	{
	this->ID = ID;
	this->Client_ID = Client_ID;
	this->Position = Position;
	this->Theta = Theta;
	this->Phi = Phi;
	this->MotorForce = MotorForce;
	this->ThetaTorque = ThetaTorque;
	this->PhiTorque = PhiTorque;
	this->ExternForce = ExternForce;
	this->Velocity = Velocity;
	this->Energy = Energy;
	this->ThetaVelocity = ThetaVelocity;
	this->PhiVelocity = PhiVelocity;
	this->Red = Red;
	this->Green = Green;
	this->Blue = Blue;
	this->Brightness = Brightness;
	this->FLAGS = FLAGS;
}
DBRecord_Object::~DBRecord_Object()
{
	this->ID = 0;
	this->Client_ID = 0;
	this->Position = CartesianVector(0.0,0.0,0.0);
	this->Theta = 0.0;
	this->Phi = 0.0;
	this->MotorForce = CartesianVector(0.0,0.0,0.0);
	this->ThetaTorque = 0.0;
	this->PhiTorque = 0.0;
	this->ExternForce = CartesianVector(0.0,0.0,0.0);
	this->Velocity = CartesianVector(0.0,0.0,0.0);
	this->Energy = 0.0;
	this->ThetaVelocity = 0.0;
	this->PhiVelocity = 0.0;
	this->Red = 0;
	this->Green = 0;
	this->Blue = 0;
}