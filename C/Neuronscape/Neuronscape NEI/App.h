#ifndef APP_H
#define APP_H

#include <wx/wx.h>
#include <stdint.h>
#include "MainFrame.h"

#define COMMAND_SET_MAJOR_VERSION 0x00
#define COMMAND_SET_MINOR_VERSION 0x00

class NEURONSCAPE_NEI_DEMO1: public wxApp
{
public:
	virtual bool OnInit();
	MainFrame *m_MainFrame;
};

#endif