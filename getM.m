function R=getM(boundary,A,B,C)
    w = 3;
    if (getK(A,B)==getK(A,C)) || (getK(A,B)==getK(B,C)) || (getK(A,C)==getK(B,C))
        M=0;
        R = [];
        return;
    end
    [CC,r]=CircleThru3Dots(A,B,C);
    
    if isnan(r) || abs(r)==Inf
        M=0;
        R = [];
        return;
    end
    temp = sqrt((boundary(:,1)-CC(1)).^2 +(boundary(:,2)-CC(2)).^2);
%     result = (temp > max(r-w/2,0)) & (temp < r+w/2);
    result = temp <= r;
    M = sum(result)/length(result);
    R = [M,CC,A,B,C,r];
end