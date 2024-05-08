[filename1,pathname1]=uigetfile({'*.bmp'},'选择左相机视图下的偏振图片(随意选一张）');
l10 = double(imread(fullfile(pathname1, '10.bmp')));
l40 = double(imread(fullfile(pathname1, '40.bmp')));
l70 = double(imread(fullfile(pathname1, '70.bmp')));
l100 = double(imread(fullfile(pathname1, '100.bmp')));
l130 = double(imread(fullfile(pathname1, '130.bmp')));
l160 = double(imread(fullfile(pathname1, '160.bmp')));

I = (l10+l40+l70+l100+l130+l160)/6;
figure,imshow(I,[]);

% 简单阈值判定二值化
use_fg_threshold = true;
mask1 = ones(size(I));
if ( use_fg_threshold )
  fg_threshold = 15;             % 阈值需要修改   
  mask1(I < fg_threshold)  = 0;
  mask1(I >=fg_threshold)  = 1; % foreground
end
mask1 = logical(mask1);
figure; imagesc(mask1);

hold on

% 自己手动划取ROI
roimask = false(size(I));
h = drawfreehand;
BW = createMask(h);
roimask(BW) = 1;
mask1 = mask1 & roimask;
imagesc(mask1); 


% 取最大连通域并且填补空洞
CC=bwconncomp(mask1); % 取最大连通域
varmask=false(size(I));
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
varmask(CC.PixelIdxList{idx}) = 1;
mask1 = varmask;
imagesc(mask1)
disp(['原始mask前景元素的个数为：----------', num2str(nnz(mask1)),'---------']);

hold off

% 生成specmask
specmask = true((size(I)));
if ( use_fg_threshold )
  fg_threshold = 230;
  specmask(I < fg_threshold)  = 0;
  specmask(I >=fg_threshold)  = 1; % 高于240的像素点置为镜面反射像素
end

specmask = specmask & mask1;
%% 偏振度rho和相位角phi
images = cat(3,l10,l40,l70,l100,l130,l160);   
angles = [10,40,70,100,130,160] * pi / 180;

% 折射率取 n=1.5
n = 1.5;
[ rho1,phi1] = DecomposePolar( double(images),angles,mask1,'nonlinear');
theta_diffuse1 = rho_diffuse(rho1,n);
disp(['theta_diffuse中非nan元素的个数为：----------', num2str(nnz(~isnan(theta_diffuse1))),'---------']);
theta_specular1 = rho_specular(rho1,n);
disp(['theta_specular中非nan元素的个数为：----------', num2str(nnz(~isnan(theta_specular1))),'---------']);

% 更新mask
mask2 = ~isnan(theta_diffuse1);
mask = mask1 & mask2;


% 用新mask更新偏振信息
rho1(~mask) = nan;
phi1(~mask) = nan;
specmask = specmask & mask;

% 可视化原始偏振信息
close all
figure
subplot(2,2,1),imshow(phi1/pi*180,[]),title('相位角');colormap parula;colorbar;
subplot(2,2,2),imshow(rho1,[]),title('偏振度');colormap parula;colorbar;
subplot(2,2,3),imshow(theta_diffuse1/pi*180,[]),title('漫反射下天顶角');colormap parula;colorbar;
subplot(2,2,4),imshow(theta_specular1(:, :,1)/pi*180,[]),title('镜面反射天顶角');colormap parula;colorbar;

% 针对mask内的偏振信息中值滤波
rho = filter_func(rho1,mask,3,3);
phi = filter_func(phi1,mask,3,3);
theta_diffuse = rho_diffuse(rho,n);
theta_specular = rho_specular(rho,n);
% 可视化滤波后的偏振信息
figure
subplot(2,2,1),imshow(phi/pi*180,[]),title('相位角');colormap parula;colorbar;
subplot(2,2,2),imshow(rho,[]),title('偏振度');colormap parula;colorbar;
subplot(2,2,3),imshow(theta_diffuse/pi*180,[]),title('漫反射下天顶角');colormap parula;colorbar;
subplot(2,2,4),imshow(theta_specular(:, :,1)/pi*180,[]),title('镜面反射天顶角');colormap parula;colorbar;

figure;
subplot(1,3,1);imshow(mask1);title('原始mask');
subplot(1,3,2);imshow(mask2);title('漫反射有效的mask');
subplot(1,3,3);imshow(mask1-mask2);title('漫反射无效的像素');


%% 保存
[fileName, pathName] = uiputfile('*.mat', '保存.mat文件');
save(fullfile(pathName, fileName),'theta_diffuse','theta_specular','phi','rho','mask','specmask','I');