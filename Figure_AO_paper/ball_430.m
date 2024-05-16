clear 
clc
close all

% 读取标定结果文件
load('./AAA_400_ball/5_8leftcalibrationSession.mat');
stereoParams2 = calibrationSession.CameraParameters;
P = stereoParams2.IntrinsicMatrix;

factor = 1; % 尺度因子 Convert to meters
k = 0.15;

% 读取偏振去歧义后存储的.mat文件
load('./AAA_400_ball/3_ball_ODS.mat');
normal1 = double(normal1);
[Z_merged1,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));

load('./AAA_400_ball/3_ball_PD.mat');
normal1 = double(normal1);
[Z_merged2,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));

load('./AAA_400_ball/3_ball_PDS.mat');
normal1 = double(normal1);
[Z_merged3,mask] = mergeDepthNormals(depthmap,normal1,P,k,logical(mask));

% 生成点云
points3D_depthmap = depth2pcl(depthmap,P,factor);
points3D_Z1_merged = depth2pcl(Z_merged1,P,factor);
points3D_Z2_merged = depth2pcl(Z_merged2,P,factor);
points3D_Z3_merged = depth2pcl(Z_merged3,P,factor);




% % 草稿用来看点云的初始范围
% % 平移点云用于可视化
% translation = 60; % 定义x方向平移向量
% points3D_Z1_merged(:,1) =  points3D_Z1_merged(:,1) + translation;
% points3D_Z2_merged(:,1) =  points3D_Z2_merged(:,1) + 2 * translation;
% points3D_Z3_merged(:,1) =  points3D_Z3_merged(:,1) + 3 * translation;
% figure;
% pcshow(points3D_depthmap);colormap('parula');colorbar
% hold on; % 保持当前图像，以便在同一个图像上绘制第二个点云
% pcshow(points3D_Z1_merged)
% pcshow(points3D_Z2_merged)
% pcshow(points3D_Z3_merged)











%% 处理点云
% 定义Z坐标和Y坐标的限制
maxZ = 442;
minY = -80;

% 针对points3D_depthmap过滤
indices = (points3D_depthmap(:, 3) <= maxZ) & (points3D_depthmap(:, 2) > minY);
points3D_depth = points3D_depthmap(indices, :);
% 针对points3D_Z1_merged过滤
indices = (points3D_Z1_merged(:, 3) <= maxZ) & (points3D_Z1_merged(:, 2) > minY);
points3D_Z1 = points3D_Z1_merged(indices, :);
% 针对points3D_Z2_merged过滤
indices = (points3D_Z2_merged(:, 3) <= maxZ) & (points3D_Z2_merged(:, 2) > minY);
points3D_Z2 = points3D_Z2_merged(indices, :);
% 针对points3D_Z3_merged过滤
indices = (points3D_Z3_merged(:, 3) <= maxZ) & (points3D_Z3_merged(:, 2) > minY);
points3D_Z3 = points3D_Z3_merged(indices, :);


% % 平移点云用于可视化
% translation = 60; % 定义x方向平移向量
% points3D_Z1(:,1) =  points3D_Z1(:,1) + translation;
% points3D_Z2(:,1) =  points3D_Z2(:,1) + 2 * translation;
% points3D_Z3(:,1) =  points3D_Z3(:,1) + 3 * translation;
% figure;
% pcshow(points3D_depth);colormap('parula');colorbar
% hold on; % 保持当前图像，以便在同一个图像上绘制第二个点云
% pcshow(points3D_Z1)
% pcshow(points3D_Z2)
% pcshow(points3D_Z3)


% 绘制四个点云在同一平面的截图
% 首先对粗糙点云进行拟合得到理想球面的形状
% 拟合球面，得到球心坐标和半径（此处半径固定）
% 拟合球面，得到球心坐标和半径（半径已知）
r = 50.795 / 2; % 球的半径
[x_center, y_center, z_center] = fit_sphere_fixradius(points3D_depth, r);
center = [x_center, y_center, z_center];

% 理想球面在 y=y_center 的截面半径
slice_radius = r;



font_size = 25;
% 绘制四个点云数据集在 y=y_center 截面

figure('Color', [1 1 1]);
hold on
[selected_points,z_negative] = plot_slice_convex_hull_with_center(points3D_depth, center,r);
% 绘制选出的点组成的折线
plot(selected_points(:,1), z_negative,'black', 'LineWidth', 1); % 绘制对称部分
plot(selected_points(:,1), selected_points(:,3), 'r','LineWidth', 1);  % 在X-Z平面上绘制
axis equal
lgd = legend('Ground truth', 'Coarse');
lgd.FontSize = font_size; % 修改图例的字体大小为12
set(gca, 'FontSize', 19); % 将字体大小设置为14
xlabel('X/mm');
ylabel('Z/mm');


