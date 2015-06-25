function [ output_args ] = trainTestPeriod_Strategy()

%%
%ѵ���ó������汾
%2015.03.22

%%

%-----------�ز������������-------------%
%=============��ȡ�û�����Ҫ��===========%
task = getUserTask();
for taskNum=1:length(task)
    singleTask = task(taskNum);
    taskName = singleTask.taskName;
    strategy = singleTask.strategyName;
    strategyArg = singleTask.arg; %���Ե�ÿ�������ķ�Χ
    arg = singleTask.serialPara; %���Ե����в����ı������
    testPro_list = singleTask.testPro_list;
    testFreq_list = singleTask.testFreq_list;
    begD = singleTask.begD;
    endD = singleTask.endD;
    isMoveOn = singleTask.isMoveOn;
    ConOpenTimes = singleTask.ConOpenTimes;
    trainDay_Length = singleTask.trainDay_Length;
    testDay_Length = singleTask.testDay_Length;
    istrainRandom = singleTask.istrainRandom;
    random_down = singleTask.random_down;
    random_up = singleTask.random_up;
    isDB = singleTask.isDB;
    opt_Way = singleTask.opt_Way;
    isProDupliTask = singleTask.isProDupliTask; %���������ã�0Ϊ���������ܣ�1Ϊ������
    
    seperator = filesep; %�ļ��ָ���
    
    %==========��ȡ�û����ý���=============%
    %======================================%
    
    pro_L = length(testPro_list);
    Freq_L = length(testFreq_list);
    testTB_list = cell([pro_L,Freq_L]); %���Եı�����
    
    %-------���������ݿ⣬�������ݿ�����----------%
    if isDB==1
        [ODBCName,user,pwd,dbName] = loadDBConfig();
        %�������ݿ�
        conna = mysql('open','localhost',user,pwd);
        mysql(['use ',dbName]);
    end
    %------�ز����-------%
    
    strategy_detail.trainDay_Length = trainDay_Length;
    strategy_detail.testDay_Length = testDay_Length;
    strategy_detail.begD = begD;
    strategy_detail.endD = endD;
    strategy_detail.strategyArg = strategyArg;
    strategy_detail.task = singleTask;
    
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
                sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testPro_list{i},'_','m1',' where date >= ''',begD,'''and date <= ''',endD,''';'];
                [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
                minuteData = [Date,Time,Open,High,Low,Close,Vol];
                sql = ['select Date,Time,Open,High,Low,Close,Vol from ',testTB_list{i,j},' where date >= ''',begD,'''and date <= ''',endD,''';'];
                [Date,Time,Open,High,Low,Close,Vol] = mysql(sql);
                bardata = [Date,Time,Open,High,Low,Close,Vol];
            else
                load(testTB_list{i,j}); %����Ʒ��_��������
                %�����ⲿ�ֽ�ȡ������ȡ����
                begNum = datenum(begD); endNum = datenum(endD);
                %��ȡminuteData
                Date = minuteData(:,1);
                dbeg = find(Date>=begNum,1); %�ҵ���ȡ���ݵ���ʼ�±�
                dend = find(Date<=endNum); %�����±�
                dend = dend(end);
                minuteData = minuteData(dbeg:dend,:);
                %��ȡbardata
                Date = bardata(:,1);
                dbeg = find(Date>=begNum,1); %�ҵ���ȡ���ݵ���ʼ�±�
                dend = find(Date<=endNum); %�����±�
                dend = dend(end);
                bardata = bardata(dbeg:dend,:);
                %��ȡ���ּ۸�
                Date = bardata(:,1); Time = bardata(:,2);
                Open = bardata(:,3); High = bardata(:,4);
                Low = bardata(:,5); Close = bardata(:,6);
                Vol = bardata(:,7);
            end
            %======��������Ƿ���ȡ��=================%
            if isempty(minuteData) || isempty(bardata)
                error('Config error!the begining of test day or the ending of the test day not right!');
            end
            %======��ȡ��ѵ�������±�Ͳ��������±�=====%
            %=========================================%
            if sum(Time) ~= 0 %�����������Ϊ������֮��
                temp = find(hour(Time)==9); %����˼����ȡ9��֮ǰ����Ϊǰһ������
                a=diff(temp);
                b=find(a~=1)+1;
                testDayBeg=temp(b(1:end-1));
                testDayBegLength = length(testDayBeg);
            else %�����������Ϊ������֮�ϣ��������ݣ������ݵȵ�
                temp = diff(day(Date));
                testDayBeg = find(temp~=0)+1; %����+1����Ϊdiff������ǰ��һλ������1,1,2.�����õ�0,1��������������Ҫ2���±�
                testDayBegLength = length(testDayBeg);
            end
            
            %===========��ѵ�����ݵõ����Ų���=========%
            %========================================%
            for trainDay=trainDay_Length
                if length(testDayBeg) <= trainDay
                    error('���ݲ�������ѵ������');
                end
                for testDay=testDay_Length
                    evalin('base','clear'); %ÿ����ͬ��ѵ������������϶�������չ����ռ�
                    %=========�洢ȫ�ֱ�����base�����ռ�=======%
                    
                    %========================================%
                    
                    %---------���������ļ������ļ���--------%
                    %���������ļ���
                    task_dir = [taskName,'_File'];
                    %�������ر������ļ��������Է��������ڱ����ʵ��ļ���
                    %���˴����У�����ע��
                    fclose('all');
                    
                    %����ÿһ��ѵ���ļ���
                    dir_flag = [strategy,'_',testTB_list{i,j},'_',num2str(trainDay),'To',num2str(testDay),...
                        '_',num2str(istrainRandom),'_',num2str(random_down),'To',num2str(random_up),'_',begD,'_','train'];
                    totalDir = [task_dir,seperator,dir_flag];
                    fprintf('���ڲ��� %s\n',totalDir);
                    %�������ļ��б��������Ŀ����
                    arg_object_dir = [totalDir,seperator,dir_flag,'_','arg_object'];
                    k_value = trainDay+random_up:testDay:testDayBegLength; %��testDayΪ�������в���
                    k_nums = 1:1:length(k_value);
                    koffset = zeros(length(k_value),1); %��¼���ƫ����
                    
                    testEntryRec = cell(length(k_nums),1); %�洢���ԵĿ��ּ�¼
                    testExitRec = cell(length(k_nums),1); %�洢���Ե�ƽ�ּ�¼
                    
                    %% �ļ��д���
                    %���������Ƿ��Ѿ����й�
                    arg_file1 = [arg_object_dir,seperator,dir_flag,'_',num2str(k_value(1)),'.mat'];
                    arg_file2 = [arg_object_dir,seperator,dir_flag,'_',num2str(k_value(end)),'.mat'];
                    %������������˲����ܹ�һ��
                    isRunned = (exist(arg_file1,'file') == 2 && exist(arg_file2,'file') == 2);
                    %�ܹ��������ܣ���ɾ���������ļ����ؽ��ļ���
                    if isRunned == 1 && isProDupliTask == 0
                        rmdir(totalDir,'s');
                        mkdir(totalDir);
                        mkdir(arg_object_dir);
                    end

                    %�ܹ��Ҳ������ܣ�������������
                    if isRunned == 1 && isProDupliTask == 1
                        fprintf('The task %s has been runned!Pass!\n',totalDir);
                        continue;
                    end

                    %û�ܹ����򴴽��ļ���
                    if isRunned == 0;
                        mkdir(task_dir);
                        mkdir(totalDir);
                        mkdir(arg_object_dir);
                    end
                    %% ��ʼѵ��
                    %����һ�����������������Ŀ��
                    pro = testPro_list{i};
                    Freq = testFreq_list{j};
                    total_obj = cell(length(k_value),1);
                    evalin('base','clear');
                    %-------�ƽ�ģ��------%
                    parfor kNum = k_nums
                        dataPre(strategy,pro,Freq);
                        k = k_value(kNum);
                        koffset(kNum) = k; %��¼���ƫ����
                        fprintf('%s%d%s\n','���ڲ��Ե�',kNum,'��');
                        %�����Ƿ�������������ÿ���ƽ���ѵ������
                        if istrainRandom == 1 %����������
                            offset = random_down + floor((random_up-random_down)*rand(1));
                        else
                            offset = 0;
                        end
                        %�ƽ��ĵ�һ�Σ�����ʼ�±꿪ʼ
                        if kNum == 1
                            trainBeg = 1;
                        else
                            trainBeg = testDayBeg(k - trainDay - offset);
                        end
                        trainEnd = testDayBeg(k - offset)-1; %����1���ݻ�ȡ�����һ��ĸ����һ��K�����1
                        trainData = bardata(trainBeg:trainEnd,:);
                        %���������������ʣ����������ôȡʣ������������Ϊ��������
                        if (k+testDay) > testDayBegLength
                            testBeg = testDayBeg(k);
                            testEnd = length(bardata);
                            testData = bardata(testBeg:testEnd,:);
                        else
                            testBeg = testDayBeg(k);
                            testEnd = testDayBeg(k+testDay)-1;
                            testData = bardata(testBeg:testEnd,:);
                        end
                        
                        %-----------------------------------------%
                        %��k����testDayBegLength��ʱ�򲻽����ƽ�
                        if k ~= testDayBegLength
                            isTrain = 1;
                            my_currentcontracts = 0;
                            %ѵ������
                            [~,~,~,temp_obj] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,isTrain,my_currentcontracts);
                            total_obj(kNum) = {temp_obj};
                            %���ݲ�����ϺͶ�Ӧ��Ŀ����Ż������õ����Ų���
                            best_arg = getBest_arg(arg,temp_obj,opt_Way);
                            best_arg = num2cell(best_arg);
                            %����Ϊѵ��
                            isTrain = 0;
                            %==========�����Ų������в���==========%
                            [test_entryRecord,test_exitRecord] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,testBeg,testEnd,best_arg,isTrain,my_currentcontracts);
                            %��ͬ���ĺ����������ּ�¼��ƽ�ּ�¼���ٷŵ�һ��cell���飬�Ȳ���������ٺϲ�����
                            testEntryRec(kNum) = {test_entryRecord};
                            testExitRec(kNum) = {test_exitRecord};
                        end
                    end
                    
                    %�������ļ����Ա�����Խ��
                    test_result_dir = [totalDir,seperator,dir_flag,'_','test_result'];
                    mkdir(test_result_dir);
                    
                    %����ÿ��ѵ���õ���Ŀ��
                    for index = 1:length(koffset)
                        filename = [arg_object_dir,seperator,dir_flag,'_',num2str(koffset(index)),'.mat'];
                        %�ж��Ƿ��ļ����ڣ�����˵���Ѿ��ܹ���
                        if exist(filename,'file') == 2
                            continue;
                        end
                        obj = total_obj{index};
                        saveVar(filename,arg,obj);
                    end
                    %����˴������ϸ��
                    strategy_detail.koffset = koffset;
                    filename = [totalDir,seperator,'train_detail'];
                    saveVar(filename,strategy_detail);
                    test_entryRecord = cell2mat(testEntryRec);
                    test_exitRecord = cell2mat(testExitRec);
                    isTrain = 0;
                    [test_obj,~,~,mytraderecord,openExitRecord,DynamicEquity] = train_reportVar(bardata,test_entryRecord,test_exitRecord,0,pro_information,isMoveOn,isTrain);
                    writeToFile(test_result_dir,openExitRecord,DynamicEquity,test_obj,dir_flag);
                    filename = [test_result_dir,seperator,dir_flag];
                    save(filename,'mytraderecord','openExitRecord','DynamicEquity','test_obj');
                    filename = [test_result_dir,seperator,dir_flag,'_','testTradeRecord'];
                    %---����base�����ռ�����Ľ��׼�¼�Ա�У��----%
                    save( filename,'test_entryRecord','test_exitRecord');
                    evalin('base','clear'); %ÿ�����Բ�ͬƷ����Ĳ�ͬ���ڲ�ͬѵ��������ȶ�������չ����ռ�
                    fprintf('���� %s ���\n',totalDir);
                end
            end
        end
        toc
    end
    
    if isDB == 1
        mysql('close');
    end
    
end

end

