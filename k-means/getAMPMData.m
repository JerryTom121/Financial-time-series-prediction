function [ AMData,PMData ] = getAMPMData(data,time)
%   author: shying 2016-06-24 00:12
%   extractDataByTime Summary of this function goes here
%   this function is to get morning and afternoon data by time between begT and endT
%   data now only support a vector
%   time is time vector

% exception check
if size(data,1) ~= size(time,1)
    msg = 'the length of data muse be the same as the time''s';
    error(msg);
end

%��ȡ���������ֱ�۸�  0.3854   0.4785  0.5625  0.6347
%%------��������ȡ��������д���ˣ���Ҫ�޸ģ�����----------%%
begtime = find(hour(time)==9 & minute(time)==15);
% begtime = find(hour(Time)==14 & minute(Time)==15);  %���ܳ�������ȱʧ����
midtime1 = find(hour(time)==11 & minute(time)==29);
midtime2 = find(hour(time)==13 & minute(time)==00);
endtime = find(hour(time)==15 & minute(time)==14);
m = length(begtime);
AMData = zeros(m,midtime1(1)-begtime(1)+1);
for i = 1:m
    AMData(i,1:midtime1(i)-begtime(i)+1) = data(begtime(i):midtime1(i));
    lossnum(i) = length(find(AMData(i,:)==0));             %��������ȱʧ
end

PMData = zeros(m,endtime(1)-midtime2(1)+1);
for i = 1:m
    PMData(i,1:endtime(i)-midtime2(i)+1) = data(midtime2(i):endtime(i));
    lossnum(i) = length(find(PMData(i,:)==0));             %��������ȱʧ
end


end