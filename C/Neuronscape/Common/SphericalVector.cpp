#include "SphericalVector.h"

SphericalVector::SphericalVector(CartesianVector const &rhs)
{
	*this = rhs;
}
// Assignment Operator
SphericalVector &SphericalVector::operator=(SphericalVector const &rhs)
{
	if (this != &rhs)
	{
		this->Mag = rhs.Mag;
		this->Theta = rhs.Theta;
		this->Phi = rhs.Phi;
	}
	return *this;
}
SphericalVector &SphericalVector::operator=(CartesianVector const &rhs)
{
	double S_temp = std::sqrt(std::pow(rhs.x,2.0) + std::pow(rhs.y,2.0));
	this->Mag = std::sqrt(std::pow(rhs.x,2.0) + std::pow(rhs.y,2.0) + std::pow(rhs.z,2.0));

	if (this->Mag == 0.0)
	{
		this->Phi = std::acos(0.0);
	}
	else
	{
		this->Phi = std::acos(rhs.z/this->Mag);
	}

	if (S_temp == 0.0)
	{
		this->Theta = std::asin(0.0);
	}
	else
	{
		if (rhs.x < 0) 
		{
			this->Theta = 3.1415926535897932384626433832795 - std::asin(rhs.y/S_temp);
		}
		else
		{
			this->Theta = std::asin(rhs.y/S_temp);
		}
	}

	return *this;
}
// Vector Addition & Subtraction
SphericalVector &SphericalVector::operator+=(SphericalVector const &rhs)
{
	CartesianVector Vector1 = *this;
	CartesianVector Vector2 = rhs;

	Vector1 += Vector2;

	*this = Vector1;

	return *this;
}
SphericalVector &SphericalVector::operator-=(SphericalVector const &rhs)
{
	CartesianVector Vector1 = *this;
	CartesianVector Vector2 = rhs;

	Vector1 -= Vector2;

	*this = Vector1;

	return *this;
}
// Scalar Multiplication & Division
SphericalVector &SphericalVector::operator*=(double const &rhs)
{
	this->Mag = this->Mag * rhs;

	return *this;
}
SphericalVector &SphericalVector::operator/=(double const &rhs)
{
	this->Mag = this->Mag / rhs;

	return *this;
}
// Vector Addition & Subtraction
SphericalVector SphericalVector::operator+(SphericalVector const &rhs) const
{
	SphericalVector Result = *this;

	Result += rhs;

	return Result;
}
SphericalVector SphericalVector::operator-(SphericalVector const &rhs) const
{
	SphericalVector Result = *this;

	Result -= rhs;

	return Result;
}
// Scalar Multiplication & Division
SphericalVector SphericalVector::operator*(double const &rhs) const
{
	SphericalVector Result = *this;

	Result *= rhs;

	return Result;
}
SphericalVector SphericalVector::operator/(double const &rhs) const
{
	SphericalVector Result = *this;

	Result /= rhs;

	return Result;
}

SphericalVector operator*(double const lhs, SphericalVector const &rhs)
{
	SphericalVector Result = rhs;

	Result *= lhs;

	return Result;
}