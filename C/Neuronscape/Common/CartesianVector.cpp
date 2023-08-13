#include "CartesianVector.h"

CartesianVector::CartesianVector(SphericalVector const &rhs)
{
	*this = rhs;
}
// Assignment Operator
CartesianVector &CartesianVector::operator=(CartesianVector const &rhs)
{
	if (this != &rhs)
	{
		this->x = rhs.x;
		this->y = rhs.y;
		this->z = rhs.z;
	}
	return *this;
}
CartesianVector &CartesianVector::operator=(SphericalVector const &rhs)
{
	this->x = rhs.Mag*std::cos(rhs.Theta)*std::sin(rhs.Phi);
	this->y = rhs.Mag*std::sin(rhs.Theta)*std::sin(rhs.Phi);
	this->z = rhs.Mag*std::cos(rhs.Phi);

	return *this;
}
// Vector Addition & Subtraction
CartesianVector &CartesianVector::operator+=(CartesianVector const &rhs)
{
	this->x = this->x + rhs.x;
	this->y = this->y + rhs.y;
	this->z = this->z + rhs.z;

	return *this;
}
CartesianVector &CartesianVector::operator-=(CartesianVector const &rhs)
{
	this->x = this->x - rhs.x;
	this->y = this->y - rhs.y;
	this->z = this->z - rhs.z;

	return *this;
}
// Scalar Multiplication & Division
CartesianVector &CartesianVector::operator*=(double const &rhs)
{
	this->x = this->x * rhs;
	this->y = this->y * rhs;
	this->z = this->z * rhs;

	return *this;
}
CartesianVector &CartesianVector::operator/=(double const &rhs)
{
	this->x = this->x / rhs;
	this->y = this->y / rhs;
	this->z = this->z / rhs;

	return *this;
}
// Vector Addition & Subtraction
CartesianVector CartesianVector::operator+(CartesianVector const &rhs) const
{
	CartesianVector Result = *this;
	Result += rhs;
	return Result;
}
CartesianVector CartesianVector::operator-(CartesianVector const &rhs) const
{
	CartesianVector Result = *this;
	Result -= rhs;
	return Result;
}
// Scalar Multiplication & Division
CartesianVector CartesianVector::operator*(double const &rhs) const
{
	CartesianVector Result = *this;
	Result *= rhs;
	return Result;
}
CartesianVector CartesianVector::operator/(double const &rhs) const
{
	CartesianVector Result = *this;
	Result /= rhs;
	return Result;
}
CartesianVector CartesianVector::UnitVector() const
{
	CartesianVector Result = *this;

	if (Result.x != 0.0)
	{
		if (Result.x < 0.0)
		{
			Result.x = -1.0;
		}
		else
		{
			Result.x = +1.0;
		}
	}
	if (Result.y != 0.0)
	{
		if (Result.y < 0.0)
		{
			Result.y = -1.0;
		}
		else
		{
			Result.y = +1.0;
		}
	}
	if (Result.z != 0.0)
	{
		if (Result.z < 0.0)
		{
			Result.z = -1.0;
		}
		else
		{
			Result.z = +1.0;
		}
	}

	return Result;
}
CartesianVector CartesianVector::Abs() const
{
	CartesianVector Result = *this;
	Result.x = std::abs(Result.x);
	Result.y = std::abs(Result.y);
	Result.z = std::abs(Result.z);
	return Result;
}
CartesianVector operator*(double const lhs, CartesianVector const &rhs)
{
	CartesianVector Result = rhs;

	Result *= lhs;

	return Result;
}
// Friend Functions
// Comparison Operators
bool operator== (CartesianVector const &lhs, CartesianVector const &rhs)
{
	bool x = false; 
	bool y = false;
	bool z = false;

	if (lhs.x == rhs.x)
	{
		x = true;
	}

	if (lhs.y == rhs.y)
	{
		y = true;
	}

	if (lhs.z == rhs.z)
	{
		z = true;
	}

	return (x && y && z);
}
bool operator!= (CartesianVector const &lhs, CartesianVector const &rhs)
{
	return !(lhs == rhs);
}