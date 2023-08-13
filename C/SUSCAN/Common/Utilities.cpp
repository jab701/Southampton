#include "Utilities.h"

unsigned short uchar2ushort(unsigned char* Bytes)
{
	return(uchar2ushort(Bytes[0],Bytes[1]));
}

unsigned short uchar2ushort(unsigned char LoByte, unsigned char HiByte)
{
	union c2s_t 
	{
		unsigned char Bytes[2];
		unsigned short int16;
	} c2s;

	c2s.Bytes[0] = LoByte;
	c2s.Bytes[1] = HiByte;

	return(c2s.int16);	

}
unsigned char *ushort2uchar(unsigned short Number)
{
	union s2c_t 
	{
		unsigned char Bytes[2];
		unsigned short int16;
	} s2c;

	s2c.int16 = Number;

	return(s2c.Bytes);

}

unsigned char *ulong2uchar(unsigned long Number)
{
	union l2c_t 
	{
		unsigned char Bytes[4];
		unsigned long int32;
	} l2c;

	l2c.int32 = Number;

	return(l2c.Bytes);

}
unsigned char *float2uchar(float Number)
{
	union f2c_t 
	{
		unsigned char Bytes[4];
		float f;
	} f2c;

	f2c.f = Number;

	return(f2c.Bytes);

}
unsigned char *double2uchar(double Number)
{
	union f2c_t 
	{
		unsigned char Bytes[8];
		double lf;
	} lf2c;

	lf2c.lf = Number;

	return(lf2c.Bytes);

}

float uchar2float(unsigned char* Bytes)
{
	int i;
	union f2c_t 
	{
		unsigned char Bytes[4];
		float f;
	} f2c;

	for (i=0;i<4;i++)
	{
		f2c.Bytes[i] = Bytes[i];
	}


	return(f2c.f);
}
double uchar2double(unsigned char* Bytes)
{
	int i;
	union f2c_t 
	{
		unsigned char Bytes[8];
		double lf;
	} lf2c;

	for (i=0;i<8;i++)
	{
		lf2c.Bytes[i] = Bytes[i];
	}
	return(lf2c.lf);
}

unsigned char Bit2Byte(bool *Bits)
{
	union
	{
		unsigned char Byte;
		bool Bit[8];
	} Data;

	for (unsigned char i = 0; i < 8; i++)
	{
		Data.Bit[i] = Bits[i];
	}

	return Data.Byte;
}

unsigned char Bit2Byte(bool B0, bool B1, bool B2, bool B3, bool B4, bool B5, bool B6, bool B7)
{
	union
	{
		unsigned char Byte;
		bool Bit[8];
	} Data;

	Data.Bit[0] = B0;
	Data.Bit[1] = B1;
	Data.Bit[2] = B2;
	Data.Bit[3] = B3;
	Data.Bit[4] = B4;
	Data.Bit[5] = B5;
	Data.Bit[6] = B6;
	Data.Bit[7] = B7;

	return Data.Byte;
}

bool *Byte2Bits(unsigned char Byte)
{
	union
	{
		unsigned char Byte;
		bool Bit[8];
	} Data;

	Data.Byte = Byte;

	return Data.Bit;
}