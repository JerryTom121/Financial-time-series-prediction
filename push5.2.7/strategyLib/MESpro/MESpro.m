function saveEmotion = MESpro(strategy,data,pro_information,M,N,E,StopLossRate,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%�豣֤data��ʼ��һ��barΪ���տ���ʱ��bar
%MΪ���翪��ʱ��
%NΪ���翪��ʱ��
%EΪ������ֵ
%StopLossRateΪֹ��ٷֱ�

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

%���Ա���
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

MarketPosition = 0;

%GG = 1;
%��һ�ο��ֵ�
%�ӵ��տ��̺������Ƴ���ΪM�Ĵ���
ActionFirst = Time(M+1);
%�ڶ��ο��ֵ�
%���ֵ��������
for i = 1:barLength
    if (Time(i)-0.4666)<0.0001
        Begin = i;
        break;
    end
end
ActionSecond = Time(Begin+N);
for i=1:barLength-1
    %�ٷֱ�ֹ��
    if MarketPosition~=0 %��ʼ����ֹ�� ��MarketPositon=0 ˵���Ѿ����й�ƽ��
        if MarketPosition == 1 %��ǰ����
            LossRate = (EntryPrice - Close(i-1))/EntryPrice;
            if LossRate > StopLossRate %ֹ�������ֵ
                sell(strategy,Date(i),Time(i),Open(i),1);
                MarketPosition = 0;
                EnrtyPrice = [ ];
                %                 GotoNextDay = 1;
            end
        else if MarketPosition == -1 %��ǰ����
                LossRate = (Close(i-1) - EntryPrice)/EntryPrice;
                if LossRate > StopLossRate %ֹ�������ֵ
                    buyToCover(strategy,Date(i),Time(i),Open(i),1);
                    MarketPosition = 0;
                    EnrtyPrice = [ ];
                    %                    GotoNextDay = 1;
                end
            end
        end
    end
    %���翪��
    if Time(i) == ActionFirst
        for t = 1:M
            winClose = Close(i-M:i-M-1+t);
            DT = winClose - Close(i-M-1+t);%һ�����ڼ�ȥ��ǰ���̼�Close(i-M-1+t)
            %���س�
            if isempty(DT(find(DT>0)))==1
                DDser(t) = 0;
            else
                DDser(t) = max((DT(find(DT>0)))/Close(i-M-1+t));
            end
            %�������س�
            if isempty(DT(find(DT<0)))==1
                RDDser(t) = 0;
            else
                RDDser(t) = -min((DT(find(DT<0)))/Close(i-M-1+t));
            end
        end
        MDD = sum(DDser)/M;%ƽ�����س�
        MRDD = sum(RDDser)/M;%ƽ���������س�
        Emotion = min(MDD,MRDD);%�г������ȶ���
        saveEmotion(GG) = Emotion;
        GG = GG + 1;
        if Emotion < E %�г�����ƽ�ȶ�С����ֵ,˵������������������
            EntryPrice = Open(i);
            %            GoToNextDay = 0; %�����н��� ��Ҫ����ֹ��
            if Close(i-1) > Close(i-M) %tʱ�̹�ָ���ڿ��̼�,����
                isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
                %isSucess�ǿ����Ƿ�ɹ��ı�־
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
                end
            else %tʱ�̹�ָ���ڿ��̼�,����
                isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = -1;
                end
            end
        end
    end
    %��������ʱ����ƽ��
    if (Time(i)-0.4784)<0.0001 %11:29:00
        if MarketPosition == 1;
            exitPrice = Close(i);
            sell(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        if MarketPosition == -1;
            exitPrice = Close(i);
            buyToCover(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
    end
    %���翪��
    if Time(i) == ActionSecond
        for t = 1:N
            winClose = Close(i-N:i-N-1+t);
            DT = winClose - Close(i-N-1+t);%һ�����ڼ�ȥ��ǰ���̼�Close(i-M-1+t)
            %���س�
            if isempty(DT(find(DT>0)))==1
                DDser(t) = 0;
            else
                DDser(t) = max((DT(find(DT>0)))/Close(i-N-1+t));
            end
            %�������س�
            if isempty(DT(find(DT<0)))==1
                RDDser(t) = 0;
            else
                RDDser(t) = -min((DT(find(DT<0)))/Close(i-N-1+t));
            end
        end
        MDD = sum(DDser)/N;%ƽ�����س�
        MRDD = sum(RDDser)/N;%ƽ���������س�
        Emotion = min(MDD,MRDD);%�г������ȶ���
        %saveEmotion(GG) = Emotion;%��¼��ֵ���ȷ����Ż���Χ����
        %GG = GG + 1;
        if Emotion < E %�г�����ƽ�ȶ�С����ֵ,˵������������������
            EntryPrice = Open(i);
            %            GoToNextDay = 0; %�����н��� ��Ҫ����ֹ��
            if Close(i-1) > Close(i-N) %tʱ�̹�ָ���ڿ��̼�,����
                isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
                %isSucess�ǿ����Ƿ�ɹ��ı�־
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
                end
            else %tʱ�̹�ָ���ڿ��̼�,����
                isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
                if isSucess == 1
                    MyEntryPrice(1) = Open(i);
                    MarketPosition = -1;
                end
            end
        end
    end
    %��������ʱ����ƽ��
    if  ((((0.6243-Time(i))<0.0001)&&(strcmp(pro_information(1),'IF')~=1))||((0.6347-Time(i))<0.0001))
        %if  ((strcmp(datestr(Time(i),'HH:MM:SS'),'14:59:00')&&(strcmp(pro_information(1),'IF')~=1))||(strcmp(datestr(Time(i),'HH:MM:SS'),'15:14:00')))
        if MarketPosition == 1;
            exitPrice = Close(i);
            sell(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
        if MarketPosition == -1;
            exitPrice = Close(i);
            buyToCover(strategy,Date(i),Time(i),exitPrice,lots);
            MarketPosition = 0;
            EnrtyPrice = [ ];
        end
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
    %                 sell(strategy,Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %���ÿ��ּ۸�����
    %             end
    %         elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp - StopLossSet*MinPoint;
    %             if Open(i) < MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             sell(strategy,Date(i),Time(i),MyExitPrice,1);
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
    %                 buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
    %                 MarketPosition = 0;
    %                 BarsSinceEntry = 0;
    %                 MyEntryPrice = []; %���ÿ��ּ۸�����
    %             end
    %         elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
    %             MyExitPrice = temp+StopLossSet*MinPoint;
    %             if Open(i) > MyExitPrice
    %                 MyExitPrice=Open(i);
    %             end
    %             buyToCover(strategy,Date(i),Time(i),MyExitPrice,1);
    %             MarketPosition = 0;
    %             BarsSinceEntry = 0;
    %             MyEntryPrice = []; %���ÿ��ּ۸�����
    %         end
    %     end
    % end
    
end