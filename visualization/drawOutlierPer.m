clear all;close all;
surfix = 'data/random/';
ptCloud = pcread('data/bunny/reconstruction/bun_zipper_res4.ply');
% ptCloud = pcdownsample(ptCloud,'gridAverage',0.0318);
src = ptCloud.Location';
batch_size = size(src,2);
center = mean(src,2);
src = src-repmat(center,[1,batch_size]);
scale = max(sqrt(sum(src.^2)));
src = src/scale;
outliers_per = 80;
R = randRotation();
dst = R*src;
noise = 0.001;
[dst,outliers] = addNoise(dst,noise,outliers_per/100,1);
drawCorr(src,dst+repmat(3,size(dst)),outliers);
title('80% outliers')