#ifndef _TransmitThreadNetworkPacketEvent_H_
#define _TransmitThreadNetworkPacketEvent_H_

#include <wx/wx.h>
#include <wx/socket.h>
#include <vector>
#include <cstdlib>
#include <stdint.h>
 
class TransmitThreadNetworkPacketEvent : public wxEvent
{
public:
    TransmitThreadNetworkPacketEvent(wxEventType eventType = 0, int winid = 0) : wxEvent(winid, eventType)
    {
		this->m_Addresses.clear();
		this->m_Payloads.clear();
    }
    TransmitThreadNetworkPacketEvent(wxEventType eventType, int winid, const wxIPV4address Address, const std::string Payload) : wxEvent(winid, eventType)
    {
		this->m_Addresses.push_back(Address);
		this->m_Payloads.push_back(Payload);
    }
    TransmitThreadNetworkPacketEvent(wxEventType eventType, int winid, const std::vector<wxIPV4address> Addresses, const std::vector<std::string> Payloads) : wxEvent(winid, eventType)
    {
		this->m_Addresses = Addresses;
		this->m_Payloads  = Payloads;
    }
	uint32_t GetNumAddresses()
	{
		return this->m_Addresses.size();
	}
	uint32_t GetNumPayloads()
	{
		return this->m_Payloads.size();
	}
	wxIPV4address GetAddress(uint32_t Index = 0)
	{
		return this->m_Addresses[Index];
	}
	std::string GetPayload(uint32_t Index = 0)
	{
		return this->m_Payloads[Index];
	}
	std::vector<wxIPV4address> GetAddresses() 
	{ 
		return this->m_Addresses;
	}
	std::vector<std::string>   GetPayloads()   
	{ 
		return this->m_Payloads;
	}

	void SetAddress(wxIPV4address Address) 
	{
		this->m_Addresses.clear(); 
		this->m_Addresses.push_back(Address); 
	}
	void SetAddresses(std::vector<wxIPV4address> Addresses) 
	{ 
		this->m_Addresses = Addresses; 
	}
	void SetPayload(std::string Payload)
	{
		this->m_Payloads.clear();
		this->m_Payloads.push_back(Payload);
	}
	void SetPayloads(std::vector<std::string>   Payloads) 
	{ 
		this->m_Payloads = Payloads;
	}

    // implement the base class pure virtual
    virtual wxEvent *Clone() const 
	{ 
		return new TransmitThreadNetworkPacketEvent(*this); 
	}

	DECLARE_DYNAMIC_CLASS(TransmitThreadNetworkPacketEvent );

private:
	std::vector<wxIPV4address> m_Addresses;
	std::vector<std::string>   m_Payloads;
};

typedef void (wxEvtHandler::*TransmitThreadNetworkPacketEventFunction)(TransmitThreadNetworkPacketEvent&);

BEGIN_DECLARE_EVENT_TYPES()
	DECLARE_EVENT_TYPE( nsTXPHYSICSBULKUPDATE, 1 )
	DECLARE_EVENT_TYPE( nsTXMOTORFORCEUPDATE, 1 )
END_DECLARE_EVENT_TYPES()

#define EVT_TXPHYSICSBULKUPDATE(id, func)  \
	DECLARE_EVENT_TABLE_ENTRY( nsTXPHYSICSBULKUPDATE, id, wxID_ANY, (wxObjectEventFunction) (TransmitThreadNetworkPacketEventFunction) & func, (wxObject *) NULL ),

#define EVT_TXMOTORFORCEUPDATE(id, func)  \
	DECLARE_EVENT_TABLE_ENTRY( nsTXMOTORFORCEUPDATE, id, wxID_ANY, (wxObjectEventFunction) (TransmitThreadNetworkPacketEventFunction) & func, (wxObject *) NULL ),

#endif