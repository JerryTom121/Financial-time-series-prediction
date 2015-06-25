function [con] = WFFTcon( data,pro_information,N,len,q,Tq,Length,Dq )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%����
preciseV = 2e-7; %���ȱ�����������ֵ��ȵľ�������

%����
%K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = length(Close); %K������
%---------------------------------------%
%---------------------------------------%

%---------���±���������Ҫ�����޸�--------%
%���Ա���
a=2/(1+Length);   %��ֵ
n=1:N;

con = zeros(barLength,1);

LLTvalue(1) = Close(1);    %LLT�߳�ʼ��
LLTvalue(2) = Close(2); 
for i = 3:barLength   %����LLT������
    LLTvalue(i)=(a-0.25*a^2)*Close(i)+0.5*a^2*Close(i-1)-(a-0.75*a^2)*Close(i-2)+(2-2*a)*LLTvalue(i-1)-(1-a)^2*LLTvalue(i-2);
end
    d=diff(LLTvalue); %����
    
    MA(1:len-1) = Close(1:len-1);    %MAƽ��
for j = len:barLength
    MA(j) = mean(Close(j-len+1:j));
end
    MA = MA-mean(MA); %����ֱ������
    
for j = N:barLength
    y = fft(MA(j-N+1:j));    %��һ��ʱ�䴰�ڽ��и���Ҷ�任
    pow(1:N) = abs(y).^2;    %����һ��ʱ�䴰�ڹ�����ǿ��
    if j==N                  %����ÿ�����ڵ�ǿ��
        S(1:N-1) = (-10/log(10))*log(0.01./(1-(pow(1:N-1)./max(pow(1:N))))) ;
    end
    S(j) = (-10/log(10))*log(0.01./(1-(pow(N)./max(pow(1:N))))) ;
    if S(j)<0
        S(j) = 0;
    end

     %����Ȩ��
     k(1:N) = abs(q - S(1:N)); 
     k(j) = abs(q - S(j)); 

     T(j) = sum(k(j-N+1:j).*n)/sum(k(j-N+1:j));  %��һ��ʱ�����е�ƽ������
                                                 %��Ӧ����j����˲ʱ����
end
shift = max(N,len);
for i = shift:barLength
    if T(i-1)<(N+1)/2+Tq && T(i-1)>(N+1)/2-Tq && d(i-2)>Dq
        con(i) = 1;
    elseif T(i-1)<(N+1)/2+Tq && T(i-1)>(N+1)/2-Tq && d(i-2)<Dq
        con(i) = -1;
    elseif (T(i-1)>(N+1)/2+Tq || T(i-1)<(N+1)/2-Tq)  
        con(i) = 2;
    end
end

end

