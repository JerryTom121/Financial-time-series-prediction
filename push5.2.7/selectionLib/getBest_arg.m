function best_arg = getBest_arg(arg,obj,opt_Way)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%1.ѡ��ǰn��������Ȼ����ѡ����������ߵ�Ϊ����
%2.ѡ��ǰn��������Ȼ����ѡ�������ʾ��У�nΪ��������Ϊ����

recCommonLength = [];

%ȡ������obj�е�ÿ��Ŀ��
n = length(obj);
profitRet = obj(:,1);
CumNetRetStdOfTradeRecord = obj(:,2);
maxDDOfTradeRecord = obj(:,3);
maxDDRetOfTradeRecord = obj(:,4);
LotsWinTotalDLotsTotal = obj(:,5);
AvgWinLossRet = obj(:,6);

if opt_Way == 1
    [bestV,bestI] = max(profitRet);
elseif opt_Way == 2
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %���׼�¼������������
    [bestV,bestI] = max(SharpOfTradeRecord);
elseif opt_Way == 3
    [bestV,bestI] = max(LotsWinTotalDLotsTotal);
elseif opt_Way == 4
    AvgWinLossRet = AvgWinLossRet * (-1);
    [bestV,bestI] = max(AvgWinLossRet);
elseif opt_Way == 5
    X = 22; Y = 22;
    %�����������Ҫ��Ŀ��
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %���׼�¼������������
    CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord * (-1);
    maxDDOfTradeRecord = maxDDOfTradeRecord * (-1); %���׼�¼���������س�
    maxDDRetOfTradeRecord = maxDDRetOfTradeRecord * (-1); %���׼�¼���������س���
    AvgWinLossRet = AvgWinLossRet * (-1);
    
    %��ÿ��Ŀ������н�������֮�������Ӧ�±�
    [profitRetV,profitRetI] = sort(profitRet,'descend');
    [CumNetRetStdOfTradeRecordV,CumNetRetStdOfTradeRecordI] = sort(CumNetRetStdOfTradeRecord,'descend');
    [SharpOfTradeRecordV,SharpOfTradeRecordI] = sort(SharpOfTradeRecord,'descend');
    [maxDDOfTradeRecordV,maxDDOfTradeRecordI] = sort(maxDDOfTradeRecord,'descend');
    [maxDDRetOfTradeRecordV,maxDDRetOfTradeRecordI] = sort(maxDDRetOfTradeRecord,'descend');
    [LotsWinTotalDLotsTotalV,LotsWinTotalDLotsTotalI] = sort(LotsWinTotalDLotsTotal,'descend');
    [AvgWinLossRetV,AvgWinLossRetI] = sort(AvgWinLossRet,'descend');
    
    %���������ȡ�����ʺ�ʤ�ʣ�ƽ���������ƽ�������ǰX%����ǰX����commonA
    %��������С�������򲻶ϸı�N����������
    iniX = X;
    varT = 0; %�仯��
    varB = 1; %�仯����
    commonMinSize = 1; %������Сֵ
    while true
        %��ǰN%�������±���в�������
        X = iniX + varT;
        if X > 100
            error('No proper common!');
        end
        X = fix(length(obj)*X*0.01);
        varT = varT + varB;
        disp(['errorT:',num2str(varT)]);
        %ȡ����
        commonA = intersect(profitRetI(1:X),LotsWinTotalDLotsTotalI(1:X));
        commonA = intersect(commonA,AvgWinLossRetI(1:X));
        
        if length(commonA) > commonMinSize
            fprintf('initial X is %f,final X is %f\n',iniX,iniX+varT);
            break;
        end
        
    end
    
    %���պ���������������õ��ļ���commonA���ٽ���ȡ��׼����س��ֱ�����Ȼ��ȡǰY%����ǰY����commonB
    sec_CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord(commonA);
    sec_maxDDOfTradeRecord = maxDDOfTradeRecord(commonA);
    sec_maxDDRetOfTradeRecord = maxDDRetOfTradeRecord(commonA);
    [sec_CumNetRetStdOfTradeRecordV,sec_CumNetRetStdOfTradeRecordI] = sort(sec_CumNetRetStdOfTradeRecord,'descend');
    [sec_maxDDOfTradeRecordV,sec_maxDDOfTradeRecordI] = sort(sec_maxDDOfTradeRecord,'descend');
    [sec_maxDDRetOfTradeRecordV,sec_maxDDRetOfTradeRecordI] = sort(sec_maxDDRetOfTradeRecord,'descend');
    iniY = Y;
    varT = 0; %�仯��
    varB = 1; %�仯����
    commonMinSize = 1; %������Сֵ
    %��������С�������򲻶ϸı�Y����������
    while true
        %��ǰN%�������±���в�������
        Y = iniY + varT;
        if Y > 100
            error('No proper common!');
        end
        Y = fix(length(commonA)*Y*0.01);
        varT = varT + varB;
        %ȡ����
        commonB = intersect(sec_CumNetRetStdOfTradeRecordI(1:Y),sec_maxDDOfTradeRecordI(1:Y));
        commonB = intersect(commonB,sec_maxDDRetOfTradeRecordI(1:Y));
        
        if length(commonB) > commonMinSize
            fprintf('initial Y is %f,final Y is %f\n',iniY,iniY+varT);
            break;
        end
    end
    
    %�Խ���commonBȡ��������ߵ�һ����Ϊ���Ų���
    %ȡ���������ŵó���Ӧ�Ĳ���
    [bestV,bestI] = max(SharpOfTradeRecord(commonA(commonB)));
    bestI = commonA(bestI); %���Ų�����Ӧ���±�
    
