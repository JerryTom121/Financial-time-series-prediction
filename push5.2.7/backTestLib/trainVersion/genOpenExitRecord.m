function openExitRecord = genOpenExitRecord(completeEntryRecord,completeExitRecord,pinPrefix,TradingUnits,MarginRatio,TradingCost_info)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%�˺��������Ŵ��㷨�Ľӿڣ��������������Ŵ��㷨���µ���¼
%TradingUnitsΪ���׵�λ
%MarginRatioΪ��֤����
%TradingCost_infoΪ���׷�����Ϣ������Ϊÿ���ն��������ѣ�����Ϊ�����׽��İٷֱ���

entryD = completeEntryRecord(:,2) + completeEntryRecord(:,3);   %����ʱ��
exitD = completeExitRecord(:,2) + completeExitRecord(:,3);  %ƽ��ʱ��


entrylots = completeEntryRecord(:,5);
exitlots = completeExitRecord(:,5);


entryLength = size(completeEntryRecord,1);
exitLength = size(completeExitRecord,1);
recLength = entryLength + exitLength;


temp_openExitRecord = zeros(recLength,6);    %��Ž��׼�¼,�Ľ����������Գ�ʼ��Ϊ����Ǹ���������ȷ����
pin = cellstr(repmat(pinPrefix,recLength,1));
delimeter = cellstr(repmat(',',recLength,1));

%-------��ϼ�¼Ȼ���������------%
%�����Ľ�ƽ�ּ�¼��ʽΪ[-1,date,time,price,lots,my_currentcontracts]
%��һ��Ϊ�������һ��Ϊ���µ�֮��ĳֲ�����
%temp_openExitRecord��ʱ�䣬���򣬼۸񣬳ֲ����������ֱ�֤�𣬵���������

temp_openExitRecord(1:entryLength,1) = entryD;
temp_openExitRecord(1:entryLength,2) = completeEntryRecord(:,1);
temp_openExitRecord(1:entryLength,3) = completeEntryRecord(:,4);
temp_openExitRecord(1:entryLength,4) = completeEntryRecord(:,6);

temp_openExitRecord(entryLength+1:end,1) = exitD;
temp_openExitRecord(entryLength+1:end,2) = completeExitRecord(:,1);
temp_openExitRecord(entryLength+1:end,3) = completeExitRecord(:,4);
temp_openExitRecord(entryLength+1:end,4) = completeExitRecord(:,6);

temp_openExitRecord(1:entryLength,5) = completeEntryRecord(:,4) * TradingUnits * MarginRatio;
temp_openExitRecord(entryLength+1:end,5) = completeExitRecord(:,4) * TradingUnits * MarginRatio;

if TradingCost_info > 0     %�����������Ϣ����0����Ϊ�������������ѣ�����Ϊ�����׽��ٷֱ�
    temp_openExitRecord(1:end,6) = repmat(TradingCost_info,recLength,1);
else
    temp_openExitRecord(1:entryLength,6) = (-1) * 0.0001 * TradingCost_info * TradingUnits * completeEntryRecord(:,4);
    temp_openExitRecord(entryLength+1:end,6) = (-1) * 0.0001 * TradingCost_info * TradingUnits * completeExitRecord(:,4);
end

openExitRecord = {};
openExitRecord(:,1) = pin;
openExitRecord(:,2) = delimeter;
openExitRecord(:,3) = cellstr(datestr(temp_openExitRecord(:,1),'yyyy-mm-dd HH:MM:SS'));
openExitRecord(:,4) = delimeter;
openExitRecord(:,5) = num2cell(temp_openExitRecord(:,2));
openExitRecord(:,6) = delimeter;
openExitRecord(:,7) = num2cell(temp_openExitRecord(:,3));
openExitRecord(:,8) = delimeter;
openExitRecord(:,9) = num2cell(temp_openExitRecord(:,4));
openExitRecord(:,10) = delimeter;
openExitRecord(:,11) = num2cell(temp_openExitRecord(:,5));
openExitRecord(:,12) = delimeter;
openExitRecord(:,13) = num2cell(temp_openExitRecord(:,6));

end

