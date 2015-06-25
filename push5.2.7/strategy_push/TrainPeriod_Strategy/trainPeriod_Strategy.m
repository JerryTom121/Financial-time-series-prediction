function [ output_args ] = trainPeriod_Strategy()

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
    %���ݲ������ֵó��ò����Ƿ��ǲ��ö�Ŀ��
    isMoead = ~isempty(strfind(lower(strategy),'moead'));
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
    strategy_detail.strategyArg = arg;
    strategy_detail.task = singleTask;
    strategy_detail.isMoead = isMoead;
    
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
                testDayBeg = zeros(length(b)+1,1);
                testDayBeg(1) = temp(1); %  fill the first index
                testDayBeg(2:end) = temp(b(1:end));
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
                    clear total_obj
                    total_obj = cell(length(k_value),1); %�洢ÿ��ѵ���ó���Ŀ��
                    if isMoead == 1
                        clear total_arg
                        total_arg = cell(length(k_value),1); %�洢ÿ��ѵ���Ĳ������˱�����Ҫ���ڶ�Ŀ��moead����
                    end
                    evalin('base','clear');
                    %-------�ƽ�ģ��------%
                    parfor kNum = k_nums
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
                        
                        %-----------------------------------------%
                        %��k����testDayBegLength��ʱ�򲻽����ƽ�
                        if k ~= testDayBegLength
                            isTrain = 1;
                            my_currentcontracts = 0;
                            %ѵ������
                            if isMoead == 0 %��ͨ����
                                [~,~,~,temp_obj] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,isTrain,my_currentcontracts);
                                total_obj(kNum) = {temp_obj};
                            else %��Ŀ�����
                                [~,~,~,temp_obj,vararg] = train_Strategy(strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,isTrain,my_currentcontracts);
                                total_obj(kNum) = {temp_obj};
                                temp_arg = vararg{1};
                                total_arg(kNum) = {temp_arg};
                            end
                            
                        end
                    end
                    %����ÿ��ѵ���õ���Ŀ��
                    for index = 1:length(koffset)
                        filename = [arg_object_dir,seperator,dir_flag,'_',num2str(koffset(index)),'.mat'];
                        %�ж��Ƿ��ļ����ڣ�����˵���Ѿ��ܹ���
                        if exist(filename,'file') == 2
                            continue;
                        end
                        obj = total_obj{index};
                        saveVar(filename,obj);
                    end
                    %����˴������ϸ��
                    strategy_detail.koffset = koffset;
                    %����Ƕ�Ŀ����ԣ�����Ҫ����ԭ����argΪ���ڵ�arg
                    if isMoead == 1
                        strategy_detail.strategyArg = total_arg;
                    end
                    filename = [totalDir,seperator,'train_detail'];
                    saveVar(filename,strategy_detail);
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
