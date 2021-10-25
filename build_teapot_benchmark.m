clear;clc;
obj = 'teapot';
batch_size = 5;

surfix = strcat('./data/',obj,'/');
pt = pcread(strcat(obj,'.ply'));
tform = eye(4);
theta = pi/6;
A = [cos(theta) sin(theta) 0 0; ...
    -sin(theta) cos(theta) 0 0; ...
            0         0  1 0; ...
            3         6 10 1];

for i = 1:batch_size
    tformi = affine3d(tform);
    Ts(:,:,i) = invtform(tform');
    ptCloudTformed = pctransform(pt,tformi);
    filepath = strcat(surfix,num2str(i),'.ply');
    pcwrite(ptCloudTformed,filepath);
    ptCloud{i} = ptCloudTformed;
    tform = A*tform;
end

save([surfix,'/ptCloud_raw.mat'],'ptCloud')
save([surfix,'/Ts_benchmark.mat'],'Ts')