function isSucess = sell(strategy,date,time,price,lots)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

my_currentcontracts = 0;
exitRecord = [];
currentcontracts_Name = [strategy,'MY_CURRENTCONTRACTS'];
exitRecord_Name = [strategy,'MY_EXITRECORD'];

if isExistInWork(currentcontracts_Name)   %��¼�ֲ���������ƽ�����в�ʱ���ã���������ж������ȷ������buy����sellshort��ʵ�ǲ��õ�
    my_currentcontracts =  evalin('base', currentcontracts_Name);
end

if ~isExistInWork(exitRecord_Name)
    assignin('base',exitRecord_Name,exitRecord);
end

if my_currentcontracts > 0     %ֻ�гֶ��ʱ�Ų�ȡ����
    if lots == 0 || lots > my_currentcontracts
        lots = my_currentcontracts;
    end
    
    my_currentcontracts = my_currentcontracts - lots;  %�ı�ֲ�
    
    temp = [-2,date,time,price,lots,my_currentcontracts];
    exitRecord = evalin('base', exitRecord_Name);
    exitRecord = [exitRecord;temp];
    
    assignin('base',currentcontracts_Name,my_currentcontracts);
    assignin('base',exitRecord_Name,exitRecord);
    
    isSucess = 1;  %ƽ�ֳɹ�
    return ;
end

isSucess = -1;  %ƽ��ʧ��

end
