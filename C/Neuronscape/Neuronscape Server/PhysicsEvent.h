#ifndef _PHYSICSEVENT_H_
#define _PHYSICSEVENT_H_

#include <wx/wx.h>
#include <wx/socket.h>
#include <vector>
#include <cstdlib>
#include <stdint.h>
 
class PhysicsEvent : public wxEvent
{
public:
    PhysicsEvent(wxEventType eventType = 0, int winid = 0) : wxEvent(winid, eventType)
    {
		this->m_Addresses.clear();
		this->m_Payloads.clear();
    }
    PhysicsEvent(wxEventType eventType, int winid, const wxIPV4address Address, const std::string Payload) : wxEvent(winid, eventType)
    {
		this->m_Addresses.push_back(Address);
		this->m_Payloads.push_back(Payload);
    }
    PhysicsEvent(wxEventType eventType, int winid, const std::vector<wxIPV4address> Addresses, const std::vector<std::string> Payloads) : wxEvent(winid, eventType)
    {
		this->m_Addresses = Addresses;
		this->m_Payloads  = Payloads;
    }
	std::vector<wxIPV4address> GetAddresses() { return this->m_Addresses;}
	std::vector<std::string>   GetPayload()   { return this->m_Payloads;}

	void SetAddresses(std::vector<wxIPV4address> Addresses) { this->m_Addresses = Addresses; }
	void SetPayloads(std::vector<std::string>   Payloads) { this->m_Payloads = Payloads;}

    // implement the base class pure virtual
    virtual wxEvent *Clone() const { return new PhysicsEvent(*this); }

	DECLARE_DYNAMIC_CLASS(PhysicsEvent )

private:
	std::vector<wxIPV4address> m_Addresses;
	std::vector<std::string>   m_Payloads;
};

typedef void (wxEvtHandler::*PhysicsEventFunction)(PhysicsEvent&);

BEGIN_DECLARE_EVENT_TYPES()
	DECLARE_EVENT_TYPE( nsPHYSICSBULKUPDATE, 1 )
END_DECLARE_EVENT_TYPES()

#define EVT_PHYSICSBULKUPDATE(id, func)  \
	DECLARE_EVENT_TABLE_ENTRY( nsPHYSICSBULKUPDATE, id, wxID_ANY, (wxObjectEventFunction) (PhysicsEventFunction) & func, (wxObject *) NULL ),

#endif