clear all;
surfix = 'data/random/';
ptCloud = pcread('data/bunny/reconstruction/bun_zipper_res4.ply');
ptCloud = pcdownsample(ptCloud,'gridAverage',0.0318);
src = ptCloud.Location';
for outliers_per = [0 20 60 70 80 90]
    for i = 1:40
        R = randRotation();
        dst = R*src;
        noise = 0.001;
        dst = addNoise(dst,noise,outliers_per/100,1);
        save([surfix, num2str(outliers_per),'/',num2str(i),'_dst.mat'],'dst')
        save([surfix, num2str(outliers_per),'/',num2str(i),'_R.mat'],'R')
%         drawPts(dst,rand(3,1))
    end
end