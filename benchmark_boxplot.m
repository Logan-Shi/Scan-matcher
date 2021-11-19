clear all;
surfix = 'data/random/';
error = [];
time = [];
outliers = [];
method = {'TEASER'};
for type = 1:length(method)
    for outliers_per = [0 20 60 70 80 90]
        load([surfix, num2str(outliers_per),'/',method{type},'_angular_error.mat'],'error_recorder')
        load([surfix, num2str(outliers_per),'/',method{type},'_time.mat'],'time_recorder')
        batch_size = length(error_recorder);
        error = [error;error_recorder];
        time = [time;time_recorder];
        outliers = [outliers;repmat(outliers_per,batch_size,1)];
    end
    boxplot(time,outliers)
    hold on
end
legend = method;
ax = gca;
ax.YAxis.Scale ="log";
xlabel('outliers percentage')
ylabel('time consumption')