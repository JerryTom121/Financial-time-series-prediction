function [ task_Config ] = getTaskConfig(strategy_Config,user_Config,taskName)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

task_Config = user_Config;
task_Config.strategyName = strategy_Config.strategyName;
task_Config.paraNumber = strategy_Config.paraNumber;

tempArg = cell(task_Config.paraNumber,1); %������в����ķ�Χ
argBeg = strfind(strategy_Config.para,'=')+1;
argEnd = strfind(strategy_Config.para,';')-1;
%�����������ʼ��ͽ���������û�������˵�������ļ�������
if length(argBeg) ~= length(argEnd)
    error('Config error! = or ; is ignored!');
end

for i=1:1:task_Config.paraNumber
    temp = eval(strategy_Config.para(argBeg(i):argEnd(i)));
    tempArg(i) = {temp};
end

[comp{1:task_Config.paraNumber}] = ndgrid(tempArg{:});
para = cell2mat(cellfun(@(a)a(:),comp,'un',0));
task_Config.arg = tempArg;
task_Config.serialPara = para;
task_Config.taskName = taskName;
        
end

