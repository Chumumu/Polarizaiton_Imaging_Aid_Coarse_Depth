function [Z] = ZfilteringAndMeanFilling2(Z,CompareSpatialRange,DeltaZ,MeanFillRadius)
%MeanFillRadius的推荐值为2，即寻找周围5*5的中值填充。
%比较中心像素与上下左右CompareRange范围内像素的高度，若DeltaZ范围内的少于30%（总数为（2*CompareSpatialRange+1）^2），认为是噪点
%查找噪点周围MeanFillRadius * MeanFillRadius的像素，若其中非nan点大于MeanFillRadius * MeanFillRadius的五分之一
%则取周围MeanFillRadius * MeanFillRadius中非nan的中值来填充噪点。
%版本迭代情况：
%在Zfiltering基础上修复了i，j初始范围为0的问题，CompareSpatialRange改成了CompareSpatialRange+1
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
                            lowToHighSort = tabulate(referPixel(:)); %tabulate自动从低到高排序，自动去除nan值。
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

