clear;clc;close all;
obj = 'bunny';
voxel_size = 0.01;
method = 'TEASER';
feature = 'FPFH';
is_graph = true;
is_refine = true;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');
Tf = [];
% profile on -historysize 50000000
batch_size = 10;
for id = 2:3%2:batch_size
    tform = registration(ptCloud{id},ptCloud{id-1},method,voxel_size,is_graph,is_refine,feature);
    Tf(:,:,id-1) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_',method,'.mat'],'Ts')