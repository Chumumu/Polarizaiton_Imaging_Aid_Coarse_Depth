function [ theta_s ] = rho_specular( rho,n )
%RHO_S Compute zenith angle from degree of polarisation for specular pix
%   There is no closed form inversion for rho_s so this functions uses a
%   look up table and interpolates

theta = 0:0.01:pi/2;

rho_s = (2.*sin(theta).^2.*cos(theta).*sqrt(n.^2-sin(theta).^2))./(n.^2-sin(theta).^2-n.^2.*sin(theta).^2+2.*sin(theta).^4);

%figure; plot(theta,rho_s)
maxpos = find(rho_s == max(rho_s));

theta_1 = theta(1:maxpos);
theta_2 = theta(maxpos:end);    % 这里注释掉的是大于maxpos的解，因为这个解并不符合实际情况
rho_s1 = rho_s(1:maxpos);
rho_s2 = rho_s(maxpos:end);


% 查表
theta_s1 = interp1(rho_s1,theta_1,rho);  % vq = interp1(x,v,xq) 使用线性插值返回一维函数在特定查询点的插入值。向量 x 包含样本点，v 包含对应值 v(x)。向量 xq 包含查询点的坐标。
theta_s2 = interp1(rho_s2,theta_2,rho);
theta_s = cat(3,theta_s1,theta_s2);   % C = cat(dim,A,B) 当 A 和 B 具有兼容的大小（除运算维度 dim 以外的维度长度匹配）时，C = cat(dim,A,B) 沿维度 dim 将 B 串联到 A 的末尾。

end

