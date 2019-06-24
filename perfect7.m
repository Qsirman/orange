clear;clc;close all;
timer = 2;
alpha = 0.99;
show = 0;
e = 10^(0);
if timer==2
    tic
end
tt = -50;
original_RGB = imread('7.jpg');

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
histeq_V = original_YUV(:,:,3);
[counts,x] = imhist(histeq_V);
T = otsuthresh(counts);
histeq_V = imbinarize(histeq_V,T);
separation_V=histeq_V;
if ~timer
    subplot(2,3,3);
    imshow(separation_V);
    title('separation_V');
end
open_V=separation_V;
B = bwboundaries(open_V,'noholes');
for k=1:length(B)
    boundary = B{k};
    if length(boundary(:,1)) < 150
        open_V(boundary(:,1),boundary(:,2))=0;
    end
end

se=strel('disk',9);
open_V = imdilate(open_V,se);
% open_V = imerode(open_V,se);

if ~timer
    subplot(2,3,4);
    imshow(open_V);
    title('open_V');
end
edge_V = edge(open_V,'canny');
se=strel('line',4,4);
edge_V = imdilate(edge_V,se);

B = bwboundaries(edge_V,'noholes');
t = 4;
step =5;

for k=1:length(B)
    boundary = B{k};
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
    if length(boundary(:,1)) < 100
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
if timer == 2
    subplot(2,3,1);
    imshow(original_RGB);
    title('original');

    subplot(2,3,2);
    imshow(original_YUV(:,:,3));
    title('original_V');
    subplot(2,3,3);
    imshow(separation_V);
    title('separation_V');
    subplot(2,3,4);
    imshow(open_V);
    title('open_V');
    subplot(2,3,5);
    imshow(edge_V);
    title('edge_V');
    subplot(2,3,6);
    imshow(original_RGB);
    title('results');
    hold on;
    if ~isempty(finalR)
        for i=1:length(finalR(:,1))
            R = finalR(i,:);
            CC = [R(2),R(3)];
            r = R(10);
            drawCircle;
        end
    end
    set(gcf,'outerposition',get(0,'screensize'));
end