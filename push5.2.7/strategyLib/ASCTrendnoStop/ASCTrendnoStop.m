function [ output_args ] = ASCTrendnoStop(strategy,data,pro_information,risk,TrailingStart,TrailingStop,StopLossSet,value2,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%��������
%strategy:��������Ϊ�ַ���
%dataΪ��������
%pro_informationΪ��Ʒ����
%ConOpenTimesΪ�������ִ���
%���ϲ����������޸�
%k,nΪ���Բ���
%TrailingStart,TrailingStop,StopLossSet��ֹ�����������Ҫֹ��������

%------����Ϊ�̶������������޸�--------%
% ����
MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ


%����
preciseV = 2e-7; %���ȱ�����������ֵ��ȵľ�������
% 
% %����
% %K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������
% %---------------------------------------%
% %---------------------------------------%
% 
% %---------���±���������Ҫ�����޸�--------%
% %���Ա���
value10 = 3 + risk*2;
% value11 = value10;
x1 = 67 + risk;
x2 = 33 - risk;
% TrueCount = 0;
% value2 = zeros(barLength);
% WPR = zeros(barLength);
% 
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%
% 
% %����
% for i=value10+1:barLength
%     Range = sum(High(i-10:i-1)-Low(i-10:i-1))/10;
%     j = 1;
%     while (j<=10) && (TrueCount<1)
%         if abs(Open(i-j)-Close(i-j))>= Range*2
%             TrueCount = TrueCount + 1;
%         end
%         j = j+1;
%     end
%     if TrueCount >= 1
%         MRO1 = j;
%     else
%         MRO1 = -1;
%     end 
% 
%     j = 1;
%     TrueCount = 0;
%     while (j<7) && (TrueCount<1)
%         if(abs(Close(i-j-3)-Close(i-j))>=Range*4.6)
%             TrueCount = TrueCount + 1;
%         end
%         j = j+1;
%     end
%     if(TrueCount>=1)
%         MRO2 = j;
%     else
%         MRO2 = -1;
%     end
% 
%     if MRO1>-1
%         value11 = 3;
%     else
%         value11 = value10;
%     end
%     if MRO2>-1
%         value11 = 4;
%     else
%         value11 = value10;
%     end
% 
%     iHigh = max(High(i-value11+1:i));
%     iLow = min(Low(i-value11+1:i));
%     WPR(i) = (Close(i-value11)-iHigh)/(iHigh-iLow)*100;
%     value2(i) = 100 - abs(WPR(i-1));
% end
for i = 2:barLength

    %-----------------------------------------------%
    %-----------------------------------------------%
    
    if MarketPosition~=1 && value2(i-1)<x2
        isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
        %isSucess�ǿ����Ƿ�ɹ��ı�־
        if isSucess == 1
            MyEntryPrice(1) = Open(i);
            MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
        end
    end
    if MarketPosition~=-1 && value2(i-1)>x1
        isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    end
    
end

end

