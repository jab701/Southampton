#include "RetinaThread.h"

// Default Constructor
RetinaThread::RetinaThread(wxFrame *Parent) : wxThread(wxTHREAD_JOINABLE)
{
	this->m_Parent = Parent;
	this->m_Exit = false;
	this->m_Condition_Mutex = new wxMutex();
	this->m_Condition = new wxCondition(*this->m_Condition_Mutex);

	this->m_DataMutex = new wxMutex();

	this->m_RetinaSize   = wxSize(0,0);
	this->m_PixelData = NULL;
	this->m_RetinaImagePreview.Create(320,240,true);
	this->m_RetinaImagePrevMutex = new wxMutex();

	this->m_Red = NULL;
	this->m_Green = NULL;
	this->m_Blue = NULL;
}
// Destructor
RetinaThread::~RetinaThread()
{

	this->m_PixelData = NULL;
	this->m_Exit = false;
	this->m_RetinaSize   = wxSize(0,0);

	delete this->m_DataMutex;
	this->m_DataMutex = NULL;

	delete this->m_Condition;
	this->m_Condition = NULL;

	delete this->m_Condition_Mutex;
	this->m_Condition_Mutex = NULL;

	delete this->m_RetinaImagePrevMutex;
	this->m_RetinaImagePrevMutex = NULL;
}
void RetinaThread::Initialize(wxSize RetinaSize, bool GreyScale)
{
	if (!this->IsRunning()) // if the thread is runnign we cant change the values
	{
		this->m_RetinaSize = RetinaSize;
		this->m_GreyScale = GreyScale;		
	}
}
void RetinaThread::OnNewImageEvent(unsigned char *PixelData, uint32_t Width, uint32_t Height)
{
	if (wxThread::IsMain())
	{
		if (PixelData == NULL)
		{
			//this->m_PixelData = NULL;
			return;
		}

		wxMutexLocker lock(*this->m_DataMutex);

		if (this->m_PixelData != NULL)
		{
			delete this->m_PixelData;
			this->m_PixelData = NULL;
		}

		this->m_PixelData = PixelData;
		this->m_PixelDataWidth = Width;
		this->m_PixelDataHeight = Height;

		wxMutexLocker lock2(*this->m_Condition_Mutex);
		this->m_Condition->Broadcast();
	}
}
wxBitmap *RetinaThread::FetchRetinaMap()
{
	if (!wxThread::IsMain())
	{
		return NULL;
	}

	this->m_RetinaImagePrevMutex->Lock();
	wxBitmap *Bitmap = new wxBitmap(this->m_RetinaImagePreview,24);
	this->m_RetinaImagePrevMutex->Unlock();
	return Bitmap;
}
void RetinaThread::LockMutex()
{
	this->m_DataMutex->Lock();
}
void RetinaThread::UnlockMutex()
{
	this->m_DataMutex->Unlock();
}

