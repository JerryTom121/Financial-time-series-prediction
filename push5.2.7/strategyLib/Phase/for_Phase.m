function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_Phase( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
obj = [];
for Cycle=strategyArg{1}
    MAClose = MA(bardata,Cycle);
    %ALL ����Z ����bardata����
    %��ǰ���trainBeg��trainEnd�س�ѵ����ϣ������
    for M=strategyArg{2}
        Flag = ReturnFlagPhase(bardata,M,MAClose);%�ڴ˴��ж��Ƿ��㹻2*M+1 %���δ����Ƿ�̫���˷�(?)
        FlagSome=Flag(trainBeg:trainEnd);%�ҵ���Ӧ��ϣ�����ر任����
        [entryRecord,exitRecord] = train_Phase(trainData,FlagSome,pro_information,ConOpenTimes);
        [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
        count = count + 1;
    end
end

end

