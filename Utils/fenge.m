%%�򵥵�ͼ��ָ��
function [D]=fenge(a,k)
copy=a;         % �ݴ�
a=a(:);        % ����a ���б��һ��
mi=min(a);     % ������

a=a-mi+1;                                %�����������a�����ֵΪ1
% ����ͼ��ֱ��ͼ
m=floor(max(a)+1);
h=zeros(1,m);
hc=zeros(1,m);
for i=1:m
    h(i)=sum(a(:)==i);                   %����m��bin��ͶƱ��ͶƱ�ֲ�Ϊh
end

ind=find(h);     % ��indҲ����ʵ�Ҷ�ֵ�ֲ�
hl = length(ind);                        % ����m-1����Ч��bin
% m = zeros(1,k);
mu=(1:k).*m/(k+1);% ����������ֵ          % (mu����������k����bin������ֵ


% ��ʼ����
oldmu=mu;
% ��ǰ����
for i=1:hl     % Ѱ�����ֵ
    c=abs(ind(i)-mu);                   % �ó�����һ������
    cc=find(c==min(c));
    hc(ind(i))=cc(1);                 % ��hc�ĳ���Ϊm��Ԫ������Ϊ��Ӧ����bin���
end
%����
for i=1:k
    b=find(hc==i);
    mu(i)=sum(b.*h(b))/sum(h(b));        %��mu������bin�󣬸���bin�������Ԫ������ֵ�ľ�ֵ
end
if mu==oldmu
    return;
end



% �Ƚϼ���
s=size(copy);
mask=zeros(s);
for i=1:s(1)
  for j=1:s(2)
    c=abs(copy(i,j)-mu);
    a=find(c==min(c));  
    mask(i,j)=a(1);                     % ����ÿ�����ش��Ϸָ����bin�ı��
  end
end

mu=mu+mi-1;   % ���õ�ǰ��Χ              % �����·ָ����ԭ��ԭʼǿ�ȷ�Χ
for i=1:k
    mu1(i)=uint8(mu(i));
end
q=0;                                    % ��mask��1��ʼ�ģ�qҲӦ�ô�1��ʼ
for i=1:s(1)
    for j=1:s(2)
        while q<=k  % kΪ�ָ�����       % ��
            if mask(i,j)==q
                D(i,j)=mu1(q);
                break;
            end
            q=q+1;
        end
        q=0;
    end
end
 
