#include "Utilities.h"

uint16_t uchar2ushort(std::vector<unsigned char> Bytes)
{
	usi2c_t c2s;

	c2s.Bytes[0] = Bytes[0];
	c2s.Bytes[1] = Bytes[1];

	return(c2s.short_);	
}
uint32_t uchar2ulong(std::vector<unsigned char> Bytes)
{
	uli2c_t l2c;

	l2c.Bytes[0] = Bytes[0];
	l2c.Bytes[1] = Bytes[1];
	l2c.Bytes[2] = Bytes[2];
	l2c.Bytes[3] = Bytes[3];

	return l2c.long_;
}
float uchar2float(std::vector<unsigned char> Bytes)
{
	f2c_t f2c;

	f2c.Bytes[0] = Bytes[0];
	f2c.Bytes[1] = Bytes[1];
	f2c.Bytes[2] = Bytes[2];
	f2c.Bytes[3] = Bytes[3];

	return(f2c.float_);
}
double uchar2double(std::vector<unsigned char> Bytes)
{
	lf2c_t lf2c;

	lf2c.Bytes[0] = Bytes[0];
	lf2c.Bytes[1] = Bytes[1];
	lf2c.Bytes[2] = Bytes[2];
	lf2c.Bytes[3] = Bytes[3];
	lf2c.Bytes[4] = Bytes[4];
	lf2c.Bytes[5] = Bytes[5];
	lf2c.Bytes[6] = Bytes[6];
	lf2c.Bytes[7] = Bytes[7];

	return(lf2c.double_);
}

std::vector<unsigned char> ushort2uchar(uint16_t Number)
{
	usi2c_t s2c;
	std::vector<unsigned char> Bytes;

	s2c.short_ = Number;

	Bytes.push_back(s2c.Bytes[0]);
	Bytes.push_back(s2c.Bytes[1]);

	return Bytes;
}
std::vector<unsigned char> ulong2uchar(uint32_t Number)
{
	uli2c_t l2c;
	std::vector<unsigned char> Bytes;

	l2c.long_ = Number;

	Bytes.push_back(l2c.Bytes[0]);
	Bytes.push_back(l2c.Bytes[1]);
	Bytes.push_back(l2c.Bytes[2]);
	Bytes.push_back(l2c.Bytes[3]);

	return Bytes;
}
std::vector<unsigned char> float2uchar(float Number)
{
	f2c_t f2c;
	std::vector<unsigned char> Bytes;

	f2c.float_ = Number;

	Bytes.push_back(f2c.Bytes[0]);
	Bytes.push_back(f2c.Bytes[1]);
	Bytes.push_back(f2c.Bytes[2]);
	Bytes.push_back(f2c.Bytes[3]);

	return Bytes;
}
std::vector<unsigned char> double2uchar(double Number)
{
	lf2c_t lf2c;
	std::vector<unsigned char> Bytes;

	lf2c.double_ = Number;

	Bytes.push_back(lf2c.Bytes[0]);
	Bytes.push_back(lf2c.Bytes[1]);
	Bytes.push_back(lf2c.Bytes[2]);
	Bytes.push_back(lf2c.Bytes[3]);
	Bytes.push_back(lf2c.Bytes[4]);
	Bytes.push_back(lf2c.Bytes[5]);
	Bytes.push_back(lf2c.Bytes[6]);
	Bytes.push_back(lf2c.Bytes[7]);

	return Bytes;
}

bool IsSystemLittleEndian()
{
	union LongnChar
	{
		int32_t li;
		char c[4];
	};
	
	LongnChar Test;
	Test.li = 0x12345678;

	if (Test.c[0] == 0x78)
	{
		return true;
	}
	else
	{
		return false;
	}
}

