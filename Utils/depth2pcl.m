function [points3D_cam] = depth2pcl(depthmap,P,factor)
%DEPTH2PCL 由深度图depthmap和相机内参P得到相机坐标系下的点云points3D_cam
%  

% 计算深度图中每个像素的三维坐标
[x,y]=meshgrid(1:size(depthmap,2),size(depthmap,1):-1:1);
X_cam = (x - P(3,1)) .* depthmap / P(1,1);
Y_cam = (y - P(3,2)) .* depthmap / P(2,2);
Z_cam = depthmap;
points3D_cam = [X_cam(:) Y_cam(:) Z_cam(:)];
points3D_cam = points3D_cam/factor;
end