elseif opt_Way == 6
    N = 33;
    %�����������Ҫ��Ŀ��
    SharpOfTradeRecord = profitRet./CumNetRetStdOfTradeRecord; %���׼�¼������������
    CumNetRetStdOfTradeRecord = CumNetRetStdOfTradeRecord * (-1);
    maxDDOfTradeRecord = maxDDOfTradeRecord * (-1); %���׼�¼���������س�
    maxDDRetOfTradeRecord = maxDDRetOfTradeRecord * (-1); %���׼�¼���������س���
    AvgWinLossRet = AvgWinLossRet * (-1); %ƽ������/ƽ��������Ϊ�����Ǹ��ģ����Ա����Ϊ��
    
    %��ÿ��Ŀ������н�������֮�������Ӧ�±�
    [profitRetV,profitRetI] = sort(profitRet,'descend');
    [CumNetRetStdOfTradeRecordV,CumNetRetStdOfTradeRecordI] = sort(CumNetRetStdOfTradeRecord,'descend');
    [SharpOfTradeRecordV,SharpOfTradeRecordI] = sort(SharpOfTradeRecord,'descend');
    [maxDDOfTradeRecordV,maxDDOfTradeRecordI] = sort(maxDDOfTradeRecord,'descend');
    [maxDDRetOfTradeRecordV,maxDDRetOfTradeRecordI] = sort(maxDDRetOfTradeRecord,'descend');
    [LotsWinTotalDLotsTotalV,LotsWinTotalDLotsTotalI] = sort(LotsWinTotalDLotsTotal,'descend');
    [AvgWinLossRetV,AvgWinLossRetI] = sort(AvgWinLossRet,'descend');
    
    iniN = N;
    varT = 0; %�仯��
    varB = 1; %�仯����
    commonMinSize = 1; %������Сֵ
    %��������С�������򲻶ϸı�N����������
    while true
        %��ǰN%�������±���в�������
        N = iniN + varT;
        if N > 100
            error('No proper common!');
        end
        N = fix(length(obj)*N*0.01);
        varT = varT + varB;
        %ȡ����
        common = intersect(profitRetI(1:N),CumNetRetStdOfTradeRecordI(1:N));
        common = intersect(common,maxDDOfTradeRecordI(1:N));
        common = intersect(common,maxDDRetOfTradeRecordI(1:N));
        common = intersect(common,LotsWinTotalDLotsTotalI(1:N));
        common = intersect(common,AvgWinLossRetI(1:N));
        
        if length(common) > commonMinSize
            fprintf('initial Y is %f,final Y is %f\n',iniN,iniN+varT);
            break;
        end
    end
    
    %ȡ�������ŵó���Ӧ�Ĳ���
    [bestV,bestI] = max(SharpOfTradeRecord(common));
    bestI = common(bestI); %���Ų�����Ӧ���±�

end

if iscell(arg)
    arg = cell2mat(arg);
end

best_arg = arg(bestI,:);

end