uint16_t Swap_Endian(uint16_t Number)
{
	usi2c_t In, Out;
	int Length = sizeof(uint16_t);

	In.short_ = Number;

	for (int i = 0; i < Length; i++)
	{
		Out.Bytes[Length-1-i] = In.Bytes[i];
	}

	return Out.short_;
}
uint32_t Swap_Endian(uint32_t Number)
{
	uli2c_t In, Out;
	int Length = sizeof(uint32_t);

	In.long_ = Number;

	for (int i = 0; i < Length; i++)
	{
		Out.Bytes[Length-1-i] = In.Bytes[i];
	}

	return Out.long_;
}
float Swap_Endian(float Number)
{
	f2c_t In, Out;
	int Length = sizeof(float);

	In.float_ = Number;

	for (int i = 0; i < Length; i++)
	{
		Out.Bytes[Length-1-i] = In.Bytes[i];
	}

	return Out.float_;
}
double Swap_Endian(double Number)
{
	lf2c_t In, Out;
	int Length = sizeof(double);

	In.double_ = Number;

	for (int i = 0; i < Length; i++)
	{
		Out.Bytes[Length-1-i] = In.Bytes[i];
	}

	return Out.double_;
}

bool IntersectLines(double X1, double X2, double Y1, double Y2)
{
	if (X1 > X2)
	{
		double Temp1 = X1;
		X1 = X2;
		X2 = Temp1;
	}

	if (Y1 > Y2)
	{
		double Temp2 = Y1;
		Y1 = Y2;
		Y2 = Temp2;
	}

	if (X1 < Y1)
	{
		if (Y1 < X2)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		if (X1 < Y2)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
bool IntersectSpheres(CartesianVector Obj1, double Obj1Radius, CartesianVector Obj2, double Obj2Radius)
{
	CartesianVector Resultant_C = Obj1 - Obj2;

	SphericalVector Resultant_S = SphericalVector(Resultant_C);

	double TotalCollisionDistance = Obj1Radius + Obj2Radius;

	if (TotalCollisionDistance > Resultant_S.Mag) // Radius 1 + Radius2 > Distance between objects = Collision!
	{
		return true;
	}
	else
	{
		return false;
	}
}
void RandomlyGeneratePosition(CartesianVector Limits, CartesianVector &RandomPosition)
{
	int RandomNumber1 = std::rand();
	int RandomNumber2 = std::rand();

	double X = (double)RandomNumber1/(double)RAND_MAX;
	double Y = (double)RandomNumber2/(double)RAND_MAX;
	double Z = 0.0;

	X = Limits.x * X;
	Y = Limits.y * Y;

	RandomPosition = CartesianVector(X,Y,Z);
}

void FixedToFloatingPoint(long Fixed, unsigned char FractionLength, float &Float)
{
	Float = (float)Fixed / (float)FractionLength;
}
void FloatingToFixedPoint(float Float, unsigned char FractionalLength, long &Fixed)
{
	Fixed = (long)(Float * FractionalLength);
}
void IPStringToBytes(wxString IPStr, std::vector<unsigned char> &Bytes)
{
	for (int i = 0; i < 4; i++)
	{
		unsigned long Temp;
		unsigned char Byte;
		int DotPosition = IPStr.Find('.');
		IPStr.Mid(0, DotPosition).ToULong(&Temp, 10);

		Byte = (unsigned char) Temp;

		Bytes.push_back(Byte);
		IPStr = IPStr.Mid(DotPosition+1, IPStr.Length());
	}
}
std::vector<unsigned char> SubVector(std::vector<unsigned char> Vector, unsigned Begin)
{
	return SubVector(Vector,Begin,(Vector.size()-Begin));
}
std::vector<unsigned char> SubVector(std::vector<unsigned char> Vector, uint32_t Begin, uint32_t NumberOfElements)
{
	std::vector<unsigned char> NewVector;

	if (Begin + NumberOfElements > Vector.size())
	{
		NumberOfElements = Vector.size() - Begin;
	}

	for (uint32_t i = 0; i < NumberOfElements; i++)
	{
		NewVector.push_back(Vector[Begin+i]);
	}
	return NewVector;
}
bool SameSign(double x, double y)
{
            return ((x >= 0) ^ (y < 0));
}
double GetSign(double x)
{
	if (x > 0.0)
	{
		return 1.0;
	}
	else if (x < 0)
	{
		return -1.0;
	}
	else
	{
		return 0.0;
	}
}



