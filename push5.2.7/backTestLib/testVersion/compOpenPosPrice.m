function OpenPosPrice = compOpenPosPrice(entryprice,myOpenIntRecord)

%���㿪���õĵ�������û���Ͻ��׵�λ��
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
myOpenInt = sum(myOpenIntRecord(:,2));
OpenPosPrice = 0;

if myOpenInt ~=0
    for num=1:length(myOpenIntRecord(:,1))
        OpenPosPrice = OpenPosPrice+entryprice(myOpenIntRecord(num,1))*myOpenIntRecord(num,2);    %�������ʽ�
    end
end

%OpenPosPrice = OpenPosPrice/sum(myOpenIntRecord(:,2));

end

