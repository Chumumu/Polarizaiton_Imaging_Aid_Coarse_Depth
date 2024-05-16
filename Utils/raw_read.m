function im = raw_read(pathname,colRaw,rowRaw)
% 读取raw格式图片
I = fopen(pathname, 'r');
ori_I = fread(I, 'uint16');
I = reshape(ori_I, [colRaw, rowRaw, 1]);
I = flipud(rot90(I));
im = double(I);
end