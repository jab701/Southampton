#ifndef DEFINITIONS_H
#define DEFINITIONS_H

/*** Define the different program roles ***/
#define ROLE_UNDEF               0x00
#define ROLE_SERVER              0x01
#define ROLE_VIEWER              0x02
#define ROLE_NEUENV              0x03
#define ROLE_CNTRL               0x04

/*** Define Packet Types ***/
#define PKT_ACK                  0x0000
#define PKT_ERROR                0x0001
#define PKT_CONNECTION_REQ       0x0002
#define PKT_DISCONNECTION_REQ    0x0003
#define PKT_FORCEDISCONNECT      0x0004
#define PKT_CLIENT_ENUMERATE     0x0005
#define PKT_REQ_ADD_OBJ          0x0006
// UPDATE_OBJ IS DEPRECATED
#define PKT_UPDATE_OBJ           0x0007
#define PKT_BULK_UPDATE_OBJ      0x0008
#define PKT_DELETE_OBJ           0x0009
#define PKT_DELETE_OBJ_ASGOD     0x00F9
#define PKT_FORCES_OBJ           0x000A
#define PKT_TORQUE_OBJ           0x000B
// ENERGYDELTA IS DEPRECATED
#define PKT_ENERGYDELTA          0x000C
#define PKT_COLOUR_OBJ           0x000D
#define PKT_ADDINANIMATE_OBJ     0x000E
#define PKT_EAT_OBJ				 0x000F
#define PKT_REMOVE_EATEN_OBJ     0x0010
#define PKT_KILL_SYSTEM          0x0011
#define PKT_TEST_ECHO_REPLY      0xFFFE
#define PKT_TEST_ECHO            0xFFFF

/*** Error Codes ***/
#define GENERAL_ERROR            0x0000

// Client Status
#define CLI_STATUS_OK            0x0000
#define CLI_STATUS_ENUM          0x0001
#define CLI_STATUS_INIT          0x0002

// Server Object Flags
#define OBJFLAG_FIXED			0x0001
#define OBJFLAG_EDIBLE			0x0002
#define OBJFLAG_NOCOLLIDE		0x0004
#define OBJFLAG_INANIMATE		0x0008
#define OBJFLAG_0010			0x0010
#define OBJFLAG_0020			0x0020
#define OBJFLAG_0040			0x0040
#define OBJFLAG_0080			0x0080
#define OBJFLAG_0100			0x0100
#define OBJFLAG_0200			0x0200
#define OBJFLAG_0400			0x0400
#define OBJFLAG_0800			0x0800
#define OBJFLAG_1000			0x1000
#define OBJFLAG_2000			0x2000
#define OBJFLAG_4000			0x4000
#define OBJFLAG_8000			0x8000

// Server Network Stack Status
enum SVR_NS_STATUS
{
	SVR_NS_OK = 0x0000,
	SVR_NS_KILL,
	SVR_NS_ERROR,
	SVR_NS_MAX
};

// Client Network Statck Status
enum CNS_STATUS
{
	CLI_NS_OK  =  0x0000,
	CLI_NS_CONNECTED,
	CLI_NS_DISCONNECTED,
	CLI_NS_DISCONNECT_FORCED,
	CLI_NS_ENUM,
	CLI_NS_ASSIGNED_OBJECT,
	CLI_NS_ASSIGNED_OBJECT_REMOVED,
	CLI_NS_OBJECT_REMOVED,
	CLI_NS_TEST_ECHO,
	CLI_NS_TEST_ECHO_REPLY,
	CLI_NS_OBJECT_DATA_DIRTY,
	CLI_NS_OBJECT_EATEN,
	CLI_NS_KILL,
	CLI_NS_ERROR,
	CLI_NS_BADBACKETID,
	CLI_NS_MAX
};

enum SNS_STATUS
{
	SPIN_NS_OK = 0x0000,
	SPIN_NS_SPIKE,
	SPIN_NS_STATE,
	SPIN_NS_MAX
};

#define MAX_PACKET_LENGTH 1000
#define UPDATE_OBJ_LENGTH 58
#define MAX_OBJ_BULK_PKT (MAX_PACKET_LENGTH/UPDATE_OBJ_LENGTH)

/*** Mathematical Constants ***/
#define PI 3.1415926535897932384626433832795
#define GRAVITY 9.81
#define mu_static 1.0 // Dry rubber and concrete -- wikipedia
#define mu_kinetic 1.0
#define phystimestep 10e-3 
#define MaxPlacementAttempts 10
#define MASS 1.0 // equiv to one kilo!
#define RADIUS 10.0
#define EatingRange 5.0
//#define EnvX 250.0
//#define EnvY 250.0
//#define EnvZ 250.0

#define MAX_TOTAL_SDP_LENGTH (8 + 16 + SDP_BUF_SIZE)

#define SPIN_CHIPMAX 2
#define SPIN_CPUMAX 17
#define SPIN_TAGMAX 3

#define RETINA_X_MAX 320
#define RETINA_Y_MAX 240
#define RETINA_UNDEF     0x00
#define RETINA_GRAYSCALE 0x01
#define RETINA_RGB       0x02
#define RETINA_MAX       0x03

// new definitions added by RM.
#define DEBUG_ENERGY_DEPLETION_ON 1 // used only in server/mainframe

#define NEI_DEFAULT_SERVERHOST "localhost"
#define NEI_DEFAULT_SERVERPORT "12000"
//#define NEI_DEFAULT_SPINNHOST  "circus.cs.man.ac.uk"
//#define NEI_DEFAULT_SPINNHOST  "valluga"
#define NEI_DEFAULT_SPINNHOST  "localhost"

#define NEI_DEFAULT_SPINNPORT  "11111"
#define NEI_SPIKE_COMMAND_RC 0xf1 
#define NEI_STATE_COMMAND_RC 0xf2

#define NEI_DEFAULT_RETINA_ROWS "3"
#define NEI_DEFAULT_RETINA_COLS "1"


// various debug options
#define NEI_USE_MANUAL_REFRESH_RATE 1
#define NEI_MANUAL_REFRESH_RATE 20
#define MUSCLE_MODEL_IMPULSE 1
#define IMPULSE_FORCE_DURATION 3
#define IMPULSE_TORQUE_DURATION 5
#define IMPULSE_FORCE_MAGNITUDE 5000
#define IMPULSE_TORQUE_MAGNITUDE 1000


// Physics Coasting options
#define PHYSICS_COASTING 0


#define INITIAL_ENERGY 120000.0

#endif