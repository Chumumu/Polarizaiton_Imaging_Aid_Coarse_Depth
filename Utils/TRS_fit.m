function [ Iun,rho,phi ] = TRS_fit( angles,I )
%TRSFIT Nonlinear least squares optimisation to fit sinusoid
%   Inputs:
%      angles - vector of polarising filter angles
%      I      - vector of measured intensities
%   Outputs:
%      Iun, rho, phi - scalar values containing polarisation image params
%
% William Smith 2016


%% 1、下面是源码的方法
% % Initialise  初始化三个未知数
% b0(1)=mean(I);                               % b(1); (Imax + Imin)/2
% b0(2)=sqrt(mean((I-b0(1)).^2)).*sqrt(2);     % b(2): (Imax - Imin)/2
% b0(3)=0;                                     % b(3): phi
% % x = lsqnonlin(fun,x0,lb,ub,options) 使用 options 所指定的优化选项执行最小化。使用 optimoptions 可设置这些选项。如果不存在边界，则为 lb 和 ub 传递空矩阵。
% options = optimoptions('lsqnonlin', 'Algorithm','trust-region-reflective','Display','final');
% 
% % 函数句柄 @(b) TRSfitobj(b,angles,I) 是要最小化的目标函数
% % b0 是目标函数的起始点
% % [0 0 -pi] 和 [inf inf pi] 分别是 b 向量中每个元素的下界和上界
% b=lsqnonlin(@(b)TRSfitobj(b,angles,I),b0,[0 0 -pi],[inf inf pi],options);
% 
% if b(3)<0
%     b(3)=b(3)+pi;
% end
% Iun = b(1);
% Imax = Iun+b(2);
% Imin = Iun-b(2);
% rho = (Imax-Imin)/(Imax+Imin);
% phi = b(3);


%% 2、这是我自己的方法
% 定义目标函数
fun = @(x,angle) x(1)/2 + x(2)/2*cos(2*angle - 2*x(3));


% 初始参数值
x0 = [mean(I), sqrt(mean((I-mean(I)).^2)).*sqrt(2), 0];

% 设置上下界
lb = [0, 0, -pi];
ub = [inf, inf, pi];

% 创建选项结构体，禁止显示迭代信息
options = optimoptions('lsqcurvefit', 'Display', 'none');

% 使用 lsqcurvefit 进行最小二乘拟合
x = lsqcurvefit(fun, x0, angles, I, lb, ub, options);


% 输出结果
Iun = x(1);
Imax = Iun+x(2);
Imin = Iun-x(2);
rho = (Imax-Imin)/(Imax+Imin);
phi = x(3);


end





function errs = TRSfitobj(b,angles,I)
% I2 = (Imax + Imin)/2 +(Imax - Imin)/2.*cos(2.*angle-2.*phi)
I2 = b(1)+b(2).*cos(2.*angles-2*b(3));
errs = I-I2;

end