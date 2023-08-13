#include "ViewerFrame.h"
/***** ViewerFrame Constructor *****/
ViewerFrame::ViewerFrame(wxWindow *Parent, const wxString& title)	
	: wxFrame(Parent, ID_VIEWERFRAME, title, wxDefaultPosition, wxSize(1024,768), wxDEFAULT_FRAME_STYLE,wxT("ViewerFrame"))
{
	this->Frame3DView = NULL;
	this->m_ForceTimer = NULL;

	this->m_EnvDimensions.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_ObjectDb = NULL;

	this->SelectedObject = 0;

	this->CreateStatusBar(2);

	// Center the frame on the screen
	this->Center();

	this->LayoutControls();
	this->DrawForceDiagram();

	this->Show();

	this->Frame3DView->InitGL();

	wxDisplay Display;
	int RefreshRate = Display.GetCurrentMode().refresh;

	if (RefreshRate == 0) // If display refresh rate is unknown(0) then set it to 50Hz
	{
		RefreshRate = 50;
	}

	double RefreshPeriod = 1.0/ (double) RefreshRate;

	this->m_RefreshTimer = new wxTimer(this,ID_VIEWERFRAME_REDRAW_TIMER);
	this->m_RefreshTimer->Start((int) RefreshPeriod,false);
}
ViewerFrame::~ViewerFrame()
{
	this->m_EnvDimensions.EnvDim = CartesianVector(0.0,0.0,0.0);

	this->m_ObjectDb = NULL;
}
/***** Layout controls *****/
void ViewerFrame::LayoutControls()
{
	wxBoxSizer* TopLevelSizer = new wxBoxSizer(wxHORIZONTAL);

	this->SetSizer(TopLevelSizer);

	this->LayoutSidePanelControls(TopLevelSizer);
	TopLevelSizer->AddSpacer(10);
	this->LayoutViewPane(TopLevelSizer);

	this->SetAutoLayout(true);
}
void ViewerFrame::LayoutSidePanelControls(wxBoxSizer *TopLevelSizer)
{
	wxBoxSizer *ControlsSizer = new wxBoxSizer(wxVERTICAL);

	wxString Choices[3] = {"Normal","Birds Eye","Animal POV"};
	wxStaticText *ViewSelectText = new wxStaticText(this,wxID_ANY,wxT("View Select"),wxDefaultPosition,wxDefaultSize,0,wxT("ViewSelectText"));

	wxComboBox *ViewSelect = new wxComboBox(this,ID_VIEWSELECT,wxT("Normal"),wxDefaultPosition,wxDefaultSize,3,Choices,0,wxDefaultValidator,wxT("ViewCombo"));

	wxStaticText *ObjectSelectText = new wxStaticText(this,wxID_ANY,wxT("Object List"),wxDefaultPosition,wxDefaultSize,0,wxT("ObjectSelectText"));

	wxComboBox *ObjectSelect = new wxComboBox(this,ID_OBJECTSELECT,wxT("0: None Selected"),wxDefaultPosition,wxDefaultSize,0,0,0,wxDefaultValidator,wxT("ObjectCombo"));

	wxNotebook *NoteBook = new wxNotebook(this,ID_SIDEPANEL,wxDefaultPosition,wxDefaultSize,wxNB_LEFT,wxT("SIDENOTEBOOK"));

	wxPanel *ObjectInfoPane = this->LayoutObjectInfoPane(NoteBook);

	wxPanel *ObjectForcePane  = this->LayoutObjectForcePane(NoteBook);

	wxPanel *AddInanimatePane = this->LayoutAddInanimateObjectPane(NoteBook);

	NoteBook->AddPage(ObjectInfoPane,wxT("Object Info"),true,0);

	NoteBook->AddPage(ObjectForcePane,wxT("Apply Force"),false,0);

	NoteBook->AddPage(AddInanimatePane,wxT("Add Inanimate"),false,0);

	TopLevelSizer->AddSpacer(5);
	TopLevelSizer->Add(ControlsSizer,0,wxEXPAND);
	ControlsSizer->AddSpacer(5);
	ControlsSizer->Add(ViewSelectText,0,wxEXPAND);
	ControlsSizer->AddSpacer(5);
	ControlsSizer->Add(ViewSelect,0,wxEXPAND);
	ControlsSizer->AddSpacer(5);
	ControlsSizer->Add(ObjectSelectText,0,wxEXPAND);
	ControlsSizer->AddSpacer(5);
	ControlsSizer->Add(ObjectSelect,0,wxEXPAND);
	ControlsSizer->AddSpacer(5);
	ControlsSizer->Add(NoteBook,1,wxEXPAND);

}
wxPanel *ViewerFrame::LayoutObjectInfoPane(wxNotebook *Notebook)
{
	wxPanel *ControlsPanel = new wxPanel(Notebook,wxID_ANY,wxDefaultPosition,wxDefaultSize,2621440L,wxT("ObjectInfoPane"));

	wxStaticText *ObjectPosition = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Position = (0,0,0)"),wxDefaultPosition,wxDefaultSize,0,wxT("ObjectPosition"));
	wxStaticText *ObjectVelocity = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Velocity = 0 m/s"),wxDefaultPosition,wxDefaultSize,0,wxT("ObjectVelocity"));

	wxBoxSizer *ControlPanelSizer = new wxBoxSizer(wxVERTICAL);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ObjectPosition,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ObjectVelocity,0,wxEXPAND);	
	ControlsPanel->SetSizer(ControlPanelSizer,true);

	return ControlsPanel;
}
wxPanel *ViewerFrame::LayoutObjectForcePane(wxNotebook *Notebook)
{
	wxPanel *ControlsPanel = new wxPanel(Notebook,wxID_ANY,wxDefaultPosition,wxDefaultSize,2621440L,wxT("ObjectForcePane"));

	wxStaticText *ForceMagText = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Force Magnitude (N)"),wxDefaultPosition,wxDefaultSize,0,wxT("ForceMagStatic"));
	wxSpinCtrlDouble *ForceMagCtrl = new wxSpinCtrlDouble(ControlsPanel,wxID_ANY,wxT("0"),wxDefaultPosition,wxDefaultSize,wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP,0.0,10000.0,0.0,0.1,wxT("ForceMagCtrl"));

	wxStaticText *ForceDirText = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Force Direction (Theta)"),wxDefaultPosition,wxDefaultSize,0,wxT("ForceDirText"));
	wxSpinCtrlDouble *ForceDirCtrl = new wxSpinCtrlDouble(ControlsPanel,wxID_ANY,wxT("0"),wxDefaultPosition,wxDefaultSize,wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP,0.0,359.9,0.0,0.1,wxT("ForceDirCtrl"));

	wxStaticText *ForceEleText = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Force Elevation (Phi)"),wxDefaultPosition,wxDefaultSize,0,wxT("ForceEleText"));
	wxSpinCtrlDouble *ForceEleCtrl = new wxSpinCtrlDouble(ControlsPanel,wxID_ANY,wxT("90"),wxDefaultPosition,wxDefaultSize,wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP,0.0,180.0,0.0,0.1,wxT("ForceEleCtrl"));

	wxStaticText *ForceDurText = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Force Duration (ms)"),wxDefaultPosition,wxDefaultSize,0,wxT("ForceDurText"));
	wxSpinCtrl   *ForceDurCtrl = new wxSpinCtrl(ControlsPanel,wxID_ANY,wxT("10"),wxDefaultPosition,wxDefaultSize,wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP,10,10000,10,wxT("ForceDurCtrl"));

	wxBitmap EmptyBitmap;

	wxStaticBitmap *ForceDiagram = new wxStaticBitmap(ControlsPanel,wxID_ANY,EmptyBitmap,wxDefaultPosition,wxDefaultSize,0,wxT("ForceDiagram"));
	wxButton       *ApplyForceButton = new wxButton(ControlsPanel,ID_FORCEBUTTON,wxT("Apply Force"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("ApplyForceButton"));

	wxBoxSizer *ControlPanelSizer = new wxBoxSizer(wxVERTICAL);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceMagText,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceMagCtrl,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceDirText,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceDirCtrl,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceEleText,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceEleCtrl,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceDurText,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceDurCtrl,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ForceDiagram,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ApplyForceButton,0,wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlsPanel->SetSizer(ControlPanelSizer,true);

	return ControlsPanel;
}
wxPanel *ViewerFrame::LayoutAddInanimateObjectPane(wxNotebook *Notebook)
{
	wxPanel *ControlsPanel = new wxPanel(Notebook,wxID_ANY,wxDefaultPosition,wxDefaultSize,2621440L,wxT("InanimateObjectPane"));

	wxStaticText *ST_InanimatePos   = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Position Selection"), wxDefaultPosition, wxDefaultSize, 0, "");
	wxStaticText *ST_InanimatePosX  = new wxStaticText(ControlsPanel,wxID_ANY,wxT("X"), wxDefaultPosition, wxDefaultSize, 0, "");
	wxStaticText *ST_InanimatePosY  = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Y"), wxDefaultPosition, wxDefaultSize, 0, "");
	wxStaticText *ST_InanimatePosZ  = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Z"), wxDefaultPosition, wxDefaultSize, 0, "");
	wxStaticText *ST_InanimateRed	= new wxStaticText(ControlsPanel,wxID_ANY,wxT("Red"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_InanimateRed"));
	wxStaticText *ST_InanimateGreen = new wxStaticText(ControlsPanel,wxID_ANY,wxT("Green"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_InanimateGreen"));
	wxStaticText *ST_InanimateBlue	= new wxStaticText(ControlsPanel,wxID_ANY,wxT("Blue"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_InanimateBlue"));
	wxStaticText *ST_InanimateLum	= new wxStaticText(ControlsPanel,wxID_ANY,wxT("Luminosity"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_InanimateLum"));
	wxStaticText *ST_InanimateEnergy	= new wxStaticText(ControlsPanel,wxID_ANY,wxT("Energy"),wxDefaultPosition,wxDefaultSize,0,wxT("ST_InanimateEnergy"));

	wxSpinCtrl *SC_InanimateRed   = new wxSpinCtrl(ControlsPanel, wxID_ANY, wxT("128"), wxDefaultPosition, wxDefaultSize,  wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP, 0, 255, 128, wxT("SC_InanimateRed"));
	wxSpinCtrl *SC_InanimateGreen = new wxSpinCtrl(ControlsPanel, wxID_ANY, wxT("128"), wxDefaultPosition, wxDefaultSize,  wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP, 0, 255, 128, wxT("SC_InanimateGreen"));
	wxSpinCtrl *SC_InanimateBlue  = new wxSpinCtrl(ControlsPanel, wxID_ANY, wxT("128"), wxDefaultPosition, wxDefaultSize,  wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP, 0, 255, 128, wxT("SC_InanimateBlue"));
	wxSpinCtrl *SC_InanimateLum   = new wxSpinCtrl(ControlsPanel, wxID_ANY, wxT("128"), wxDefaultPosition, wxDefaultSize,  wxSP_VERTICAL|wxSP_ARROW_KEYS|wxSP_WRAP, 0, 255, 128, wxT("SC_InanimateLum"));

	wxTextCtrl *TC_InanimateStartX = new wxTextCtrl(ControlsPanel,wxID_ANY,wxT("500"),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_Inanimate_X"));
	wxTextCtrl *TC_InanimateStartY = new wxTextCtrl(ControlsPanel,wxID_ANY,wxT("500"),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_Inanimate_Y"));
	wxTextCtrl *TC_InanimateStartZ = new wxTextCtrl(ControlsPanel,wxID_ANY,wxT("10"),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_Inanimate_Z"));

	wxTextCtrl *TC_InanimateEnergy = new wxTextCtrl(ControlsPanel,wxID_ANY,wxT("5000.0"),wxDefaultPosition,wxSize((20*this->GetCharWidth()),wxDefaultSize.GetY()),0,wxDefaultValidator,wxT("TC_InanimateEnergy"));

	wxRadioButton *RB_Random = new wxRadioButton(ControlsPanel, wxID_ANY, wxT("Random Position"), wxDefaultPosition, wxDefaultSize, wxRB_GROUP, wxDefaultValidator, wxT("RB_Random"));
	wxRadioButton *RB_Custom = new wxRadioButton(ControlsPanel, wxID_ANY, wxT("Custom Position"), wxDefaultPosition, wxDefaultSize, 0, wxDefaultValidator, wxT("RB_Custom"));

	wxCheckBox *CB_InanimateFixed = new wxCheckBox(ControlsPanel, wxID_ANY, wxT("Fixed"), wxDefaultPosition, wxDefaultSize, 0, wxDefaultValidator, wxT("CB_InanimateFixed"));
	wxCheckBox *CB_InanimateEdible = new wxCheckBox(ControlsPanel, wxID_ANY, wxT("Edible"), wxDefaultPosition, wxDefaultSize, 0, wxDefaultValidator, wxT("CB_InanimateEdible"));
	wxCheckBox *CB_InanimateNoCollide = new wxCheckBox(ControlsPanel, wxID_ANY, wxT("No Collisions"), wxDefaultPosition, wxDefaultSize, 0, wxDefaultValidator, wxT("CB_InanimateNoCollide"));

	wxButton   *B_AddInanimate = new wxButton(ControlsPanel,ID_ADDINANIMATE,wxT("Add Inanimate Object"),wxDefaultPosition,wxDefaultSize,0,wxDefaultValidator,wxT("ApplyForceButton"));

	wxBoxSizer *ControlPanelSizer = new wxBoxSizer(wxVERTICAL);

	ControlPanelSizer->Add(ST_InanimatePos, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(RB_Random, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(RB_Custom, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimatePosX, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(TC_InanimateStartX, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimatePosY, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(TC_InanimateStartY, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimatePosZ, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(TC_InanimateStartZ, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimateRed, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(SC_InanimateRed, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimateGreen, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(SC_InanimateGreen, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimateBlue, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(SC_InanimateBlue, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimateLum, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(SC_InanimateLum, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(ST_InanimateEnergy, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(TC_InanimateEnergy, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(CB_InanimateFixed, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(CB_InanimateEdible, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(CB_InanimateNoCollide, 0, wxEXPAND);
	ControlPanelSizer->AddSpacer(5);
	ControlPanelSizer->Add(B_AddInanimate, 0, wxEXPAND);

	ControlsPanel->SetSizer(ControlPanelSizer,true);

	return ControlsPanel;
}
void ViewerFrame::LayoutViewPane(wxBoxSizer *TopLevelSizer)
{
	int args[] = {WX_GL_RGBA, WX_GL_DOUBLEBUFFER, WX_GL_DEPTH_SIZE, 16, 0};

	this->Frame3DView = new View3D(this, wxString("View3D"), args);
	this->Frame3DView->SetViewer(true);

	TopLevelSizer->Add(this->Frame3DView,1,wxEXPAND);
}
void ViewerFrame::DrawForceDiagram()
{
	int BitmapWidth = 128;
	int BitmapHeight = 128;

	wxBitmap Bitmap(BitmapWidth,BitmapHeight,-1);
	wxMemoryDC Bitmap_dc(Bitmap);

	// First clear background to white
	Bitmap_dc.SetPen(*wxWHITE_PEN);
	Bitmap_dc.SetBrush(*wxWHITE_BRUSH);
	Bitmap_dc.DrawRectangle(0,0,BitmapWidth,BitmapHeight);

	Bitmap_dc.SetPen(*wxBLACK_PEN);
	Bitmap_dc.DrawCircle(BitmapWidth/2,BitmapHeight/2,(BitmapWidth/2 - 10));

	Bitmap_dc.DrawLine(BitmapWidth/2,0,BitmapWidth/2,BitmapHeight);
	Bitmap_dc.DrawLine(0,BitmapHeight/2,BitmapWidth,BitmapHeight/2);
	wxStaticBitmap *StaticBitmap = (wxStaticBitmap*) this->FindWindowByName(wxT("ForceDiagram"),this);
	StaticBitmap->SetBitmap(Bitmap);

}
/***** Set Arguements *****/
bool ViewerFrame::SetArguements(CartesianVector EnvDimensions, NetworkStackClient *NetworkStack, DB_ClientObject *ObjectDatabase)
{
	if ((EnvDimensions.x <= 0.0)||(EnvDimensions.y <= 0.0)||(EnvDimensions.z <= 0.0))
	{
		return false;
	}

	if (ObjectDatabase == NULL)
	{
		return false;
	}

	if (NetworkStack == NULL)
	{
		return false;
	}

	this->m_EnvDimensions.EnvDim = EnvDimensions;

	this->m_NetworkStack = NetworkStack;

	this->m_ObjectDb = ObjectDatabase;

	if (this->Frame3DView != NULL)
	{
		this->Frame3DView->SetArguements(EnvDimensions, ObjectDatabase);
	}


	return true;
}
/***** Drawing Context Functions *****/
void ViewerFrame::OnPaint(wxPaintEvent &event)
{
	this->OnObjectDatabaseChange();
	event.Skip();
}
void ViewerFrame::OnRedrawTimer(wxTimerEvent &event)
{
	wxWindow::Refresh();
	wxWindow::Update();
}
void ViewerFrame::OnKeyDownEvent(wxKeyEvent &event)
{

}
/***** GUI Function Callback Functions *****/
void ViewerFrame::OnClose(wxCloseEvent &event)
{
	if (this->m_RefreshTimer != NULL)
	{
		this->m_RefreshTimer->Stop();
		delete this->m_RefreshTimer;
		this->m_RefreshTimer = NULL;
	}

	View3D *Frame3DView = (View3D*) this->FindWindowByName("View3D");

	if (Frame3DView != NULL)
	{
		Frame3DView->GLCleanup();
		delete Frame3DView;
	}
	event.Skip();
}
/***** On ObjectDatabase Change *****/
void ViewerFrame::OnObjectDatabaseChange()
{
	static uint16_t NumberObjects = 0;
	uint16_t PrevNumberObjects = NumberObjects;
	bool SetSelection = false;

	std::vector<DBRecord_ClientObject> Records;
	this->m_ObjectDb->FetchAll(Records);
	NumberObjects = Records.size();
	wxComboBox *ObjectComboBox = (wxComboBox*) this->FindWindowByName("ObjectCombo");

	if (NumberObjects != PrevNumberObjects)
	{
		ObjectComboBox->Freeze();

		ObjectComboBox->Clear();

		ObjectComboBox->Append(wxT("0: None Selected"));

		for(unsigned int i = 0; i < Records.size(); i++)
		{
			if ((Records[i].Flags & OBJFLAG_INANIMATE) == 0)
			{
				wxString ObjectID;
				ObjectID.Printf("%d:",Records[i].ID);
				int SelectID = ObjectComboBox->Append(ObjectID);

				if (Records[i].ID == this->SelectedObject) 
				{
					SetSelection = true;
					ObjectComboBox->Select(SelectID);
				}
			}
		}

		if (SetSelection == false)
		{
			ObjectComboBox->Select(0);
		}

		ObjectComboBox->Thaw();
	}
}
/***** On Object Combo Selected *****/
void ViewerFrame::OnObjectComboSelect(wxCommandEvent &event)
{
	wxComboBox *ObjectComboBox = (wxComboBox*) this->FindWindowByName("ObjectCombo");

	int Selection = event.GetSelection();

	wxString SelectionText = ObjectComboBox->GetString(Selection);

	int SelectionTextPos = SelectionText.Find(':',false);

	wxString ObjectIDStr = SelectionText.Mid(0,SelectionTextPos);

	unsigned long ObjectID_ulong = 0;

	ObjectIDStr.ToULong(&ObjectID_ulong,10);

	this->SelectedObject = (uint32_t) ObjectID_ulong;

	this->Frame3DView->SetObjectID(this->SelectedObject);
}
/***** On View Combo Selected *****/
void ViewerFrame::OnViewComboSelect(wxCommandEvent &event)
{
	if (this->Frame3DView == NULL)
	{
		return;
	}

	int Selection = event.GetSelection();

	switch(Selection)
	{
	case 0: // Normal View
		this->Frame3DView->SetViewer(true, false);
		break;
	case 1: // Birds Eye View
		this->Frame3DView->SetViewer(true, true);
		break;
	case 2: // Object POV
		this->Frame3DView->SetViewer(false, false);
		break;
	default:
		break;
	}
}
/***** On Add Inanimate Object *****/
void ViewerFrame::OnAddInanimateObject(wxCommandEvent &event)
{
	wxSpinCtrl *SC_Red		= (wxSpinCtrl*) this->FindWindowByName("SC_InanimateRed");
	wxSpinCtrl *SC_Green	= (wxSpinCtrl*) this->FindWindowByName("SC_InanimateGreen");
	wxSpinCtrl *SC_Blue		= (wxSpinCtrl*) this->FindWindowByName("SC_InanimateBlue");
	wxSpinCtrl *SC_Lum		= (wxSpinCtrl*) this->FindWindowByName("SC_InanimateLum");

	wxTextCtrl *TC_X	= (wxTextCtrl*) this->FindWindowByName("TC_Inanimate_X");
	wxTextCtrl *TC_Y	= (wxTextCtrl*) this->FindWindowByName("TC_Inanimate_Y");
	wxTextCtrl *TC_Z	= (wxTextCtrl*) this->FindWindowByName("TC_Inanimate_Z");
	wxTextCtrl *TC_ENERGY = (wxTextCtrl*) this->FindWindowByName("TC_InanimateEnergy");

	wxRadioButton *RB_Random = (wxRadioButton*) this->FindWindowByName("RB_Random");
	wxRadioButton *RB_Custom = (wxRadioButton*) this->FindWindowByName("RB_Custom");

	wxCheckBox *CB_Fixed		= (wxCheckBox*) this->FindWindowByName("CB_InanimateFixed");
	wxCheckBox *CB_Edible		= (wxCheckBox*) this->FindWindowByName("CB_InanimateEdible");
	wxCheckBox *CB_NoCollide	= (wxCheckBox*) this->FindWindowByName("CB_InanimateNoCollide");

	unsigned char Red	= SC_Red->GetValue();
	unsigned char Green = SC_Green->GetValue();
	unsigned char Blue	= SC_Blue->GetValue();
	unsigned char Lum	= SC_Lum->GetValue();

	wxString Energy_Str = TC_ENERGY->GetValue();

	double X;
	double Y;
	double Z;
	double Energy;

	if (RB_Random->GetValue() == true)
	{
		X = -1.0;
		Y = -1.0;
		Z = -1.0;
	}
	else
	{
		wxString X_Str = TC_X->GetValue();
		wxString Y_Str = TC_Y->GetValue();
		wxString Z_Str = TC_Z->GetValue();


		if (!X_Str.ToDouble(&X))
		{
			return;
		}

		if (!Y_Str.ToDouble(&Y))
		{
			return;
		}

		if (!Z_Str.ToDouble(&Z))
		{
			return;
		}
	}

	if (!Energy_Str.ToDouble(&Energy))
	{
		return;
	}

	uint16_t FLAGS = 0;

	if (CB_Fixed->GetValue())
	{
		FLAGS += OBJFLAG_FIXED;
	}

	if (CB_Edible->GetValue())
	{
		FLAGS += OBJFLAG_EDIBLE;
	}

	if (CB_NoCollide->GetValue())
	{
		FLAGS += OBJFLAG_NOCOLLIDE;
	}

	this->m_NetworkStack->SendAddInanimateObj(X,Y,Z,Red,Green,Blue,Lum,Energy,FLAGS);
}
/***** On Apply Force Click *****/
void ViewerFrame::OnApplyForceClick(wxCommandEvent &event)
{
	wxComboBox *ObjectComboBox = (wxComboBox*) this->FindWindowByName("ObjectCombo");
	wxSpinCtrlDouble *ForceMagCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceMagCtrl");
	wxSpinCtrlDouble *ForceDirCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceDirCtrl");
	wxSpinCtrlDouble *ForceEleCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceEleCtrl");
	wxSpinCtrl *ForceDurCtrl = (wxSpinCtrl*) this->FindWindowByName("ForceDurCtrl");
	wxButton *ForceButton = (wxButton*) this->FindWindowByName("ApplyForceButton");

	if (this->SelectedObject == 0)
	{
		wxLogError("No Object Selected");
		return;
	}

	double ForceMag = ForceMagCtrl->GetValue();
	double ForceDir = ForceDirCtrl->GetValue();
	double ForceEle = ForceEleCtrl->GetValue();
	int    ForceDur = ForceDurCtrl->GetValue();

	ForceDir = (ForceDir/180.0)*PI;
	ForceEle = (ForceEle/180.0)*PI;

	this->m_ForceTimer = new wxTimer(this,ID_VIEWERFRAME_FORCE_TIMER);

	CartesianVector ExternalForce(SphericalVector(ForceMag,ForceDir,ForceEle));

	this->m_NetworkStack->SendObjectForces(this->SelectedObject,ExternalForce);

	this->m_ForceTimer->Start(ForceDur,true);

	ObjectComboBox->Disable();
	ForceMagCtrl->Disable();
	ForceDirCtrl->Disable();
	ForceEleCtrl->Disable();
	ForceDurCtrl->Disable();
	ForceButton->Disable();

}
void ViewerFrame::OnForceTimerExpired(wxTimerEvent &event)
{
	wxComboBox *ObjectComboBox = (wxComboBox*) this->FindWindowByName("ObjectCombo");
	wxSpinCtrlDouble *ForceMagCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceMagCtrl");
	wxSpinCtrlDouble *ForceDirCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceDirCtrl");
	wxSpinCtrlDouble *ForceEleCtrl = (wxSpinCtrlDouble*) this->FindWindowByName("ForceEleCtrl");
	wxSpinCtrl *ForceDurCtrl = (wxSpinCtrl*) this->FindWindowByName("ForceDurCtrl");
	wxButton *ForceButton = (wxButton*) this->FindWindowByName("ApplyForceButton");

	this->m_NetworkStack->SendObjectForces(this->SelectedObject,CartesianVector(0.0,0.0,0.0));

	delete this->m_ForceTimer;
	this->m_ForceTimer = NULL;

	ObjectComboBox->Enable();
	ForceMagCtrl->Enable();
	ForceDirCtrl->Enable();
	ForceEleCtrl->Enable();
	ForceDurCtrl->Enable();
	ForceButton->Enable();
}

void ViewerFrame::KeyboardDown(wxKeyEvent &event)
{
	if (this->Frame3DView == NULL)
	{
		return;
	}

	int keycode = event.GetKeyCode();

	bool NewKeyDown = this->m_KeyboardMap.SetDown(keycode);

	double DegreesToTurn = 1.0;
	double RadsToTurn = ToRadians(1.0);

	switch(keycode)
	{
	case 'W' :
		this->Frame3DView->StepForward(0.75);
		break;

	case 'S' :
		this->Frame3DView->StepBackward(0.75);
		break;

	case 'A':

		this->Frame3DView->TurnLeft(RadsToTurn);
		break;

	case 'D':
		this->Frame3DView->TurnRight(RadsToTurn);
		break;

	default:
		event.Skip();
		break;
	}
}
void ViewerFrame::KeyboardUp(wxKeyEvent &event)
{
	int keycode = event.GetKeyCode();

	bool NewKeyUp = this->m_KeyboardMap.SetUp(keycode);
}
/*******************************/
/** Event Table For ViewerFrame **/
/*******************************/
BEGIN_EVENT_TABLE(ViewerFrame, wxFrame)
	EVT_PAINT(ViewerFrame::OnPaint)
	EVT_CLOSE(ViewerFrame::OnClose)
	EVT_BUTTON(ID_FORCEBUTTON,ViewerFrame::OnApplyForceClick)
	EVT_BUTTON(ID_ADDINANIMATE, ViewerFrame::OnAddInanimateObject)
	EVT_TIMER(ID_VIEWERFRAME_REDRAW_TIMER,ViewerFrame::OnRedrawTimer)
	EVT_TIMER(ID_VIEWERFRAME_FORCE_TIMER,ViewerFrame::OnForceTimerExpired)
	EVT_KEY_DOWN(ViewerFrame::KeyboardDown)
	EVT_KEY_UP(ViewerFrame::KeyboardUp)
	EVT_COMBOBOX(ID_OBJECTSELECT, ViewerFrame::OnObjectComboSelect)
	EVT_COMBOBOX(ID_VIEWSELECT, ViewerFrame::OnViewComboSelect)
	END_EVENT_TABLE()