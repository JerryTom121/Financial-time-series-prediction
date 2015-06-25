function [Type,Lots,NetMargin,RateOfReturn,CostSeries] = train_handleTradeRecord(traderecord,TradingUnits,TradingCost_info)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% ���ɶ�Ӧ���Ժ���Ʒ�Ľ��׼�¼��Ȼ����ݼӽ��׼�¼
% ���������ʣ�ʤ�ʵȵ�
%fprintf('\n%s\n','ѵ���汾�����׼�¼...');

recordRows = size(traderecord,1);%���׼�¼����

Type(:,1) = traderecord(:,1);                   %���ͷ����

entryprice(:,1) = traderecord(:,4);             %���ּ۸�
exitprice(:,1) = traderecord(:,7);              %ƽ�ּ۸�
Lots(:,1) = traderecord(:,8);            %����

%�زⱨ���������
NetMargin = zeros(recordRows,1);                  %������
RateOfReturn = zeros(recordRows,1);            %������
CostSeries = zeros(recordRows,1);              %��¼���׳ɱ�

%���ÿ�ν��׵ľ�����
for i=1:recordRows
    
    %���׳ɱ�(����+ƽ��)
    CostSeries(i)= train_compTradingCost(exitprice(i),entryprice(i),TradingUnits,Lots(i),TradingCost_info);
    %CostSeries(i) = 10;
    if Type(i) == 1
        NetMargin(i) = (exitprice(i) - entryprice(i))*Lots(i)*TradingUnits-CostSeries(i);
    end
    
    if Type(i) == -1
        NetMargin(i) = (entryprice(i) - exitprice(i))*Lots(i)*TradingUnits-CostSeries(i);
    end
    
    temp = entryprice(i)*TradingUnits*Lots(i);
    %������
    RateOfReturn(i) = double(NetMargin(i))/double(temp);
end
%fprintf('\n%s\n','ѵ���汾�����׼�¼���...');

end

