function [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,date,time,price,lots,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


if my_currentcontracts > 0 %�ֿղ��������ƽ�����в�������
    [exitRecord,my_currentcontracts,isSucess] = train_sell(exitRecord,my_currentcontracts,date,time,price,0);
end

if my_currentcontracts >= (-1) * ConOpenTimes     %�����������ִ���
    temp = [-1,date,time,price,lots,my_currentcontracts]; %��ʱ���ּ�¼
    entryRecord = [entryRecord;temp];
    my_currentcontracts = my_currentcontracts-lots;
    isSucess = 1;   %���ֳɹ�
    return;
end

isSucess = -1;  %����ʧ��
end
