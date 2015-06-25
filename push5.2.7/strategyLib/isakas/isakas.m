function [ output_args ] = isakas(strategy,data,pro_information,con,ConOpenTimes)
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
% %���Ա���
% cycle=4;
% pricesmoothing=0.3;
% indexsmoothing=0.3;
% rangeperiods=35;
% MACDfast=12;
% MACDslow=26;
% MACDma=9;
% devition=2;
% moneyrisk=1;
% phase=Length_1-1;
% coeff=3*pi;
% len=Length_1*cycle+phase;
% 
% MACDvalue=EMA(Close,MACDfast)-EMA(Close,MACDslow);
% MACDmain=EMA(MACDvalue,MACDma);
% MACDsignal=MACDvalue-MACDmain;
% 
% con1=zeros(barLength,1);
% con2=zeros(barLength,1);
% con3=zeros(barLength,1);
% Trend=zeros(barLength,1);
% smoothedlocation=zeros(barLength,1);
% smoothedfish=zeros(barLength,1);
% ma=zeros(barLength,1);
% iHigh=zeros(barLength,1);
% iLow=zeros(barLength,1);
% upperband=zeros(barLength,1);
% lowerband=zeros(barLength,1);
% % weight=zeros(barLength,1);
% % sum=zeros(barLength,1);
% price=zeros(barLength,1);

MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%

%����
% for i=len*2-1:barLength
%     m=0;
%     for j=0:len-1
%         g=1/(coeff*m+1);
%         if m<=0.5
%             g=1;
%         end
%         b=cos(m*pi);
%         a=g*b;
%         price(i)=mean(Close(i-len-j+1:i));
%         sum(i)=sum(i)+a*price(i-1);
%         weight(i)=weight(i)+a; 
%         if m<1
%             m=m+1/(phase-1);
%         elseif m<len-1
%             m=m+(2*cycle-1)/(cycle*Length_1-1);
%         end        
%     end
% end

% 
% for i=len*2-1:barLength
    %Nonlagdot ָ��
%     m=0;
%     sum=0;
%     weight=0;
%     
%     for j = 0:len-1
%         g=1/(coeff*m+1);
%         if m<=0.5
%             g=1;
%         end
%         b=cos(m*pi);
%         a=g*b;
%         price(i)=mean(Close(i-len-j+1:i));  %%price
%         sum=sum+a*price(i-1);
%         weight=weight+a;
%         if m<1
%             m=m+1/(phase-1);
%         elseif m<len-1
%             m=m+(2*cycle-1)/(cycle*Length_1-1);
%         end
%     end
%     if weight(i)>0
%         ma(i)=(1+devition/100)*sum(i)/weight(i);
%     end
%     if filter>0 && abs(ma(i)-ma(i-1))<filter*MinPoint
%         ma(i)=ma(i-1);
%     end
%     if ma(i)-ma(i-1)>filter*MinPoint
%         con1(i)=1;
%     elseif ma(i-1)-ma(i)>filter*MinPoint
%         con1(i)=-1;
%     else
%         con1(i)=con1(i-1);
%     end
%     
%     
%     %fisher kuskusָ��
%     iHigh(i)=max(High(i-rangeperiods+1:i));  %%
%     iLow(i)=min(Low(i-rangeperiods+1:i));
%     if iHigh(i)-iLow(i)<0.1*MinPoint
%         iHigh(i)=iLow(i)+0.1*MinPoint;
%     end
%     greatrange=iHigh(i-1)-iLow(i-1);
%     midprice=(High(i-1)+Low(i-1))/2;
    
% %     if i==len*2+1
% %         smoothedlocation(i)=0;
% %         smoothedfish(i)=0;
% %         fisherindex=0;
% %         pricelocation=0;
% %     end
%     pricelocation=(midprice-iLow(i-1))/greatrange;
%     pricelocation=2*pricelocation-1;
%     
%     smoothedlocation(i)=pricesmoothing*smoothedlocation(i-1)+(1-pricesmoothing)*pricelocation;
%     if smoothedlocation(i)>0.99
%         smoothedlocation(i)=0.99;
%     end
%     if smoothedlocation(i)<-0.99
%         smoothedlocation(i)=-0.99;
%     end
%     
%     if 1-smoothedlocation(i)~=0
%         fisherindex=log((1+smoothedlocation(i))/(1-smoothedlocation(i)));
%     end
%     smoothedfish(i)=indexsmoothing*smoothedfish(i-1)+(1-indexsmoothing)*fisherindex;
%     if smoothedfish(i)>0
%         con2(i)=1;
%     elseif smoothedfish(i)<0
%         con2(i)=-1;
%     else
%         con2(i)=con2(i-1);
%     end
%     
%     %flattrend
% 
%     if MACDsignal(i)<MACDmain(i)
%         con3(i)=1;
%     elseif MACDsignal(i)>MACDmain(i)
%         con3(i)=-1;
%     else
%         con3(i)=con3(i-1);
%     end
%     
%     %bolling band
% 
%     upperband(i)=mean(Close(i-Length+1:i))+2*std(Close(i-Length+1:i));
%     lowerband(i)=mean(Close(i-Length+1:i))-2*std(Close(i-Length+1:i));
%     
%     if Close(i)>upperband(i-1)
%         Trend(i)=1;
%     elseif Close(i)<lowerband(i-1)
%         Trend(i)=-1;
%     else
%         Trend(i)=Trend(i-1);
%     end
% %     if Trend(i)>0 && lowerband(i)<lowerband(i-1)
% %         lowerband(i)=lowerband(i-1);
% %     end
% %     if Trend(i)<0 && upperband(i)<upperband(i-1)
% %         upperband(i)=upperband(i-1);
% %     end    
    
for i = 2:barLength    
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
    
    if MarketPosition~=1 && con(i)>0
        isSucess = buy(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
        %isSucess�ǿ����Ƿ�ɹ��ı�־
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
        end
    end
    if MarketPosition~=-1 && con(i)<0
        isSucess = sellshort(strategy,Date(i),Time(i),Open(i),1,ConOpenTimes);
        if isSucess == 1
            BarsSinceEntry = 0;
            MyEntryPrice(1) = Open(i);
            MarketPosition = -1;
        end
    end
     
end


end


