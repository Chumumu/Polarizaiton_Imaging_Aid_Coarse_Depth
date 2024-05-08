close all
clear 
clc 
% 依次读取左相机图像、右相机图像、标定参数
[filename1,pathname1]=uigetfile({'*.bmp'},'选择左相机视图');
I1 = imread(fullfile(pathname1, filename1));
[filename2,pathname2]=uigetfile({'*.bmp'},'选择右相机视图');
I2 = imread(fullfile(pathname2, filename2));
[filename3,pathname3]=uigetfile({'*.mat'},'选择双目标定结果.mat文件');
load([pathname3,filename3]);
stereoParams = calibrationSession.CameraParameters;
clearvars -except  I1 I2  stereoParams

% 读取存储偏振信息.mat文件
[filename4,pathname4]=uigetfile({'*.mat'},'选择被测物偏振信息mat文件');
load([pathname4,filename4]);

% Anaglyph_raw = stereoAnaglyph(I1, I2);
% figure; imshow(Anaglyph_raw);title('立体图像对');
% imtool(Anaglyph_raw); % 使用 imtool 确定视差范围值  
% 极线校正(大致估计视差范围）
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams,OutputView='full'); % 矫正左右彩色图像，利用导入的立体相机参数
Anaglyph = stereoAnaglyph(J1, J2);
figure; imshow(Anaglyph);title('立体图像对');
imtool(Anaglyph); % 使用 imtool 确定视差范围值  

% % 计算粗糙深度图
% 计算视差图
DisparityRange=[320,448]; 
disparityMap=disparitySGM(J1,J2,'DisparityRange',DisparityRange,'UniquenessThreshold',5);
figure;imshow(disparityMap,[]);title('原始视差图');colormap parula;colorbar;  % color map可选择jet parula viridis

% 原始深度图
points3D = reconstructScene(disparityMap, stereoParams);
z = double(points3D(:,:,3));            % 原始深度图
z(~mask) = nan;
% ptCloud = pointCloud(points3D);
% 
% pcshow(ptCloud);
% % Create a streaming point cloud viewer
% player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
%     'VerticalAxisDir', 'down');
% 
% view(player3D, ptCloud);



% 对原始视差图插值
disparityMap2 = interpolate_depth_map(double(disparityMap),'natural');  
points3D2 = reconstructScene(disparityMap2, stereoParams);
depthmap = double(points3D2(:,:,3));    % 视差图插值后的深度图
depthmap(~mask) = nan;
% 可视化深度图
figure;
subplot(1,2,1);surf(z), title('原始深度图');colormap parula;colorbar;
subplot(1,2,2);surf(depthmap), title('插值后深度图');colormap parula;colorbar;
disp(['深度图非NaN元素的数量为：----------', num2str(nnz(~isnan(depthmap))),'---------']);
%% 对粗糙深度图差分获取表面引导法线
%%%%%%%%%%正交投影模型%%%%%%%%%%
N_guide = ortho_Z2N(depthmap,mask);
figure;imshow((N_guide+1)./2);title('表面引导法线');colormap parula;colorbar;

% figure;
% subplot(3,1,1);surf(N_guide(:,:,1));title(" 法线的x分量");colorbar;
% subplot(3,1,2);surf(N_guide(:,:,2));title(" 法线的y分量");colorbar;
% subplot(3,1,3);surf(N_guide(:,:,3));title(" 法线的z分量");colormap parula;colorbar;
%% 保存计算结果
cam1 = struct();
cam1.rho_est = rho;
cam1.theta_est_diffuse = theta_diffuse;
cam1.theta_est_spec = theta_specular;
cam1.phi_est = phi;
cam1.mask = mask;
cam1.specmask = specmask;

[fileName, pathName] = uiputfile('*.mat', '保存.mat文件');
save(fullfile(pathName, fileName), 'cam1', 'depthmap', 'N_guide','I');