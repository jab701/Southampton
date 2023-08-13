#ifndef VIEW3D_H
#define VIEW3D_H

#include <wx/wx.h>
#include <wx/tglbtn.h>
#include <wx/socket.h>
#include <wx/toolbar.h>
#include <wx/dcclient.h>
#include <wx/dcbuffer.h>
#include <wx/timer.h>
#include <wx/display.h>
#include <wx/glcanvas.h>
#include <stdint.h>

#include <GL/glu.h>
#include <GL/gl.h>

//#include <GL/glut.h>
//#include <gl/GL.h>


#include <wx/utils.h>


#include "../Common/GLTexture.h"
#include "../Common/GLUtilities.h"

#include "../Common/Definitions.h"
#include "../Common/CartesianVector.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"

#include "../Common/EnvParameters.h"

#include "../Common/Utilities.h"

#ifdef NEURONSCAPE_NEI
#include "../Neuronscape NEI/RetinaThread.h"
#else
class RetinaThread
{
public:
	void OnNewImageEvent(unsigned char *PixelData, uint32_t w, uint32_t h)
	{
		return;
	}
};
#endif


class View3D: public wxGLCanvas
{
public:
	View3D(wxWindow *parent, wxString Name, int* args = 0);
	void SetArguements(CartesianVector EnvDimensions, DB_ClientObject *ObjectDb);
	void SetObjectID(uint32_t ObjectID);
	void SetViewer(bool ViewerMode, bool BirdsEye = false);
	void SetRetina(RetinaThread *Retina);
	void SetCameraViewPoint(CartesianVector Position, double Theta, double Phi);
	void InitGL();
	void GLCleanup();
	void KBEvent(wxKeyEvent &event);
	void StepForward(double Amount);
	void StepBackward(double Amount);
	void TurnLeft(double Amount);
	void TurnRight(double Amount);
	void FullScreen(bool Mode)
	{
		this->m_FullScreen = Mode;
	}
	~View3D();

protected:
	void OnPaint(wxPaintEvent& event);
	void OnRedrawTimer(wxTimerEvent &event);
	void OnSize(wxSizeEvent& event);
	void OnEraseBackground(wxEraseEvent& event);
	void OnClose(wxCloseEvent &event);

private:
	void DrawTexturedQuad();
	void DrawSphere(double r, int lats, int longs);
	void DrawTorus(double InnerRadius, double OuterRadius);
	void DrawWorld();
	void ResetProjectionMode();

	bool m_Init;
	GLTexture *m_Image;
	EnvParameters m_EnvDimensions;

	int FilterLevel;
	GLfloat XZPlane_Rotate;

	GLfloat xrot;
	GLfloat yrot;
	GLfloat zrot;

	uint16_t m_ObjectID;
	DB_ClientObject *m_ObjectDb;

	wxTimer *m_RefreshTimer;
	wxGLContext *m_context;
	RetinaThread *m_Retina;

	bool m_IsViewer;
	bool m_BirdsEyeView;

	CartesianVector m_CameraView;
	double m_CameraTheta;
	double m_CameraPhi;

	bool m_FullScreen;

	DECLARE_EVENT_TABLE()
};


#endif
