#include "NeuronUSBInterface.h"



NeuronUSBInterface::NeuronUSBInterface(wxFrame *Parent)
{
	this->m_ParentWindow = Parent;

	this->m_USBDevice = new  CCyUSBDevice(Parent);

	this->m_BulkCommandIn = NULL;

	this->m_BulkCommandOut = NULL;

	this->m_BulkDataIn = NULL;

	this->m_BulkDataOut = NULL;

	this->m_NeuronActivityDataReceiveThread = NULL;

	this->m_ReceivedDataMutex = NULL;

	this->m_USBTxSemaphore = NULL;
}

bool NeuronUSBInterface::OpenUSBDevice(short VID, short PID)
{
	int DeviceCount = 0;
	int EndpointCount = 0;
	int i;

	if (this->m_USBDevice == NULL)
	{
		return(false);
	}

	DeviceCount = this->m_USBDevice->DeviceCount();

	if (DeviceCount == 0)
	{
		delete this->m_USBDevice;
		this->m_USBDevice = NULL;
		return(false);
	}

	for(i=0; i<DeviceCount; i++)
	{
		if (this->m_USBDevice->Open(i))
		{
			if ((this->m_USBDevice->VendorID == VID)&&(this->m_USBDevice->ProductID == PID))
			{
				break;
			}
			else
			{
				this->m_USBDevice->Close();
			}
		}
	}

	if (!this->m_USBDevice->IsOpen())
	{
		delete this->m_USBDevice;
		this->m_USBDevice = NULL;
		return(false);
	}
	
	EndpointCount = this->m_USBDevice->EndPointCount();
	
	for(i=1; i<EndpointCount; i++)
	{
		if (this->m_USBDevice->EndPoints[i]->Attributes == 2) // Is this a bulk endpoint?
		{
			if (this->m_USBDevice->EndPoints[i]->Address == 0x81) // Is this Endpoint 1 IN?
			{
				this->m_BulkCommandIn = (CCyBulkEndPoint*) this->m_USBDevice->EndPoints[i];
			}
			else if (this->m_USBDevice->EndPoints[i]->Address == 0x02) // Is this Endpoint 2 OUT?
			{
				this->m_BulkCommandOut = (CCyBulkEndPoint*) this->m_USBDevice->EndPoints[i];
			}
			else if (this->m_USBDevice->EndPoints[i]->Address == 0x83) // Is this Endpoint 3 IN?
			{
				this->m_BulkDataIn = (CCyBulkEndPoint*) this->m_USBDevice->EndPoints[i];
			}
			else if (this->m_USBDevice->EndPoints[i]->Address == 0x04)
			{
				this->m_BulkDataOut = (CCyBulkEndPoint*) this->m_USBDevice->EndPoints[i];
			}
		}
	}

	if ((this->m_BulkCommandIn == NULL) || (this->m_BulkCommandOut == NULL) || (this->m_BulkDataIn == NULL) || (this->m_BulkDataOut == NULL))
	{
		// Not all the required endpoints were found. Invalid USB Device!
		return(false);
	}

	this->m_USBTxSemaphore = new wxSemaphore(1,1);
	return (true);
}


long NeuronUSBInterface::GetBulkDataInLength()
{
	return((long) this->m_BulkDataIn->MaxPktSize);
}
bool NeuronUSBInterface::AssertSystemReset()
{
	unsigned char USBCommand[2];

	USBCommand[0] = 0xFF;
	USBCommand[1] = 0x00;
	if (!this->TransmitData(2,USBCommand))
	{
		// Could not transmit the command
		return(false);
	}
	return(true);
}
bool NeuronUSBInterface::DeassertSystemReset()
{
	unsigned char USBCommand[2];

	USBCommand[0] = 0xFF;
	USBCommand[1] = 0x01;
	if (!this->TransmitData(2,USBCommand))
	{
		// Could not transmit the command
		return(false);
	}
	return(true);
}
bool NeuronUSBInterface::TransmitData(long Length, unsigned char* Data)
{
	long *TxLength;
	long i;
	unsigned char *TxData;

	TxCommand *TxThread;

	if (this->m_USBDevice != NULL)
	{
		if ((this->m_BulkCommandOut == NULL) || (this->m_BulkCommandIn == NULL))
		{
			return(false);
		}
		else
		{

			TxThread = new TxCommand(this->m_USBTxSemaphore);

			TxLength = new long;
			TxData = new unsigned char[Length];

			*TxLength = Length;

			for (i=0;i<Length;i++)
			{
				TxData[i] = Data[i];
			}

			TxThread->SetArguements(this->m_ParentWindow,TxData,TxLength,this->m_BulkCommandOut,this->m_BulkCommandIn);

			if (TxThread->Create() != wxTHREAD_NO_ERROR)
			{
				return(false);

			}
			if (TxThread->Run() != wxTHREAD_NO_ERROR)
			{
				return(false);
			}

			return(true);
		}
	}
	else
	{
		return(false);
	}
}
bool NeuronUSBInterface::TransmitNeuronControlData(wxString Data)
{
	wxString DataToSend;
	unsigned char ZeroChar = 0;
	DataToSend.Append(ZeroChar);
	DataToSend.Append(Data);

	bool ReturnValue = this->TransmitNeuronControlData(DataToSend.Len(),(unsigned char*) DataToSend.c_str());
	return ReturnValue;
}
bool NeuronUSBInterface::TransmitNeuronControlData(long Length, unsigned char * Data)
{
	long *TxLength;
	long i;
	unsigned char *TxData;

	TxNeuronControl *TxThread;

	if (this->m_USBDevice != NULL)
	{
		if (this->m_BulkDataOut == NULL)
		{
			return(false);
		}
		else
		{

			TxThread = new TxNeuronControl(this->m_USBTxSemaphore);

			TxLength = new long;
			TxData = new unsigned char[Length];

			*TxLength = Length;

			for (i=0;i<Length;i++)
			{
				TxData[i] = Data[i];
			}

			TxThread->SetArguements(this->m_ParentWindow,TxData,TxLength,this->m_BulkDataOut);

			if (TxThread->Create() != wxTHREAD_NO_ERROR)
			{
				return(false);

			}
			if (TxThread->Run() != wxTHREAD_NO_ERROR)
			{
				return(false);
			}

			return(true);
		}
	}
	else
	{
		return(false);
	}
	return(true);
}

