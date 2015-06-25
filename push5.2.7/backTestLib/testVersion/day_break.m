function total_profit=day_break(bardata,f)

%���ݿ������Լ���ȡ���� begin
pro = 'IF888';
Freq = 'M5';
strategy = 'day_break';
%������ر������� begin
status = 0; %��¼�������գ�1���࣬-1����
profit = [];
totalprofit = [];
%������ر������� end

%Ʒ�ֲ���
Lots=1;                                       %��������
[m,n] = size(bardata);
minuteClose = bardata(:,6);
minuteOpen = bardata(:,3);
minuteHigh = bardata(:,4);
minuteLow = bardata(:,5);
date = bardata(:,1);
time = bardata(:,2);
minuteRows = m;
entryCount = 0; %���ּ۸�ʱ�����
exitCount = 0;%ƽ�ּ۸�ʱ�����
con=0;
day_con=0;%�ж��Ƿ�Ϊ�µ�һ��
%������ͻ��
for i=1:minuteRows
    if con==0
        up=minuteOpen(i)*(1+f*0.001);
        down=minuteOpen(i)*(1-f*0.001);
        openD=minuteOpen(i); 
        con=1; 
    end
    
    if minuteHigh(i)>up && day_con==0
        if(status==0)
            entryCount = entryCount + 1;
            entryprice(entryCount) = max([up,minuteOpen(i)]);    %��¼���ּ۸�
            entryDate(entryCount,:) = date(i,:);  %��¼����ʱ��
            entryTime(entryCount,:) = time(i,:);
            %disp(entryprice(entryCount))
            %buy(strategy,pro,Freq,entryDate(entryCount,:),entryTime(entryCount,:),entryprice(entryCount),Lots);
            status=1;
            day_con=1;
        end
    end
    if minuteLow(i)<down && day_con==0
        if(status==0)
            entryCount = entryCount + 1;
            entryprice(entryCount) = min([down,minuteOpen(i)]);    %��¼���ּ۸�
            entryDate(entryCount,:) = date(i,:);  %��¼����ʱ��
            entryTime(entryCount,:) = time(i,:);
            %disp(entryprice(entryCount))
            %sellsort(strategy,pro,Freq,entryDate(entryCount,:),entryTime(entryCount,:),entryprice(entryCount),Lots);
            status=-1;
            day_con=1;
        end
    end
    if status==1
        if (minuteLow(i)<openD) && (time(i,:)~=entryTime(entryCount,:))
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %��¼ƽ��ʱ��
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = min([minuteOpen(i),openD]); %��¼ƽ�ּ۸�
            %sell(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (exitprice(exitCount) - entryprice(entryCount))*Lots*300 - 10; %ƽ��
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
            day_con=1;
        end
    end
    if status==-1
        if (minuteHigh(i)>openD) && (time(i,:)~=entryTime(entryCount,:))
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %��¼ƽ��ʱ��
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = max([minuteOpen(i),openD]); %��¼ƽ�ּ۸�
            %buyToCover(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (entryprice(entryCount) - exitprice(exitCount))*Lots*300-10; %ƽ��
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
    end
    if i==minuteRows || date(i,:)~=date(i+1,:) %��ĩ
        con=0;
        day_con=0;
        if status==1
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %��¼ƽ��ʱ��
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = minuteClose(i); %��¼ƽ�ּ۸�
            %sell(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (exitprice(exitCount) - entryprice(entryCount))*Lots*300 - 10; %ƽ��
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
        if status==-1
            exitCount = exitCount + 1;
            exitDate(exitCount,:) = date(i,:);   %��¼ƽ��ʱ��
            exitTime(exitCount,:) = time(i,:);
            exitprice(exitCount) = minuteClose(i); %��¼ƽ�ּ۸�
            %buyToCover(strategy,pro,Freq,exitDate(exitCount,:),exitTime(exitCount,:),exitprice(exitCount),Lots);
            profit(exitCount) = (entryprice(entryCount) - exitprice(exitCount))*Lots*300-10; %ƽ��
            totalprofit(exitCount) = sum(profit(1:end));
            status=0;
        end
        
    end
end

% if entryCount > 1
%    plot(totalprofit(1:end));
% end
total_profit=totalprofit(end);
%report('day_break','IF888','M5');
% save data;

        
        
        

