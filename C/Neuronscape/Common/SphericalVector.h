#ifndef SPHERICALVECTOR_H
#define SPHERICALVECTOR_H

#include "../Common/Definitions.h"
#include "CartesianVector.h"
#include <numeric>
#include <cmath>
#include <stdint.h>

class CartesianVector;

class SphericalVector
{
public:
	SphericalVector() : Mag(0.0), Theta(0.0), Phi(0.0) {}
	SphericalVector(double _Mag, double _Theta, double _Phi) : Mag(_Mag), Theta(_Theta), Phi(_Phi) {}
	SphericalVector(CartesianVector const &rhs);
	// Assignment Operator
	SphericalVector &operator=(SphericalVector const &rhs);
	SphericalVector &operator=(CartesianVector const &rhs);
	// Vector Addition & Subtraction
	SphericalVector &operator+=(SphericalVector const &rhs);
	SphericalVector &operator-=(SphericalVector const &rhs);
	// Scalar Multiplication & Division
	SphericalVector &operator*=(double const &rhs);
	SphericalVector &operator/=(double const &rhs);
	// Vector Addition & Subtraction
	SphericalVector operator+(SphericalVector const &rhs) const;
	SphericalVector operator-(SphericalVector const &rhs) const;
	// Scalar Multiplication & Division
	SphericalVector operator*(double const &rhs) const;
	SphericalVector operator/(double const &rhs) const;
	
	double Mag;
	double Theta;
	double Phi;
};

SphericalVector operator*(double const lhs, SphericalVector const &rhs);

#endif