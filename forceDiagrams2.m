function [V,u] = forceDiagrams2(x,P,L,V,u,n)

%Basic Reactions Calcs
Ra=P;


%Generating Sheer Array
V=V+Ra*ones(1,n);
m=ceil(x*n/L);
for i=m:n
    V(m)=V(m)-P;
    m=m+1;
end

%Generating Deflection Array

A1 = P/6;
A2 = -P*x/2;
B1 = -P*x^2/2;
B2 = P*x^3/6;

m=ceil(x*n/L);      
for i=1:m   %left elastic curve
    u(i)=u(i)+(A1*(i*L/n)^3+A2*(i*L/n)^2);     
end

for i=m+1:n   %right elastic curve
    u(i)=u(i)+(B1*(i*L/n)+B2);
end