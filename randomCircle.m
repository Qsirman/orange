
subplot(2,3,6);
imshow(original_RGB);
title('results');

max_Iterator = 5000;
w = 8;
ratio = 0.85;
[B_,L] = bwboundaries(edge_V,'noholes');
count = 0;
hold on;
for l=1:length(B_)
    boundary = B_{l};
    flag = 0;
    for i=1:length(boundary(:,1))-2
        if flag
            break;
        end
        for j=1:length(boundary(:,1))-1
            if flag
                break;
            end
            for k=1:length(boundary(:,1))
                count = count+1;
                if flag
                    break;
                end
                A=[boundary(i,1),boundary(i,2)];
                B=[boundary(j,1),boundary(j,2)];
                C=[boundary(k,1),boundary(k,2)];
                
                if (getK(A,B)==getK(A,C)) || (getK(A,B)==getK(B,C)) || (getK(A,C)==getK(B,C))
                    continue;
                end
                [CC,r]=CircleThru3Dots(A,B,C);
                if isnan(r) || abs(r)==Inf
                    continue;
                end
                temp = sqrt((boundary(:,1)-CC(1)).^2 +(boundary(:,2)-CC(2)).^2);
                result = (temp > r-w/2) & (temp < r+w/2);
                ratio_ = sum(result)/length(result);
                if(count > max_Iterator)
                    flag = 1;
                    break;
                end
                if ratio_ >= ratio
                    drawCircle;
                    flag = 1;
                    break;
                end
            end
        end
    end
end