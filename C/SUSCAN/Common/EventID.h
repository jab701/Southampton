#ifndef EVENTID_H
#define EVENTID_H
enum EVENTS
{
	MAINFRAMEEVENTSMIN = wxID_HIGHEST + 1,
	ID_CONNECT,
	ID_DISCONNECT,
    ID_RESET,
	ID_FORWARD,
	ID_BACKWARD,
	ID_COIL,
	ID_STOP,
	ID_TIMER,
	ID_SOCKET_EVENT,
	ID_DEVICECONNECT,
	ID_DEVICEDISCONNECT,
	ID_SERVERLISTENPORT,
	ID_SERVERCONNECT,
	ID_SERVERDISCONNECT,
	ID_USB_TX_ENUM,
	ID_USB_RCV_ENUM,
	ID_USB_ERROR_ENUM,
	MAINFRAMEEVENTSMAX,
	ID_USB_TX_OK,
	ID_USB_TX_NULL_EPTS,
	ID_USB_TX_FAIL,
    ID_USB_TX_NO_RESPONSE,
	ID_USB_TX_INVALID_COMMAND,
	EVENTSMAX
};

DECLARE_EVENT_TYPE(ID_USB_RCV, ID_USB_RCV_ENUM)
#endif