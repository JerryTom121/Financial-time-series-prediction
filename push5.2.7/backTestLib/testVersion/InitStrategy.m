function [ output_args ] = InitStrategy(strategy,table_Name)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%���ò��Ե�ʱ���ʼ������������report�ܴ�base�����ռ�֪����ǰ���е���ʲô�����Լ���Ӧ�����ݿ��
%strategy�ǲ��������������ַ�����talbe_Name�Ǳ������������ַ���

%�����base�����ռ�
evalin('base', 'clear');
assignin('base','My_strategy',strategy);
assignin('base','My_table_Name',table_Name);

end

