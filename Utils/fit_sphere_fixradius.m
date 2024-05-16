function [x0,y0,z0] = fit_sphere_fixradius(xyz,r)
%FIT_SPHERE_FIXRADIUS 此处显示有关此函数的摘要
%   此处显示详细说明
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);
A = [ -2*x, -2*y , -2*z , ones(size(x))];
b = r^2-(x.*x+y.*y+z.*z);
u = lsqminnorm(A, b);
x0 = u(1);
y0 = u(2);
z0 = u(3);
end

