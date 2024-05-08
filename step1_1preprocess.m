
% 多选图像，降低图像分辨率
clear
clc
% 让用户选择多个图片文件
[filename, pathname] = uigetfile({'*.bmp'}, '选择图片文件','MultiSelect', 'on');
% 遍历每个选择的图片文件
for i = 1:length(filename)
    % 读取图片
    img = imread(fullfile(pathname, filename{i}));
    % 对图片进行降采样
    img_downsampled = imresize(img, 0.25);
    % 保存降采样后的图片并覆盖原文件
    imwrite(img_downsampled, fullfile(pathname, filename{i}));
end


%% 根据双目标定参数，对图像进行立体校正，与左相机坐标系对齐
clear
clc
% 读取所有左相机标定图片
[filename1, pathname1] = uigetfile({'*.bmp'}, '多选所有左相机图片','MultiSelect', 'on');
% 读取某一张右相机图片
[filename2, pathname2] = uigetfile({'*.bmp'}, '选择一张右相机图片');
right = imread(fullfile(pathname2,filename2));

% 读取双目标定文件
[filename3,pathname3]=uigetfile({'*.mat'},'选择双目标定结果.mat文件');
load([pathname3,filename3]);
stereoParams = calibrationSession.CameraParameters;
% 校正后的左相机棋盘格图片存储文件夹
 folder_path = uigetdir();

% 遍历每个选择的图片文件
for i = 1:length(filename1)
    % 读取图片
    img = imread(fullfile(pathname1, filename1{i}));
    [img_rectified, ~] = rectifyStereoImages(img, right, stereoParams,OutputView='full');
    % 保存校正后的图片
    imwrite(img_rectified, fullfile(folder_path, filename1{i}));
end