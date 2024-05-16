function [N] = pers_Z2N(z,varmask,Dx,Dy,P)
%   基于透射投影模型，通过深度图求得法线图

fx = P(1,1);
fy = P(2,2);
u0 = P(3,1);
v0 = P(3,2);

rows = size(varmask,1);
cols = size(varmask,2);


% size(mask,1):-1:1的原因是图像坐标系的y轴向上为正，不同于像素坐标系
[x,y]=meshgrid(1:size(varmask,2),size(varmask,1):-1:1);   % size(varmask,1):-1:1
Zx = nan(rows,cols);
Zy = nan(rows,cols);
Zx(varmask)=Dx*z(varmask);
Zy(varmask)=Dy*z(varmask);

% 根据公式求法线N
pnx = -Zx.*fy;
pny = -Zy.*fx;
pnz = ((x-u0).*Zx+(y-v0).*Zy+z);  
PN(:,:,1)=pnx;
PN(:,:,2)=pny;
PN(:,:,3)=pnz;

sumN=pnx.^2+pny.^2+pnz.^2;   % B 3. compute the squre of the magnitude
mag=sqrt(sumN);              % B 4. magnitude
zero_idx=(mag==0);
magr1=1./mag;                % B 5. Reciprocal of the magnitude
magr1(zero_idx)=0;
N=PN.*magr1;                 % B 6. Normalize the normal


end