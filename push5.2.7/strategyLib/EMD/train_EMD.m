function [entryRecord,exitRecord,my_currentcontracts] = train_EMD(data,pro_information,T0,Rmean,StopLossRate,ConOpenTimes)
%UNTITLED Summary of this function goes here
%���еĻ������Ȱ�װEMD��غ�����
%   Detailed explanation goes here


%����
MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ
lots = 1; %��������

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
barLength = size(Close,1); %K������


%��������������Ҫ�ı���
entryRecord = []; %���ּ�¼
exitRecord = []; %ƽ�ּ�¼
my_currentcontracts = 0;  %�ֲ�����

%���Ա���
stoploss=zeros(barLength,1); %ֹ��۸�
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = 0; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������

MarketPosition = 0;

%Times = 0;
%���翪�ֵ�
%�ӵ��տ��̺������Ƴ���ΪT0�Ĵ���
%Action = datestr(Time(M+1),'HH:MM:SS');
%Action = Time(T0+1);%c���ڳ���ΪT0

%ֹ�����
%StopLossRate = 0.006;
C = 1 ;
beg = 0;
%�ӵڶ������� Ѱ�ҿ��̵�
a=day(Date);
b=diff(a);
index=b>0;
Begin = find(index>0,1)+1;
OpenMoment = Time(Begin);%���̵�
Action = Time(Begin + T0);%���ֵ� ��֤���ڳ���ΪT0 - 1

for i=1:barLength-1
    %�ٷֱ�ֹ��
    if MarketPosition~=0 %��ʼ����ֹ�� ��MarketPositon=0 ˵���Ѿ����й�ƽ��
        if MarketPosition == 1 %��ǰ����
            LossRate = (EntryPrice - Close(i-1))/EntryPrice;
            if LossRate > StopLossRate %ֹ�������ֵ
                [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                    Date(i),Time(i),Open(i),lots);
                MarketPosition = 0;
                EnrtyPrice = [ ];
                %                 GotoNextDay = 1;
            end
        else if MarketPosition == -1 %��ǰ����
                LossRate = (Close(i-1) - EntryPrice)/EntryPrice;
                if LossRate > StopLossRate %ֹ�������ֵ
                    [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                        Date(i),Time(i),Open(i),lots);
                    MarketPosition = 0;
                    EnrtyPrice = [ ];
                    %                    GotoNextDay = 1;
                end
            end
        end
    end
    %���翪��
    if Time(i) == OpenMoment %��ǿ���ʱ��
        beg  = i ;
    end
    if (Time(i) == Action) && (beg~=0) %ȷ���ѱ�ǿ��̵�
        winClose = Close(beg:i-1);%���ڳ���ΪT0
        %winClose = Close(i-T0:i-1);%���ڳ���ΪT0
        Output = emd(winClose); %EMD����
        residue = Output(end,:); %��������һ��Ϊʣ����rn;
        R = log(std(winClose'-residue)/std(residue)); %�õ��ж�ָ�� ����������R %winClose��Ҫ����
        if R < Rmean(C) %�г�����ƽ�ȶ�С����ֵ,˵������������������
            C = C + 1;
            EntryPrice = Open(i);
            %            GoToNextDay = 0; %�����н��� ��Ҫ����ֹ��
            if Close(i-1) > Open(beg) %T0ʱ�̹�ָ���ڿ��̼�,����
                [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                    Date(i),Time(i),EntryPrice,lots,ConOpenTimes);
                %isSucess�ǿ����Ƿ�ɹ��ı�־
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
                end
            else %tʱ�̹�ָ���ڿ��̼�,����
                [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                    Date(i),Time(i),EntryPrice,lots,ConOpenTimes);
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = -1;
                end
            end
        end
    end
    %��������ʱ����ƽ��
    %��ָƽ��ʱ��Ϊ15:15:00 �ǹ�ָΪ15:00:00
    if  ((((0.6243-Time(i))<0.0001)&&(strcmp(pro_information(1),'IF')~=1))||((0.6347-Time(i))<0.0001))
        %if  ((strcmp(datestr(Time(i),'HH:MM:SS'),'14:59:00')&&(strcmp(pro_information(1),'IF')~=1))||(strcmp(datestr(Time(i),'HH:MM:SS'),'15:14:00')))
        if MarketPosition == 1;
            exitPrice = Close(i);
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
                Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        if MarketPosition == -1;
            exitPrice = Close(i);
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
                Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        beg = 0;
    end
    %---------------ֹ������---------------%
    %=====================================%
    %     if BarsSinceEntry == 0
    %         AvgEntryPrice = mean(MyEntryPrice);
    %         HighestAfterEntry(i) = Close(i);
    %         LowestAfterEntry(i) = Close(i);
    %         if MarketPosition ~= 0
    %             HighestAfterEntry(i) = max(HighestAfterEntry(i),AvgEntryPrice);
    %             LowestAfterEntry(i) = min(LowestAfterEntry(i),AvgEntryPrice);
    %         end
    %     elseif BarsSinceEntry > 0
    %         HighestAfterEntry(i) = max(HighestAfterEntry(i),High(i));
    %         LowestAfterEntry(i) = min(LowestAfterEntry(i),Low(i));
    %     end
    %
    %     temp=AvgEntryPrice; %���ּ۸����
    %     if MarketPosition==1 && BarsSinceEntry > 0
    %         if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint) || abs(HighestAfterEntry(i-1) - (temp+TrailingStart*MinPoint)) < preciseV
    %             if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) || abs(Low(i) - (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) < preciseV
    %                 MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
    %                 if Open(i) < MyExitPrice
    %                     MyExitPrice = Open(i);
    %                 end
    %                 [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
    %                     Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %���ÿ��ּ۸�����
    %             end
    %         elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp - StopLossSet*MinPoint;
    %             if Open(i) < MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
    %                 Date(i),Time(i),MyExitPrice,1);
    %             MarketPosition = 0;
    %             BarsSinceEntry = 0;
    %             MyEntryPrice = []; %���ÿ��ּ۸�����
    %         end
    %     elseif MarketPosition==-1 && BarsSinceEntry > 0
    %         if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint) || abs(LowestAfterEntry(i-1) - (temp - TrailingStart*MinPoint)) < preciseV
    %             if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint)) || abs(High(i)-(LowestAfterEntry(i-1) + TrailingStop*MinPoint)) < preciseV %������ʾ���ڻ����
    %                 MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
    %                 if Open(i) > MyExitPrice
    %                     MyExitPrice = Open(i);
    %                 end
    %                 [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
    %                     Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %���ÿ��ּ۸�����
    %             end
    %         elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp+StopLossSet*MinPoint;
    %             if Open(i) > MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
    %                 Date(i),Time(i),MyExitPrice,1);
    %             MarketPosition = 0;
    %             BarsSinceEntry = 0;
    %             MyEntryPrice = []; %���ÿ��ּ۸�����
    %         end
    %     end
end


end