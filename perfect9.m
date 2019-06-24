clear;clc;close all;
timer = 0;
if timer==2
    tic
end
tt = -20;
original_RGB = imread('9.jpeg');

original_YUV = rgb2ycbcr(original_RGB);

width = size(original_RGB,1);
height = size(original_RGB,2);
if ~timer
    subplot(2,3,1);
    imshow(original_RGB);
    title('original');

    subplot(2,3,2);
    imshow(original_YUV(:,:,3));
    title('original_V');
end
histeq_V = double(original_YUV(:,:,3)).*2.8;

[m,n] = size(histeq_V);

histeq_V = reshape(histeq_V(:,:),m*n,1);

histeq_V = kmeans(double(histeq_V),2);

histeq_V = reshape(histeq_V,m,n);
if histeq_V(1,1) == 1
    separation_V = rgb2gray(label2rgb(histeq_V,'gray','k'));
else
    separation_V = rgb2gray(label2rgb(histeq_V,[1,1,1;0,0,0],'w'));
end
if ~timer
    subplot(2,3,3);
    imshow(separation_V);
    title('separation_V');
end
se=strel('disk',7);
open_V = imerode(separation_V,se);
% se=strel('disk',18);
open_V = imdilate(open_V,se);
if ~timer
    subplot(2,3,4);
    imshow(open_V);
    title('open_V');
end
edge_V = edge(open_V,'canny');
se=strel('line',8,4);
edge_V = imdilate(edge_V,se);

B = bwboundaries(edge_V,'noholes');
t = 4;
step = 5;

for k=1:length(B)
    boundary = B{k};
%     if length(boundary(:,1)) < 50
%         edge_V(boundary(:,1),boundary(:,2))=0;
%         continue
%     end
    for i=1:length(boundary(:,1))-4*step
        temp1 = boundary(i+step,:)-boundary(i,:);
        temp2 = boundary(i+step*2,:)-boundary(i+step,:);
        kk = abs(temp2(2)/temp2(1)-temp1(2)/temp1(1));
        if kk == Inf
            continue
        elseif kk > t
            edge_V(boundary(i:i+step*4,1),boundary(i:i+step*4,2))=0;
        end
    end
end


B = bwboundaries(edge_V,'noholes');
for k=1:length(B)
    boundary = B{k};
    if length(boundary(:,1)) < 120
        edge_V(boundary(:,1),boundary(:,2))=0;
        continue
    end
end
if ~timer
    subplot(2,3,5);
    imshow(edge_V);
    title('edge_V');
end
randomCircleModified;
if timer==2
    toc
end