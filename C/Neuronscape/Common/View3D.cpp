#include "View3D.h"

View3D::View3D(wxWindow *parent, wxString Name, int* args)
	: wxGLCanvas(parent, wxID_ANY,  args, wxDefaultPosition, wxSize(320,240), 0, Name)
{
	this->m_context = new wxGLContext(this);

	this->m_Init = false;
	this->m_Image = NULL;

	this->m_ObjectDb = NULL;
	this->m_Retina = NULL;

	this->m_IsViewer = false;
	this->m_BirdsEyeView = false;

	this->m_CameraView = CartesianVector(0.0,0.0,0.0);
	this->m_CameraTheta = 0.0;
	this->m_CameraPhi = 0.0;

	this->m_ObjectID = 0;
	this->FilterLevel = 2;
}

View3D::~View3D()
{
	this->m_Init = false;

	this->GLCleanup();

	if (this->m_context != NULL)
	{
		delete this->m_context;
		this->m_context = NULL;
	}

	this->m_Retina = NULL;	
}
void View3D::SetArguements(CartesianVector EnvDimensions, DB_ClientObject *ObjectDb)
{
	this->m_EnvDimensions.EnvDim = EnvDimensions;
	this->m_ObjectDb = ObjectDb;

	this->m_CameraView = CartesianVector(this->m_EnvDimensions.EnvDim.x/2.0,this->m_EnvDimensions.EnvDim.y/2.0,10.0);
	this->m_CameraTheta = 0.0;
	this->m_CameraPhi = 0.0;
}
void View3D::SetObjectID(uint32_t ObjectID)
{
	this->m_ObjectID = ObjectID;
}
void View3D::SetViewer(bool ViewerMode, bool BirdsEye)
{
	this->m_IsViewer = ViewerMode;
	this->m_BirdsEyeView = BirdsEye;
}
void View3D::SetRetina(RetinaThread *Retina)
{
	this->m_Retina = Retina;
}
void View3D::SetCameraViewPoint(CartesianVector Position, double Theta, double Phi)
{
	this->m_CameraView = Position;
	this->m_CameraTheta = Theta;
	this->m_CameraPhi = Phi;
}
void View3D::OnPaint(wxPaintEvent& event)
{
	CartesianVector ViewPoint;
	double ViewPointTheta;
	double ViewPointPhi;
	uint32_t SelectedObjectID;

	if (this->IsShown() == false)
	{
		return;
	}

	if (this->IsShownOnScreen() == false)
	{
		return;
	}

	if (this->m_context == NULL)
	{
		return;
	}

	if (this->m_Init == false)
	{
		this->InitGL();
		return;
	}

	// must always be here
	SetCurrent(*this->m_context);
	wxPaintDC dc(this);

	//wxGLCanvas::SetCurrent(*this->m_context);

	this->ResetProjectionMode();



	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer

	glLoadIdentity();

	if (this->m_ObjectDb == NULL)
	{	
		// Flush
		glFlush();
		// Swap
		SwapBuffers();
		return;
	}

	if ((this->m_ObjectID == 0)&&(this->m_IsViewer == false))
	{	
		// Flush
		glFlush();
		// Swap
		SwapBuffers();
		return;
	}

	if (this->m_IsViewer == true)
	{
		if (this->m_BirdsEyeView == true)
		{
			ViewPoint = CartesianVector(this->m_EnvDimensions.EnvDim.x/2.0,this->m_EnvDimensions.EnvDim.y/2.0,this->m_EnvDimensions.EnvDim.z);
			ViewPointTheta = (90.0/180.0)*PI;
			ViewPointPhi = 0;
			//SelectedObjectID = 0; // No Selected Object ID!
		}
		else
		{
			ViewPoint = this->m_CameraView;
			ViewPointTheta = this->m_CameraTheta;
			ViewPointPhi = this->m_CameraPhi;
			//SelectedObjectID = 0; // No Selected Object ID!
		}
	}
	else
	{
		DBRecord_ClientObject Record;

		if (this->m_ObjectDb->FindByID(this->m_ObjectID,Record) == false)
		{
			return;
		}

		ViewPoint = Record.Position;
		ViewPointTheta = Record.Theta;
		ViewPointPhi = Record.Phi;

		SelectedObjectID = Record.ID;
	}


	GLfloat global_ambient[] = { 1.0f, 1.0f, 1.0f, 1.0f };
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);

	CartesianVector EnvCenter = this->m_EnvDimensions.EnvDim/2.0;
	// Calculate the relative position of the object with respect to our position
	CartesianVector RelativePositon = EnvCenter - ViewPoint;
	double Corrected_Camera_XZ_Rotation = ToDegrees(ViewPointTheta) + 90.0;

	if (this->m_BirdsEyeView == true)
	{
		glRotatef(90.0f,1.0f,0.0f,0.0f);	// Rotate Camera On The X Axis
	}
	else
	{
		glRotatef(Corrected_Camera_XZ_Rotation,0.0f,1.0f,0.0f);	// Rotate Camera On The Y Axis
	}


	glTranslatef(RelativePositon.x,RelativePositon.z,RelativePositon.y); // Move to the relative position of the object

	GLfloat gray[] = { 1.0f, 1.0f, 1.0f, 1.0f };
	glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, gray);

	this->DrawWorld();

	std::vector<DBRecord_ClientObject> Records;
	this->m_ObjectDb->FetchAll(Records);

	if (Records.size() != 0)
	{
		for (unsigned i = 0; i < Records.size(); i++)
		{
			if (Records[i].ID != SelectedObjectID) // If the object is not our object
			{
				glLoadIdentity();	// Reset The Current View Matrix (Set to 0,0,0)

				// Calculate the relative position of the object with respect to our position
				CartesianVector RelativePositon = Records[i].Position - ViewPoint;
				// Calculate the corrected Camera rotation
				double Corrected_Camera_XZ_Rotation = ToDegrees(ViewPointTheta) + 90.0;
				// Calculate the corrected object rotation
				double Corrected_Object_XZ_Rotation = ToDegrees(Records[i].Theta) + 90.0;

				if (this->m_BirdsEyeView == true)
				{
					glRotatef(90.0f,1.0f,0.0f,0.0f);	// Rotate Camera On The X Axis
				}
				else
				{
					glRotatef(Corrected_Camera_XZ_Rotation,0.0f,1.0f,0.0f);	// Rotate Camera On The Y Axis
				}

				glTranslatef(RelativePositon.x,RelativePositon.z,RelativePositon.y); // Move to the relative position of the object
				glRotatef(Corrected_Object_XZ_Rotation,0.0f,1.0f,0.0f); // Rotate the object

				double Red	 = (double)Records[i].Red/255.0;
				double Green = (double)Records[i].Green/255.0;
				double Blue  = (double)Records[i].Blue/255.0;
				double Lum   = (double)Records[i].Brightness/255.0;

				// Apply "luminosity"
				Red *= Lum;
				Green *= Lum;
				Blue *= Lum;

				glColor3f(Red,Green,Blue);

				GLfloat ObjGlow[] = { Red, Green, Blue, 1.0 };
				glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, ObjGlow);

				if (Records[i].Flags & OBJFLAG_INANIMATE)
				{
					this->DrawTorus(1.0,10.0);
				}
				else
				{
					this->DrawSphere(10.0, 20, 20);
				}
			}
		}
	}

	// Flush
	glFlush();

	if (this->m_Retina != NULL)
	{
		int w, h;
		GetClientSize(&w, &h);
		// Read the pixels back
		unsigned char *PixelData = new unsigned char[w*h*3];
		glReadPixels(0,0,w,h,GL_RGB,GL_UNSIGNED_BYTE,PixelData);
		this->m_Retina->OnNewImageEvent(PixelData,w,h);
	}

	// Swap
	SwapBuffers();

	event.Skip();
}
void View3D::DrawTexturedQuad()
{
	glBindTexture(GL_TEXTURE_2D, 0 );
	//glBindTexture(GL_TEXTURE_2D, this->m_Image[0].getID()[this->FilterLevel] );
	glBegin(GL_QUADS);
	// Front Face
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-5.0f, -5.0f,  5.0f);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 5.0f, -5.0f,  5.0f);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 5.0f,  5.0f,  5.0f);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-5.0f,  5.0f,  5.0f);	// Top Left Of The Texture and Quad
	glEnd();

	//glBindTexture(GL_TEXTURE_2D, this->m_Image[1].getID()[this->FilterLevel] );

	glBegin(GL_QUADS);
	// Back Face
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-5.0f, -5.0f, -5.0f);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-5.0f,  5.0f, -5.0f);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 5.0f,  5.0f, -5.0f);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 5.0f, -5.0f, -5.0f);	// Bottom Left Of The Texture and Quad
	glEnd();

	glBegin(GL_QUADS);
	// Top Face
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-5.0f,  5.0f, -5.0f);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-5.0f,  5.0f,  5.0f);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 5.0f,  5.0f,  5.0f);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 5.0f,  5.0f, -5.0f);	// Top Right Of The Texture and Quad
	// Bottom Face
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-5.0f, -5.0f, -5.0f);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 5.0f, -5.0f, -5.0f);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 5.0f, -5.0f,  5.0f);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-5.0f, -5.0f,  5.0f);	// Bottom Right Of The Texture and Quad
	glEnd();

	glBegin(GL_QUADS);
	// Right face
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 5.0f, -5.0f, -5.0f);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 5.0f,  5.0f, -5.0f);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 5.0f,  5.0f,  5.0f);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 5.0f, -5.0f,  5.0f);	// Bottom Left Of The Texture and Quad
	// Left Face
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-5.0f, -5.0f, -5.0f);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-5.0f, -5.0f,  5.0f);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-5.0f,  5.0f,  5.0f);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-5.0f,  5.0f, -5.0f);	// Top Left Of The Texture and Quad
	glEnd();
}
void View3D::DrawSphere(double r, int lats, int longs)
{
	glBindTexture(GL_TEXTURE_2D, 0 );
	int i, j;
	for(i = 0; i <= lats; i++) {
		double lat0 = PI * (-0.5 + (double) (i - 1) / lats);
		double z0  = r*sin(lat0);
		double zr0 =  r*cos(lat0);

		double lat1 = PI * (-0.5 + (double) i / lats);
		double z1 = r*sin(lat1);
		double zr1 = r*cos(lat1);

		glBegin(GL_QUAD_STRIP);
		for(j = 0; j <= longs; j++) {
			double lng = 2 * M_PI * (double) (j - 1) / longs;
			double x = cos(lng);
			double y = sin(lng);

			glNormal3f(x * zr0, y * zr0, z0);
			glVertex3f(x * zr0, y * zr0, z0);
			glNormal3f(x * zr1, y * zr1, z1);
			glVertex3f(x * zr1, y * zr1, z1);
		}
		glEnd();
	}
}
void View3D::DrawTorus(double InnerRadius, double OuterRadius)
{
	glBindTexture(GL_TEXTURE_2D, 0 );

	double TubeRadius = (OuterRadius - InnerRadius)/2;

	int numc = 100, numt = 100;
	double TWOPI = 2.0 * PI;
	for (int i = 0; i < numc; i++) 
	{
		glBegin(GL_QUAD_STRIP);
		for (int j = 0; j <= numt; j++) 
		{
			for (int k = 1; k >= 0; k--) 
			{

				double s = (i + k) % numc + 0.5;
				double t = j % numt;

				double x = (3 + 2 * cos(s * TWOPI / numc)) * cos(t * TWOPI / numt);
				double y = (3 + 2 * cos(s * TWOPI / numc)) * sin(t * TWOPI / numt);
				double z = 2 * sin(s * TWOPI / numc);

				glVertex3d(2 * x, 2 * y, 2 * z);
			}
		}
		glEnd();
	}
}
void View3D::DrawWorld()
{
	double HalfEnvX = this->m_EnvDimensions.EnvDim.x/2.0;
	double HalfEnvY = this->m_EnvDimensions.EnvDim.y/2.0;
	double HalfEnvZ = this->m_EnvDimensions.EnvDim.z/2.0;

	glBindTexture(GL_TEXTURE_2D, this->m_Image[3].getID()[2] ); // Sky
	glBegin(GL_QUADS);
	// Front Face
	glTexCoord2f(0.75f, 1.0f);  glVertex3f(-HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(0.25f, 1.0f);  glVertex3f( HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(0.25f, 0.75f); glVertex3f( HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.75f, 0.75f); glVertex3f(-HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Top Left Of The Texture and Quad
	glEnd();

	glBegin(GL_QUADS);
	// Back Face
	glTexCoord2f(0.75f, 0.0f);  glVertex3f(-HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(0.75f, 0.25f); glVertex3f(-HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.25f, 0.25f); glVertex3f( HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.25f, 0.0f);  glVertex3f( HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glEnd();

	glBegin(GL_QUADS);
	// Top Face
	glTexCoord2f(0.75f, 0.25f); glVertex3f(-HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.25f, 0.25f); glVertex3f(-HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(0.75f, 0.25f); glVertex3f( HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(0.75f, 0.75f); glVertex3f( HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Right Of The Texture and Quad
	glEnd();

	glBindTexture(GL_TEXTURE_2D, this->m_Image[2].getID()[2] ); // Sand
	glBegin(GL_QUADS);
	// Bottom Face
	glTexCoord2f(10.0f, 10.0f); glVertex3f(-HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 10.0f);  glVertex3f( HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f);   glVertex3f( HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(10.0f, 0.0f);  glVertex3f(-HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glEnd();

	glBindTexture(GL_TEXTURE_2D, this->m_Image[3].getID()[2] ); // Sky
	glBegin(GL_QUADS);
	// Right face
	glTexCoord2f(1.0f, 0.75f);  glVertex3f( HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(0.75f, 0.75f); glVertex3f( HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.75f, 0.25f); glVertex3f( HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Top Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.25f);  glVertex3f( HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glEnd();

	glBegin(GL_QUADS);
	// Left Face
	glTexCoord2f(0.0f, 0.75f);  glVertex3f(-HalfEnvX, -HalfEnvY, -HalfEnvZ);	// Bottom Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.25f);  glVertex3f(-HalfEnvX, -HalfEnvY,  HalfEnvZ);	// Bottom Right Of The Texture and Quad
	glTexCoord2f(0.25f, 0.25f); glVertex3f(-HalfEnvX,  HalfEnvY,  HalfEnvZ);	// Top Right Of The Texture and Quad
	glTexCoord2f(0.25f, 0.75f); glVertex3f(-HalfEnvX,  HalfEnvY, -HalfEnvZ);	// Top Left Of The Texture and Quad
	glEnd();
}
void View3D::OnSize(wxSizeEvent& event)
{
	// this is also necessary to update the context on some platforms
	//	wxGLCanvas::OnSize(event);
	// Reset the OpenGL view aspect
	ResetProjectionMode();
	Refresh();
	event.Skip();
}
void View3D::OnEraseBackground(wxEraseEvent& WXUNUSED(event))
{
	// Do nothing, to avoid flashing on MSW
}
void View3D::InitGL()
{
	wxGLCanvas::SetCurrent(*this->m_context);
	glEnable(GL_TEXTURE_2D);						// Enable Texture Mapping ( NEW )
	glShadeModel(GL_SMOOTH);						// Enable Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f);					// Black Background
	glClearDepth(1.0f);							// Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);						// Enables Depth Testing
	glDepthFunc(GL_LEQUAL);							// The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);			// Really Nice Perspective Calculations

	//glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);				// Setup The Ambient Light
	//glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);				// Setup The Diffuse Light
	//glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);			// Position The Light
	//glEnable(GL_LIGHT1);

	glColor4f(1.0f,1.0f,1.0f,0.5f);			// Full Brightness, 50% Alpha ( NEW )
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);		// Blending Function For Translucency Based On Source Alpha Value ( NEW )

	glEnable(GL_LIGHTING);

	glEnable(GL_NORMALIZE);

	this->m_Image = new GLTexture[4]();
	this->m_Image[0].load("textures/NeHe.bmp");
	this->m_Image[1].load("textures/Crate.bmp");
	this->m_Image[2].load("textures/Sand_6_Diffuse.png");
	this->m_Image[3].load("textures/SkyBox-Clouds-Wispy-Noon.png");

	this->ResetProjectionMode();
	this->m_Init = true;
}
void View3D::GLCleanup()
{
#ifndef NEURONSCAPE_VIEWER
	delete [] this->m_Image;
#endif
}
void View3D::ResetProjectionMode()
{
	int w, h;

	if (this->m_FullScreen)
	{
		GetClientSize(&w, &h);
	}
	else
	{
		SetClientSize(320,240);
		w = 320;
		h = 240;
	}
	//#ifndef __WXMOTIF__
	//	if ( GetContext() )
	//#endif
	//	{
	//		wxGLCanvas::SetCurrent(*this->m_context);
	glViewport(0, 0, (GLint) w, (GLint) h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	if (this->m_BirdsEyeView == true)
	{
		gluPerspective(53.13f, (GLfloat)w/h, 1.0, 1500.0);
	}
	else
	{
		gluPerspective(45.0f, (GLfloat)w/h, 1.0, 1500.0);
	}

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	//	}
}
void View3D::KBEvent(wxKeyEvent &event)
{
	event.ResumePropagation(2);
	event.Skip();
}
void View3D::StepForward(double Amount)
{
	double CorrectedXYRotation = -this->m_CameraTheta + (PI/2.0);
	this->m_CameraView.x += Amount*sin(CorrectedXYRotation);
	this->m_CameraView.y += Amount*cos(CorrectedXYRotation);
}
void View3D::StepBackward(double Amount)
{
	double CorrectedXYRotation = -this->m_CameraTheta + (PI/2.0);
	this->m_CameraView.x -= Amount*sin(CorrectedXYRotation);
	this->m_CameraView.y -= Amount*cos(CorrectedXYRotation);
}
void View3D::TurnLeft(double Amount)
{
	this->m_CameraTheta -= Amount;
}
void View3D::TurnRight(double Amount)
{
	this->m_CameraTheta += Amount;
}
BEGIN_EVENT_TABLE(View3D, wxGLCanvas)
	EVT_SIZE(View3D::OnSize)
	EVT_PAINT(View3D::OnPaint)
	EVT_ERASE_BACKGROUND(View3D::OnEraseBackground)
	EVT_KEY_DOWN(View3D::KBEvent)
	EVT_KEY_UP(View3D::KBEvent)
	END_EVENT_TABLE()