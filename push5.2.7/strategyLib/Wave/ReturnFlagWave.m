function Flag = ReturnFlagWave(data,M,d)
%UNTITLED2 Summary of this function goes here
%��bardata���������仯,�ó��������
%   Detailed explanation goes here
%���ݿ������Լ���ȡ����
%���Ż���������������

%�����Է���
%Mȡֵ
%����or
%��tick����ת��Ϊһ��������
%minuteData = exchangeTo1(tickdata);
% evalin('base','clear');
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������

%�������׸�ͨ�˲�����(HPF)�õ�������������
a=2/(d+1);
HPFClose0=HPF(Close,a);

%��ȡ��Ч��
%���Է�ʽ ����ȷ��׼
for t=1:length(HPFClose0)
    if(HPFClose0(t)<0)
        index=t;
        break;
    end
end
HPFClose = HPFClose0(1,index:end);%Attention!�Ѷ�

%ϣ�����ش���
HiClose = Hilbertrewroten(M,HPFClose);

%ת�����
P = angle(HiClose);
%ת��˲ʱ��������
T(1)=0;
for t=2:length(P)
    T(t) = (2*pi)/(P(t)-P(t-1));
    if(T(t)>62) T(t) = 62;
    end
    if(T(t)<5) T(t) = 5;
    end
end
%������������EMAƽ������
Tafter = EMA(T);

c=0;
%����H�˵����ڲ����仯
for g=(index+2*M):barLength
    c=c+1;
    deltaN(c)=Close(g)-Close(g-floor(Tafter(g-index-2*M+1)));
end

%��ǰ�ж� -1Ϊ���� 1Ϊ���� 0Ϊû������
Flag0(1) = 0;
for i = 1:length(deltaN)-1%�ж����� �Դ��տ��̼۽��� -1��ֹ����
    t = i+1;%1Ϊ��ȡ���տ�������
    if(deltaN(i)>=0)%����
        Flag0(t) = 1;
    else
        Flag0(t) = -1;
    end
end
%���㵽��bardata������ͬ(?)
a=zeros(1,2*M+index-1);%��M,index�й� 3.12��δ����
%b=zeros(1,M);
Flag=[a,Flag0];
end