function isSucess = sellshort(strategy,date,time,price,lots,ConOpenTimes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
my_currentcontracts = 0;
entryRecord = [];
entryRecord_Name = [strategy,'MY_ENTRYRECORD'];
currentcontracts_Name = [strategy,'MY_CURRENTCONTRACTS'];

if isExistInWork(currentcontracts_Name)   %��¼�ֲ���������ƽ�����в�ʱ����
   my_currentcontracts =  evalin('base', currentcontracts_Name);
   
   if my_currentcontracts > 0 %�ֿղ��������ƽ�����в�������
       sell(strategy,date,time,price,0);
       my_currentcontracts = 0;
   end
end


%��һ�ε������entryRecord��ӵ�base
if ~isExistInWork(entryRecord_Name)
    assignin('base',entryRecord_Name,entryRecord);
end

if my_currentcontracts >= (-1) * ConOpenTimes     %�����������ִ���
    my_currentcontracts = my_currentcontracts-lots; %�ı�ֲ�
    
    temp = [-1,date,time,price,lots,my_currentcontracts]; %��ʱ���ּ�¼
    entryRecord = evalin('base', entryRecord_Name);
    entryRecord = [entryRecord;temp];
    assignin('base',currentcontracts_Name,my_currentcontracts);
    assignin('base',entryRecord_Name,entryRecord);
    isSucess = 1;  %���ֳɹ�
    return ;
end

isSucess = -1;  %����ʧ��

end

