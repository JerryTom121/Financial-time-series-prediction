function Flag = ReturnFlagPhase(data,M,MAClose)
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

%��MA�ƶ�ƽ����
%�ͼ����� ���ɰ�data��Close��

%ͨ�����׸�ͨ�˲�����ȥ����������
SFClose0 = SF(MAClose);

%��ȡ��Ч��
%���Է�ʽ ����ȷ��׼
for t=1:length(SFClose0)
    if(SFClose0(t)<0)
        index=t;
        break;
    end
end
SFClose = SFClose0(1,index:end);%Attention!�Ѷ�

%ϣ�����ش���
HiClose = Hilbertrewroten(M,SFClose);

%ת�����
P=angle(HiClose);
%ת��˲ʱ��������
T(1)=0;
for t=2:length(P)
    T(t)=(2*pi)/(P(t)-P(t-1));
    if(T(t)>62) T(t)=62;
    end
    if(T(t)<5) T(t)=5;
    end
end
%������������EMAƽ������
Tafter=EMA(T);

%����Ҷ�任���㶯̬���
a=0;
for t=index+M:barLength-M
    N=floor(Tafter(t-index-M+1));%����tʱ�̵�˲ʱ����%������һ��T(1)=0
    if(N<=t)%��ȡ������������ ��ʱ������
        I=0;
        R=0;
        for n=(t-N+1):t
            I=I+Close(n)*sin((2*pi*(n-(t-N+1)))/N);%�鲿
            R=R+Close(n)*cos((2*pi*(n-(t-N+1)))/N);%ʵ��
        end
        a=a+1;
        Theta(a)=atan(I/R);
    end
end

%��ǰ�ж� -1Ϊ���� 1Ϊ���� 0Ϊû������
Flag0(1) = 0;
Flag0(2) = 0;
for i=2:length(Theta)-1%�ж����� �Դ��տ��̼۽��� -1��ֹ����
    d1 = sin(Theta(i-1)+pi)-sin(Theta(i-1)+1.25*pi);
    d2 = sin(Theta(i)+pi)-sin(Theta(i)+1.25*pi);
    t=i+1;%+1Ϊ��ȡ���տ�������
    if( d1 * d2 < 0)%�����л�
        if( d2 > 0 )%����           %�鿴�˴�"<"or">".
            Flag0(t) = -1;
        end
        if( d2 < 0 ) %����
            Flag0(t) = 1;
        end
    else
        Flag0(t) = 0;
    end
end
%���㵽��bardata������ͬ(?)
a=zeros(1,2*M+index-1);%��M,index�й� 3.12��δ����
%b=zeros(1,M);
Flag=[a,Flag0];
end