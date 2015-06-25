function [entryRecord,exitRecord,my_currentcontracts] = train_WFFT(data,pro_information,con,ConOpenTimes)
%UNTITLED2 Summary of this function goes here
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
%MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ
%����
%preciseV = 2e-7; %���ȱ�����������ֵ��ȵľ�������

%����
%K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������

%��������������Ҫ�ı���
entryRecord = []; %���ּ�¼
exitRecord = []; %ƽ�ּ�¼
my_currentcontracts = 0;  %�ֲ�����

%---------------------------------------%
%---------------------------------------%

%---------���±���������Ҫ�����޸�--------%
%���Ա���
% a=2/(1+Length);   %��ֵ
% n=1:N;

MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%

%����
% 
% LLTvalue(1:2) = Close(1:2);    %LLT�߳�ʼ��
% for i = 2+1:barLength   %����LLT������
%     LLTvalue(i)=(a-0.25*a^2)*Close(i)+0.5*a^2*Close(i-1)-(a-0.75*a^2)*Close(i-2)+(2-2*a)*LLTvalue(i-1)-(1-a)^2*LLTvalue(i-2);
% end
%     d=diff(LLTvalue); %����
%     
%     MA(1:len-1) = Close(1:len-1);    %MAƽ��
% for j = len:barLength
%     MA(j) = mean(Close(j-len+1:j));
% end
%     MA = MA-mean(MA); %����ֱ������
%     
% for j = N:barLength
%     y = fft(MA(j-N+1:j));    %��һ��ʱ�䴰�ڽ��и���Ҷ�任
%     pow(1:N) = abs(y).^2;    %����һ��ʱ�䴰�ڹ�����ǿ��
%     if j==N                  %����ÿ�����ڵ�ǿ��
%         S(1:N-1) = (-10/log(10))*log(0.01./(1-(pow(1:N-1)./max(pow(1:N))))) ;
%     end
%     S(j) = (-10/log(10))*log(0.01./(1-(pow(N)./max(pow(1:N))))) ;
%     if S(j)<0
%         S(j) = 0;
%     end
% 
%      %����Ȩ��
%      k(1:N) = abs(q - S(1:N)); 
%      k(j) = abs(q - S(j)); 
% 
%      T(j) = sum(k(j-N+1:j).*n)/sum(k(j-N+1:j));  %��һ��ʱ�����е�ƽ������
%                                                  %��Ӧ����j����˲ʱ����
% end
             
for i=1:barLength
    if MarketPosition~=1 && con(i)==1    %����״̬
%         if d(i-2)>Dq    %б�ʴ���0������   
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
            %isSucess�ǿ����Ƿ�ɹ��ı�־
            if isSucess == 1
                BarsSinceEntry = 0; %����ֹ���ɾ��
                MyEntryPrice(1) = Open(i); %����ֹ���ɾ��
                MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
            end
    end
    if MarketPosition~=-1 && con(i)==-1    %����״̬
%         if d(i-2)<Dq  %б��С��0������
            [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                Date(i),Time(i),Open(i),1,ConOpenTimes);
            if isSucess == 1
                BarsSinceEntry = 0;
                MyEntryPrice(1) = Open(i);
                MarketPosition = -1;
            end
    end
    if con(i)==2
        if MarketPosition == 1
            MyExitPrice = Open(i);
            [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
              Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        elseif MarketPosition == -1
            MyExitPrice = Open(i);
            [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
              Date(i),Time(i),MyExitPrice,1);
            MarketPosition = 0;
            BarsSinceEntry = 0;
            MyEntryPrice = []; %���ÿ��ּ۸�����
        end
    end
end

end

