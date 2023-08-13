#include "Neuron.h"

/***** Neuron Constructor *****/
Neuron::Neuron(unsigned long ID)
{
	this->m_ID = ID;
	this->m_Name = wxEmptyString;
	this->m_Colour = wxColour(0,0,0);
	this->m_Position = wxPoint(0,0);
	this->m_Active = false;
	this->m_Enabled = true;
}
/***** Set Functions *****/
void Neuron::SetName(wxString Name)
{
	this->m_Name = Name;
}
void Neuron::SetColour(wxColour Colour)
{
	this->m_Colour = Colour;
}
void Neuron::SetActive()
{
	this->m_Active = true;
}
void Neuron::SetInActive()
{
	this->m_Active = false;
}
void Neuron::SetPosition(wxPoint Position)
{
	this->m_Position = Position;
}
void Neuron::SetEnabled()
{
	this->m_Enabled = true;
}
void Neuron::SetDisabled()
{
	this->m_Enabled = false;
}
/***** Get Functions *****/
wxString Neuron::GetName()
{
	return(this->m_Name);
}
wxColour Neuron::GetColour()
{
	return(this->m_Colour);
}
wxPoint Neuron::GetPosition()
{
	return(this->m_Position);
}
/***** Test Functions *****/
bool Neuron::IsActive()
{
	return(this->m_Active);
}
bool Neuron::IsEnabled()
{
	return(this->m_Enabled);
}
/***** Neuron Destructor *****/
Neuron::~Neuron()
{
	this->m_ID = 0;
	this->m_Name = wxEmptyString;
	this->m_Colour = wxColour(0,0,0);
	this->m_Position = wxPoint(0,0);
	this->m_Active = false;
	this->m_Enabled = false;
}