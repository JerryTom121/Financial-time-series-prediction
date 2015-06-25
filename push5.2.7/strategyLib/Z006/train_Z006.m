function [entryRecord,exitRecord,my_currentcontracts] = train_Z006(data,pro_information,ConOpenTimes,currentcontracts,swingprice,TrailingStart,TrailingStop,StopLossSet)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Z006 0.3�汾
%dataΪ�۸����ݣ�pro_infoΪ��Ʒ����
%k=1.6 ZigZag��ϳ̶�
%TrailingStart=72 ����ֹ����������
%TrailingStop=27 ����ֹ������
%StopLossSet=37 ֹ������
%14/10/11 19:39

%����
MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ
lots = 1; %��������

%����
preciseV = 0.09; %���ȱ�����������ֵ��ȵľ�������

%����
%K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Close,1); %K������

%��������������Ҫ�ı���
entryRecord = []; %���ּ�¼
exitRecord = []; %ƽ�ּ�¼
my_currentcontracts = currentcontracts;  %�ֲ�����

%���Ա���
stoploss=0; %ֹ��۸�
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = getMarketPosition(my_currentcontracts);
BarsSinceEntry = 0; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������

for i=3:barLength
    
    HighestAfterEntry(i) = HighestAfterEntry(i-1);
    LowestAfterEntry(i) = LowestAfterEntry(i-1);
    
    if MarketPosition~=0
        BarsSinceEntry = BarsSinceEntry+1;
    end
    %-------------��������--------------%
    %==================================%
    tranVar1 = High(i-1)-Low(i-1);
    tranVar2 = High(i-2)-Low(i-2);
    tranCon1 = (tranVar1 - tranVar2) > preciseV;
    if MarketPosition~=1 && (Low(i-1)>swingprice(i)) && tranCon1 && (Low(i-1)>Low(i-2))
        entryPrice = Open(i);
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),entryPrice,lots,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
        %isSucess�ǿ����Ƿ�ɹ��ı�־
        if isSucess == 1
            BarsSinceEntry = 0; %����ֹ���ɾ��
            MyEntryPrice(1) = entryPrice; %����ֹ���ɾ��
            stoploss=swingprice(i);
            MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
        end
    end
    if MarketPosition~=-1 && (High(i-1)<swingprice(i)) && tranCon1 && (High(i-1)<High(i-2))
        entryPrice = Open(i);
        [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
            Date(i),Time(i),entryPrice,lots,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = entryPrice;
            stoploss=swingprice(i);
            MarketPosition = -1;
        end
    end
    if MarketPosition == 1 && Close(i-1) < stoploss
        exitPrice = Open(i);
        [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
            Date(i),Time(i),exitPrice,lots);
        MarketPosition = 0;
        BarsSinceEntry = 0;
        MyEntryPrice = []; %���ÿ��ּ۸�
    end
    if MarketPosition == -1 && Close(i-1) > stoploss
        exitPrice = Open(i);
        [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
            Date(i),Time(i),exitPrice,lots);
        MarketPosition=0;
        BarsSinceEntry = 0;
        MyEntryPrice = []; %���ÿ��ּ۸�
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
        if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint)
            if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint))
                MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
                if Open(i) < MyExitPrice
                    MyExitPrice = Open(i);
                end
                [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %���ÿ��ּ۸�����
            end
        elseif Low(i) < (temp -StopLossSet*MinPoint)
            MyExitPrice = temp - StopLossSet*MinPoint;
            if Open(i) < MyExitPrice
                MyExitPrice=Open(i);
            end
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        end
    elseif MarketPosition==-1 && BarsSinceEntry > 0
        if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint)
            if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint))
                MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
                if Open(i) > MyExitPrice
                    MyExitPrice = Open(i);
                end
                [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),MyExitPrice,1);
                MarketPosition = 0;
                BarsSinceEntry = 0;
                MyEntryPrice = []; %���ÿ��ּ۸�����
            end
        elseif High(i) > (temp+StopLossSet*MinPoint)
            MyExitPrice = temp+StopLossSet*MinPoint;
            if Open(i) > MyExitPrice
                MyExitPrice=Open(i);
            end
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        end
    end
end

end