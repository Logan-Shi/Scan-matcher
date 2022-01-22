clear;clc;close all;
obj = 'bunny';
voxel_size = 0.01;
methods = {'FPFH','CGA','Eigen'};
is_graph = false;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

noise_bound = 1;
base_idx = 2;
position = ptCloud{base_idx}.Location + noise_bound * voxel_size * rand(size(ptCloud{base_idx}.Location));
ptCloudNoise = pointCloud(position);

for j = 1:length(methods)
    fixed = ptCloud{base_idx};
    moving = ptCloudNoise;
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    [matching_pair,~] = featureCorrespondence(moving_down,fixed_down,methods{j},is_graph);
    lerror = [];
    for i = 1:size(matching_pair,1)
        moving_idx = matching_pair(i,1);
        fixed_idx = matching_pair(i,2);
        moving_sample = select(ptCloudNoise,moving_idx).Location;
        fixed_sample = select(ptCloud{1},fixed_idx).Location;
        error(i) = norm(moving_sample-fixed_sample);
    end
    save([surfix,'/FeatureAccuracy_',methods{j},'.mat'],'error')
end