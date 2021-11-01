% Read point cloud data from a PLY file
ptObj = pcread("teapot.ply");

% Downsample input point cloud
ptCloudIn = pcdownsample(ptObj, 'gridAverage', 0.05);

% Select sample plane and corner points as key indices.
keyInds = [6565, 10000];

% Extract FPFH features for points at key indices
features = extractFPFHFeatures(ptCloudIn, keyInds);

% Display key points on input point cloud
ptKeyObj = pointCloud(ptCloudIn.Location(keyInds, :), 'Color', [255, 0, 0; 0, 0, 255]);
figure;
pcshow(ptObj);
title('Selected Indices On Input Point Cloud');
hold on;
pcshow(ptKeyObj, 'MarkerSize', 1000);
hold off;

% Display extracted features at key points
figure;
ax1 = subplot(2, 1, 1);
bar(features(1, :), 'FaceColor', [1 0 0]);
title("Features Of Selected Indices");
ax2 = subplot(2, 1, 2);
bar(features(2, :), 'FaceColor', [0 0 1]);
linkaxes([ax1, ax2], 'xy');