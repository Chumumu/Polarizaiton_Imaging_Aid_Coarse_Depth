clear 
clc


factor = 1; % 尺度因子 Convert to meters
k = 0.05;


%企鹅 19 -56  杯子16 -70  天鹅 12 -84
Az = 19;
El = -56;

% 读取标定结果文件
load('/Users/mumu/Documents/MATLAB/Polarizaiton_Imaging_Aid_Coarse_Depth/data/3_20_leftcalibrationSession.mat');
stereoParams2 = calibrationSession.CameraParameters;
P = stereoParams2.IntrinsicMatrix;


% 读取偏振去歧义后存储的.mat文件
load('/Users/mumu/Documents/MATLAB/Polarizaiton_Imaging_Aid_Coarse_Depth/data/3_penguin_ODS.mat');
% figure('Position', [100, 100, 500, 1600])
% subplot(4,1,1);
% surf(depthmap);colormap parula;axis off;axis equal;colorbar
% view(Az, El)
normal1 = double(normal1);
[Z_merged1,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));
% subplot(4,1,2);
% surf(Z_merged1);colormap parula;axis off;axis equal;colorbar
% view(Az, El)

load('/Users/mumu/Documents/MATLAB/Polarizaiton_Imaging_Aid_Coarse_Depth/data/3_penguin_PD.mat');
normal1 = double(normal1);
[Z_merged2,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));
% subplot(4,1,3);
% surf(Z_merged2);colormap parula;axis off;axis equal;colorbar
% view(Az, El)

load('/Users/mumu/Documents/MATLAB/Polarizaiton_Imaging_Aid_Coarse_Depth/data/3_penguin_PDS.mat');
normal1 = double(normal1);
[Z_merged3,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));
% subplot(4,1,4);
% surf(Z_merged3);colormap parula;axis off;axis equal;colorbar
% view(Az, El)


% 生成点云
factor = 1; % 尺度因子 Convert to meters
translation = 80; % 定义x方向平移向量
points3D_depthmap = depth2pcl(depthmap,P,factor);
points3D_Z1_merged = depth2pcl(Z_merged1,P,factor);
points3D_Z1_merged(:,1) =  points3D_Z1_merged(:,1) + translation;
points3D_Z2_merged = depth2pcl(Z_merged2,P,factor);
points3D_Z2_merged(:,1) =  points3D_Z2_merged(:,1) + 2 * translation;
points3D_Z3_merged = depth2pcl(Z_merged3,P,factor);
points3D_Z3_merged(:,1) =  points3D_Z3_merged(:,1) + 3 * translation;


figure;
pcshow(points3D_depthmap);colormap('parula');colorbar
hold on; % 保持当前图像，以便在同一个图像上绘制第二个点云
pcshow(points3D_Z1_merged)
pcshow(points3D_Z2_merged)
pcshow(points3D_Z3_merged)

set(gca, 'Color', 'white'); % 更改坐标轴背景颜色
set(gcf, 'Color', 'white'); % 更改整个图形窗口的背景颜色
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % 将坐标轴颜色设置为黑色 
grid off
xlabel('X/mm');
ylabel('Y/mm');
zlabel('Z/mm');
set(gca, 'FontSize', 19); % 将字体大小设置为14
