#ifndef _RXNEURONDATA_H
#define _RXNEURONDATA_H

#include <wx/wx.h>
#include <wx/thread.h>
#include "MainFrame.h"
#include "../Common/EventID.h"
#include "CyAPI.h"
#include "CyAPI.h"
#include "cyioctl.h"
#include "usb200.h"


class RxNeuronData : public wxThread
{
public:
	RxNeuronData();
	void SetArguements(wxFrame *Parent, unsigned char *RxBuffer, long *ReceivedDataLength, wxMutex *USBReceivedDataMutex, CCyBulkEndPoint *BulkInEpt);
	virtual void* Entry();
	~RxNeuronData();
private:
	wxFrame *m_ParentFrame;
	unsigned char *m_RxBuffer;
	long *m_ReceievdDataLength;
	CCyBulkEndPoint *m_BulkInEpt; 
	wxMutex *m_USBReceivedDataMutex;
};

#endif