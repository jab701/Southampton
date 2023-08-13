#include "RxNeuronData.h"

RxNeuronData::RxNeuronData() : wxThread(wxTHREAD_JOINABLE)
{
	this->m_ParentFrame = NULL;
	this->m_RxBuffer = NULL;
	this->m_ReceievdDataLength = NULL;
	this->m_BulkInEpt = NULL; 
	this->m_USBReceivedDataMutex = NULL;
}

void RxNeuronData::SetArguements(wxFrame *Parent, unsigned char *RxBuffer, long *ReceivedDataLength, wxMutex *USBReceivedDataMutex, CCyBulkEndPoint *BulkInEpt)
{
	this->m_ParentFrame = Parent;
	this->m_RxBuffer = RxBuffer;
	this->m_ReceievdDataLength = ReceivedDataLength;
	this->m_BulkInEpt = BulkInEpt;
	this->m_USBReceivedDataMutex = USBReceivedDataMutex;
}

void* RxNeuronData::Entry()
{
	unsigned char buffer[64];
	long Length;
	long i;
	bool ReceiveResult;
	wxCommandEvent *NewEvent;

	if (this->m_BulkInEpt != NULL)
	{
		this->m_BulkInEpt->TimeOut = 1000;
	}

	while (!this->TestDestroy())
	{
		if (this->m_BulkInEpt != NULL)
		{
				this->m_BulkInEpt->TimeOut = 1000;
				Length = 12;
				ReceiveResult = this->m_BulkInEpt->XferData(buffer,Length, NULL);
				if (ReceiveResult) // If successful
				{

					this->m_USBReceivedDataMutex->Lock();
					for (i=0; i<Length; i++)
					{
						this->m_RxBuffer[i] = buffer[i];
						*this->m_ReceievdDataLength = Length;
					}
					this->m_USBReceivedDataMutex->Unlock();

					NewEvent = new wxCommandEvent(ID_USB_RCV);
					this->m_ParentFrame->AddPendingEvent(*NewEvent);
					delete NewEvent;
				}
		}
	}
	return(0);
}
RxNeuronData::~RxNeuronData()
{
	this->m_ParentFrame = NULL;
	this->m_RxBuffer = NULL;
	this->m_ReceievdDataLength = NULL;
	this->m_BulkInEpt = NULL; 
	this->m_USBReceivedDataMutex = NULL;
}