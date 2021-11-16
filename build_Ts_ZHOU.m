clear;clc;
obj = 'bunny';
voxel_size = 0.01;
method = 'ZHOU';
is_graph = true;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');
Tf = [];
% profile on -historysize 50000000
for id = 3:length(ptCloud)
    tform = registration(ptCloud{id},ptCloud{id-1},method,voxel_size,is_graph);
    Tf(:,:,id-1) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_',method,'.mat'],'Ts')