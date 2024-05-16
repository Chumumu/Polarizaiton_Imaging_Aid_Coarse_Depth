function [Z_merged,mask] = mergeDepthNormals(Z,NM,P,lambda,mask)
%MERGEDEPTHNORMALS Optimise depth map to better match target normals
%   This function takes an initial depth map and a target normal map as 
%   input and optimises the depth map such that its surface normals better 
%   match those in the target normal map. It does so by solving a linear
%   system of equations as described in the paper "Efficiently combining 
%   positions and normals for precise 3D geometry", Nehab et al. 2005.
%
% Inputs:
%    Z       - H x W perspective depth map
%    NM      - H x W x 3 normal map in cameras coordinates
%    cx,cy,f - camera parameters
%    lambda  - regularisation weight, larger means Z_merged is closer to Z
%    mask    - H x W binary foreground mask (logical)
%
% Outputs:
%    Z_merged - H x W refined depth map
%    mask     - H x W mask (mask may need to be modified to compute finite
%               differences)
%
% Implemention created for the following paper which you may like to cite
% in addition to the original Nehab paper:
%
% Ye Yu and William A. P. Smith. Depth estimation meets inverse rendering 
% for single image novel view synthesis. In Proc. CVMP, 2019.

[ Dx,Dy,mask,~ ] = xch_gradMatrices( mask,'SmoothedCentral' );
% [Dx,Dy,~] = DepthGradient2(mask,mask);   % 这个函数不行，因为直接单向的偏导噪声太多

cx = P(3,1);
cy = P(3,2);
f = (P(1,1)+P(2,2))/2;


% size(mask,1):-1:1的原因是像素坐标系和图像坐标系的y轴方向不一样
[x,y]=meshgrid(1:size(mask,2),size(mask,1):-1:1);
x = x - cx;
y = y - cy;

npix = sum(mask(:));  % npix -多少个前景像素

X = sparse(1:npix,1:npix,x(mask),npix,npix);
Y = sparse(1:npix,1:npix,y(mask),npix,npix);

% Build tangent vector matrices
Tx = [1/f.*X   1/f.*speye(npix); ...
      1/f.*Y sparse([],[],[],npix,npix); ...
      speye(npix) sparse([],[],[],npix,npix)] * [Dx; speye(npix)];
Ty = [1/f.*X sparse([],[],[],npix,npix); ...
      1/f.*Y 1/f.*speye(npix); ...
      speye(npix) sparse([],[],[],npix,npix)] * [Dy; speye(npix)];


% Build matrix for performing dot product with target surface normals
Nx = NM(:,:,1);
Ny = NM(:,:,2);
Nz = NM(:,:,3);
N = sparse([1:npix 1:npix 1:npix],1:3*npix,[Nx(mask); Ny(mask); Nz(mask)],npix,3*npix); % any(isnan(full(N)), 'all')判读一个稀疏矩阵中是否有nan


% %Solve linear system

% %1、将粗糙深度图放入线性方程组
% A = [lambda.*speye(npix); N*Tx; N*Ty];
% b = [lambda.*Z(mask); zeros(2*npix,1)];
% % 设置迭代求解线性方程组的选项
% opts.tol = 1e-6;  % 设置收敛精度
% opts.maxit = 100; % 设置最大迭代次数
% % 使用bicgstab函数迭代求解线性方程组
% z = bicgstab(A, b, opts);


% % % 2、将粗糙深度图作为解的初始值
% A = [ N*Tx; N*Ty];
% b = [ zeros(2*npix,1)];
% z = lsqr(A,b,[],1000,[],[],Z(mask));

% 3、 直接解线性方程组
z = [lambda.*speye(npix); N*Tx; N*Ty]\[lambda.*Z(mask); zeros(2*npix,1)];  % sum(isnan(Z(mask)))



% Put vector result back into depth map
Z_merged = nan(size(mask));
Z_merged(mask) = z;

end

