clear;clc;close all;
obj = 'fin';
method = 'TEASER';
voxel_size = 1;
is_graph = true;
is_refine = false;
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

% 5 6 7 8
ptCloudAll = ptCloud{9};
[tform,ptCloudReg,error] = registration(ptCloud{4},ptCloudAll,method,voxel_size,is_graph,is_refine);
ptCloudAll = pcmerge(ptCloudAll,ptCloudReg,0.0001);
ptCloudAll = pctransform(ptCloudAll,tform);
save([surfix,'/ptCloud_',method,'_incre_',num2str(3),'.mat'],'ptCloudAll')

    
% Tf(:,:,id-1) = tform.T';
% Ts = eye(4);
% for id = 1 : size(Tf,3)
%     Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
% end
% 
% save([surfix,'/Ts_',method,'_incre.mat'],'Ts')