function [entryRecord,exitRecord ] = train_genEntryExitRecord(completeEntryRecord,completeExitRecord,isMoveOn,MinPoint)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%������С�ƶ���λ���û���

%����۸񲻺������
temp1 = completeEntryRecord(:,1);
temp2 = completeEntryRecord(:,4); %ȡС�����2λ
temp2(temp1>0) = temp2(temp1>0) + mod(temp2(temp1>0),MinPoint); %��۸�������ȡ�۸�
temp2(temp1<0) = temp2(temp1<0) - mod(temp2(temp1<0),MinPoint);
temp2 = roundn(temp2,-2); %��Ϊ�������⣬�����������������������
completeEntryRecord(:,4) = temp2;

temp1 = completeExitRecord(:,1);
temp2 = completeExitRecord(:,4);
temp2(temp1>0) = temp2(temp1>0) + mod(temp2(temp1>0),MinPoint); %��۸�������ȡ�۸�
temp2(temp1<0) = temp2(temp1<0) - mod(temp2(temp1<0),MinPoint);
temp2 = roundn(temp2,-2); %��Ϊ�������⣬�����������������������
completeExitRecord(:,4) = temp2; 

%������
if isMoveOn==1  %���ֻ���
    temp1 = completeEntryRecord(:,1);
    temp2 = completeEntryRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint; %���������ʱ��Ļ���
    temp2(temp1<0) = temp2(temp1<0) - MinPoint; %����������ʱ��Ļ���
    completeEntryRecord(:,4) = temp2;
elseif isMoveOn==2  %ƽ�ֻ���
    temp1 = completeExitRecord(:,1);
    temp2 = completeExitRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint; %ƽ�������ʱ��Ļ���
    temp2(temp1<0) = temp2(temp1<0) - MinPoint; %ƽ��������ʱ��Ļ���
    completeExitRecord(:,4) = temp2;
elseif isMoveOn==4
    temp1 = completeEntryRecord(:,1);
    temp2 = completeEntryRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint;
    temp2(temp1<0) = temp2(temp1<0) - MinPoint;
    completeEntryRecord(:,4) = temp2;
    temp1 = completeExitRecord(:,1);
    temp2 = completeExitRecord(:,4);
    temp2(temp1>0) = temp2(temp1>0) + MinPoint;
    temp2(temp1<0) = temp2(temp1<0) - MinPoint;
    completeExitRecord(:,4) = temp2;
end

entryRecord = completeEntryRecord(:,1:end-1);
exitRecord = completeExitRecord(:,1:end-1);

end

