function [obj,completeEntryRecord,completeExitRecord,mytraderecord,openExitRecord,DynamicEquity_List] = reportVar(strategy,bardata,pro_information,isMoveOn,varargin)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%��ʼ�ʽ�
originalMoney = 1e6;
isTrain = varargin{1};
%Ʒ����Ϣ
pinPrefix = pro_information{1};
TradingUnits = cell2mat(pro_information(:,2));       %���׵�λ
MinPoint = cell2mat(pro_information(:,3));  %��С�䶯��λ
MarginRatio = cell2mat(pro_information(:,6));        %��֤����
TradingCost_info = cell2mat(pro_information(:,5));  %���׷���


%���������Ľ���ƽ�ּ�¼�Ͳü���ʣ��ֲ����Ľ�ƽ�ּ�¼��������Ϊ�˱��ֺ���Ĵ��������޸�,������Ϊ������������
[ completeEntryRecord,completeExitRecord,entryRecord,exitRecord ] = genEntryExitRecord(strategy,isMoveOn,MinPoint);

%�����Ŵ��㷨�Ľ��׼�¼
openExitRecord = genOpenExitRecord(completeEntryRecord,completeExitRecord,pinPrefix,TradingUnits,MarginRatio,TradingCost_info);

%���ɽ��׼�¼
[traderecord,isExitLeft] = genTradeRecord(entryRecord,exitRecord);

%�����׼�¼δƽ�ּ�¼
if isExitLeft == 1
    repairedRec = zeros(1,3);
    repairedRec(1:2) = bardata(end,1:2);
    repairedRec(3) = bardata(end,6);
    traderecord = handleLeftTraderecord(traderecord,repairedRec);
end

%�����׼�¼Ϊ�ջ���Ŀǰ���ڲ��Խ׶Σ��������ָ����Ϊ-Inf�ҷ���
if size(traderecord,1) == 0 || isTrain == 0
    openExitRecord = [];
    mytraderecord = {};
    DynamicEquity_List = {};
    profitRet = -Inf;
    CumNetRetStdOfTradeRecord = -Inf;
    maxDDOfTradeRecord = -Inf;
    maxDDRetOfTradeRecord = -Inf;
    LotsWinTotalDLotsTotal = -Inf;
    AvgWinLossRet = -Inf;
    obj = [profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet];
    return;
end

mytraderecord = num2cell(traderecord);
mytraderecord(:,2) = cellstr(datestr(traderecord(:,2),'yyyy-mm-dd'));
mytraderecord(:,3) = cellstr(datestr(traderecord(:,3),'HH:MM:SS'));
mytraderecord(:,5) = cellstr(datestr(traderecord(:,5),'yyyy-mm-dd'));
mytraderecord(:,6) = cellstr(datestr(traderecord(:,6),'HH:MM:SS'));

%���ݽ��׼�¼�õ�ÿ����¼�������
[Type,Lots,NetMargin,RateOfReturn,CostSeries] =...
    handleTradeRecord(traderecord,TradingUnits,TradingCost_info);

%���׼�¼����
RecLength = length(NetMargin);


%�ۼƾ���
CumNetMargin=cumsum(NetMargin);

%�ɽ��׼�¼�������Գ�ʼ�ʽ���ۼ������ʱ�׼��
CumNetRetStdOfTradeRecord = std(CumNetMargin/originalMoney);

addMoney = min(CumNetMargin);
if addMoney <= 0
    addMoney = abs(addMoney);
else
    addMoney = 0;
end

if length(CumNetMargin) > 1
    %�ɽ��׼�¼����õ������س�ֵ�Լ����س���
    maxDDOfTradeRecord = maxdrawdown(CumNetMargin+addMoney,'arithmetic');
    maxDDRetOfTradeRecord = maxdrawdown(CumNetMargin+addMoney+originalMoney);
else
     maxDDOfTradeRecord = -Inf;
     maxDDRetOfTradeRecord = -Inf;
end

mytraderecord(:,9) = num2cell(CumNetMargin);
mytraderecord(:,10) = num2cell(CostSeries);


%�ۼ�������
CumRateOfReturn=cumsum(RateOfReturn);


