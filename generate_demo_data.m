clear;clc;
ptCloud = pcread('teapot.ply');
surfix = './data/teapot/';
batch_size = 5;
mask = [];

tform = eye(4);
A = [cos(pi/6) sin(pi/6) 0 0; ...
    -sin(pi/6) cos(pi/6) 0 0; ...
            0         0  1 0; ...
            5         5 10 1];

for i = 1:batch_size
    tformi = affine3d(tform);
    tform = A*tform;
    ptCloudTformed = pctransform(ptCloud,tformi);
    filepath = strcat(surfix,num2str(i),'.ply');
    pcwrite(ptCloudTformed,filepath);
end