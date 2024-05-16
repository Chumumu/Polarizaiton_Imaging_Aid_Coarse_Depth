function depth_map = interpolate_depth_map(dense_map, method)
% Interpolate depth values in a dense depth map using existing values.

% Find pixels with known depth values.
known_depth_mask = ~isnan(dense_map);

% Create a grid of pixel coordinates.
[X, Y] = meshgrid(1:size(dense_map, 2), 1:size(dense_map, 1));

% Interpolate depth values using the 'griddata' function.
if strcmpi(method, 'linear')
    depth_map = griddata(X(known_depth_mask), Y(known_depth_mask), dense_map(known_depth_mask), X, Y, 'linear');
elseif strcmpi(method, 'natural')
    depth_map = griddata(X(known_depth_mask), Y(known_depth_mask), dense_map(known_depth_mask), X, Y, 'natural');
elseif strcmpi(method, 'nearest')
    depth_map = griddata(X(known_depth_mask), Y(known_depth_mask), dense_map(known_depth_mask), X, Y, 'nearest');
elseif strcmpi(method, 'cubic')
    depth_map = griddata(X(known_depth_mask), Y(known_depth_mask), dense_map(known_depth_mask), X, Y, 'cubic');
else
    depth_map = griddata(X(known_depth_mask), Y(known_depth_mask), dense_map(known_depth_mask), X, Y, 'v4');
end

end
