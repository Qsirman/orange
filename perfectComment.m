
clear;clc;close all;
% 计时的一个标志变量
% timer=0时，不进行计时，会显示所有的结果
% timer=1时，单个文件内既不计时，也不显示结果，是为了方便在外部对其进行计时操作，看test.m
% timer=2时，在单个文件内计时，会显示结果，但显示时间不会计算入内
timer = 1;
% 存储结果的一个标志变量
% show=1时，如果timer=0，最后会将结果保存为相应的文件，文件名为：文件名.jpg
% show=0时，不保存
show = 0;
% 模拟退火算法参数
alpha = 0.99;
e = 10^(-1);
% 去除两圆相交时的一个参数，tt越大，这个标准越严格
tt = -50;
% timer=2的时候开始计时
if timer==2
    tic
end
% 读入图片
original_RGB = imread('1.jpg');
% 将RGB转为YUV通道，图像的三个通道依次对应YUV通道
original_YUV = rgb2ycbcr(original_RGB);
% 保存一下原图像的宽和高度，后面会用
width = size(original_RGB,1);
height = size(original_RGB,2);
% 把V通道的图像单独保存出来
histeq_V = original_YUV(:,:,3);
% 计算V通道的灰度直方图
[counts,x] = imhist(histeq_V);
% 使用大津阈值获得一个MASK
T = otsuthresh(counts);
% 二值化
histeq_V = imbinarize(histeq_V,T);
separation_V=histeq_V;
% 构造一个disk结构的一个窗口
se=strel('disk',18);
% 这里先腐蚀后膨胀，经过测试，这样分开处理比直接用开运算的函数会快一点
% 腐蚀
open_V = imerode(separation_V,se);
% 膨胀
open_V = imdilate(open_V,se);
% 使用canny算子来获得轮廓
edge_V = edge(open_V,'canny');
% 因为直接获得的轮廓效果不好
% 再用线形的窗口膨胀一下
se=strel('line',4,8);
edge_V = imdilate(edge_V,se);
% 获取所有的连通域
B = bwboundaries(edge_V,'noholes');
% 曲率变化率的阈值
t = 4;
% 计算曲率的步长
step = 5;
% 便利所有区域
for k=1:length(B)
    boundary = B{k};
    for i=1:length(boundary(:,1))-2*step
        temp1 = boundary(i+step,:)-boundary(i,:);
        temp2 = boundary(i+step*2,:)-boundary(i+step,:);
        % 计算曲率变化率
        kk = abs(temp2(2)/temp2(1)-temp1(2)/temp1(1));
        % 这里是因为有的时候会有分母为0的情况，或有inf
        if kk == Inf
            continue
        % 如果曲率变化率过高的话，把这一段像素直接设置为0
        elseif kk > t
            edge_V(boundary(i:i+step*4,1),boundary(i:i+step*4,2))=0;
        end
    end
end

% 再次获取所有连通域
B = bwboundaries(edge_V,'noholes');
% 筛去面积过小的区域
for k=1:length(B)
    boundary = B{k};
    if length(boundary(:,1)) < 100
        edge_V(boundary(:,1),boundary(:,2))=0;
        continue
    end
end

% 保存一下当前文件的文件名
name = mfilename;
% 运行改进的随机圆环法
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
    % hold on 接着画图
    hold on;
    % 画圆
    if ~isempty(finalR)
        for i=1:length(finalR(:,1))
            R = finalR(i,:);
            CC = [R(2),R(3)];
            r = R(10);
            drawCircle;
        end
    end
    % 窗口最大化
    set(gcf,'outerposition',get(0,'screensize'));
end