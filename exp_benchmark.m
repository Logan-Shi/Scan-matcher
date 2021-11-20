clear all;
addpath('/home/logan/Documents/TEASER-plusplus/build/matlab')
surfix = 'data/random/';
ptCloud = pcread('data/bunny/reconstruction/bun_zipper_res4.ply');
ptCloud = pcdownsample(ptCloud,'gridAverage',0.0318);
src = ptCloud.Location';
batch_size = size(src,2);
center = mean(src,2);
src = src-repmat(center,[1,batch_size]);
scale = max(sqrt(sum(src.^2)));
src = src/scale;

noise = 0.001;
types = {'RANSAC1k','RANSAC10k','ZHOU','TEASER','TEASERC'};
% types = {'TEASERC'};
for type = 1:length(types)
    for outliers_per = [0 20 60 70 80 90 95 96 97 98 99]
        error_recorder = [];
        time_recorder = [];
        for i = 1:40
            load([surfix, num2str(outliers_per),'/',num2str(i),'_dst.mat'],'dst')
            load([surfix, num2str(outliers_per),'/',num2str(i),'_R.mat'],'R')
            tic
            Rt = solveR(src,dst,types{type},noise,outliers_per/100);
            toc
            error = getAngularError(R,Rt);
            error_recorder = [error_recorder error];
            time_recorder = [time_recorder toc];
        end
        save([surfix, num2str(outliers_per),'/',types{type},'_angular_error.mat'],'error_recorder')
        save([surfix, num2str(outliers_per),'/',types{type},'_time.mat'],'time_recorder')
    end
end