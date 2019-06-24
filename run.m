tic;
original_RGB = imread('1.jpg');

original_YUV = rgb2ycbcr(original_RGB);

width = size(original_RGB,1);
height = size(original_RGB,2);

% subplot(2,3,1);
% imshow(original_RGB);
% title('original');
% 
% subplot(2,3,2);
% imshow(original_YUV(:,:,3));
% title('original_V');

histeq_V = double(original_YUV(:,:,3)).*2.8;

[m,n] = size(histeq_V);

histeq_V = reshape(histeq_V(:,:),m*n,1);

histeq_V = kmeans(double(histeq_V),2);

histeq_V = reshape(histeq_V,m,n);

separation_V = rgb2gray(label2rgb(histeq_V,'gray','k'));

subplot(2,3,3);
imshow(separation_V);
title('separation_V');

se=strel('disk',18);
open_V = imerode(separation_V,se);
se=strel('disk',18);
open_V = imdilate(open_V,se);
subplot(2,3,4);
imshow(open_V);
title('open_V');

edge_V = edge(open_V,'canny');
se=strel('line',4,6);
edge_V = imdilate(edge_V,se);
% subplot(2,3,5);
% imshow(edge_V);
% title('ï¿½ï¿½Ôµï¿½ï¿½ï¿?);

[B,L] = bwboundaries(edge_V,'noholes');
t = 4;
step = 5;
l = 0;
for k=1:length(B)
    boundary = B{k};
    if length(boundary(:,1)) < 50
        edge_V(boundary(:,1),boundary(:,2))=0;
        continue
    end
    for i=1:length(boundary(:,1))-4*step-l
        temp1 = boundary(i+step,:)-boundary(i,:);
        temp2 = boundary(i+step*2,:)-boundary(i+step,:);
        kk = abs(temp2(2)/temp2(1)-temp1(2)/temp1(1));
%         if kk ~= Inf
%             disp(kk);
%         end
%         disp(kk);
        if kk == Inf
%             edge_V(boundary(i:i+step*4,1),boundary(i:i+step*4,2))=0;
        elseif kk > t
            s = sprintf('kk=%f',abs(kk));
            disp(s);
            edge_V(boundary(i:i+step*4,1),boundary(i:i+step*4,2))=0;
        end
    end
end

% [B,L] = bwboundaries(edge_V,'noholes');
% for k=1:length(B)
%     boundary = B{k};
%     if length(boundary(:,1)) < 50
%         edge_V(boundary(:,1),boundary(:,2))=0;
%     end
% end

subplot(2,3,5);
imshow(edge_V);
title('edge_V');

tic;
randomCircleModified;
toc;