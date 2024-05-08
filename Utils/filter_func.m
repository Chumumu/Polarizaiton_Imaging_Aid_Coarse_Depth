function result = filter_func(I, mask, m, n)
% 获取图像I的大小
[rows, cols] = size(I);

% 计算邻域的半径
r = floor((m-1)/2);
s = floor((n-1)/2);

% 初始化结果矩阵
result = nan(rows, cols);

% 将掩膜mask中的像素转换为线性索引
mask_pixels = find(mask);

% 循环遍历掩膜mask中的每个像素
num_mask_pixels = length(mask_pixels);
for k = 1:num_mask_pixels
    idx = mask_pixels(k);
    [i, j] = ind2sub([rows, cols], idx);
    
    % 获取当前像素的邻域
    row_start = max(i-r, 1);
    col_start = max(j-s, 1);
    row_end = min(i+r, rows);
    col_end = min(j+s, cols);
    neighborhood = I(row_start:row_end, col_start:col_end);
    mask_neighborhood = mask(row_start:row_end, col_start:col_end);

    % 判断邻域是否都在mask中
    if all(mask_neighborhood(:))
        % 对邻域进行中值滤波
        result(idx) = median(neighborhood(:));
    else
        % 只对邻域中mask部分的像素取平均值
        mask_pixels2 = neighborhood(mask_neighborhood);
        if numel(mask_pixels2) > 0
            result(idx) = mean(mask_pixels2(:));
        else
            result(idx) = I(idx);
        end
    end
end
end
