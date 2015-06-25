function [tradeTime,Marketposition,StaticEquity,DynamicEquity,LongMargin,ShortMargin] = train_handleTradeProcedure(bardata,traderecord,TradingUnits,MarginRatio,TradingCost_info)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%fprintf('\n%s\n','���ڴ����׹���...');
[m,n] = size(traderecord);
recordRows = m;

%��ȡ�����׼�¼������
Type(:,1) = traderecord(:,1);                   %���ͷ����

entryTime = traderecord(:,2) + traderecord(:,3);    %����ʱ��
exitTime = traderecord(:,5) + traderecord(:,6);     %ƽ��ʱ��

entryprice(:,1) = traderecord(:,4);             %���ּ۸�
exitprice(:,1) = traderecord(:,7);     %ƽ�ּ۸�
lots(:,1) = traderecord(:,8);         %����

[m,n] = size(bardata);
Close = bardata(:,6);
barLength = m;

tradeTime = bardata(:,1) + bardata(:,2);    %����ʱ��

%ģ��ȫ�̽��ױ�������
entrypos = 1;   %���ٿ���ʱ��
exitpos = 1;    %����ƽ��ʱ��
Marketposition = zeros(barLength,1);
myOpenIntRecord = zeros(1,2);   %��¼�ֲּ�¼����һ��Ԫ��Ϊ���ּ�¼�±꣬�ڶ���Ϊ��Ӧ�˽��ּ�¼�ܵ�����
myOpenInt = zeros(barLength,1);          %��¼Ŀǰ�ֲ���
openIntLength = 0;
startPos = find(tradeTime==entryTime(1,:));   %�ҳ���һ�ο��ֵ�ʱ��

%��¼�ʲ��仯����
LongMargin=zeros(barLength,1);              %��ͷ��֤��
ShortMargin=zeros(barLength,1);             %��ͷ��֤��
DynamicEquity=repmat(1e6,barLength,1);      %��̬Ȩ��,��ʼ�ʽ�Ϊ100W
StaticEquity=repmat(1e6,barLength,1);       %��̬Ȩ��,��ʼ�ʽ�Ϊ100W

for i=startPos:barLength
    if i > 1
        myOpenInt(i) = myOpenInt(i-1);
        Marketposition(i) = Marketposition(i-1);
    end
    %�����ʲ��仯
    OpenPosPrice = 0;
    my_profit = 0;      %�������
    
    %ģ�⽻�׹���
    %�����ּ�¼
    while entrypos<=recordRows && tradeTime(i,:)==entryTime(entrypos,:) %��while����ͬһʱ����������
        if Type(entrypos)==1
            Marketposition(i) = 1;
        else
            Marketposition(i) = -1;
        end
        openIntLength = openIntLength + 1;
        myOpenIntRecord(openIntLength,1:2) = [entrypos,lots(entrypos)];
        entrypos = entrypos + 1;
    end
    %����ƽ�ּ�¼
    while exitpos<=recordRows && tradeTime(i,:)==exitTime(exitpos,:)    %��while����ͬһʱ���Բ�ͬ�۸�ƽ��,�˴����迼����ƽ�ּ�¼����ʱmyOpenIntRecord�Ѿ�Ϊ�գ�
        exitNum = lots(exitpos);   %���ƽ������                         %��������ڱ������ǲ����ܳ��֣���Ϊ�����н��ֲ���ƽ��
        k = 1;
        while k <= openIntLength
            if myOpenIntRecord(k,2) == exitNum   %ƽ�������ڵ�һ��������
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info);
                myOpenIntRecord(k,:) = [];
                k = k -1;
                openIntLength = openIntLength - 1;
                exitpos = exitpos+1;
                break;      %ƽ���������ѭ��
            elseif myOpenIntRecord(k,2) > exitNum     %��һ�����ּ�¼����������ƽ����
                myOpenIntRecord(k,2) =  myOpenIntRecord(k,2)-exitNum;
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info); %������Ŀ��ּ۸���ƽ�ֶ�Ӧ�Ŀ��ּ�¼������Ȩ��Ŀ��ּ۸������гֲֵ����п��ּ۸�
                exitpos = exitpos+1;
                break;   %ƽ���������ѭ��
            else            %��һ�����ּ�¼������С��ƽ������������齨�ּ�¼
                lots(exitpos) = exitNum - myOpenIntRecord(k,2);      %����exitpos����ƽ������
                exit_OpenPosPrice = entryprice(myOpenIntRecord(k,1));
                my_profit = my_profit + train_compProfit(Type(myOpenIntRecord(k,1)),exitprice(exitpos),exit_OpenPosPrice,TradingUnits,exitNum,TradingCost_info); %������Ŀ��ּ۸���ƽ�ֶ�Ӧ�Ŀ��ּ�¼������Ȩ��Ŀ��ּ۸������гֲֵ����п��ּ۸�
                myOpenIntRecord(k,:)=[];
                k = k-1;
                openIntLength = openIntLength - 1;
            end
            k = k + 1;
        end

    end
    
    myOpenInt(i) = sum(myOpenIntRecord(:,2));
    if myOpenInt(i) == 0
        Marketposition(i) = 0;
    else
        for num=1:length(myOpenIntRecord(:,1))
            OpenPosPrice = OpenPosPrice+entryprice(myOpenIntRecord(num,1))*myOpenIntRecord(num,2);    %�������ʽ�
        end
    end
    if i>1
        if Marketposition(i) == 0
            LongMargin(i)=0;                            %��ͷ��֤��
            ShortMargin(i)=0;                           %��ͷ��֤��
            StaticEquity(i)=StaticEquity(i-1)+my_profit;          %��̬Ȩ��
            DynamicEquity(i)=StaticEquity(i);           %��̬Ȩ��
        elseif Marketposition(i) == 1
            LongMargin(i)=Close(i)*myOpenInt(i)*TradingUnits*MarginRatio;
            ShortMargin(i) = 0;
            StaticEquity(i)=StaticEquity(i-1)+my_profit;
            DynamicEquity(i)=StaticEquity(i)+(Close(i)*myOpenInt(i)-OpenPosPrice)*TradingUnits;
        else
            LongMargin(i) = 0;
            ShortMargin(i)=Close(i)*myOpenInt(i)*TradingUnits*MarginRatio;
            StaticEquity(i)=StaticEquity(i-1)+my_profit;
            DynamicEquity(i)=StaticEquity(i)+(OpenPosPrice-Close(i)*myOpenInt(i))*TradingUnits;
        end
    end
end
%fprintf('\n%s\n','�����׹������...');
end


