clear;clc;
obj = 'teapot';
batch_size = 2;
mask = [];

surfix = strcat('./data/',obj,'/');
count = 0;
for number = 1:batch_size
    if any(number == mask)
        continue
    end
    filename = [surfix,num2str(number),'.ply'];
    ptCloud{count+1} = pcread(filename);
%     ptCloud{count+1} = pcdownsample(ptCloud{count+1},'gridAverage',1);
    count = count+1;
end

for id = 1:count-1
    tform = pcregistericp(ptCloud{id+1},ptCloud{id});
    Tf(:,:,id) = tform.T';
end

Ts = eye(4);
for id = 1 : size(Tf,3)
    Ts(:,:,id+1) = Ts(:,:,id) * Tf(:,:,id);
end

save([surfix,'/Ts_ICP.mat'],'Ts')