#ifndef CARTESIANVECTOR_H
#define CARTESIANVECTOR_H

#include "../Common/Definitions.h"
#include "SphericalVector.h"
#include <numeric>
#include <cmath>
#include <stdint.h>

class SphericalVector;

class CartesianVector
{
public: 
	CartesianVector() : x(0.0), y(0.0), z(0.0) {}
	CartesianVector(double xx, double yy, double zz) : x(xx), y(yy), z(zz) {}
	CartesianVector(SphericalVector const &rhs);
	// Assignment Operator
	CartesianVector &operator=(CartesianVector const &rhs);
	CartesianVector &operator=(SphericalVector const &rhs);
	// Vector Addition & Subtraction
	CartesianVector &operator+=(CartesianVector const &rhs);
	CartesianVector &operator-=(CartesianVector const &rhs);
	// Scalar Multiplication & Division
	CartesianVector &operator*=(double const &rhs);
	
	CartesianVector &operator/=(double const &rhs);
	// Vector Addition & Subtraction
	CartesianVector operator+(CartesianVector const &rhs) const;
	CartesianVector operator-(CartesianVector const &rhs) const;
	// Scalar Multiplication & Division
	CartesianVector operator*(double const &rhs) const;
	CartesianVector operator/(double const &rhs) const;
	CartesianVector UnitVector() const;
	CartesianVector Abs() const;

	// Friend Functions
	// Scalar Multiplication & Division
	friend CartesianVector operator*(double const lhs, CartesianVector const &rhs);

	// Comparison Operator
	friend bool operator== (CartesianVector const &lhs, CartesianVector const &rhs);
	friend bool operator!= (CartesianVector const &lhs, CartesianVector const &rhs);
	//friend bool operator== (CartesianVector const &lhs, double const &rhs);

	double x;
	double y;
	double z;
};



#endif