ptCloud = pcread('teapot.ply');
figure
pcshow(ptCloud)
title('Teapot')

% Create a transform object with 30 degree rotation along z-axis and
% translation [5, 5, 10]
theta = pi/6;
rot   = [cos(theta) sin(theta) 0; ...
    -sin(theta) cos(theta) 0; ...
    0          0  1];
trans = [5 5 10];

tform1 = rigid3d(rot, trans);

% Transform the point cloud
ptCloudTformed = pctransform(ptCloud, tform1);

figure
pcshow(ptCloudTformed)
title('Transformed Teapot')

% Apply the rigid registration
[tform, ptCloudReg] = pcregistericp(ptCloudTformed, ptCloud, 'Extrapolate', true);

% Visualize the alignment
pcshowpair(ptCloud, ptCloudReg)

% Compare the result with the true transformation
disp(tform1.T);
tform2 = invert(tform);
disp(tform2.T);