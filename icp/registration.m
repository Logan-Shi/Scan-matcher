function [tform,reg] = registration(moving,fixed,type,voxel_size,is_graph)
isICP = strcmpi(type,'ICP');
isRANSAC = strcmpi(type,'RANSAC');
isZHOU = strcmpi(type,'ZHOU');
isTEASER = strcmpi(type,'TEASER');
if isICP
    [tform,reg] = pcregistericp(moving,fixed, ...
        'Verbose', is_graph);
    %     tform = pcregistericp(moving,fixed, ...
    %         'Metric', 'pointToPlane', ...
    %         'Extrapolate', true, ...
    %         'InlierRatio', 0.95, ...
    %         'MaxIteration', 150, ...
    %         'Verbose', true);
end

if isRANSAC
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
    if is_graph
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("Original Matched Points")
    end
    
    sample_size = 3;
    [tform,ransac_pairs] = ransacCorrespondence(moving_down,fixed_down,matching_pairs,sample_size,voxel_size,is_graph);
    
    matched_pts_moving = select(moving_down,ransac_pairs(:,1));
    matched_pts_fixed = select(fixed_down,ransac_pairs(:,2));
    
    if is_graph
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("ransaced Matched Points")
        coarse = pctransform(moving_down,tform);
        pcshowpair(coarse, fixed_down)
    end
    
    [tform,reg,error] = pcregistericp(moving,fixed, ...
        'Metric', 'pointToPlane', ...
        'InlierRatio',0.8, ...
        'InitialTransform',tform, ...
        'Verbose', is_graph);
    if is_graph
        pcshowpair(reg,fixed)
        title(['Matched Points' num2str(error)])
    end
end

if isZHOU
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    fixed_feature = extractFPFHFeatures(fixed_down);
    moving_feature = extractFPFHFeatures(moving_down);
    
    match_threshold = 40;
    matching_pairs = findCorrespondenceFromFeature(moving_feature,fixed_feature,match_threshold);
    
    sample_size = 3;
    [tform,ransac_pairs] = zhouCorrespondence(moving_down,fixed_down,matching_pairs,sample_size,voxel_size,is_graph);
    
    matched_pts_moving = select(moving_down,ransac_pairs(:,1));
    matched_pts_fixed = select(fixed_down,ransac_pairs(:,2));
    
    if is_graph
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("ZHOU's Matched Points")
        coarse = pctransform(moving_down,tform);
        pcshowpair(coarse, fixed_down)
    end
    
    [tform,reg,error] = pcregistericp(moving,fixed, ...
        'Metric', 'pointToPlane', ...
        'InlierRatio',0.8, ...
        'InitialTransform',tform, ...
        'Verbose', is_graph);
    if is_graph
        pcshowpair(reg,fixed)
        title(['Matched Points' num2str(error)])
    end
end

if isTEASER
    addpath('/home/logan/Documents/TEASER-plusplus/build/matlab')
    cbar2 = 1;
    noise_bound = voxel_size*0.5;
    rot_alg = 0;
    rot_gnc_factor = 1.4;
    rot_max_iters = 100;
    rot_cost_threshold = 1e-12;
    inlier_arg = 0;
    kcore_thr = 0.5;
    
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
%     if is_graph
%         pcshow(fixed)
%         title('Estimated normals of a point cloud')
%         hold on
%         
%         x = fixed.Location(1:10:end, 1);
%         y = fixed.Location(1:10:end, 2);
%         z = fixed.Location(1:10:end, 3);
%         u = fixed.Normal(1:10:end, 1);
%         v = fixed.Normal(1:10:end, 2);
%         w = fixed.Normal(1:10:end, 3);
%         
%         % Plot the normal vectors
%         quiver3(x, y, z, u, v, w);
%         hold off
%     end
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    fixed_feature = extractFPFHFeatures(fixed_down);
    moving_feature = extractFPFHFeatures(moving_down);
    
    match_threshold = 40;
    matching_pairs = findCorrespondenceFromFeature(moving_feature,fixed_feature,match_threshold);
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    
    src = double(matched_pts_moving.Location');
    dst = double(matched_pts_fixed.Location');
    
    R = teaserSolveR(src,dst,cbar2,noise_bound,is_graph);

    [~, ~, t, time_taken] = teaser_solve(src, dst, 'Cbar2', cbar2, 'NoiseBound', noise_bound, ...
        'EstimateScaling', false, 'RotationCostThreshold', rot_cost_threshold);
    T = eye(4);
    T(1:3,1:3) = R;
    T(1:3,4) = t;
    tform = rigid3d(T');
    
    if is_graph
        figure()
        subplot(2,1,1)
        coarse = pctransform(moving_down,tform);
        pcshowpair(coarse, fixed_down)
    end
    
    [tform,reg,error] = pcregistericp(moving,fixed, ...
        'Metric', 'pointToPlane', ...
        'InlierRatio',0.8, ...
        'InitialTransform',tform, ...
        'Verbose', is_graph);
    if is_graph
        subplot(2,1,2)
        pcshowpair(reg,fixed)
        title(['Matched Points' num2str(error)])
    end
end
end