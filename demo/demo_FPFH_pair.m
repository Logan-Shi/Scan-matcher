ptCld = pcread('teapot.ply');
ptCloud = pcdownsample(ptCld,'gridAverage',0.5);

A = [cos(pi/6) sin(pi/6) 0 0; ...
    -sin(pi/6) cos(pi/6) 0 0; ...
            0         0  1 0; ...
            5         5 10 1];
tform = affine3d(A);
ptCloudTformed = pctransform(ptCloud,tform);
[fixedFeature,fixedIndex] = extractFPFHFeatures(ptCloud);
[movingFeature,movingIndex] = extractFPFHFeatures(ptCloudTformed);

[matchingPairs,scores] = pcmatchfeatures(fixedFeature,movingFeature,ptCloud,ptCloudTformed);
% figure()
% plot(scores);
index = find(scores>0.004);
matchingPairs = matchingPairs(index,:);
matchedPts1 = select(ptCloud,matchingPairs(:,1));
matchedPts2 = select(ptCloudTformed,matchingPairs(:,2));

pcshowMatchedFeatures(ptCloud,ptCloudTformed,matchedPts1,matchedPts2, ...
    "Method","montage")
title("Matched Points")