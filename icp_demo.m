clear;clc;
ptCloud = pcread('teapot.ply');
A = [cos(pi/6) sin(pi/6) 0 0; ...
    -sin(pi/6) cos(pi/6) 0 0; ...
            0         0  1 0; ...
            5         5 10 1];
tform1 = affine3d(A);
ptCloudTformed = pctransform(ptCloud,tform1);
tform = pcregistericp(ptCloud,ptCloudTformed,'Extrapolate',true);
tform1.T
tform.T
