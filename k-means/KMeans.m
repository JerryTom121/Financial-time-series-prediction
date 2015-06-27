%N������һ���ֶ�����
%data������Ĳ��������ŵ�����
%u��ÿһ�������
%re�Ƿ��صĴ������ŵ�����
function [u re]=KMeans(data,N)
    [m n]=size(data);   %m�����ݸ�����n������ά��
    ma=zeros(n);        %ÿһά������
    mi=zeros(n);        %ÿһά��С����
    u=zeros(N,n);       %�����ʼ�������յ�����ÿһ�������λ��
    %��ʼ����������u
    for i=1:n
       ma(i)=max(data(:,i));    %ÿһά������
       mi(i)=min(data(:,i));    %ÿһά��С����
       for j=1:N
            u(j,i)=ma(i)+(mi(i)-ma(i))*rand();  %�������ĵ������ʼ��������������ÿһά[min max]�г�ʼ����Щ
       end
    end
    k=0;
    while 1
        k = k+1;
%         disp(k);
        if k>100
            break;
        end
        pre_u=u;            %��һ����õ�����λ��
        for i=1:N
            tmp{i}=[];      % ��ʽһ�е�x(i)-uj,Ϊ��ʽһʵ����׼��
            for j=1:m
                tmp{i}=[tmp{i};data(j,:)-u(i,:)];
            end
        end
        
        quan=zeros(m,N);
        for i=1:m        %��ʽһ��ʵ��
            c=[];
            for j=1:N
                c=[c norm(tmp{j}(i,:))];
            end
            [junk index]=min(c);
            quan(i,index)=norm(tmp{index}(i,:));
        end
        
        for i=1:N            %��ʽ����ʵ��
            for j=1:n
                if quan(:,i)==0
                    continue;
                else
                    u(i,j)=sum(quan(:,i).*data(:,j))/sum(quan(:,i));
                end
            end
        end
        
        dis = norm(pre_u-u);
        if dis < 0.1  %���ϵ���ֱ��λ�ò��ٱ仯
            break;
        end
    end
    
    re=[];
    for i=1:m
        tmp=[];
        for j=1:N
            tmp=[tmp norm(data(i,:)-u(j,:))];
        end
        [junk index]=min(tmp);
        re=[re;data(i,:) index];
    end
    
end