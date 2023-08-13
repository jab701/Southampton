#ifndef _SERVERPACKETEVENT_H_
#define _SERVERPACKETEVENT_H_

#include <wx/wx.h>
#include <wx/socket.h>
#include <vector>
#include <cstdlib>
#include <stdint.h>
 
class ServerPacketEvent : public wxEvent
{
public:
    ServerPacketEvent(wxEventType eventType = 0, int winid = 0) : wxEvent(winid, eventType)
    {
		
    }
    ServerPacketEvent(wxEventType eventType, int winid, const wxIPV4address Address, const std::string Payload) : wxEvent(winid, eventType)
    {
		this->m_Address = Address;
		this->m_Payload = Payload;
    }
	wxIPV4address GetAddress() { return this->m_Address;}
	std::string GetPayload()   { return this->m_Payload;}

	void SetAddress(wxIPV4address Address) { this->m_Address = Address; }
	void SetPayload(std::string   Payload) { this->m_Payload = Payload;}

    // implement the base class pure virtual
    virtual wxEvent *Clone() const { return new ServerPacketEvent(*this); }

	DECLARE_DYNAMIC_CLASS( ServerPacketEvent )

private:
    wxIPV4address m_Address;
	std::string m_Payload;
};

typedef void (wxEvtHandler::*ServerPacketEventFunction)(ServerPacketEvent&);

BEGIN_DECLARE_EVENT_TYPES()
	DECLARE_EVENT_TYPE( nsSERVERPACKETPROCESSED, 1 )
END_DECLARE_EVENT_TYPES()

#define EVT_SERVERPACKETPROCESSED(id, func)  \
	DECLARE_EVENT_TABLE_ENTRY( nsSERVERPACKETPROCESSED, id, wxID_ANY, (wxObjectEventFunction) (ServerPacketEventFunction) & func, (wxObject *) NULL ),

#endif