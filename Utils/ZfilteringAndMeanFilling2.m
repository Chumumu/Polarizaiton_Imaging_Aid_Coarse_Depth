function [Z] = ZfilteringAndMeanFilling2(Z,CompareSpatialRange,DeltaZ,MeanFillRadius)
%MeanFillRadius���Ƽ�ֵΪ2����Ѱ����Χ5*5����ֵ��䡣
%�Ƚ�������������������CompareRange��Χ�����صĸ߶ȣ���DeltaZ��Χ�ڵ�����30%������Ϊ��2*CompareSpatialRange+1��^2������Ϊ�����
%���������ΧMeanFillRadius * MeanFillRadius�����أ������з�nan�����MeanFillRadius * MeanFillRadius�����֮һ
%��ȡ��ΧMeanFillRadius * MeanFillRadius�з�nan����ֵ�������㡣
%�汾���������
%��Zfiltering�������޸���i��j��ʼ��ΧΪ0�����⣬CompareSpatialRange�ĳ���CompareSpatialRange+1
    [row,col]=size(Z);

    for i=CompareSpatialRange+1:row-CompareSpatialRange
        for j=CompareSpatialRange+1:col-CompareSpatialRange
            if ~isnan(Z(i,j))
                ComparePixel=Z(i-CompareSpatialRange:i+CompareSpatialRange,j-CompareSpatialRange:j+CompareSpatialRange);
                ComparePixelDelta=abs(ComparePixel-Z(i,j));
                PixelNumInDeltaZ=sum(ComparePixelDelta<DeltaZ,'all');
                if  PixelNumInDeltaZ<0.3*(2*CompareSpatialRange+1)*(2*CompareSpatialRange+1)
                    referPixel=Z(i-MeanFillRadius:i+MeanFillRadius,j-MeanFillRadius:j+MeanFillRadius);
                    referTotalnub=(2*MeanFillRadius+1)^2 ;
                    refer_un_nan=~isnan(referPixel);
                        if sum(refer_un_nan(:)) > (referTotalnub/2)
                            lowToHighSort = tabulate(referPixel(:)); %tabulate�Զ��ӵ͵��������Զ�ȥ��nanֵ��
                            [un_nanNum,~]=size(lowToHighSort);
                            Z(i,j)= lowToHighSort(ceil(un_nanNum/2),1);
                        else
                            Z(i,j)=NaN;       
                        end
                end
            end
%            
%             if Z(i,j)>-1150
%                 Z(i,j)=NaN;
%             end
%             if Z(i,j)<-1450
%                 Z(i,j)=NaN;
%             end             
        end
    end
end

