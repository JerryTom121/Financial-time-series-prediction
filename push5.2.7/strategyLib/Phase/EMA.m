function EMAminuteClose = EMA( minuteClose )
%UNTITLED3 Summary of this function goes here
%����MA�ƶ�ƽ����,һ���˲���
%   Detailed explanation goes here
a=0.05;
m=length(minuteClose);
EMAminuteClose(1)=minuteClose(1);
for i=2:m
    EMAminuteClose(i)=a*minuteClose(i)+(1-a)*EMAminuteClose(i-1);
end