bool NeuronUSBInterface::EnableReceieveNeuronData()
{
	if (this->m_USBDevice == NULL)
	{
		// USB Device is not allocated
		// wxMessageBox("USB Device not allocated", "Status", wxOK, this->m_ParentWindow);
		return(false);
	}

	if (this->m_USBDevice->IsOpen() == false)
	{
		// USB Device is not open
		// wxMessageBox("Could not open USB device", "Status", wxOK, this->m_ParentWindow);
		return(false);
	}

	this->m_ReceivedDataMutex = new wxMutex();

	if (this->m_ReceivedDataMutex == NULL)
	{
		// Memory was not allocated for mutex
		// wxMessageBox("Could not allocate receive data mutex", "Status", wxOK, this->m_ParentWindow);
		return(false);
	}	

	this->m_ReceivedDataLength = this->m_BulkDataIn->MaxPktSize;

	this->m_ReceivedData = new unsigned char[this->m_BulkDataIn->MaxPktSize];

	if (this->m_ReceivedData == NULL)
	{
		// Memory was not allocated for Received Data array
		// wxMessageBox("Could not allocate memory for receive data array", "Status", wxOK, this->m_ParentWindow);
		return(false);
	}

	this->m_NeuronActivityDataReceiveThread = new RxNeuronData();

	if (this->m_NeuronActivityDataReceiveThread == NULL)
	{
		// Could not allocate memory for receive thread
		// wxMessageBox("Could not allocate memory for receieve data thread!", "Status", wxOK, this->m_ParentWindow);
		return(false);
	}

	this->m_NeuronActivityDataReceiveThread->SetArguements(this->m_ParentWindow,this->m_ReceivedData,&this->m_ReceivedDataLength,this->m_ReceivedDataMutex,this->m_BulkDataIn);

	if (this->m_NeuronActivityDataReceiveThread->Create() != wxTHREAD_NO_ERROR)
	{
		// Must delete allocated thread	
		// wxMessageBox("Could not create receive data thread", "Status", wxOK, this->m_ParentWindow);
		delete this->m_NeuronActivityDataReceiveThread;
		return(false);
	}


	if (this->m_NeuronActivityDataReceiveThread->Run() != wxTHREAD_NO_ERROR)
	{
		// Must delete allocated thread
		// wxMessageBox("Could not run receive data thread", "Status", wxOK, this->m_ParentWindow);
		delete this->m_NeuronActivityDataReceiveThread;
		return(false);
	}
	return(true);
}
bool NeuronUSBInterface::ReceievedNeuronData(long *DataLength, unsigned char *Data)
{
	long i;

	if (this->m_USBDevice == NULL)
	{
		// USB Device is not allocated
		return(false);
	}

	if (this->m_USBDevice->IsOpen() == false)
	{
		// USB Device is not open
		return(false);
	}



	this->m_ReceivedDataMutex->Lock();
	
	*DataLength = this->m_ReceivedDataLength;
	if (DataLength  > 0)
	{
		for(i=0; i < this->m_ReceivedDataLength; i++)
		{
			Data[i] = this->m_ReceivedData[i];
		}
	}
	this->m_ReceivedDataMutex->Unlock();	
	return(true);
}
bool NeuronUSBInterface::DisableReceiveNeuronData()
{
	if (this->m_USBDevice != NULL)
	{
		if(this->m_NeuronActivityDataReceiveThread != NULL)
		{
			this->m_NeuronActivityDataReceiveThread->Delete();
			delete this->m_NeuronActivityDataReceiveThread;
			delete this->m_ReceivedDataMutex;
			delete [] this->m_ReceivedData;
			this->m_ReceivedDataLength = 0;
		}
	}
	return(true);
}
bool NeuronUSBInterface::CloseUSBDevice()
{
	if (this->m_USBDevice != NULL)
	{
		if (this->m_USBDevice->IsOpen())
		{
			this->DisableReceiveNeuronData();
			this->m_USBTxSemaphore->Wait();
			this->m_USBDevice->Close();


			delete this->m_USBTxSemaphore;
			this->m_USBTxSemaphore = NULL;
		}
		delete this->m_USBDevice;
		this->m_USBDevice = NULL;
	}

	this->m_BulkCommandIn = NULL;
	this->m_BulkCommandOut = NULL;
	this->m_BulkDataIn = NULL;
	this->m_BulkDataOut = NULL;

	return true;
}

bool NeuronUSBInterface::USBDeviceDisconnected()
{
	return(true);

}

NeuronUSBInterface::~NeuronUSBInterface()
{
	this->CloseUSBDevice();

	this->m_ParentWindow = NULL;
	this->m_USBDevice = NULL;

	this->m_BulkCommandIn = NULL;

	this->m_BulkCommandOut = NULL;

	this->m_BulkDataIn = NULL;

	this->m_BulkDataOut = NULL;

	this->m_NeuronActivityDataReceiveThread = NULL;


	this->m_ReceivedDataMutex = NULL;

	this->m_USBTxSemaphore = NULL;
}