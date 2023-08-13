#ifndef _NEURON_H
#define _NEURON_H

#include <wx/wx.h>
#include <wx/listimpl.cpp>

class Neuron
{
public:
	/***** Neuron Constructor *****/
	Neuron(unsigned long ID);
	/***** Set Functions *****/
	void SetName(wxString Name);
	void SetColour(wxColour Colour);
	void SetActive();
	void SetInActive();
	void SetPosition(wxPoint Position);
	void SetEnabled();
	void SetDisabled();

	/***** Get Functions *****/
	wxString GetName();
	wxColour GetColour();
	wxPoint GetPosition();

	/***** Test Functions *****/
	bool IsActive();
	bool IsEnabled();
	/***** Neuron Destructor *****/
	~Neuron();
	


private:
    unsigned long m_ID;
	wxString m_Name;
	wxColour m_Colour;
	wxPoint m_Position;

	bool m_Active;
	bool m_Enabled;
};

WX_DECLARE_LIST(Neuron, NeuronList);


#endif