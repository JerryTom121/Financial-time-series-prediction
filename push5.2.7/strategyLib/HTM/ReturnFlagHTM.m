function Flag = ReturnFlagHTM(data,M,MAClose)
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
%sql = strcat('select * from taodata.',pro,'_',Freq,';');ȫ������
entryCount = 0; %��¼���״���
status = 0; %��¼�������գ�1���࣬-1����
profit = [];
totalprofit = [];
%������ر������� end
%Ʒ�ֲ���
Lots=1;        %��������

Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������

%��MA�ƶ�ƽ����
%�ں����������� 3.19
% %����:ֻ���ز�
% %��ִ��� �����������һλ
%x=diff(minuteClose);
x=diff(MAClose);
%x=diff(MA)
%ϣ�����ش���
%����hilbert����
z=Hilbertrewroten(M,x);%�˴��õ��˵���֮ǰ������
%ת������
Theta=angle(z);

%15.3.15 ��ǰ�ж� -1Ϊ���� 1Ϊ����
%flagΪ�жϽ��
Flag0(1) = 0;
Flag0(2) = 0;
for i=2:length(Theta)-1%�ж����� �Դ��տ��̼۽��� -1��ֹ����
    t=i+1;%3.8 M�ӳ�����ϣ�����ر任ʱ������ 1Ϊ��ȡ���տ�������
    if(Theta(i-1)*Theta(i)<0)%�����л�
        if(Theta(i)>0)%��������һ������ ����           %�鿴�˴�"<"or">".
            Flag0(t) = -1;
        end
        if(Theta(i)<0) %���������������� ����
            Flag0(t) = 1;
        end
    else
        Flag0(t) = 0;
    end
end
%���㵽��bardata������ͬ(?)
a=zeros(1,2*M+1);
%b=zeros(1,M);
Flag=[a,Flag0];
end