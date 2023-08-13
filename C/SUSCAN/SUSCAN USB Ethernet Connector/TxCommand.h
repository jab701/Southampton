#ifndef _TXCOMMAND_H
#define _TXCOMMAND_H

#include <wx/wx.h>
#include <wx/thread.h>
#include "MainFrame.h"
#include "../Common/EventID.h"
#include "CyAPI.h"
#include "cyioctl.h"
#include "usb200.h"


class TxCommand : public wxThread
{
public:
	TxCommand(wxSemaphore *USBTxSemaphore);
	void SetArguements(wxFrame *Parent, unsigned char *TxBuffer, long *TxDataLength, CCyBulkEndPoint *BulkOutEpt, CCyBulkEndPoint *BulkInEpt);
	virtual void* Entry();

	~TxCommand();
private:
	wxFrame *m_ParentFrame;
	wxSemaphore *m_USBTxSemaphore;
	unsigned char *m_TxBuffer;
	long *m_TxDataLength;
    CCyBulkEndPoint *m_BulkOutEpt;
    CCyBulkEndPoint *m_BulkInEpt;
};

#endif