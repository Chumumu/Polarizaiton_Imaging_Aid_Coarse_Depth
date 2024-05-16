function filtered_depth = local_consistency_check(depth_map, mask, neighborhood_size)
    % 自定义的函数，仅在mask指定的非NaN区域内应用中值滤波。

    % 初始化输出矩阵，用NaN填充。
    [m, n] = size(depth_map);
    filtered_depth = NaN(m, n);
    
    % 扩展depth_map以处理边缘像素
    pad_size = (neighborhood_size - 1) / 2;
    padded_depth_map = padarray(depth_map, [pad_size pad_size], NaN);
    
    % 计算每个像素的中值
    for i = 1:m
        for j = 1:n
            if mask(i, j)
                % 获取当前像素的邻域
                local_window = padded_depth_map(i:i+neighborhood_size-1, j:j+neighborhood_size-1);
                
                % 计算邻域的中值，忽略NaN
                local_median = nanmedian(local_window(:));
                
                % 将计算的中值赋值给输出矩阵的相应位置
                filtered_depth(i, j) = local_median;
            end
        end
    end
end