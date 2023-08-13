#include "DBRecord_Client.h"

DBRecord_Client::DBRecord_Client()
{
	this->ID = 0;
	this->Role = 0;
	this->Command_Ver_Major = 0;
	this->Command_Ver_Minor = 0;
	this->Status = 0;
}
DBRecord_Client::DBRecord_Client(uint32_t ID, wxIPV4address Addr, unsigned char Role, uint16_t Command_Ver_Major, uint16_t Command_Ver_Minor, uint16_t Status)
{
	this->ID = ID;
	this->Addr = Addr;
	this->Role = Role;
	this->Command_Ver_Major = Command_Ver_Major;
	this->Command_Ver_Minor = Command_Ver_Minor;
	this->Status = Status;
}
DBRecord_Client::~DBRecord_Client()
{
	this->ID = 0;
	this->Role = 0;
	this->Command_Ver_Major = 0;
	this->Command_Ver_Minor = 0;
	this->Status = 0;
}