%�������������ձ���
SharpRet = (mean(RateOfReturn)*length(RateOfReturn))/(std(RateOfReturn)*sqrt(length(RateOfReturn)));
%save('D:\MatlabWork\program\����\���Լ��ƽ�\RateOfReturn','RateOfReturn','NetMargin');
%-------------------------���׻���------------------------------------
%���ݽ��׼�¼�õ�ÿ��K���ʲ��仯����

%������
ProfitTotal=sum(NetMargin);
ProfitLong=sum(NetMargin(Type==1));
ProfitShort=sum(NetMargin(Type==-1));

%�������ʣ�������/��ʼ�ʽ�
profitRet = ProfitTotal/originalMoney;

%��ӯ��
WinTotal=sum(NetMargin(NetMargin>0));
temp=NetMargin(Type==1);
WinLong=sum(temp(temp>0));
temp=NetMargin(Type==-1);
WinShort=sum(temp(temp>0));

%ƽ��ӯ��
AvgWinTotal = WinTotal/length(NetMargin(NetMargin>0));

%�ܿ���
LoseTotal=sum(NetMargin(NetMargin<0));
temp=NetMargin(Type==1);
LoseLong=sum(temp(temp<0));
temp=NetMargin(Type==-1);
LoseShort=sum(temp(temp<0));

%ƽ������
AvgLossTotal = LoseTotal/length(NetMargin(NetMargin<0));

%��ӯ��/�ܿ���
WinTotalDLoseTotal=abs(WinTotal/LoseTotal);
WinLongDLoseLong=abs(WinLong/LoseLong);
WinShortDLoseShort=abs(WinShort/LoseShort);

%ƽ������/ƽ������
AvgWinLossRet = AvgWinTotal/AvgLossTotal;

%��������
LotsTotal = sum(Lots);
LotsLong= sum(Lots(Type==1));
LotsShort=sum(Lots(Type==-1));

%ӯ������
LotsWinTotal =  sum(Lots(NetMargin>0));
temp=NetMargin(Type==1);
LotsWinLong = sum(Lots(temp>0));
temp=NetMargin(Type==-1);
LotsWinShort = sum(Lots(temp>0));

%��������
LotsLoseTotal = sum(Lots(NetMargin>0));
temp=NetMargin(Type==1);
LotsLoseLong = sum(Lots(temp<0));
temp=NetMargin(Type==-1);
LotsLoseShort = sum(Lots(temp<0));

%��ƽ����
temp=NetMargin(Type==1);
LotsDrawLong = sum(Lots(temp==0));
temp=NetMargin(Type==-1);
LotsDrawShort = sum(Lots(temp==0));
LotsDrawTotal=LotsDrawLong+LotsDrawShort;

%ӯ������
LotsWinTotalDLotsTotal = LotsWinTotal/LotsTotal;
LotsWinLongDLotsLong = LotsWinLong/LotsLong;
LotsWinShortDLotsShort = LotsWinShort/LotsShort;

%���ӯ��
MaxWinTotal=max(NetMargin(NetMargin>0));
temp=NetMargin(Type==1);
MaxWinLong=max(temp(temp>0));
temp=NetMargin(Type==-1);
MaxWinShort=max(temp(temp>0));

%������
MaxLoseTotal=min(NetMargin(NetMargin<0));
temp=NetMargin(Type==1);
MaxLoseLong=min(temp(temp<0));
temp=NetMargin(Type==-1);
MaxLoseShort=min(temp(temp<0));

