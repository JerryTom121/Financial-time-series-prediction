function [ userSeries,itemSeries ] = getbeforeAfterOpenSeries(data,time,preMinute,rearMinute)
%   author:shying 2015-06-24 01:27
%   getbeforeAfterOpenSeries Summary of this function goes here
%   Detailed explanation goes here
%   This function is to get the series that is preMinute before the close
%   time and rearMinuter after open time
%   data can only be a vector and the row number must be the same as time
%   preMinute and rearMinute are both integer
%   Attention: because many product will have night market,here I just drop
%   the night market and fetch the data as when there is no night market
%   TODO:   now the time only support one minute

%   exception check
if isvector(data) ~= 1 || isvector(time) ~= 1
    msg = 'data and time must both be a vector';
    error(msg);
end

if size(data,1) ~= size(time,1)
    msg = 'the row number of data and time must be the same';
    error(msg);
end

if preMinute < 0 || rearMinute < 0
    msg = 'preMinute and rearMinute must be positive';
    error(msg);
end

%   get the index of the open time of every day
%   ����Ŀ���ͨ������������ȡhour��Ȼ����������ֵ��Ϊ0��1������ֵ����11���Ǿ����������̵������Ǹ�Сʱ
%   ֻҪ�õ����Сʱ������취�͸�ȡÿ�쿪��9�������һ���ˣ�oh yeah
if sum(time) ~= 0 % �����������Ϊ������֮��
    %----get the day begin index----%
    dayOpenHour = 9;
    temp = find(hour(time)==9); % 9 is the hour of open time
    a = diff(temp);
    b = find(a~=1)+1;
    dayOpenIndex = zeros(length(b)+1,1);
    dayOpenIndex(1) = temp(1); %  fill the first index
    dayOpenIndex(2:end) = temp(b(1:end));
    
    %----get the day close index,drop the night open and close index----%
    % get the day close hour
    tmpHour = hour(time);
    difHour = diff(tmpHour);
    tmp = (difHour ~= 0 & difHour ~= 1);
    temptedHour = tmpHour(tmp);
    dayCloseHour = temptedHour(find(temptedHour > 11,1));
    %   get the index
    temp = find(hour(time)==dayCloseHour); % dayCloseHour is the hour of day close time
    a = diff(temp);
    b = find(a~=1);
    dayCloseIndex = zeros(length(b)+1,1);
    dayCloseIndex(1:end-1) = temp(b(1:end));
    dayCloseIndex(end) = temp(end); %  fill the end index
else %  �����������Ϊ������֮�ϣ��������ݣ������ݵȵ�,�򱨴�
    msg = 'the data''s time level must lower than the day level,such as 1 minute data';
    error(msg);
end

beforeCloseIndex = dayCloseIndex - preMinute;
afterOpenIndex = dayOpenIndex + rearMinute;
%   because the first day and the last day have no preMinute or rearMinute
%   so it must be attentioned
beforeCloseIndex = beforeCloseIndex(1:end-1);
afterOpenIndex = afterOpenIndex(2:end);

[m,n] = size(afterOpenIndex);
dataColmun = length(beforeCloseIndex(1):afterOpenIndex(1));
userSeries = zeros(m,dataColmun);
for i=1:m
    temp = data(beforeCloseIndex(i):afterOpenIndex(i)); %  use a temporal variable to handle data loss
    lossPosition = dataColmun - length(temp) + 1; %  put the loss data in the first position to try to not to influence the next phase
    userSeries(i,lossPosition:end) = temp;
end

dataColmun = length(afterOpenIndex(1)+1:dayCloseIndex(2));
itemSeries = zeros(m,dataColmun);
for i=1:m
    temp = data(afterOpenIndex(i)+1:dayCloseIndex(i+1));
    lossPosition = dataColmun - length(temp) + 1; %  put the loss data in the first position to try to not to influence the next phase
    itemSeries(i,lossPosition:end) = temp;
end

end