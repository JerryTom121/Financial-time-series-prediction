
%-------�����û�����----------%
[testPro_list,testFreq_list,begD,endD,isMinPointOn,ConOpenTimes,trainDay_Length,testDay_Length,opt_Way] = loadTestInfoConfig();

load([testPro_list{1},'_',testFreq_list{1}]);
pinPrefix = cell2mat(regexp(testPro_list{1},'[^\d]','match'));
load([pinPrefix,'_pro_info']);
%�����ⲿ�ֽ�ȡ������ȡ����
begNum = datenum(begD); endNum = datenum(endD);
%��ȡminuteData
Date = minuteData(:,1);
dbeg = find(Date>=begNum,1); %�ҵ���ȡ���ݵ���ʼ�±�
dend = find(Date<=endNum); %�����±�
dend = dend(end);
minuteData = minuteData(dbeg:dend,:);
%��ȡbardata
Date = bardata(:,1);
dbeg = find(Date>=begNum,1); %�ҵ���ȡ���ݵ���ʼ�±�
dend = find(Date<=endNum); %�����±�
dend = dend(end);
bardata = bardata(dbeg:dend,:);
%��ȡ���ּ۸�
Date = bardata(:,1); Time = bardata(:,2);
Open = bardata(:,3); High = bardata(:,4);
Low = bardata(:,5); Close = bardata(:,6);
Vol = bardata(:,7);

%----------MES����--------%
%���Բ���
strategy = 'MESpro';
% M = '10:04:00'; %���翪��ʱ�� ���ڳ���(��9:15:00��ʼ)
% N = '13:33:00'; %���翪��ʱ�� ���ڳ���(��11:12:00��ʼ)
M = 50;
N = 50;
E = 0.0009; %ƽ�ȶ���ֵ
StopLossRate = 0.005 ;%ֹ����ֵ
%---------���԰汾---------%
tic
MESpro(strategy,bardata,pro_information,M,N,E,StopLossRate,ConOpenTimes);
[mytraderecord,openExitRecord,DynamicEquity_List] = reportVar(strategy,bardata,pro_information);
toc
%--------ѵ���汾----------%
tic
[profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy] = train_MESpro(bardata,pro_information,M,N,E,StopLossRate,ConOpenTimes,isMinPointOn);
toc

