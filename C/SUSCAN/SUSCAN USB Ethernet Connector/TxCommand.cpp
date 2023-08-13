#include "TxCommand.h"

TxCommand::TxCommand(wxSemaphore *USBTxSemaphore): wxThread(wxTHREAD_DETACHED)
{
	this->m_ParentFrame = NULL;
	this->m_USBTxSemaphore = USBTxSemaphore;
	this->m_TxBuffer = NULL;
	this->m_TxDataLength = NULL;
	this->m_BulkOutEpt = NULL;
	this->m_BulkInEpt = NULL;
}
void TxCommand::SetArguements(wxFrame *Parent, unsigned char *TxBuffer, long *TxDataLength, CCyBulkEndPoint *BulkOutEpt, CCyBulkEndPoint *BulkInEpt)
{
	this->m_ParentFrame = Parent;
	this->m_TxBuffer = TxBuffer;
	this->m_TxDataLength = TxDataLength;
	this->m_BulkOutEpt = BulkOutEpt;
	this->m_BulkInEpt = BulkInEpt;
}
void* TxCommand::Entry()
{
	unsigned char ReturnData[64];
	long ReturnLength = 1;

	this->m_USBTxSemaphore->Wait();

	if ((this->m_BulkInEpt == NULL)&&(this->m_BulkOutEpt == NULL))
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


	this->m_BulkInEpt->TimeOut = 5000;
	if (!this->m_BulkInEpt->XferData(ReturnData,ReturnLength,NULL))
	{
		// Send Error Event to Main Window
		
		return(0);
	}

	if (ReturnData[0] == 255)
	{
		// Send Command Processed Error
		
		return(0);
	}

	return(0);
}

TxCommand::~TxCommand()
{
	this->m_USBTxSemaphore->Post();

	this->m_ParentFrame = NULL;
	this->m_USBTxSemaphore = NULL;

	delete this->m_TxBuffer;
	this->m_TxBuffer = NULL;

	delete this->m_TxDataLength;
	this->m_TxDataLength = NULL;

	this->m_BulkOutEpt = NULL;
	this->m_BulkInEpt = NULL;
}