%%简单的图像分割函数
function [D]=fenge(a,k)
copy=a;         % 暂存
a=a(:);        % 量化a 按列变成一列
mi=min(a);     % 处理负数

a=a-mi+1;                                %（经过处理后a中最低值为1
% 创建图像直方图
m=floor(max(a)+1);
h=zeros(1,m);
hc=zeros(1,m);
for i=1:m
    h(i)=sum(a(:)==i);                   %（在m个bin里投票，投票分布为h
end

ind=find(h);     % 此ind也是真实灰度值分布
hl = length(ind);                        % （有m-1个有效的bin
% m = zeros(1,k);
mu=(1:k).*m/(k+1);% 重置样本均值          % (mu向量里有着k个新bin的中心值


% 开始处理
oldmu=mu;
% 当前分类
for i=1:hl     % 寻求最近值
    c=abs(ind(i)-mu);                   % 得出来是一个向量
    cc=find(c==min(c));
    hc(ind(i))=cc(1);                 % （hc的长度为m，元素内容为对应的新bin编号
end
%重置
for i=1:k
    b=find(hc==i);
    mu(i)=sum(b.*h(b))/sum(h(b));        %（mu里代表分bin后，根据bin里的所有元素像素值的均值
end
if mu==oldmu
    return;
end



% 比较计算
s=size(copy);
mask=zeros(s);
for i=1:s(1)
  for j=1:s(2)
    c=abs(copy(i,j)-mu);
    a=find(c==min(c));  
    mask(i,j)=a(1);                     % （给每个像素打上分割类别bin的编号
  end
end

mu=mu+mi-1;   % 重置当前范围              % （将新分割类别还原到原始强度范围
for i=1:k
    mu1(i)=uint8(mu(i));
end
q=0;                                    % （mask从1开始的，q也应该从1开始
for i=1:s(1)
    for j=1:s(2)
        while q<=k  % k为分割的类别       % （
            if mask(i,j)==q
                D(i,j)=mu1(q);
                break;
            end
            q=q+1;
        end
        q=0;
    end
end
 
