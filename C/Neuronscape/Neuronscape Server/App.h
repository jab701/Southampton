#ifndef APP_H
#define APP_H

#include <wx/wx.h>
#include <stdint.h>

#include <wx/cmdline.h>

#include "MainFrame.h"

#define COMMAND_SET_MAJOR_VERSION 0x00
#define COMMAND_SET_MINOR_VERSION 0x00

class BIMPA_SERVER_KERNEL: public wxApp
{
public:
	virtual bool OnInit();
	virtual int OnExit();
	MainFrame *m_MainFrame;

};

static const wxCmdLineEntryDesc cmdLineDesc[] =
{
	{ wxCMD_LINE_SWITCH, "h", "help", "Help Text", wxCMD_LINE_VAL_NONE, wxCMD_LINE_OPTION_HELP},

	{ wxCMD_LINE_SWITCH, "a", "auto", "Automatically Start Server", wxCMD_LINE_VAL_NONE, wxCMD_LINE_PARAM_OPTIONAL},

	{ wxCMD_LINE_OPTION, "p", "port",  "Network Port To Listen On", wxCMD_LINE_VAL_DOUBLE, wxCMD_LINE_PARAM_OPTIONAL },
	{ wxCMD_LINE_OPTION, "s", "step",  "Physics Timestep interval (in milliseconds)", wxCMD_LINE_VAL_NUMBER, wxCMD_LINE_PARAM_OPTIONAL },
	{ wxCMD_LINE_OPTION, "g", "grav",  "Gravity Value", wxCMD_LINE_VAL_DOUBLE, wxCMD_LINE_PARAM_OPTIONAL},
	{ wxCMD_LINE_OPTION, "x", "envx",  "Environment X Size", wxCMD_LINE_VAL_DOUBLE, wxCMD_LINE_PARAM_OPTIONAL},
	{ wxCMD_LINE_OPTION, "y", "envy",  "Environment Y Size", wxCMD_LINE_VAL_DOUBLE, wxCMD_LINE_PARAM_OPTIONAL},
	{ wxCMD_LINE_OPTION, "z", "envz",  "Environment Z Size", wxCMD_LINE_VAL_DOUBLE, wxCMD_LINE_PARAM_OPTIONAL},
	{ wxCMD_LINE_NONE }
};
#endif