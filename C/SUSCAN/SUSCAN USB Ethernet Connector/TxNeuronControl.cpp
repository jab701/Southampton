#include "TxNeuronControl.h"

TxNeuronControl::TxNeuronControl(wxSemaphore *USBTxSemaphore): wxThread(wxTHREAD_DETACHED)
{
	this->m_ParentFrame = NULL;
	this->m_USBTxSemaphore = USBTxSemaphore;
	this->m_TxBuffer = NULL;
	this->m_TxDataLength = NULL;
	this->m_BulkOutEpt = NULL;
}
void TxNeuronControl::SetArguements(wxFrame *Parent, unsigned char *TxBuffer, long *TxDataLength, CCyBulkEndPoint *BulkOutEpt)
{
	this->m_ParentFrame = Parent;
	this->m_TxBuffer = TxBuffer;
	this->m_TxDataLength = TxDataLength;
	this->m_BulkOutEpt = BulkOutEpt;
}
void* TxNeuronControl::Entry()
{
	this->m_USBTxSemaphore->Wait();

	if (this->m_BulkOutEpt == NULL)
	{
		// Send Error Event to Main Window

		return(0);
	}

	this->m_BulkOutEpt->TimeOut = 2000;
	if (!this->m_BulkOutEpt->XferData(this->m_TxBuffer,*this->m_TxDataLength,NULL))
	{
		// Send Error Event to Main Window

		return(0);
	}
	return(0);
}

TxNeuronControl::~TxNeuronControl()
{
	this->m_USBTxSemaphore->Post();

	this->m_ParentFrame = NULL;
	this->m_USBTxSemaphore = NULL;

	delete this->m_TxBuffer;
	this->m_TxBuffer = NULL;

	delete this->m_TxDataLength;
	this->m_TxDataLength = NULL;

	this->m_BulkOutEpt = NULL;
}