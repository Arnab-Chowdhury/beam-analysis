function [V,u] = forceDiagrams(x,P,L,V,u,n)

%Basic Reactions Calcs
Rb=P*x/L;
Ra=P-Rb;

%Generating Sheer Array
V=V+Ra*ones(1,n);
V(n)=V(n)+Rb;
m=ceil(x*n/L);
for i=m:n
    V(m)=V(m)-P;
    m=m+1;
end

%Generating Deflection Array

A1 = P*(L-x)/(6*L);
A2 = x*(x-2*L);
B1 = P*x/2;
B2 = -P*x/(6*L);
B3 = -P*x*L^2/3;
B4 = P*x*(x^2+2*L^2)/6;

m=ceil(x*n/L);      
for i=1:m   %left elastic curve
    u(i)=u(i)+(A1*(i*L/n)^3+A1*A2*(i*L/n));     
end

for i=m+1:n   %right elastic curve
    u(i)=u(i)+(B1*(i*L/n)^2+B2*(i*L/n)^3+B3+B4-B4*(i*L/n)/L);
end