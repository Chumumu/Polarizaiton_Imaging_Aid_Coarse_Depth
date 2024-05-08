% close all
clc
clear
% 读取偏振去歧义后存储的.mat文件以及标定结果文件
[filename4,pathname4]=uigetfile({'*.mat'},'选择法线去歧义结果.mat文件');
load([pathname4,filename4]);
[filename3,pathname3]=uigetfile({'*.mat'},'选择左相机标定结果.mat文件');
load([pathname3,filename3]);
stereoParams2 = calibrationSession.CameraParameters;
P = stereoParams2.IntrinsicMatrix;

% 融合粗糙深度图和法线
normal1 = double(normal1);
[Z_merged,mask1] = mergeDepthNormals(depthmap,normal1,P,0.1,logical(mask));

% % 结果可视化
% figure
% subplot(1,2,1);surf(depthmap);title('粗糙深度图');colormap parula;colorbar;axis off
% subplot(1,2,2);surf(Z_merged);title('融合深度图');colormap parula;colorbar;axis off




%% %%%%%%%%%%%%%%%%%%%%%%%点云拟合%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 生成点云
factor = 1; % 尺度因子 Convert to meters
points3D_depthmap = depth2pcl(depthmap,P,factor);
points3D_Z_merged = depth2pcl(Z_merged,P,factor);
% 可视化点云
figure;
pcshow(points3D_Z_merged);title('融合后点云');colorbar;h = colorbar;set(h, 'Color', 'white');
figure;
pcshow(points3D_depthmap);title('粗糙点云');colorbar;h = colorbar;set(h, 'Color', 'white');

% %%%%%%%%%%%%%%%拟合融合点云%%%%%%%%%%%%%%%%%%%%%%%%
% pointCloud_fusion = pointCloud(points3D_Z_merged);
% roi = [-inf,inf;-inf,inf;0,650];   % [-45,-5;-35,0;0,520]  [-50,0;-41,6;0,580]
% sampleIndices = findPointsInROI(pointCloud_fusion, roi);
% roiCloud = select(pointCloud_fusion, sampleIndices);
% figure;
% pcshow(roiCloud);title("融合点云ROI")
% sphere = sphereFitLSQ1_uncR(roiCloud.Location);
% center = sphere.Center;
% fprintf('融合后球心坐标：(%8.4f, %8.4f, %8.4f)\n',center(1), center(2), center(3));
% % 获取半径
% radius = sphere.Radius;
% fprintf('    半径    ：%8.4f\n',2*radius);
% % 输出平均误差
% fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere.Residuals)));
% 
% %%%%%%%%%%%%%%%拟合粗糙点云%%%%%%%%%%%%%%%%%%%%%%%%
% pointCloud_depth = pointCloud(points3D_depthmap);
% roi2 = [-inf,inf;-inf,inf;0,650];
% sampleIndices2 = findPointsInROI(pointCloud_depth, roi2);
% roiCloud2 = select(pointCloud_depth, sampleIndices2);
% figure;
% pcshow(roiCloud2);title("粗糙点云ROI")
% sphere2 = sphereFitLSQ1_uncR(roiCloud2.Location);
% center2 = sphere2.Center;
% fprintf('粗糙球心坐标：(%8.4f, %8.4f, %8.4f)\n',center2(1), center2(2), center2(3));
% % 获取半径
% radius2 = sphere2.Radius;
% fprintf('    半径    ：%8.4f\n',2*radius2);
% % 输出平均误差
% fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere2.Residuals)));