function [ output_args ] = recommend_push( )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

begD = '2010-04-06'; endD = '2015-02-01';
trainDay_Length = 66; testDay_Length = 22;
K1_Length = 5; K2_Length = 5;
stopLossRet_Length = 40:10:160;
isMoveOn = 4; opt_Way = 1;

%% get data

data = load('if000_m1'); %����Ʒ��_��������
minuteData = data.minuteData;
bardata = data.bardata;
pro_info = load('if_pro_info'); % ������Ʒ��Ϣ
pro_information = pro_info.pro_information;
MinPoint = pro_information{3};
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

%======��������Ƿ���ȡ��=================%
if isempty(minuteData) || isempty(bardata)
    error('Config error!the begining of test day or the ending of the test day not right!');
end
%======��ȡ��ѵ�������±�Ͳ��������±�=====%
%=========================================%
if sum(Time) ~= 0 % �����������Ϊ������֮��
    temp = find(hour(Time)==9); %����˼����ȡ9��֮ǰ����Ϊǰһ������
    a=diff(temp);
    b=find(a~=1)+1;
    testDayBeg = zeros(length(b)+1,1);
    testDayBeg(1) = temp(1); %  fill the first index
    testDayBeg(2:end) = temp(b(1:end));
    testDayBegLength = length(testDayBeg);
else % �����������Ϊ������֮�ϣ��������ݣ������ݵȵ�.��������ȡ�Ļ���ÿ�ܵ�����
    testDayBeg = 1:1:length(Date);
    testDayBegLength = length(testDayBeg);
end

for trainDay=trainDay_Length
    if length(testDayBeg) <= trainDay
        error('���ݲ�������ѵ������');
    end
    for testDay=testDay_Length
        totalTrainDay = trainDay + testDay; % ѵ���������ϲ�����������ѵ�������������
        k_value = totalTrainDay:testDay:testDayBegLength; %��testDayΪ�������в���
        k_nums = 1:1:length(k_value);
        testEntryRec = cell(length(k_nums),1); % ������ԵĽ��ּ�¼
        testExitRec = cell(length(k_nums),1); % ������Ե�ƽ�ּ�¼
        fprintf('%s%d%s\n','�ܹ���',k_nums(end),'��');
        parfor kNum = k_nums
            k = k_value(kNum);
            fprintf('%s%d%s\n','���ڲ��Ե�',kNum,'��');
            offset = 0;
            %�ƽ��ĵ�һ�Σ�����ʼ�±꿪ʼ
            if kNum == 1
                train_trainBeg = 1;
            else
                train_trainBeg = testDayBeg(k - totalTrainDay - offset);
            end
            train_trainEnd = testDayBeg(k - testDay)-1; %����1���ݻ�ȡ�����һ��ĸ����һ��K�����1
            train_testBeg = train_trainEnd + 1;
            train_testEnd = testDayBeg(k)-1;
            test_trainBeg = testDayBeg(k - trainDay);
            test_trainEnd = testDayBeg(k) - 1;
            test_testBeg = test_trainEnd + 1;
            if k + testDay >= testDayBegLength
                test_testEnd = length(Date);
            else
                test_testEnd = testDayBeg(k + testDay)-1; %����1���ݻ�ȡ�����һ��ĸ����һ��K�����1
            end
            train_trainData = bardata(train_trainBeg:train_trainEnd,:);
            train_testData = bardata(train_testBeg:train_testEnd,:);
            test_trainData = bardata(test_trainBeg:test_trainEnd,:);
            test_testData = bardata(test_testBeg:test_testEnd,:);
%             datestr(train_trainData(1,1)+train_trainData(1,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(train_trainData(end,1)+train_trainData(end,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(train_testData(1,1)+train_testData(1,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(train_testData(end,1)+train_testData(end,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(test_trainData(1,1)+test_trainData(1,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(test_trainData(end,1)+test_trainData(end,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(test_testData(1,1)+test_testData(1,2),'yyyy-mm-dd HH:MM:SS')
%             datestr(test_testData(end,1)+test_testData(end,2),'yyyy-mm-dd HH:MM:SS')
            % train to get the result
            [ arg,trainObj ] = for_recommend( train_trainData,train_testData,K1_Length,K2_Length,stopLossRet_Length,MinPoint,pro_information,isMoveOn )
            best_arg = getBest_arg(arg,trainObj,opt_Way);
            bestK1 = best_arg(1); bestK2 = best_arg(2); bestStopLossRet = best_arg(3);
            [ test_entryRecord,test_exitRecord,testObj,hit ] = recommend( test_trainData,test_testData,bestK1,bestK2,bestStopLossRet,MinPoint,pro_information,isMoveOn,0);
            totalTestHit(kNum) = hit;
            testEntryRec(kNum) = {test_entryRecord};
            testExitRec(kNum) = {test_exitRecord};
        end
        
        % �������в��Խ��׼���
        test_entryRecord = cell2mat(testEntryRec);
        test_exitRecord = cell2mat(testExitRec);
        isTrain = 0;
        [test_obj,~,~,mytraderecord,openExitRecord,DynamicEquity] = train_reportVar(bardata,test_entryRecord,test_exitRecord,0,pro_information,isMoveOn,isTrain);
        fileName = [num2str(trainDay),'To',num2str(testDay),'_',begD,'_',endD,'_OptWay_',num2str(opt_Way)];
        save(fileName,'totalTestHit','test_obj','mytraderecord','openExitRecord');
    end
end


end

