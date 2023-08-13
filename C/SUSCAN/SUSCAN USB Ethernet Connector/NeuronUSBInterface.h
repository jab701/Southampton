#ifndef NEURONUSBINTERFACE_H
#define NEURONUSBINTERFACE_H

#include <wx/wx.h>
#include "CyAPI.h"
#include "cyioctl.h"
#include "usb200.h"
#include "RxNeuronData.h"
#include "TxCommand.h"
#include "TxNeuronControl.h"
#include "../Common/EventID.h"

class RxNeuronData;

class NeuronUSBInterface
{
public:
	NeuronUSBInterface(wxFrame *Parent);
	bool OpenUSBDevice(short VID, short PID);
    long GetBulkDataInLength();
	bool AssertSystemReset();
	bool DeassertSystemReset();
	bool TransmitData(long Length, unsigned char *Data);
	bool TransmitNeuronControlData(wxString Data);
	bool TransmitNeuronControlData(long Length, unsigned char * Data);
	bool EnableReceieveNeuronData();
	bool ReceievedNeuronData(long *DataLength, unsigned char *Data);
	bool DisableReceiveNeuronData();
	bool CloseUSBDevice();
	/*** This function should be called when the driver indicates a pnp disconnect event ***/
	bool USBDeviceDisconnected();
	~NeuronUSBInterface();
	
private:
	wxFrame *m_ParentWindow;
	wxSemaphore *m_USBTxSemaphore;
	wxMutex *m_ReceivedDataMutex;

	unsigned char *m_ReceivedData;
	long m_ReceivedDataLength;

	CCyUSBDevice *m_USBDevice;
	CCyBulkEndPoint *m_BulkCommandIn;
	CCyBulkEndPoint *m_BulkCommandOut;
	CCyBulkEndPoint *m_BulkDataIn;
	CCyBulkEndPoint *m_BulkDataOut;

	RxNeuronData *m_NeuronActivityDataReceiveThread;
};


#endif
