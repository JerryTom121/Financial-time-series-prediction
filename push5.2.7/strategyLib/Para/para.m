function [ output_args ] = para(strategy,data,pro_information,chris,pink,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%��������
%strategy:��������Ϊ�ַ���
%dataΪ��������
%pro_informationΪ��Ʒ����
%ConOpenTimesΪ�������ִ���
%���ϲ����������޸�
%chris,pinkΪ���Բ���
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
MyEntryPrice = []; %���ּ۸񣬱����ǿ��־��ۣ�Ҳ�ɸ�����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%

%����
%������ʼ��������
%��һ��
begin=1;
y1=Close(1:chris);
x=1:chris;
num=polyfit2(x,y1');
%num=polyfit(x,y1',2);
a1=num(1);b1=num(2);
%�ڶ���
y2=Close(1:chris+1);
x=1:chris+1;
num=polyfit2(x,y2');
%num=polyfit(x,y2',2);
a2=num(1);b2=num(2);
%workΪ�жϹյ��Ƿ�ȷ�ϵ�ʱ��
work=0;
%����һ��ͳ��ֹյ�����
if((2*a1*(chris+1)+b1)*(2*a2*(chris+1)+b2)<=0)
    work=chris+pink;
    a0=a2;b0=b2;
end
%��������������
%ÿ������
for i=chris+2:barLength-1
        
    %-----�����������Ϊ��ֹ������ֹ�����ɾ��------%
    %�漰��ֹ��ı�����HighestAfterEntry��LowestAfterEntry��BarsSinceEntry��MyEntryPrice
%     if i > 1
%         HighestAfterEntry(i) = HighestAfterEntry(i-1);
%         LowestAfterEntry(i) = LowestAfterEntry(i-1);
%     end
%     if MarketPosition~=0
%         BarsSinceEntry = BarsSinceEntry+1;
%     end
    %-----------------------------------------------%
    %-----------------------------------------------%
    
    %��������
    %a1Ϊǰһ��,a2Ϊ����,a0Ϊ�յ���ֵ�һ��
    if((i-begin)>chris)%��bar��ĿС��chris֮ǰ,���������
        y2=Close(begin:i);
        x=(begin:i);
        %x=(1:i-begin+1);
        num=polyfit2(x,y2');
        %num=polyfit(x,y2',2);
        a1=a2;b1=b2;
        a2=num(1);b2=num(2);%�˴��߼�����(?),��Ч������.10.13δ���
        if(i==work)%��֤�յ�
            if((a0*a2)>0)%���ƿ���,ȷ�Ϲյ�
                if(a2>0) %��������
                    isSucess = buy(strategy,Date(i+1),Time(i+1),Open(i+1),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
                    %isSucess�ǿ����Ƿ�ɹ��ı�־
                    if isSucess == 1
                        BarsSinceEntry = 0;
                        MyEntryPrice(1) = Open(i+1);
                        MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
                    end
                    %����������¼����
                else %�����Ƶ�
                    isSucess = sellshort(strategy,Date(i+1),Time(i+1),Open(i+1),1,ConOpenTimes);
                    if isSucess == 1
                        BarsSinceEntry = 0;
                        MyEntryPrice(1) = Open(i+1);
                        MarketPosition = -1;
                    end
                end
                begin=i;
            end
        else
            if(work>i);%�ڹյ��ѳ���,��δȷ���ڼ�,�����в���
            else
                %�жϹյ��Ƿ����
                %�����������۲�
                d1=2*a1*i+b1;
                d2=2*a2*i+b2;
                if(d1*d2<=0.001)%�յ���� �ص�����!
                    work=i+pink;
                    a0=a2;b0=b2;%������ʱ��������߲���
                end
            end
        end
    else continue;
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

