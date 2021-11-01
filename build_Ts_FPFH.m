clear;clc;
obj = 'bunny';
voxel_size = 0.001;
method = 'FPFH';
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');
Tf = [];
for id = 2:length(ptCloud)
    tform = registration(ptCloud{id},ptCloud{id-1},method,voxel_size);
    Tf(:,:,id-1) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_',method,'.mat'],'Ts')