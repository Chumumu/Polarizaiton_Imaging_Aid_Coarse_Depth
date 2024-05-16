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


%% 生成mask
[filename3,pathname3]=uigetfile({'*.bmp'},'选择灰度图像来生成mask');
I3 = imread(fullfile(pathname3, filename3));
[I3, ~] = rectifyStereoImages(I3, I2, stereoParams,OutputView='full'); % 矫正左右彩色图像，利用导入的立体相机参数
% 简单阈值判定二值化
use_fg_threshold = true;
mask1 = ones(size(I3));
if ( use_fg_threshold )
  fg_threshold = 35;             % 阈值需要修改   
  mask1(I3 < fg_threshold)  = 0;
  mask1(I3 >=fg_threshold)  = 1; % foreground
end
mask1 = logical(mask1);
figure; imagesc(mask1);
% 自己手动划取ROI
roimask = false(size(I3));
h = drawfreehand;
BW = createMask(h);
roimask(BW) = 1;
mask1 = mask1 & roimask;
imagesc(mask1); 
% 取最大连通域并且填补空洞
CC=bwconncomp(mask1); % 取最大连通域
varmask=false(size(I3));
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
varmask(CC.PixelIdxList{idx}) = 1;
mask = varmask;
imagesc(mask)

%% 立体校正和计算深度图
% Anaglyph_raw = stereoAnaglyph(I1, I2);
% figure; imshow(Anaglyph_raw);title('立体图像对');
% 极线校正(大致估计视差范围）
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams,OutputView='full'); % 矫正左右彩色图像，利用导入的立体相机参数
Anaglyph = stereoAnaglyph(J1, J2);
% figure; imshow(Anaglyph);title('立体图像对');
imtool(Anaglyph);


% % 计算粗糙深度图
% 计算视差图
DisparityRange=[1344,1448]; 
disparityMap=disparitySGM(J1,J2,'DisparityRange',DisparityRange,'UniquenessThreshold',0);
figure;imshow(disparityMap,[]);title('原始视差图');colormap parula;colorbar;  % color map可选择jet parula viridis
disparityMap2 = interpolate_depth_map(double(disparityMap),'cubic');  % 对原始视差图插值

% 原始深度图
points3D = reconstructScene(disparityMap, stereoParams);
z = double(points3D(:,:,3));            % 原始深度图
z(~mask) = nan;

% 对原始视差图插值
disparityMap2 = interpolate_depth_map(double(disparityMap),'natural');  
points3D2 = reconstructScene(disparityMap2, stereoParams);
depthmap = double(points3D2(:,:,3));    % 视差图插值后的深度图
depthmap(~mask) = nan;


% 可视化深度图
figure;
subplot(1,2,1);surf(z), title('原始深度图');colormap parula;colorbar;
subplot(1,2,2);surf(depthmap), title('插值后深度图');colormap parula;colorbar;


% [A] = ZfilteringAndMeanFilling2(disparityMap,10,5,2); 
% A(~mask) =nan;figure;imshow(A,[])
% indices = (depthmap>450);
% z2 = dept
