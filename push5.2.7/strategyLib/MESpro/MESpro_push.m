function [ output_args ] = MESpro_push()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%2015/01/21

%-----------�ز������������-------------%
%=============��ȡ�û�����Ҫ��===========%
[testPro_list,testFreq_list,begD,endD,isMinPointOn,...
    ConOpenTimes,trainDay_Length,testDay_Length,opt_Way] = loadTestInfoConfig();

seperator = '/';

%--------������������Ϣ-------%
istrainRandom = 1; %�Ƿ�ѵ�����������ȡ,1��ʾ������0��ʾ�ر�
down = 1; %�������
up = 22; %�������

%--------�Ƿ�ʹ�����ݿ��ȡ������Ϣ-------%
isDB = 1; %1��ʾ������0��ʾ�ر�

%==========��ȡ�û����ý���=============%
%======================================%

pro_L = length(testPro_list);
Freq_L = length(testFreq_list);
testTB_list = cell([pro_L,Freq_L]); %���Եı�����
test_data = cell([pro_L*Freq_L,1]); %�洢ÿ��Ʒ��ÿ���������ƽ������Ķ�Ӧ���ʽ����ߣ���һ��Ԫ����Ʒ��_���ڣ�������Ԫ������������

%-------���������ݿ⣬�������ݿ�����----------%
if isDB==1
    [ODBCName,user,pwd,dbName] = loadDBConfig();
    %�������ݿ�
    conna = mysql('open','localhost',user,pwd);
    mysql(['use ',dbName]);
end
%------�ز����-------%
obj = {}; %���ѵ����Ŀ��ֵ
arg = 0; %���ѵ��ʱ��ÿ���������
strategy_detail.trainDay_Length = trainDay_Length;
strategy_detail.testDay_Length = testDay_Length;
strategy_detail.begD = begD;
strategy_detail.endD = endD;