figure('Color', [1 1 1]);
hold on
[selected_points,z_negative] = plot_slice_convex_hull_with_center(points3D_Z1, center, r);
plot(selected_points(:,1), z_negative,'black', 'LineWidth', 1); % 绘制对称部分
plot(selected_points(:,1), selected_points(:,3), 'r','LineWidth', 1);  % 在X-Z平面上绘制
axis equal
lgd = legend('Ground truth', 'ODS');
lgd.FontSize = font_size; % 修改图例的字体大小为12
set(gca, 'FontSize', 19); % 将字体大小设置为14
xlabel('X/mm');
ylabel('Z/mm');



figure('Color', [1 1 1]);
hold on
[selected_points,z_negative] = plot_slice_convex_hull_with_center(points3D_Z2, center, r);
plot(selected_points(:,1), z_negative,'black', 'LineWidth', 1); % 绘制对称部分
plot(selected_points(:,1), selected_points(:,3), 'r','LineWidth', 1);  % 在X-Z平面上绘制
axis equal
lgd = legend('Ground truth', 'PD');
lgd.FontSize = font_size; % 修改图例的字体大小为12
set(gca, 'FontSize', 19); % 将字体大小设置为14
xlabel('X/mm');
ylabel('Z/mm');


figure('Color', [1 1 1]);
hold on
[selected_points,z_negative] = plot_slice_convex_hull_with_center(points3D_Z3, center, r);
plot(selected_points(:,1), z_negative,'black', 'LineWidth', 1); % 绘制对称部分
plot(selected_points(:,1), selected_points(:,3), 'r','LineWidth', 1);  % 在X-Z平面上绘制
axis equal
lgd = legend('Ground truth','PDS');
lgd.FontSize = font_size; % 修改图例的字体大小为12
set(gca, 'FontSize', 19); % 将字体大小设置为14
xlabel('X/mm');
ylabel('Z/mm');



% 拟合点云
D = 50.796;
sphere = sphereFitLSQ1_uncR(points3D_depth);
sphere1 = sphereFitLSQ1_uncR(points3D_Z1);
sphere2 = sphereFitLSQ1_uncR(points3D_Z2);
sphere3 = sphereFitLSQ1_uncR(points3D_Z3);



center = sphere.Center;
fprintf('粗糙A球心坐标：(%8.4f, %8.4f, %8.4f)\n',center(1), center(2), center(3));
fprintf('    直径    ：%8.4f   差值为：%8.4f\n',2*sphere.Radius,2*sphere.Radius-D);
fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere.Residuals)));

center = sphere1.Center;
fprintf('ODS下A球心坐标：(%8.4f, %8.4f, %8.4f)\n',center(1), center(2), center(3));
fprintf('    直径    ：%8.4f   差值为：%8.4f\n',2*sphere1.Radius,2*sphere1.Radius-D);
fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere1.Residuals)));

center = sphere2.Center;
fprintf('PD下A球心坐标：(%8.4f, %8.4f, %8.4f)\n',center(1), center(2), center(3));
fprintf('    直径    ：%8.4f   差值为：%8.4f\n',2*sphere2.Radius,2*sphere2.Radius-D);
fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere2.Residuals)));

center = sphere3.Center;
fprintf(' PDS下A球心坐标：(%8.4f, %8.4f, %8.4f)\n',center(1), center(2), center(3));
fprintf('    直径    ：%8.4f   差值为：%8.4f\n',2*sphere3.Radius,2*sphere3.Radius-D);
fprintf('   平均误差  ：%8.4f\n',mean(abs(sphere3.Residuals)));









% 平移点云用于可视化
translation = 50; % 定义x方向平移向量
points3D_Z1(:,1) =  points3D_Z1(:,1) + translation;
points3D_Z2(:,1) =  points3D_Z2(:,1) + 2 * translation;
points3D_Z3(:,1) =  points3D_Z3(:,1) + 3 * translation;

figure;
pcshow(points3D_depth);colormap('parula');colorbar
hold on; % 保持当前图像，以便在同一个图像上绘制第二个点云
pcshow(points3D_Z1)
pcshow(points3D_Z2)
pcshow(points3D_Z3)

set(gca, 'Color', 'white'); % 更改坐标轴背景颜色
set(gcf, 'Color', 'white'); % 更改整个图形窗口的背景颜色
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % 将坐标轴颜色设置为黑色 
grid off
xlabel('X/mm');
ylabel('Y/mm');
zlabel('Z/mm');
lgd.FontSize = font_size; % 修改图例的字体大小为12
set(gca, 'FontSize', 25); % 将字体大小设置为14


function [selected_points,z_negative] = plot_slice_convex_hull_with_center(points, center, r)
    % 解构球心坐标
    x_center = center(1);
    y_center = center(2);
    z_center = center(3);

    % 筛选出y坐标接近y_center的点
    selected_points = points(abs(points(:,2)-y_center) < 0.1, :);  % 根据需要调整这个阈值
    x = selected_points(:,1);
    % 考虑球心位置的影响，计算理想球面上对应的z坐标
    z_squared = r^2 - (x - x_center).^2;
%     z_positive = sqrt(max(z_squared, 0)) + z_center; % 防止负数开方，仅取实数部分
    z_negative = -sqrt(max(z_squared, 0)) + z_center;

end