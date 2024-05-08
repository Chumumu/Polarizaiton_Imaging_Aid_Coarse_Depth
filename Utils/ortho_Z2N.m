function [N] = ortho_Z2N(z,varmask)
% 基于正交投影模型，通过深度图求得法线图
[ Dx,Dy,mask ] = gradMatrices(varmask,'Backward' );
p = Dx*z(mask);
q = Dy*z(mask);


% 梯度图可视化
% figure,
% subplot(1,2,1),imshow(p,[]);colormap summer;colorbar;
% subplot(1,2,2),imshow(q,[]);colormap summer;colorbar;



Nx = nan(size(mask));
Nx(mask)=p;
Ny = nan(size(mask));
Ny(mask)=q;
Nz= nan(size(mask));
Nz(mask) = 1; 

N(:,:,1)=Nx;
N(:,:,2)=Ny;
N(:,:,3)=Nz;


% Normalise to unit vectors
norms = sqrt(sum(N.^2,3));
N = N./repmat(norms,[1 1 3]);

end

