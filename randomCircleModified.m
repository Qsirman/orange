% �?��循环次数，�?�以少一点，但其实没�?��必�?，大多数的时候�?过一定的循环次数就会得到�?��?的结�?
steps=20;
% 获得�?��的连通域
B__ = bwboundaries(edge_V,'noholes');
% 用于�?存所有的圆环的结�?
finalR = [];
for l=1:length(B__)
    boundary = B__{l};
    % 计算x，y的最大最�?�?
    x_min = min(boundary(:,1));
    x_max = max(boundary(:,1));
    y_min = min(boundary(:,2));
    y_max = max(boundary(:,2));

    % 然�?�分别得到这四个�?
    temp = find(boundary(:,1)==x_min);
    A = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,1)==x_max);
    B = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_min);
    C = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_max);
    D = [boundary(temp(1),1),boundary(temp(1),2)];
    % 由这四个点�?�以计算出三个圆�?
    R1 = getM(boundary,A,B,C);
    R2 = getM(boundary,A,B,D);
    R3 = getM(boundary,B,C,D);
    % 因为如果拟�?�出的圆环�?符�?�一些�?�件，会返回�?��空集，如果这三个圆环里有空集，那我们�?新进行下�?��
    if length(R1)*length(R2)*length(R3)==0
        continue;
    end
    % 如果圆心的�?置超出图的范围，�?新下�?��
    if R1(2) >= width || R1(2) <= 0 || R1(3) >= height || R1(3) <= 0
            continue;
    end
    if R2(2) >= width || R2(2) <= 0 || R2(3) >= height || R2(3) <= 0
            continue;
    end
    if R3(2) >= width || R3(2) <= 0 || R3(3) >= height || R3(3) <= 0
            continue;
    end
    R_ = [R1;R2;R3];
    % 找出M�?��的那个圆
    maxM = max([R1(1),R2(1),R3(1)]);
    
    indexM = find([R1(1),R2(1),R3(1)] == maxM);
    
    R = R_(indexM,:);
    % 循环次数计数
    count = 0;
    % 温度

    if maxM > 0.85
        finalR = [finalR;R];
        continue;
    end
    
    T = 1; L = 100;alpha = 0.99;
    %while T > e
    for k=1:L
         
        T = T*alpha;
        
        A_ = [R(4),R(5)];
        B_ = [R(6),R(7)];
        C_ = [R(8),R(9)];

        indexA = find(boundary(:,1)==A_(1)&boundary(:,2)==A_(2));
        indexA = indexA(1);
        indexB = find(boundary(:,1)==B_(1)&boundary(:,2)==B_(2));
        indexB = indexB(1);
        indexC = find(boundary(:,1)==C_(1)&boundary(:,2)==C_(2));
        indexC = indexC(1);

        indexA_ = indexA+floor(steps/2-steps*rand());
        indexA_ = max(1,indexA_);
        indexA_ = min(length(boundary),indexA_);

        indexB_ = indexB+floor(steps/2-steps*rand());
        indexB_ = max(1,indexB_);
        indexB_ = min(length(boundary),indexB_);

        indexC_ = indexC+floor(steps/2-steps*rand());
        indexC_ = max(1,indexC_);
        indexC_ = min(length(boundary),indexC_);

        plus = unidrnd(3);
        if plus == 1
%                 B(1) = ;
%                 C(2) = C_(2) + d;
            B= boundary(indexB_,:);
            C= boundary(indexC_,:);
        elseif plus == 2
            A= boundary(indexA_,:);
            C= boundary(indexC_,:);
%                 A(1) = A_(1) + d;
%                 C(2) = C_(2) + d;
        elseif plus == 3
            B= boundary(indexB_,:);
            A= boundary(indexA_,:);
%                 A(1) = A_(1) + d;
%                 B(2) = B_(2) + d;
        end
        % 计算当�?的一个圆�?
        R_ = getM(boundary,A,B,C);

        if isempty(R_)
            continue;
        end
        % 获�?�圆心�??�?
        CC = [R_(2),R_(3)];
        % 获�?��?�径
        r = R_(10);
        % 获�?�M
        m = R_(1);
        % 计算df
        df = maxM - m;
        %maxM = m;
        if (df < 0 || exp(-df/T)>=rand())
            maxM = m;
            if R(1) > 0.85
                checkR;
                if ff == 1
                    finalR = [finalR;R_];
                    break;
                end
            end
            R = R_;
        elseif ~timer
                disp(p);
        end
        
        if T<e
            break;
        end 
   end
end

if show
    set(gcf,'outerposition',get(0,'screensize'));
    n=sprintf('%s.jpg',name);
    % 获�?�当�?figure的显示�?�柄
    f=getframe(gcf);
    fframe=f.cdata;
%     w=fspecial('gaussian',[15 15],15);
%     fframe=imfilter(fframe,w);
    % �?存图�?
    imwrite(fframe,n)
end