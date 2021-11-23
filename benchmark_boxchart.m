clear all;close all
surfix = 'data/random/';
method = {'RANSAC10k','RANSAC1k','ZHOU','TEASER','TEASERC'};
error = [];
time = [];
methods = {};
outliers = [];
for outliers_per = [0 20 60 70 80 90 95 96 97 98 99]
    for type = 1:length(method)
        load([surfix, num2str(outliers_per),'/',method{type},'_angular_error.mat'],'error_recorder')
        load([surfix, num2str(outliers_per),'/',method{type},'_time.mat'],'time_recorder')
        batch_size = length(error_recorder);
        error = [error;error_recorder'];
        time = [time;time_recorder'];
        methodi = cell(batch_size,1);
        methodi(:) = {method{type}};
        methods = [methods;methodi];
        outliers = [outliers;repmat(outliers_per,batch_size,1)];
    end
end
T = table(methods,outliers,error,time);
outlierOrder = [0 20 60 70 80 90 95 96 97 98 99];
T.outliers = categorical(T.outliers,outlierOrder);
figure()
subplot(2,1,1)
boxchart(T.outliers,T.error,'GroupByColor',T.methods)
ax = gca;
ax.YAxis.Scale ="log";

ylabel('angular error')
legend
grid on
title('\sigma = 0.001')
subplot(2,1,2)
boxchart(T.outliers,T.time,'GroupByColor',T.methods)
ax = gca;
ax.YAxis.Scale ="log";
ylabel('time consumption')
legend
grid on