function tform = registration(moving,fixed,type,voxel_size)
isICP = strcmpi(type,'ICP');
isFPFH = strcmpi(type,'FPFH');
if isICP
    tform = pcregistericp(moving,fixed, ...
        'Verbose', true);
%     tform = pcregistericp(moving,fixed, ...
%         'Metric', 'pointToPlane', ...
%         'Extrapolate', true, ...
%         'InlierRatio', 0.95, ...
%         'MaxIteration', 150, ...
%         'Verbose', true);
end

if isFPFH
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    fixedFeature = extractFPFHFeatures(fixed_down);
    movingFeature = extractFPFHFeatures(moving_down);
    
    [matchingPairs,scores] = pcmatchfeatures(fixedFeature,movingFeature,fixed_down,moving_down,...
        "MatchThreshold", 0.003);
    
%     figure()
%     plot(scores);
%     index = scores>0.004;
%     matchingPairs = matchingPairs(index,:);
    matchedPts_fixed = select(fixed_down,matchingPairs(:,1));
    matchedPts_moving = select(moving_down,matchingPairs(:,2));
    
    pcshowMatchedFeatures(fixed_down,moving_down,matchedPts_fixed,matchedPts_moving, ...
        "Method","montage")
    title("Matched Points")
  
    tform = registration(matchedPts_moving,matchedPts_fixed,'icp');
    coarse = pctransform(moving_down,tform);
    pcshowpair(coarse, fixed_down)
    tform = pcregistericp(moving,fixed, ...
        'Metric', 'pointToPlane', ...
        'InlierRatio',0.8, ...
        'InitialTransform',tform, ...
        'Verbose', true);
    refine = pctransform(moving,tform);
    pcshowpair(refine,fixed)
end
end