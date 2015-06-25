function [ output_args ] = Z017(strategy,data,pro_information,k,n,TrailingStart,TrailingStop,StopLossSet,ConOpenTimes)
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
%����
MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ


%����
preciseV = 2e-7; %���ȱ�����������ֵ��ȵľ�������

%����
%K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������
%---------------------------------------%
%---------------------------------------%

%---------���±���������Ҫ�����޸�--------%
%���Ա���
smallswing = myZigZag(Close,k);
largeswing = myZigZag(Close,n);
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%

%����
for i=1:barLength
    
    %-----�����������Ϊ��ֹ������ֹ�����ɾ��------%
    %�漰��ֹ��ı�����HighestAfterEntry��LowestAfterEntry��BarsSinceEntry��MyEntryPrice
    if i > 1
        HighestAfterEntry(i) = HighestAfterEntry(i-1);
        LowestAfterEntry(i) = LowestAfterEntry(i-1);
    end
    if MarketPosition~=0
        BarsSinceEntry = BarsSinceEntry+1;
    end
    %-----------------------------------------------%
    %-----------------------------------------------%
    
    if MarketPosition~=1 && Open(i) > largeswing(i) && High(i) >= smallswing(i) && smallswing(i)~=largeswing(i)
        isSucess = buy(strategy,Date(i),Time(i),max(Open(i),smallswing(i)),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
        %isSucess�ǿ����Ƿ�ɹ��ı�־
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = max(Open(i),smallswing(i));
            MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
        end
    end
    if MarketPosition~=-1 && Open(i) < largeswing(i) && Low(i) <= smallswing(i) && smallswing(i)~=largeswing(i)
        isSucess = sellshort(strategy,Date(i),Time(i),min(Open(i),smallswing(i)),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = min(Open(i),smallswing(i));
            MarketPosition = -1;
        end
    end
    
    %---------------ֹ������---------------%
    %=====================================%
    if BarsSinceEntry == 0
        AvgEntryPrice = mean(MyEntryPrice);
        HighestAfterEntry(i) = Close(i);
        LowestAfterEntry(i) = Close(i);
        if MarketPosition ~= 0
            HighestAfterEntry(i) = max(HighestAfterEntry(i),AvgEntryPrice);
            LowestAfterEntry(i) = min(LowestAfterEntry(i),AvgEntryPrice);
        end
    elseif BarsSinceEntry > 0
        HighestAfterEntry(i) = max(HighestAfterEntry(i),High(i));
        LowestAfterEntry(i) = min(LowestAfterEntry(i),Low(i));
    end
    
    temp=AvgEntryPrice; %���ּ۸����
    if MarketPosition==1 && BarsSinceEntry > 0
        if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint) || abs(HighestAfterEntry(i-1) - (temp+TrailingStart*MinPoint)) < preciseV
            if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) || abs(Low(i) - (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) < preciseV
                MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
                if Open(i) < MyExitPrice
                    MyExitPrice = Open(i);
                end
                sell(strategy,Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %���ÿ��ּ۸�����
            end
        elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
            MyExitPrice = temp - StopLossSet*MinPoint;
            if Open(i) < MyExitPrice
                MyExitPrice=Open(i);
            end
            sell(strategy,Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        end
    elseif MarketPosition==-1 && BarsSinceEntry > 0
        if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint) || abs(LowestAfterEntry(i-1) - (temp - TrailingStart*MinPoint)) < preciseV
            if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint)) || abs(High(i)-(LowestAfterEntry(i-1) + TrailingStop*MinPoint)) < preciseV %������ʾ���ڻ����
                MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
                if Open(i) > MyExitPrice
                    MyExitPrice = Open(i);
                end
                buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %���ÿ��ּ۸�����
            end
        elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
            MyExitPrice = temp+StopLossSet*MinPoint;
            if Open(i) > MyExitPrice
                MyExitPrice=Open(i);
            end
            buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        end
    end
end

end

