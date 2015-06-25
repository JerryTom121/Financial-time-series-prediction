function [ data ] = extractDataByDate(data,date,begD,endD)
%   author: shying 2016-06-24 00:12
%   extractDataByDate Summary of this function goes here
%   this function is to extract data by date between begD and endD
%   data is Close,Volume,High or all of them mix into a matrix
%   date is date vector,begD is the begin date to extract the data
%   endD is obvious

if size(data,1) ~= size(date,1)
    msg = 'the row number of data must be the same as the date';
    error(msg);
end
% �����ⲿ�ֽ�ȡ������ȡ����
begNum = datenum(begD); endNum = datenum(endD);
% �쳣�ж�
if begNum > endNum
    msg = 'begD must smaller than endD';
    error(msg);
end
%��ȡdata
dbeg = find(date>=begNum,1); %�ҵ���ȡ���ݵ���ʼ�±�
dend = find(date<=endNum); %�����±�
dend = dend(end);
data = data(dbeg:dend,:);

end

