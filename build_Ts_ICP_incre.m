clear;clc;
obj = 'bunny';
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

ptCloudAll = ptCloud{1};
for id = 2:length(ptCloud)
%     tform = pcregistericp(ptCloud{id},ptCloud{id-1}, ...
%         'Extrapolate', true, ...
%         'Verbose', true);
    [tform,ptCloudReg] = pcregistericp(ptCloud{id},ptCloudAll, ...
        'Metric', 'pointToPlane', ...
        'Extrapolate', true, ...
        'InlierRatio', 0.95, ...
        'MaxIteration', 150, ...
        'Verbose', true);
    ptCloudAll = pcmerge(ptCloudAll,ptCloudReg,0.01);
    Tf(:,:,id-1) = tform.T';
    
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_ICP_incre.mat'],'Ts')