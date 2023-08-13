#ifndef _CLIENTPACKETEVENT_H_
#define _CLIENTPACKETEVENT_H_

#include <wx/wx.h>
#include <wx/socket.h>
#include <vector>
#include <cstdlib>
#include <stdint.h>

#include  "../Common/CartesianVector.h"
 
class ClientPacketEvent : public wxEvent
{
public:
    ClientPacketEvent(wxEventType eventType = 0, int winid = 0) : wxEvent(winid, eventType)
    {
		this->m_ID = 0;
		this->m_Data = 0;
    }
    ClientPacketEvent(wxEventType eventType, int winid, const uint32_t ID, const uint32_t Data) : wxEvent(winid, eventType)
    {
		this->m_ID = ID;
		this->m_Data = Data;
    }
	uint32_t GetID() { return this->m_ID;}
	uint32_t GetData()   { return this->m_Data;}
	CartesianVector GetCartesianVector() {return this->m_CartesianVector;}
	std::string GetString() {return this->m_String;}

	void SetID(uint32_t ID) { this->m_ID = ID; }
	void SetData(uint32_t Data) { this->m_Data = Data;}
	void SetCartesianVector(CartesianVector Vector) { this->m_CartesianVector = Vector;}
	void SetString( std::string String) { this->m_String = String;}

    // implement the base class pure virtual
    virtual wxEvent *Clone() const { return new ClientPacketEvent(*this); }

	DECLARE_DYNAMIC_CLASS( ClientPacketEvent );

private:
    uint32_t m_ID;
	uint32_t m_Data;
	CartesianVector m_CartesianVector;
	std::string m_String;
};

typedef void (wxEvtHandler::*ClientPacketEventFunction)(ClientPacketEvent&);

BEGIN_DECLARE_EVENT_TYPES()
	DECLARE_EVENT_TYPE( nsCLIENTPACKETPROCESSED, 1 )
END_DECLARE_EVENT_TYPES()

#define EVT_CLIENTPACKETPROCESSED(id, func)  \
	DECLARE_EVENT_TABLE_ENTRY( nsCLIENTPACKETPROCESSED, id, wxID_ANY, (wxObjectEventFunction) (ClientPacketEventFunction) & func, (wxObject *) NULL ),

#endif