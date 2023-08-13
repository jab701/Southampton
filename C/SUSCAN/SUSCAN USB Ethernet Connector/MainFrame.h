#ifndef MAINFRAME_H
#define MAINFRAME_H
#include <wx/wx.h>
#include <wx/socket.h>
#include <wx/toolbar.h>
#include <wx/dcclient.h>
#include <wx/dcbuffer.h>
#include <wx/log.h>
#include "../Common/EventID.h"
#include "ControlFrame.h"
#include "CyAPI.h"
#include "cyioctl.h"
#include "usb200.h"
#include "NeuronUSBInterface.h"
#include <wx/timer.h>
#include <wx/numdlg.h>
#include <wx/aboutdlg.h>
#include "../Common/NetworkStack.h"


class NeuronUSBInterface;

class MainFrame : public wxFrame
{
public:
	/***** MainFrame Constructor *****/
	MainFrame(const wxString& title);
	/***** MainFrame Destructor *****/
	~MainFrame();
	void InitMenuBar();
	void LayoutWindowControls();
	/***** File Menu Event Handlers *****/
	/***** Function Responsible For Closing The Program *****/
	void MenuExit(wxCommandEvent &event);
	/***** USB Device Control Menu Event Handlers *****/
	/***** Function Responsible For Connecting to the USB Device *****/
	void ConnectToUSB(wxCommandEvent &event);
	/***** Function Responsible For Disconnecting from the USB Device *****/
	void DisconnectFromUSB(wxCommandEvent &event);
	/***** Server Control Menu Event Handlers *****/
	/***** Function To Start listening for network connections *****/
	void StartNetworkServer(wxCommandEvent &event);
	/***** Function To Stop listening for network connections *****/
	void StopNetworkServer(wxCommandEvent &event);
	/***** Function Responsible For changing the port for listening for connections *****/
	void ChangeNetworkPort(wxCommandEvent &event);
	/***** Help Menu Event Handlers *****/
	/***** Function Responsible For Displaying About Dialogue *****/
	void MenuAbout(wxCommandEvent &event);
	/***** Socket Events *****/
	void OnSocketEvent(wxSocketEvent &event);
	/***** On USB Neuron Data Received *****/
	void OnUSBDeviceReceiveData(wxCommandEvent &event);
	/***** On Application Close Events *****/
	void OnClose(wxCloseEvent &event);

	void UpdateStatusLabel(wxString ControlName, wxString Text);



private:
	wxMenuBar *m_MenuBar;
    wxMenu *m_FileMenu;
	wxMenu *m_USBDeviceControlMenu;
	wxMenu *m_ServerControlMenu;
	wxMenu *m_HelpMenu;

	NeuronUSBInterface *m_USBInterface;

	NetworkStack *m_NetworkStack;

	wxMutex m_USBReceiveDataMutex;

	unsigned short m_ServerPort;
	bool m_Connected;

	unsigned long m_TxPacket;
	unsigned long m_RxPacket;


	unsigned char m_NeuronActivity[11];
	unsigned char m_OldNeuronActivity[11];

	DECLARE_EVENT_TABLE()
};


#endif