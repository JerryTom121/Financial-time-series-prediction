function [exitRecord,my_currentcontracts,isSucess] = train_buyToCover(exitRecord,my_currentcontracts,date,time,price,lots)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if my_currentcontracts < 0     %ֻ�гֿղ�ʱ�Ų�ȡ����
    if lots == 0 || lots > my_currentcontracts*(-1)
        lots = my_currentcontracts*(-1);
    end
    temp = [2,date,time,price,lots,my_currentcontracts];
    exitRecord = [exitRecord;temp];
    my_currentcontracts = my_currentcontracts + lots;
    
    isSucess = 1;   %ƽ�ֳɹ�
    return;
end

isSucess = -1;   %ƽ��ʧ��

end

