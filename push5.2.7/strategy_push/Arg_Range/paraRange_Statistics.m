function [ upperFreq,lowerFreq] = paraRange_Statistics(arg,best_arg)
%PARARANGE_STATISTICS Summary of this function goes here
%   Detailed explanation goes here
%ͳ�����Ų������������·�Χ��Եֵ����
%2015.03.25

%�Դ�����Ե����ͳ��
[bestArg_Num,argNum] = size(best_arg);
lowerTimes = zeros(1,argNum); %ͳ�Ʋ��������±�Ե����
upperTimes = zeros(1,argNum); %ͳ�Ʋ��������ϱ�Ե����
for i=1:argNum
    temp = find(best_arg(:,i)==arg(1,i));
    lowerTimes(i) = length(temp);
    temp = find(best_arg(:,i)==arg(end,i));
    upperTimes(i) = length(temp);
end

lowerFreq = lowerTimes/bestArg_Num;
upperFreq = upperTimes/bestArg_Num;

end

