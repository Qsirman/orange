alpha = 0.99;
e = 10^(-10);
if ~timer
    subplot(2,3,6);
    imshow(original_RGB);
    title('results');
    hold on;
end
max_Iterator = 5000;

[B_,L] = bwboundaries(edge_V,'noholes');
finalR = [];
for l=1:length(B_)
    boundary = B_{l};
    x_min = min(boundary(:,1));
    x_max = max(boundary(:,1));
    y_min = min(boundary(:,2));
    y_max = max(boundary(:,2));
    
    temp = find(boundary(:,1)==x_min);
    A = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,1)==x_max);
    B = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_min);
    C = [boundary(temp(1),1),boundary(temp(1),2)];
    
    temp = find(boundary(:,2)==y_max);
    D = [boundary(temp(1),1),boundary(temp(1),2)];
    
    R1 = getM(boundary,A,B,C);
    R2 = getM(boundary,A,B,D);
    R3 = getM(boundary,B,C,D);
    if length(R1)*length(R2)*length(R3)==0
        continue;
    end
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
    
    maxM = max([R1(2),R2(2),R3(2)]);
    
    indexM = find([R1(2),R2(2),R3(2)] == maxM);
    
    R = R_(indexM,:);
    
    d = 1;
    
    count = 0;
    T = 1;

    A = [R(4),R(5)];
    B = [R(6),R(7)];
    C = [R(8),R(9)];
    
    if maxM > 0.85
        finalR = [finalR;R];
        continue
    end
    
    while 1
        count = count + 1;
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
        
        R_ = getM(boundary,A,B,C);
        
        if isempty(R_)
            continue;
        end
        
        CC = [R_(2),R_(3)];
        r = R_(10);
        
        
        m = R_(1);
        df = maxM - m;
        
        p = P(df,T);
        T = T*alpha;
        
        d = d +1;
        if p < e
            checkR;
            break;
        else
            if ~timer
                disp(p);
            end
        end
        
        if count > max_Iterator
            break;
        end
        
    end
    
end
if ~timer
    if ~isempty(finalR)
        for i=1:length(finalR(:,1))
            R = finalR(i,:);
            CC = [R(2),R(3)];
            r = R(10);
            drawCircle;
        end
    end
end