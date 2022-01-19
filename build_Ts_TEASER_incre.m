clear;clc;
obj = 'fin';
method = 'TEASER';
voxel_size = 1;
is_graph = true;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

ptCloudAll = ptCloud{1};
for id = 2:length(ptCloud)
    [tform,ptCloudReg] = registration(ptCloud{id},ptCloudAll,method,voxel_size,is_graph);
    ptCloudAll = pcmerge(ptCloudAll,ptCloudReg,0.0001);
    Tf(:,:,id-1) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_',method,'_incre.mat'],'Ts')