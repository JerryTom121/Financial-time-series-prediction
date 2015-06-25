function [tradeRecord,isExitLeft] = genTradeRecord(entryRecord,exitRecord)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%�˺������ɽ��׼�¼,�Ŵ��㷨�ӿڵ��µ���¼
%isExitLeft��¼�Ƿ���δƽ���Ĳ֣�0û�У�1�У����ں��洦��

%sprintf('\n%s\n','generating trade record...');

entrylots = entryRecord(:,5);
exitlots = exitRecord(:,5);

entryLength = size(entryRecord,1);
exitLength = size(exitRecord,1);
recLength = max(entryLength,exitLength);

tradeRecord = [];    %��Ž��׼�¼,�Ľ����������Գ�ʼ��Ϊ����Ǹ���������ȷ����
isExitLeft = 0;

entrypos = 1;   %��¼���ֱ������λ��
exitpos = 1;    %��¼ƽ�ֱ������λ��
i = 1;

while i <= recLength
    if entrypos > entryLength
%         disp('index out of entry record''s length');
%         disp('Please check the trade record is right or not');
        break ;
    end
    if exitpos > exitLength
%         disp('index out of entry record''s length');
%         disp('Please check the trade record whether is there are entry records which haven''t been exited');
        leftNum = entryLength - entrypos; %���ʣ�µĿ��ּ�¼�ж���
        exitRecClom = size(exitRecord,2); %��ƽ�ּ�¼����
        tradeRecord(i:i+leftNum,:) = [entryRecord(entrypos:end,1:end-1),zeros(leftNum+1,exitRecClom-2),entryRecord(entrypos:end,end)];
        isExitLeft = 1;
        break ;
    end
    if entrylots(entrypos)==exitlots(exitpos)
        tradeRecord(i,:) = [entryRecord(entrypos,1:end-1),exitRecord(exitpos,2:end)]; %�Ľ������Ը�Ϊ[tradeRecord;temp]
        %openExitLength = openExitLength + 1;
        %openExitRecord(openExitLength,:) = [entryRecord(entrypos,1),entryRecord(entrypos,2)+entryRecord(entrypos,3),entryRecord(entrypos,4)];
        entrypos = entrypos+1;
        exitpos = exitpos+1;
    elseif entrylots(entrypos) > exitlots(exitpos)
        tradeRecord(i,:) = [entryRecord(entrypos,1:end-1),exitRecord(exitpos,2:end)];
        entrylots(entrypos) = entrylots(entrypos)-exitlots(exitpos);
        exitpos = exitpos+1;
    elseif entrylots(entrypos) < exitlots(exitpos)
        for j=entrypos:length(entryRecord(:,1))
            if sum(entrylots(entrypos:j)) == exitlots(exitpos)
                tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)];
                entrypos = j+1;
                exitpos = exitpos+1;
                break;
            elseif sum(entrylots(entrypos:j)) > exitlots(exitpos)
                leftlots = sum(entrylots(entrypos:j)) - exitlots(exitpos);   %ʣ��ûƽ�Ĳ�
                entrypos = j;
                entrylots(entrypos) = leftlots; %��¼ʣ��δƽ�Ĳ�
                tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)-leftlots];
                exitpos = exitpos + 1;
                break;
            end
            tradeRecord(i,:) = [entryRecord(j,1:end-1),exitRecord(exitpos,2:end-1),entryRecord(j,end)];
            i = i+1;
        end
    end
    i = i+1;
end
% sprintf('\n%s\n','ending generating trade record...\n');

end

