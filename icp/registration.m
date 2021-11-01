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
    fixed_feature = extractFPFHFeatures(fixed_down);
    moving_feature = extractFPFHFeatures(moving_down);
    
    match_threshold = 40;
    matching_pairs = findCorrespondenceFromFeature(moving_feature,fixed_feature,match_threshold);

    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
        "Method","montage")
    title("Matched Points")
    
    sample_size = 3;
    [tform,ransac_pairs] = ransacCorrespondence(moving_down,fixed_down,matching_pairs,sample_size,voxel_size);
    
    matched_pts_moving = select(moving_down,ransac_pairs(:,1));
    matched_pts_fixed = select(fixed_down,ransac_pairs(:,2));
    
    pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
        "Method","montage")
    title("Matched Points")

    coarse = pctransform(moving_down,tform);
    pcshowpair(coarse, fixed_down)
    [tform,refine,error] = pcregistericp(moving,fixed, ...
        'Metric', 'pointToPlane', ...
        'InlierRatio',0.8, ...
        'InitialTransform',tform, ...
        'Verbose', true);
    pcshowpair(refine,fixed)
    title(['Matched Points' num2str(error)])
end
end