function MAClose = MA( data,Cycle )
%UNTITLED Summary of this function goes here
%�ƶ�ƽ����
%   Detailed explanation goes here
%��������,����m����
%  for i=1:Cycle-1
%  MAminuteClose(i)=0;
%  end
% for i=Cycle:m
Close = data(:,6);

m=length(data);
MAClose=Close;
for t=Cycle:m
 MAClose(t) = mean(Close(t-Cycle+1:t));
end
end

