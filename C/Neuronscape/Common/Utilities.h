#ifndef UTILITIES_H
#define UTILITIES_H

#include <wx/wx.h>
#include <vector>
#include <cstdlib>
#include <stdint.h>

#include "CartesianVector.h"
#include "SphericalVector.h"

uint16_t uchar2ushort(std::vector<unsigned char> Bytes);
uint32_t uchar2ulong(std::vector<unsigned char> Bytes);
float uchar2float(std::vector<unsigned char> Bytes);
double uchar2double(std::vector<unsigned char> Bytes);

std::vector<unsigned char> ushort2uchar(uint16_t Number);
std::vector<unsigned char> ulong2uchar(uint32_t Number);
std::vector<unsigned char> float2uchar(float Number);
std::vector<unsigned char> double2uchar(double Number);

bool IsSystemLittleEndian();

uint16_t Swap_Endian(uint16_t uint16_t);
uint32_t Swap_Endian(uint32_t uint32_t);
float Swap_Endian(float Number);
double Swap_Endian(double Number);

bool IntersectLines(double X1, double X2, double Y1, double Y2);
bool IntersectSpheres(CartesianVector Obj1, double Obj1Radius, CartesianVector Obj2, double Obj2Radius);
void RandomlyGeneratePosition(CartesianVector Limits, CartesianVector &RandomPosition);
void FixedToFloatingPoint(long Fixed, unsigned char FractionBits, float &Float);
void FloatingToFixedPoint(float Float, unsigned char FractionalLength, long &Fixed);

void IPStringToBytes(wxString IPStr, std::vector<unsigned char> &Bytes);

inline double ToDegrees(double Radians)
{
	return (Radians / PI) * 180.0;
}
inline double ToRadians(double Degrees)
{
	return (Degrees/180.0) * PI;
}
std::vector<unsigned char> SubVector(std::vector<unsigned char> Vector, unsigned Begin);
std::vector<unsigned char> SubVector(std::vector<unsigned char> Vector, unsigned Begin, unsigned NumberOfElements);

union usi2c_t 
{
	unsigned char Bytes[sizeof(uint16_t)];
	uint16_t short_;
};
union uli2c_t 
{
	unsigned char Bytes[sizeof(uint32_t)];
	uint32_t long_;
};
union f2c_t 
{
	unsigned char Bytes[sizeof(float)];
	float float_;
};
union lf2c_t 
{
	unsigned char Bytes[sizeof(double)];
	double double_;
};
bool SameSign(double x, double y);
double GetSign(double x);

//void VectorCopy(std::vector<unsigned char> A, unsigned Offset_A, std::vector<unsigned char> B, unsigned Offset_B, unsigned Length)
//{
//
//}

#endif
