function z = Hilbertrewroten(M,x)
%UNTITLED Summary of this function goes here
%MΪϣ�����ر任�Ĵ��ڳ���
%xΪԭ�ź�
%�˰汾Ϊ�������ݴ���
%   Detailed explanation goes here
%12.15 ������ȷ ������д
m=length(x);
for n=1:M
    y(n)=0;
end
for n=M+1:m-M
    y(n)=0;
for r=1:2*M+1
    if (r==M+1)
        u=0;
    else
        u=(1-(-1)^(r-M-1))/(pi*(r-M-1));
    end
    y(n)=y(n)+u*x(n-M-1+r);
end
end
%ͳһ��Z����
for n=1:m-2*M %����m,��ȥǰ��m������
    z(n)=x(M+n)+y(M+n)*i;
end
end

