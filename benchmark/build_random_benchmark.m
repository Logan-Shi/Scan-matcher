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
for outliers_per = [0 20 60 70 80 90 95 96 97 98 99]
    for i = 1:100
        R = randRotation();
        dst = R*src;
        noise = 0.001;
        [dst,outliers] = addNoise(dst,noise,outliers_per/100,1);
        if ~exist([surfix, num2str(outliers_per)],'dir')
            mkdir([surfix, num2str(outliers_per)])
        end
        save([surfix, num2str(outliers_per),'/',num2str(i),'_dst.mat'],'dst')
        save([surfix, num2str(outliers_per),'/',num2str(i),'_R.mat'],'R')
    end
end