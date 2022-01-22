clear;clc;close all;
obj = 'bunny';
voxel_size = 0.01;
method = 'Eigen';
is_graph = false;
weight = 0.2;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');
Tf = [];
batch_size = 10;
time_taken = 0;

for id = 2:batch_size
    fixed = ptCloud{id-1};
    moving = ptCloud{id};
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);

    [~,time] = featureCorrespondence(moving_down,fixed_down,method,is_graph);
    time_taken = time_taken + time;
end
