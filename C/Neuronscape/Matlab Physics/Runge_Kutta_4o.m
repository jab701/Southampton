function [ t, x, v] = runge_kutta_4o( timestep, time, initialposition)

% Spring Constant (k)
k = 20.0;
% Mass (m) in Kg
m = 1.0;

numsteps = time/timestep;

h = timestep;
t = zeros(1,numsteps);
x = zeros(1,numsteps);
v = zeros(1,numsteps);

t(1) = 0.0;
x(1) = initialposition;
v(1) = 0.0;

for i = 2:numsteps
    t(i) = t(i-1) + h;
    
    %%% K1 Calculations f(t, x)
    V_k1 = h*F_ma(x(i-1),k,m);
    
    %%% K2 Calculations f(t + 1/2*h, x + 1/2*k1)
    V_k2 = h*F_ma(x(i-1) + (1/2)*V_k1,k,m);
    
    %%% K3 Calculations f(t + 1/2*h, x + 1/2*k2)
    V_k3 = h*F_ma(x(i-1) + (1/2)*V_k2,k,m);    
    
    %%% K4 Calculations f(t + h, x + k3)
    V_k4 = h*F_ma(x(i-1) + (1/2)*V_k3,k,m);    
    
    v(i) = v(i-1) + (1/6)*(V_k1 + 2*V_k2 + 2*V_k3 + V_k4);
   
    x(i) = x(i-1) + v(i)*h;
    
end;
end

function [A] = F_ma(X, k, m)
 F = -1.0*k*X;
 A = F/m;
end

