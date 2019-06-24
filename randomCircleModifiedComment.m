% 最大循环次数，可以少一点，但其实没什么必要，大多数的时候经过一定的循环次数就会得到需要的结果
max_Iterator = 5000;
% 获得所有的连通域
[B_,L] = bwboundaries(edge_V,'noholes');
% 用于保存所有的圆环的结果
finalR = [];
for l=1:length(B_)
    boundary = B_{l};
    % 计算x，y的最大最小值
    x_min = min(boundary(:,1));
    x_max = max(boundary(:,1));
    y_min = min(boundary(:,2));
    y_max = max(boundary(:,2));

    % 然后分别得到这四个点
    temp = find(boundary(:,1)==x_min);
    A = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,1)==x_max);
    B = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_min);
    C = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_max);
    D = [boundary(temp(1),1),boundary(temp(1),2)];
    % 由这四个点可以计算出三个圆环
    R1 = getM(boundary,A,B,C);
    R2 = getM(boundary,A,B,D);
    R3 = getM(boundary,B,C,D);
    % 因为如果拟合出的圆环不符合一些条件，会返回一个空集，如果这三个圆环里有空集，那我们重新进行下一轮
    if length(R1)*length(R2)*length(R3)==0
        continue;
    end
    % 如果圆心的位置超出图的范围，重新下一轮
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
    % 找出M最大的那个圆
    maxM = max([R1(2),R2(2),R3(2)]);
    
    indexM = find([R1(2),R2(2),R3(2)] == maxM);
    
    R = R_(indexM,:);
    % 这对应模拟退火算法里的Δ
    d = 1;
    % 循环次数计数
    count = 0;
    % 温度
    T = 1;

    % 把最大M圆环对应的三个点保存下来
    A = [R(4),R(5)];
    B = [R(6),R(7)];
    C = [R(8),R(9)];
    % 如果这个圆的M已经超过这个阈值，直接保存这个圆
    if maxM > 0.85
        finalR = [finalR;R];
        continue;
    end
    % 循环，直到找到合适的圆环
    while 1
        count = count + 1;
        % 每次需要选择一对点的x和y分别改变
        % 随机机一个数字，随机到的数字对应的点不变
        plus = unidrnd(3);
        if plus == 1
            B(1) = B(1) + d;
            C(2) = C(2) + d;
        elseif plus == 2
            A(1) = A(1) + d;
            C(2) = C(2) + d;
        elseif plus == 3
            A(1) = A(1) + d;
            B(2) = B(2) + d;
        end
        % 计算当前的一个圆环
        R_ = getM(boundary,A,B,C);
        
        if isempty(R_)
            continue;
        end
        % 获取圆心坐标
        CC = [R_(2),R_(3)];
        % 获取半径
        r = R_(10);
        % 获取M
        m = R_(1);
        % 计算df
        df = maxM - m;
        % 计算P
        p = P(df,T);
        % 更新温度
        T = T*alpha;
        
        d = d +1;
        % 如果P<e，就是说现在这个圆环是合适的
        if p < e
            % 从其他方面筛选一下R
            checkR;
            break;
        else
            if ~timer
                disp(p);
            end
        end
        % 如果已经超过最大循环次数，跳出循环
        if count > max_Iterator
            break;
        end
        
    end
    
end

if show
    set(gcf,'outerposition',get(0,'screensize'));
    n=sprintf('%s.jpg',name);
    % 获取当前figure的显示句柄
    f=getframe(gcf);
    fframe=f.cdata;
%     w=fspecial('gaussian',[15 15],15);
%     fframe=imfilter(fframe,w);
    % 保存图片
    imwrite(fframe,n)
end