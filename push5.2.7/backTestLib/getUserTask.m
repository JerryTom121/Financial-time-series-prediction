function [ Task_Config ] = getUserTask()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

seperator = filesep; %��ȡ��ǰϵͳ���ļ��ָ���
%% ���Բ��Ե������б����
filename = ['Config',seperator,'strategy_taskTable.txt'];
[fid,message] = fopen(filename,'r');
if fid==-1
    error(message);
end

%���û��и�ʽ
line_Format = '\n';

%�����������
fscanf(fid,'Strategy Number:');
strategyNumber = fscanf(fid,['%d',line_Format]);

fscanf(fid,['Strategy:',line_Format]);

%���Ҫ���еĲ���
strategy = cell(strategyNumber,1);
%����Ҫ���еĲ���
for i=1:strategyNumber
    temp = '%d';
    temp = fscanf(fid,temp);
    temp = ['.','%s',line_Format];
    temp = fscanf(fid,temp);
    strategy(i) = {temp};
end

fscanf(fid,['Please choose the strategy to run:']);
strategyNum = fscanf(fid,['%d%*c',line_Format]);

fclose(fid);

%% ���Զ���ÿ�������������ϸ��Ϣ
taskNum = 1;
for strNum = 1:length(strategyNum)
    fileDir = ['Config',seperator,strategy{strategyNum(strNum)},'_Config'];
    a = what(fileDir); %�ѳ�fileDir���ھ���·������set Pathϵͳ�д�����������ѡ���һ��
    if isempty(a)
        errorMsg = ['strategy ',strategy{strategyNum(strNum)},'''s config directory not exists!'];
        error(errorMsg);
    end
    if length(a) > 1
        warning('There are more than one Push vision in your computer');
    end
    fileDir = a.path;
    files = dir(fileDir);   %����ļ����������ļ���
    files = struct2cell(files);
    files = files';
    filesnum = size(files,1); %�ļ�������
    trueFilesnum = filesnum - 2; %ȥ�������ļ��кͱ��ļ��е��ļ�������
    filesname = cell(filesnum-2,1);
    
    for i = 3:1:filesnum
        filesname(i-2) = {files{i,1}};
    end
    %��ÿ��Config�ļ����µ��ļ�����ÿ�����������
    for  index = 1:1:(trueFilesnum)
        filename = fullfile(fileDir,filesname{index},'taskDetail.txt');
        [ strategy_Config,user_Config ] = loadTaskDetail( filename );
        Task_Config(taskNum) = getTaskConfig(strategy_Config,user_Config,filesname{index});
        taskNum = taskNum + 1;
    end
end


end