%���׳ɱ��ϼ�
CostTotal=sum(CostSeries);
temp=CostSeries(Type==1);
CostLong=sum(temp);
temp=CostSeries(Type==-1);
CostShort=sum(temp);
%----------------------�ö�̬Ȩ������ı�����ÿ��K�߾���------------------------%
% [Date,pos,StaticEquity,DynamicEquity,LongMargin,ShortMargin] = ...
%     handleTradeProcedure(bardata,traderecord,TradingUnits,MarginRatio,TradingCost_info);
% 
% %K�߳���
% barLength = length(Date);
% 
% % %========�ϵĻس����ݼ��㣬���������س�ʱ��=========%
% % retracement=zeros(barLength,1);  
% % retracementTime=zeros(barLength,1);
% % BackRatio = zeros(barLength,1);
% % for i=1:barLength
% %     [maxD, index] = max(DynamicEquity(1:i));
% %     if maxD==DynamicEquity(i)
% %         retracement(i) = 0;
% %         BackRatio(i) = 0;
% %         retracementTime(i) = 0;
% %     else 
% %         retracement(i) = DynamicEquity(i)-maxD;
% %         BackRatio(i) = retracement(i)/maxD;
% %         retracementTime(i) = round( Date(i) - Date(index) );
% %     end
% % end
% % 
% % %���س�
% % [value,D] = min(retracement);
% % maxRetracement = abs(value);
% % %���س�����
% % maxRetracementRet = abs(min(BackRatio))*100;
% % %���س�����(������)
% % maxRetracementTime = retracementTime(D);
% % %��س����ڣ������㣩
% % longestRetracementTime = max(retracementTime);
% % %���س�����ʱ��
% % maxRectracementDate = datestr(Date(D),'yyyy-mm-dd HH:MM:SS');
% % %=========�ϵĻس����ݼ��㣬���������س�ʱ��=========%
% 
% % %���س�
% % [value,D] = maxdrawdown(DynamicEquity,'arithmetic');
% % %���س�����
% % maxRetracementRet = maxdrawdown(DynamicEquity);
% % %���س�����(������)
% % maxRetracementTime = round(Date(D(2)) - Date(D(1)));
% 
% 
% %�ɶ�̬Ȩ���������Գ�ʼ�ʽ���ۼ������ʱ�׼��
% CumNetRetStdOfDy = std(DynamicEquity/originalMoney - 1);
% 
% addMoney = min(DynamicEquity);
% if addMoney <= 0
%     addMoney = abs(addMoney) + 1;
% else
%     addMoney = 0;
% end
% 
% if length(DynamicEquity) > 1
%     %���ն�̬Ȩ�����õ������س�ֵ�Լ����س���
%     maxDDOfDy = maxdrawdown(DynamicEquity+addMoney,'arithmetic');
%     maxDDRetOfDy = maxdrawdown(DynamicEquity+addMoney);
% else
%     maxDDOfDy = 0;
%     maxDDRetOfDy = 0;
% end
% 
% %�洢��̬Ȩ�����һ��Ϊʱ�䣬�ڶ���Ϊ��̬Ȩ�棬������Ϊpos
% DynamicEquity_List = {};
% DynamicEquity_List(:,1) = cellstr(datestr(Date,'yyyy-mm-dd HH:MM:SS'));
% DynamicEquity_List(:,2) = cellstr(repmat(',',length(Date),1));
% DynamicEquity_List(:,3) = num2cell(DynamicEquity);
% DynamicEquity_List(:,4) = cellstr(repmat(',',length(Date),1));
% DynamicEquity_List(:,5) = num2cell(pos);
% 
% %�տ�ʼʱ��ͽ���ʱ������,���������������Ƶ���,��û��ǸĽ�Ϊÿ��Ʒ�ֶ�Ӧȷ��������
% temp = day(Date);
% temp = find((temp(1:end-1)-temp(2:end))~=0,1); %��������������0����ÿ������һ��K��
% begDate = Date(temp+1);
% endDate = Date(temp);
% begHour = hour(begDate); begMin = minute(begDate); begSec = second(begDate);
% endHour = hour(endDate); endMin = minute(endDate); endSec = second(endDate);
% 
% %���ݶ�̬Ȩ�����ۼ�������
% CumDynamicRet = DynamicEquity/DynamicEquity(1) - 1;
% 
% %���ݾ�̬Ȩ�����ۼ�������
% CumStaticRet = StaticEquity/StaticEquity(1) - 1;
% 
% %��������&�ۼ�������
% Daily=Date(hour(Date)==begHour  & minute(Date)==begMin & second(Date)==begSec);
% DailyEquity=DynamicEquity(hour(Date)==begHour  & minute(Date)==begMin & second(Date)==begSec);
% 
% %��������ֹֻ��һ�����ݣ�����tick2ret�����
% if length(Daily) > 1
%     DailyRet=tick2ret(DailyEquity);  %��������
% else
%     DailyRet = CumStaticRet(end);
% end
% 
% %���ݶ�̬Ȩ�������ۼ�������
% DailyCumDynamicRet = CumDynamicRet(hour(Date)==endHour  & minute(Date)==endMin & second(Date)==endSec);
% 
% %���ݾ�̬Ȩ�������ۼ�������
% DailyCumStaticRet = CumStaticRet(hour(Date)==endHour  & minute(Date)==endMin & second(Date)==endSec);
% 
% %��������
% WeeklyNum=weeknum(Daily);    %weeknum������һ��ĵڼ���
% Weekly=[Daily((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);Daily(end)];
% WeeklyEquity=[DailyEquity((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Weekly) > 1
%     WeeklyRet=tick2ret(WeeklyEquity);   %��������
% else
%     WeeklyRet = CumStaticRet(end);
% end
% 
% %���ݶ�̬Ȩ�������ۼ�������
% WeeklyCumDynamicRet = [DailyCumDynamicRet((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %���ݾ�̬Ȩ�������ۼ�������
% WeeklyCumStaticRet = [DailyCumStaticRet((WeeklyNum(1:end-1)-WeeklyNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %��������
% MonthNum=month(Daily);
% Monthly=[Daily((MonthNum(1:end-1)-MonthNum(2:end))~=0);Daily(end)];
% MonthlyEquity=[DailyEquity((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Monthly) > 1
%     MonthlyRet=tick2ret(MonthlyEquity);     %��������
% else
%     MonthlyRet = CumStaticRet(end);
% end
% 
% %���ݶ�̬Ȩ�������ۼ�������
% MonthlyCumDynamicRet = [DailyCumDynamicRet((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %���ݾ�̬Ȩ�������ۼ�������
% MonthlyCumStaticRet = [DailyCumStaticRet((MonthNum(1:end-1)-MonthNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %��������
% YearNum=year(Daily);
% Yearly=[Daily((YearNum(1:end-1)-YearNum(2:end))~=0);Daily(end)];
% YearlyEquity=[DailyEquity((YearNum(1:end-1)-YearNum(2:end))~=0);DailyEquity(end)];
% 
% if length(Yearly) > 1
%     YearlyRet=tick2ret(YearlyEquity);       %��������
%     YearSharp = (mean(YearlyRet)*length(YearlyRet))/(std(YearlyRet)*sqrt(length(YearlyRet)));
% else
%     YearlyRet = CumStaticRet(end);
%     YearSharp = 0; %����һ��û���껯���ձ�
% end
% 
% %���ݶ�̬Ȩ�������ۼ�������
% YearlylyCumDynamicRet = [DailyCumDynamicRet((YearNum(1:end-1)-YearNum(2:end))~=0);DailyCumDynamicRet(end)];
% 
% %���ݾ�̬Ȩ�������ۼ�������
% YearlyCumStaticRet = [DailyCumStaticRet((YearNum(1:end-1)-YearNum(2:end))~=0);DailyCumStaticRet(end)];
% 
% %�ֲ�ʱ��
% HoldingDays=round(round(Date(end)-Date(1))*(length(pos(pos~=0))/barLength));%�ֲ�ʱ��
% 
% %��Ч������
% TrueRatOfRet=(DynamicEquity(end)-DynamicEquity(1))/max(max(LongMargin),max(ShortMargin));

% obj.ProfitTotal = ProfitTotal;
% obj.CumNetRetStd = CumNetRetStd;
% obj.maxDD = maxDD;
% obj.LotsWinTotalDLotsTotal = LotsWinTotalDLotsTotal;
% obj.AvgWinLossRet = AvgWinLossRet;
% objNum = 9;
% obj = zeros(objNum,1);
% obj(1:end) = [ProfitTotal;CumNetRetStdOfTradeRecord;CumNetRetStdOfDy;maxDDOfTradeRecord;maxDDRetOfTradeRecord;...
%     maxDDOfDy;maxDDRetOfDy;LotsWinTotalDLotsTotal;AvgWinLossRet];
DynamicEquity_List = {};
obj = [profitRet,CumNetRetStdOfTradeRecord,maxDDOfTradeRecord,maxDDRetOfTradeRecord,LotsWinTotalDLotsTotal,AvgWinLossRet];

end

