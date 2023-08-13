function [S, V, F] = f_massspring( X, U, timestep, k )
%F_MASSSPRING Summary of this function goes here
%   Detailed explanation goes here

F = -1.0 * k * X;
A = F/Mass;
V = U + A*timestep;

S = (U * timestep) + (A*timestep*timestep)/2.0;

end

