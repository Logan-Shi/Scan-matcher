clear;clc;close all;
obj = 'bunny';
methods = {'FPFH','CGA','Eigen'};
surfix = strcat('./data/',obj,'/');

for j = 1:length(methods)
    subplot(1,length(methods),j)
    load([surfix,'/FeatureAccuracy_',methods{j},'.mat'],'error')
    histogram(error,'Normalization','pdf')
    title(methods{j})
end