#include "DBRecord_ClientObject.h"

DBRecord_ClientObject::DBRecord_ClientObject()
{
	this->ID = 0;
	this->Position = CartesianVector(0.0,0.0,0.0);
	this->Theta = 0.0;
	this->Phi = 0.0;
	this->Red = 255;
	this->Green = 255;
	this->Blue = 255;
	this->Brightness = 0;
	this->Energy = 0.0;
	this->Flags = 0;
}
DBRecord_ClientObject::DBRecord_ClientObject(uint32_t ID, CartesianVector Position, double Theta, double Phi, unsigned char Red, unsigned char Green, unsigned char Blue, unsigned char Brightness, double Energy, uint16_t Flags)
{
	this->ID = ID;
	this->Position = Position;
	this->Theta = Theta;
	this->Phi = Phi;
	this->Red = Red;
	this->Green = Green;
	this->Blue = Blue;
	this->Brightness = Brightness;
	this->Energy = Energy;
	this->Flags = Flags;
}
DBRecord_ClientObject::~DBRecord_ClientObject()
{
	this->ID = 0;
	this->Position = CartesianVector(0.0,0.0,0.0);
	this->Theta = 0.0;
	this->Phi = 0.0;
	this->Red = 0;
	this->Green = 0;
	this->Blue = 0;
	this->Brightness = 0;
	this->Energy = 0.0;
	this->Flags = 0;
}