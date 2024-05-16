function [Z] = integrate_using_depth_normal_fusion(gx,gy,im,lambda)

% Args:
% gx - normals x coordinates
% gy - normals y coordinates
% im - depth map

% Returns:
% Z - surface

[H,W] = size(gx);

p = gx;
q = gy;

sigma = 0.3; 
ss = floor(6*sigma);%�� X ��ÿ��Ԫ���������뵽С�ڻ���ڸ�Ԫ�ص���ӽ�����
if(ss<3)
    ss = 3;
end

% New: Define a gaussian filter
ww = fspecial('gaussian',ss,sigma);%����һ����СΪss����ת�ԳƸ�˹��ͨ�˲��������׼ƫ��Ϊsigma������

% New: Apply the filter
T11 = filter2(ww,p.^2,'same');%���ݾ��� H �е�ϵ���������ݾ��� X Ӧ������������Ӧ�˲����� 'same' - �����˲����ݵ����Ĳ��֣���С�� X ��ͬ��
T22 = filter2(ww,q.^2,'same');
T12 = filter2(ww,p.*q,'same');

% find eigen values
ImagPart = sqrt((T11 - T22).^2 + 4*(T12.^2));
EigD_1 = (T22 + T11 + ImagPart)/2.0;

% New: Set a threshold on eignevalues
THRESHOLD_SMALL = max(EigD_1(:))/100; 

L1 = ones(H,W);
idx = find(EigD_1 > THRESHOLD_SMALL);
alpha = 0.02;
L1(idx) = alpha + 1 - exp(-3.315./(EigD_1(idx).^4));
L2 = ones(H,W);

% New: Structure the matrix�������
D11 = zeros(H,W);
D12 = zeros(H,W);
D22 = zeros(H,W);

for ii = 1:H
    for jj = 1:W
        Wmat = [T11(ii,jj) T12(ii,jj);T12(ii,jj) T22(ii,jj)];
        [v,d] = eig(Wmat);%[V,D] = eig(A) ��������ֵ�ĶԽǾ��� D �;��� V�������Ƕ�Ӧ��������������ʹ�� A*V = V*D
        
        % New: Swap���� if d(1,1)>d(2,2)
        if(d(1,1)>d(2,2))
            temp_d = d;
            d(1,1) = temp_d(2,2);
            d(2,2) = temp_d(1,1);
            temp_v = v;
            v(:,1) = temp_v(:,2);
            v(:,2) = temp_v(:,1);
        end

        % d(1,1) is smaller
        d(1,1) = L2(ii,jj);
        d(2,2) = L1(ii,jj);

        Wmat = v*d*v';
        D11(ii,jj) = Wmat(1,1);
        D22(ii,jj) = Wmat(2,2);
        D12(ii,jj) = Wmat(1,2);
    end
end

A = laplacian_matrix_tensor(H,W,D11,D12,D12,D22);
f = calculate_f_tensor(p,q,D11,D12,D12,D22);
A = A(:,2:end);
f = f(:);

% regularize
A_bot = sparse(numel(im)); %����Ԫ�ص���Ŀ
for ii=1:numel(im)
    A_bot(ii,ii) = lambda;
end

A_bot = A_bot(:,2:end); 
f_bot = lambda*(-im(:));

A = [A; A_bot]; 
f = [f; f_bot]; 

% New: Solve the system       % (x = A\B �����Է����� A*x = B ���
Z = A\f;                      %  AZ = f

Z = [0;-Z];
Z = reshape(Z,H,W);
Z = Z - min(Z(:));









