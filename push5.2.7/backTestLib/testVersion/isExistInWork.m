function result = isExistInWork(varname)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%�ж�һ�������Ƿ���ڻ��������ռ��У�����Ϊһ��������

all_var = evalin('base', 'who');

if ismember(varname,all_var)
    result = true;
else
    result = false;
end

end

