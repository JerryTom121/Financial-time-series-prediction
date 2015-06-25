function profit = downSwingStrategy()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



begT = '2010-04-01';
endT = '2014-05-01';
sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
bardata = getBarData(sql);
Close = cell2mat(bardata(:,1));
Date = exchangeDateToNum(bardata(:,2),bardata(:,3));

DayBegTime = [];    %ÿ��ĵ�һʱ��
DayEndTime = [];    %ÿ������һ��

%��ȡÿ��ĵ�һ�̺����һ��
for i=2:length(Date)
    yestD = Date(i-1,:);
    if day(Date(i,:)) ~= day(yestD)  %���գ���¼��������һ��ʱ��
        DayBegTime = Date(i,:);
        DayEndTime = yestD;
        break;
    end
end
before6Time = DayEndTime - datenum('0000-01-00 00:30:00','yyyy-mm-dd HH:MM:SS');    %datenum�Ǵ�0000-01-00��ʼ����ģ������·ݱ���Ϊ1��
betweenI = find(Date==DayEndTime) - find(Date==before6Time); %��������Сʱ������������
begI = find(hour(Date)==hour(DayBegTime)&minute(Date)==minute(DayBegTime)&second(Date)==second(DayBegTime));   %�ҳ�ÿ��ĵ�һ�����ݵ��±�
endI = find(hour(Date)==hour(DayEndTime)&minute(Date)==minute(DayEndTime)&second(Date)==second(DayEndTime));   %�ҳ�ÿ������һ�����ݵ��±�

%��ÿ�����̼۳���ÿ�쿪�̼�-1�����������
DayPro = Close(endI)./Close(begI) - 1;
%��ȡ����Сʱ����
[m n] = size(endI);
m=m-1;
for i=1:m %m-1��Ϊ������һ����������������
    before6Close(i,:) = Close(endI(i)-betweenI+1:endI(i));
end

%
data = mapminmax(before6Close);
K = 5;
[u re] = KMeans(data,K);
K_Pro = zeros(K,1);

for i=1:K
    k_index = find(re(:,end)==i);
    K_Pro(i) = mean(DayPro(k_index+1));
end

%���Խ���

begT = endT;
endT = datestr(datenum(endT,'yyyy-mm-dd')+datenum('0001-01-00','yyyy-mm-dd'),'yyyy-mm-dd');
sql = ['select Close,Date,Time from if000_M1 where Date>''',begT,'''and Date < ''',endT,''';'];
testbardata = getBarData(sql);
testClose = cell2mat(testbardata(:,1));
testDate = exchangeDateToNum(testbardata(:,2),testbardata(:,3));

begI = find(hour(testDate)==hour(DayBegTime)&minute(testDate)==minute(DayBegTime)&second(testDate)==second(DayBegTime));   %�ҳ�ÿ��ĵ�һ�����ݵ��±�
endI = find(hour(testDate)==hour(DayEndTime)&minute(testDate)==minute(DayEndTime)&second(testDate)==second(DayEndTime));   %�ҳ�ÿ������һ�����ݵ��±�

%��ÿ�����̼ۼ�ȥ���̼����������
testDayPro1 = testClose(endI)-testClose(begI);
testDayPro2 = testClose(begI)-testClose(endI);
%��ȡ����Сʱ����
[m n] = size(endI);
m=m-1;
for i=1:m %m-1��Ϊ������һ����������������
    testbefore6Close(i,:) = testClose(endI(i)-betweenI+1:endI(i));
end

testre=[];
[m n] = size(testbefore6Close);
data = mapminmax(testbefore6Close);
K = 5;
for i=1:m
    tmp=[];
    for j=1:K
        tmp=[tmp norm(data(i,:)-u(j,:))];
    end
    [junk index]=min(tmp);
    disp(index);
    testre=[testre;data(i,:) index];
end

test_Pro = zeros(K,1);
for i=1:K
    if K_Pro(i)>0
        k_index = find(testre(:,end)==i);
        test_Pro(i) = sum(testDayPro(k_index+1));
    end
end

profit = test_Pro*300;
save data;
end
