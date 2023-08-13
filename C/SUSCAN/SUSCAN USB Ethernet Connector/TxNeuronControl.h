#ifndef _TXNEURONCONTROL_H
#define _TXNEURONCONTROL_H

#include <wx/wx.h>
#include <wx/thread.h>
#include "MainFrame.h"
#include "../Common/EventID.h"
#include "CyAPI.h"
#include "cyioctl.h"
#include "usb200.h"


class TxNeuronControl : public wxThread
{
public:
	TxNeuronControl(wxSemaphore *USBTxSemaphore);
	void SetArguements(wxFrame *Parent, unsigned char *TxBuffer, long *TxDataLength, CCyBulkEndPoint *BulkOutEpt);
	virtual void* Entry();

	~TxNeuronControl();
private:
	wxFrame *m_ParentFrame;
	wxSemaphore *m_USBTxSemaphore;
	unsigned char *m_TxBuffer;
	long *m_TxDataLength;
    CCyBulkEndPoint *m_BulkOutEpt;
    
};

#endif