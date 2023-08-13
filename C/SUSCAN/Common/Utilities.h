#ifndef UTILITIES_H
#define UTILITIES_H

unsigned short uchar2ushort(unsigned char* Bytes);
unsigned short uchar2ushort(unsigned char LoByte, unsigned char HiByte);
unsigned char *ushort2uchar(unsigned short Number);
unsigned char *ulong2uchar(unsigned long Number);
unsigned char *float2uchar(float Number);
unsigned char *double2uchar(double Number);
float uchar2float(unsigned char* Bytes);
double uchar2double(unsigned char* Bytes);

unsigned char Bit2Byte(bool *Bits);
unsigned char Bit2Byte(bool B0, bool B1, bool B2, bool B3, bool B4, bool B5, bool B6, bool B7);
bool *Byte2Bits(unsigned char Byte);

#endif;