function [LongMargin,ShortMargin,StaticEquity,DynamicEquity,Cash] = compAssertsVar(Marketposition,Close,StaticEquity,entryprice,myOpenIntRecord,profit,TradingUnits,MarginRatio)

%�����ʲ��������������ͷ��֤�𣬾�̬Ȩ��Ͷ�̬Ȩ���
%�����о�̬Ȩ���������һ��K�ľ�̬Ȩ��
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if Marketposition == 0
    LongMargin=0;                            %��ͷ��֤��
    ShortMargin=0;                           %��ͷ��֤��
    StaticEquity=StaticEquity+profit;          %��̬Ȩ��
    DynamicEquity=StaticEquity;           %��̬Ȩ��
    Cash=DynamicEquity;                   %�����ʽ�
elseif Marketposition == 1
    myOpenInt = sum(myOpenIntRecord(:,2));
    OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord);
    LongMargin=Close*myOpenInt*TradingUnits*MarginRatio;
    ShortMargin = 0;
    StaticEquity=StaticEquity+profit;
    DynamicEquity=StaticEquity+(Close*myOpenInt-OpenPosPrice)*TradingUnits;
    Cash=DynamicEquity-LongMargin;
else
    myOpenInt = sum(myOpenIntRecord(:,2));
    OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord);    %������ַ���
    LongMargin = 0;
    ShortMargin=Close*myOpenInt*TradingUnits*MarginRatio;
    StaticEquity=StaticEquity+profit;
    DynamicEquity=StaticEquity+(OpenPosPrice-Close*myOpenInt)*TradingUnits;
    Cash=DynamicEquity-ShortMargin;
end
    
end

