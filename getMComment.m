function R=getM(boundary,A,B,C)
    % 阈值参数
    w = 3;
    % 检测是否有平行
    if (getK(A,B)==getK(A,C)) || (getK(A,B)==getK(B,C)) || (getK(A,C)==getK(B,C))
        M=0;
        R = [];
        return;
    end
    % 三点拟合出圆
    [CC,r]=CircleThru3Dots(A,B,C);
    % 检测半径是否有问题
    if isnan(r) || abs(r)==Inf
        M=0;
        R = [];
        return;
    end
    % 计算出x，y到圆心的距离
    temp = sqrt((boundary(:,1)-CC(1)).^2 +(boundary(:,2)-CC(2)).^2);
    % 根据距离筛选
    result = (temp > max(r-w/2,0)) & (temp < r+w/2);
    % 计算M
    M = sum(result)/length(result);
    R = [M,CC,A,B,C,r];
end