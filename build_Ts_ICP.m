clear;clc;
obj = 'bunny';
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

for id = 2:length(ptCloud)
%     tform = pcregistericp(ptCloud{id},ptCloud{id-1}, ...
%         'Extrapolate', true, ...
%         'Verbose', true);
    tform = pcregistericp(ptCloud{id},ptCloud{id-1}, ...
        'Metric', 'pointToPlane', ...
        'Extrapolate', true, ...
        'InlierRatio', 0.95, ...
        'MaxIteration', 150, ...
        'Verbose', true);
    Tf(:,:,id-1) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_ICP.mat'],'Ts')