%----------���Բ�������һ���������Ҫ�����޸�------------%
strategy = 'MESpro';
M_Length = input('������M�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
N_Length = input('������N�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
E_Length = input('������TrailingStop�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
StopLossRate_Length = input('������StopLossSet�Ĳ�����Χ����ʽΪ(1:1:3),1Ϊ��һ��ֵ���м��1Ϊ������������ֵΪ��ֵֹ�������룺\n');
arg_number = 4; %��������

%���Դ�������
test_Times = 0;
%------------�ƽ�����--------------%
for i=1:length(testPro_list)
    if isDB==1
        pinPrefix =  cell2mat(regexp(testPro_list{i},'[^\d]','match'));    %�õ���Ʒǰ׺���ڻ�ȡ��Ʒ��Ϣ
        sql = ['select * from pro_information where pinPrefix=''',pinPrefix,''';'];
        [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio] = mysql(sql);
        pro_information = [pinPrefix,contractUnit,minimumPriceChange,limitUpDown,chargeRate,leverRatio];
    else
        pinPrefix = cell2mat(regexp(testPro_list{i},'[^\d]','match'));
        pro_name = [pinPrefix,'_pro_info'];
        load(pro_name); %����Ʒ������
    end
    tic
    for j=1:length(testFreq_list)
        evalin('base','clear'); %ÿ�����Բ�ͬƷ����Ĳ�ͬ���ڶ�������չ����ռ�
        testTB_list(i,j) = {[testPro_list{i},'_',testFreq_list{j}]};
        
        if isDB==1
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testPro_list{i},'_','m1',' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            minuteData = [Date,Time,Open,High,Low,Close,Vol];
            sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testTB_list{i,j},' where date > ''',begD,'''and date < ''',endD,''';'];
            [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
            bardata = [Date,Time,Open,High,Low,Close,Vol];
        else
            load(testTB_list{i,j}); %����Ʒ��_��������
            Date = bardata(:,1);
        end
        %======��ȡ��ѵ�������±�Ͳ��������±�=====%
        %=========================================%
        temp = diff(day(Date));
        testDayBeg = find(temp~=0)+1;
        testDayBegLength = length(testDayBeg);
        %===========��ѵ�����ݵõ����Ų���=========%
        %========================================%
        for trainDay=trainDay_Length
            if length(testDayBeg) <= trainDay
                error('���ݲ�������ѵ������');
            end
            for testDay=testDay_Length
                times = 0; %��¼ÿ���ƽ������д���
                evalin('base','clear'); %ÿ����ͬ��ѵ������������϶�������չ����ռ�
                fprintf('���ڲ��� %s\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
                %---------���������ļ������ļ���--------%
                %������ű�����Ŀ¼����strategy_detail��Ž�ȥ
                dir = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(down),'To',num2str(up)];
                if exist(dir,'dir')
                    rmdir(dir,'s');
                end
                mkdir(dir);
                %�������ļ��б��������Ŀ����
                arg_object_dir = [dir,seperator,'arg_object'];
                mkdir(arg_object_dir);
                koffset = []; %��¼���ƫ����
                %-------�ƽ�ģ��------%
                for k=trainDay+up:testDay:testDayBegLength  %��testDayΪ�������в��ԡ�
                    times = times+1;
                    koffset(end+1) = k; %��¼���ƫ����
                    %�����Ƿ�������������ÿ���ƽ���ѵ������
                    if istrainRandom == 1 %����������
                        offset = down + floor((up-down)*rand(1));
                    else
                        offset = 0;
                    end
                    trainBeg = testDayBeg(k - trainDay - offset);
                    trainEnd = testDayBeg(k - offset)-1; %����1���ݻ�ȡ�����һ��ĸ����һ��K�����1
                    trainData = bardata(trainBeg:trainEnd,:);
                    %�����������
                    if (k+testDay) > testDayBegLength
                        if k == testDayBegLength %������һ������ָ��պ������һ������������
                            break;
                        end
                        testData = bardata(testDayBeg(k):testDayBeg(end)-1,:);
                    else
                        testData = bardata(testDayBeg(k):testDayBeg(k+testDay)-1,:);
                    end
                    if size(testData,1) < 1
                        disp(1);
                    end
                    opt_temp = 0; %��ʱ�洢���Ž�
                    temp_P_I = zeros(1,arg_number); %��¼��������Ӧ�Ĳ���
                    %-----��ʼ����������Ҫ������Ҫ�����޸�---%
                    %-----�����Լ����ԵĲ��������޸ģ���ʽ����-----%
                    arg.M = [];
                    arg.N = [];
                    arg.E = [];
                    arg.StopLossRate = [];
                    %-----------------------------------------%
                    obj = {};
                    for M=M_Length
                        for N=N_Length
                            for E=E_Length
                                for StopLossRate=StopLossRate_Length
                                    [profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy] = ...
                                        train_MESpro(trainData,pro_information,M,N,E,StopLossRate,ConOpenTimes,isMinPointOn)
                                    %�ж����Ž�
                                    %�洢Ŀ��temp_P�Ͷ�Ӧ�Ĳ���
                                    obj{end+1} = {profitRet,CumNetRetStd,maxDD,LotsWinTotalDLotsTotal,AvgWinLossRet,traderecord,Dy};
                                    %����Ĳ����������������޸�
                                    arg.M(end+1) = M;
                                    arg.N(end+1) = N;
                                    arg.E(end+1) = E;
                                    arg.StopLossRate(end+1) = StopLossRate;
                                    %ѡ���㷨���Ը����Ĳ�ͬ��׼ѡ������Ų���
                                    if opt_temp==0 || obj{end}{opt_Way} > opt_temp
                                        opt_temp = obj{end}{opt_Way};
                                        temp_P_I(1:end) = [M;N;E;StopLossRate]; %��������ݲ��������޸�
                                    end
                                end
                            end
                        end
                    end
                    %-------------------------------%
                    %-------------------------------%
                    %---�����м�Ĳ����Լ�Ŀ�����----%
                    filename = [arg_object_dir,seperator,strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                        '_',num2str(istrainRandom),'_',num2str(down),'To',num2str(up),'_',num2str(k)];
                    save(filename,'arg','obj','offset');
                    %==========�����Ų������в���==========%
                    %==========�����������Ҫ�����޸�==========%
                    fprintf('%s%d%s\n','���ڲ��Ե�',times,'��');
                    bestM = M; bestN = temp_P_I(2); bestE = temp_P_I(3); bestStopLossRate = temp_P_I(4);
                    fprintf('ѵ������Ϊ%d����������Ϊ%d�����Ų���Ϊ��%f %f %f %f\n',trainDay,testDay,bestM,bestN,bestE,bestStopLossRate);
                    MESpro(strategy,testData,pro_information,bestM,bestN,bestE,bestStopLossRate,ConOpenTimes);
                end
                test_Times = test_Times + 1;
                strategy_detail.koffset = koffset;
                filename = [dir,seperator,strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),'_',num2str(istrainRandom),'_',num2str(down),'To',num2str(up)];
                save(filename,'strategy_detail');
                [mytraderecord,openExitRecord,DynamicEquity,obj] = reportVar(strategy,minuteData,pro_information);
                writeToFile(dir,openExitRecord,DynamicEquity,strategy,testTB_list{i,j},trainDay,testDay,istrainRandom,down,up);
                filename = [dir,seperator,strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                    '_',num2str(istrainRandom),'_',num2str(down),'To',num2str(up)];
                save(filename,'mytraderecord','openExitRecord','DynamicEquity','obj','-append');
                filename = [dir,seperator,strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                    '_',num2str(istrainRandom),'_',num2str(down),'To',num2str(up),'_','testTradeRecord'];
                %---����base�����ռ�����Ľ��׼�¼�Ա�У��----%
                evalin('base',['save ',filename]);
                evalin('base','clear'); %ÿ�����Բ�ͬƷ����Ĳ�ͬ���ڲ�ͬѵ��������ȶ�������չ����ռ�
                fprintf('���� %s ���\n',[testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay)]);
            end
        end
    end
    toc
end

if isDB == 1
    mysql('close');
end

end

