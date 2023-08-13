#ifndef RETINATHREAD_H
#define RETINATHREAD_H

#include <wx/wx.h>
#include <vector>
#include <map>
#include <stdint.h>

#include "../Common/Definitions.h"
#include "../Common/Utilities.h"
#include "../Common/NetworkStackClient.h"
#include "../Common/DBRecord_ClientObject.h"
#include "../Common/DB_ClientObject.h"
#include "../Common/CartesianVector.h"
#include "../Common/SphericalVector.h"

#include "EventID.h"





class Pixel_Point
{
public:
	Pixel_Point() : x(0), y(0) {}
	Pixel_Point(uint32_t xx, unsigned yy) : x(xx), y(yy) {}
	Pixel_Point &operator=(Pixel_Point const &rhs)
	{
		this->x = rhs.x;
		this->y = rhs.y;
	}
	bool operator==(Pixel_Point const &rhs) const
	{
		return ((this->x == rhs.x)&&(this->y == rhs.y));
	}
	bool operator!=(Pixel_Point const &rhs) const
	{
		return !(*this == rhs);
	}
	bool operator<(Pixel_Point const &rhs) const
	{
		return ((this->x < rhs.x)&&(this->y< rhs.y));
	}
	uint32_t x;
	uint32_t y;
};

class Pixel_Neuron
{
public:
    uint32_t R;
	uint32_t G;
	uint32_t B;
	uint32_t BW;
};

typedef std::pair   <Pixel_Point, Pixel_Neuron> Pixel_Pair;
typedef std::vector <Pixel_Pair> Pixel_Vector;
typedef std::map    <Pixel_Point, Pixel_Neuron> Pixel_Map;

class RetinaThread : public wxThread
{
public:
	// Default Constructor
	RetinaThread(wxFrame * Parent);
	// Destructor
	~RetinaThread();

	void Initialize(wxSize RetinaSize, bool GreyScale = false);
	void OnNewImageEvent(unsigned char *PixelData, uint32_t Width, uint32_t Height);
	wxBitmap *FetchRetinaMap();
	void LockMutex();
	void UnlockMutex();
	inline unsigned GetLength()
	{
		return (this->m_RetinaSize.x * this->m_RetinaSize.y);
	}
	unsigned char *GetRedData();
	unsigned char *GetGreenData();
	unsigned char *GetBlueData();

	void FetchRetinaData(unsigned char *Red, unsigned char *Green, unsigned char *Blue, unsigned &Length);
	void Exit();

private:
	virtual wxThread::ExitCode Entry();
	void GeneratePreview(unsigned Pixelx, unsigned Pixely, unsigned char *Red, unsigned char *Green, unsigned char *Blue);

private:
	wxFrame * m_Parent;
	bool m_Exit;
	wxMutex     *m_Condition_Mutex;
	wxCondition *m_Condition;

	wxMutex *m_DataMutex;
	unsigned char *m_PixelData;
	uint32_t m_PixelDataWidth;
	uint32_t m_PixelDataHeight;

	wxSize m_RetinaSize;
	bool m_GreyScale;

	wxImage m_RetinaImagePreview;

	unsigned char *m_Red;
	unsigned char *m_Green;
	unsigned char *m_Blue;

	wxMutex *m_RetinaImagePrevMutex;

	Pixel_Map m_PixelNeuronMap;
};

#endif
