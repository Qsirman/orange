ff = 1;

if ~isempty(finalR)
    for i=1:length(finalR(:,1))
        R__ = finalR(i,:);
        CC1_ = [R_(2),R_(3)];
        CC2_ = [R__(2),R__(3)];
        
        if CC1_(1) >= width || CC1_(1) <= 0 || CC1_(2) >= height || CC1_(2) <= 0
            ff = 0;
            break;
        end
        
        CC_ = CC1_ - CC2_;
        dis = sqrt(sum(CC_.^2));
       
        if  dis <= R_(10) + R__(10)+tt 
            if R_(1) > R__(1)
                finalR(i,:) = R_;
            end
            ff = 0;
        end
    end
end