unsigned char *RetinaThread::GetRedData()
{
	unsigned Length = this->GetLength();

	unsigned char* Red = new unsigned char[Length];

	for (unsigned i = 0; i < Length; i++)
	{
		Red[i] = this->m_Red[i];
	}	

	return Red;
}
unsigned char *RetinaThread::GetGreenData()
{
	unsigned Length = this->GetLength();

	unsigned char* Green = new unsigned char[Length];

	for (unsigned i = 0; i < Length; i++)
	{
		Green[i] = this->m_Green[i];
	}	

	return Green;
}
unsigned char *RetinaThread::GetBlueData()
{
	unsigned Length = this->GetLength();

	unsigned char* Blue = new unsigned char[Length];

	for (unsigned i = 0; i < Length; i++)
	{
		Blue[i] = this->m_Blue[i];
	}	

	return Blue;
}
void RetinaThread::Exit()
{
	if (wxThread::IsMain())
	{
		wxMutexLocker lock(*this->m_DataMutex);
		wxMutexLocker lock2(*this->m_Condition_Mutex);
		this->m_Exit = true;
		this->m_Condition->Broadcast();
	}
}
wxThread::ExitCode RetinaThread::Entry()
{
	wxImage RetinaImage;
	wxImage *SubImages = new wxImage[this->m_RetinaSize.x*this->m_RetinaSize.y];

	while(!this->TestDestroy())
	{
		this->m_DataMutex->Lock();

		if (this->m_PixelData != NULL)
		{			
			if (this->m_Red != NULL)
			{
				delete [] this->m_Red;
				this->m_Red = NULL;
			}

			if (this->m_Green != NULL)
			{
				delete [] this->m_Green;
				this->m_Green = NULL;
			}

			if (this->m_Blue != NULL)
			{
				delete [] this->m_Blue;
				this->m_Blue = NULL;
			}

			//*******************************
			// TODO: Processing Section Here!
			//*******************************
			RetinaImage.Create(wxSize(this->m_PixelDataWidth,this->m_PixelDataHeight),this->m_PixelData,true);

			RetinaImage = RetinaImage.Mirror(false);
			unsigned Sizex = this->m_PixelDataWidth/this->m_RetinaSize.x;
			unsigned Sizey = this->m_PixelDataHeight/this->m_RetinaSize.y;

			for (unsigned i = 0; i < (unsigned)this->m_RetinaSize.y; i++)
			{
				for (unsigned j = 0; j < (unsigned)this->m_RetinaSize.x; j++)
				{
					unsigned Base = (i * this->m_RetinaSize.x) + j;
					wxRect Bounds = wxRect(j*Sizex,i*Sizey,Sizex,Sizey);
					SubImages[Base] = RetinaImage.GetSubImage(Bounds);
				}
			}

			this->m_Red = new unsigned char[this->m_RetinaSize.x*this->m_RetinaSize.y];
			this->m_Green = new unsigned char[this->m_RetinaSize.x*this->m_RetinaSize.y];
			this->m_Blue =  new unsigned char[this->m_RetinaSize.x*this->m_RetinaSize.y];

			for (unsigned i = 0; i < (unsigned)(this->m_RetinaSize.x*this->m_RetinaSize.y); i++)
			{
				wxSize Size = SubImages[i].GetSize();

				double Red = 0.0;
				double Green = 0.0;
				double Blue = 0.0;

				for (unsigned x = 0; x < (unsigned)Size.x; x++)
				{
					for (unsigned y = 0; y < (unsigned)Size.y; y++)
					{
						Red   += SubImages[i].GetRed(x,y);
						Green += SubImages[i].GetGreen(x,y);
						Blue  += SubImages[i].GetBlue(x,y);
					}
				}

				this->m_Red[i] = Red/(Size.x*Size.y);
				this->m_Green[i] = Green/(Size.x*Size.y);
				this->m_Blue[i]  = Blue/(Size.x*Size.y);

				if (this->m_GreyScale)
				{
					double Pixel = (0.299*this->m_Red[i]) + (0.587*this->m_Green[i]) + (0.114*this->m_Blue[i]);
					this->m_Red[i] = (unsigned char)Pixel;
					this->m_Green[i] = (unsigned char)Pixel;
					this->m_Blue[i] = (unsigned char)Pixel;
				}
			}

			this->GeneratePreview(this->m_RetinaSize.x,this->m_RetinaSize.y,this->m_Red,this->m_Green,this->m_Blue);

			//this->m_SpinNetStack->SendVisualData(this->m_Red, this->m_Green, this->m_Blue, (this->m_RetinaSize.x*this->m_RetinaSize.y), this->m_GreyScale);
			
			wxCommandEvent event (wxEVT_COMMAND_TEXT_UPDATED, ID_RETINA_UPDATE);
			this->m_Parent->GetEventHandler()->AddPendingEvent(event);
			
			//this->m_SpinNetStack->Temp2(this->m_RetinaSize.x,this->m_RetinaSize.y,RetinaPixels);


			//**********************************
			// END TODO: End Processing Section!
			//**********************************
		}

		this->m_DataMutex->Unlock();

		if (this->m_Exit == false)
		{
			// Executed at the end of the loop
			this->m_Condition_Mutex->Lock();
			this->m_Condition->Wait();
		}
	}

	if (this->m_Red != NULL)
	{
		delete [] this->m_Red;
		this->m_Red = NULL;
	}

	if (this->m_Green != NULL)
	{
		delete [] this->m_Green;
		this->m_Green = NULL;
	}

	if (this->m_Blue != NULL)
	{
		delete [] this->m_Blue;
		this->m_Blue = NULL;
	}

	if (SubImages != NULL)
	{
		delete [] SubImages;
		SubImages = NULL;
	}

	if (this->m_PixelData != NULL)
	{
		delete this->m_PixelData;
		this->m_PixelData = NULL;
	}

	return (wxThread::ExitCode) 0;
}
void RetinaThread::GeneratePreview(unsigned Pixelx, unsigned Pixely, unsigned char *Red, unsigned char *Green, unsigned char *Blue)
{
	unsigned char *Pixels = new unsigned char[Pixelx*Pixely*3];

	for (unsigned i=0; i < (Pixelx*Pixely); i++)
	{
		unsigned base = i*3;
		Pixels[base] = Red[i];
		Pixels[base+1] = Green[i];
		Pixels[base+2] = Blue[i];
	}

	this->m_RetinaImagePrevMutex->Lock();
	this->m_RetinaImagePreview.Create(wxSize(Pixelx,Pixely),Pixels,false);
	this->m_RetinaImagePreview.Rescale(320,240);
	this->m_RetinaImagePrevMutex->Unlock();
}