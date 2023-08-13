#ifndef DEFINITIONS_H
#define DEFINITIONS_H

/*** Define the different program roles ***/
#define ROLE_UNDEF               0x00
#define ROLE_SERVER              0x01
#define ROLE_VIEWER              0x02

/*** Define Packet Types ***/
#define PKT_CONNECTION_ACK       0x0000
#define PKT_CONNECTION_REQ       0x0001
#define PKT_FORCEDISCONNECT      0x0002
#define PKT_NEURON_CTRL          0x0003
#define PKT_NEURON_DATA          0x0004
#define PKT_SET_RESET            0x0005
#define PKT_UNSET_RESET          0x0006
#define PKT_TEST_ECHO_REPLY      0x0007
#define PKT_TEST_ECHO            0x0008

// Client Network Statck Status
#define NS_NOP                     0x0000
#define NS_CONNECTED               0x0001
#define NS_DISCONNECT_FORCED       0x0002
#define NS_TEST_ECHO_REPLY         0x0003
#define NS_NAD_DATA_DIRTY          0x0004
#define NS_NCD_DATA_DIRTY          0x0005
#define NS_RESET_DATA_DIRTY        0x0006
#define NS_ERROR                   0x0007


#endif