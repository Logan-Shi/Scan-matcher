clear all;
surfix = 'data/random/';
ptCloud = pcread('data/bunny/reconstruction/bun_zipper_res4.ply');
ptCloud = pcdownsample(ptCloud,'gridAverage',0.0318);
src = ptCloud.Location';

type = 'RANSAC';
for outliers_per = [0 20 60 70 80 90]
    error_recorder = [];
    time_recorder = [];
    for i = 1:40
        load([surfix, num2str(outliers_per),'/',num2str(i),'_dst.mat'],'dst')
        load([surfix, num2str(outliers_per),'/',num2str(i),'_R.mat'],'R')
        tic
        Rt = solveR(src,dst,type);
        toc
        error = getAngularError(R,Rt);
        error_recorder = [error_recorder error];
        time_recorder = [time_recorder toc];
    end
    save([surfix, num2str(outliers_per),'/',type,'_angular_error.mat'],'error_recorder')
    save([surfix, num2str(outliers_per),'/',type,'_time.mat'],'time_recorder')
end