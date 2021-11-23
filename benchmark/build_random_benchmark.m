clear all;close all;
surfix = 'data/random/';
ptCloud = pcread('data/bunny/reconstruction/bun_zipper_res4.ply');
ptCloud = pcdownsample(ptCloud,'gridAverage',0.0318);
src = ptCloud.Location';
batch_size = size(src,2);
center = mean(src,2);
src = src-repmat(center,[1,batch_size]);
scale = max(sqrt(sum(src.^2)));
src = src/scale;
for outliers_per = [95]
    for i = 1:100
        R = randRotation();
        dst = R*src;
        noise = 0.001;
        [dst,outliers] = addNoise(dst,noise,outliers_per/100,1);
        save([surfix, num2str(outliers_per),'/',num2str(i),'_dst.mat'],'dst')
        save([surfix, num2str(outliers_per),'/',num2str(i),'_R.mat'],'R')
    end
end