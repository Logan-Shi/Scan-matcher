function [tform,reg,error] = registration(moving,fixed,type,voxel_size,is_graph,is_refine,feature)

isRANSAC = strcmpi(type,'RANSAC');
isZHOU = strcmpi(type,'ZHOU');
isTEASER = strcmpi(type,'TEASER');
if isempty(feature)
    feature = 'FPFH';
end

if isRANSAC
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);

    [matching_pairs,~] = featureCorrespondence(moving_down,fixed_down,feature,is_graph);
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
        'InlierRatio',0.2, ...
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
    
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);

    [matching_pairs,~] = featureCorrespondence(moving_down,fixed_down,feature,is_graph);
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    
    if is_graph
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("ZHOU's Matched Points")
        coarse = pctransform(moving_down,tform);
        pcshowpair(coarse, fixed_down)
    end
    
    if is_refine
        [tform,reg,error] = pcregistericp(moving,fixed, ...
            'Metric', 'pointToPlane', ...
            'InlierRatio',0.8, ...
            'InitialTransform',tform, ...
            'Verbose', is_graph);
        if is_graph
            figure()
            pcshowpair(reg,fixed)
            title(['Matched Points' num2str(error)])
        end
    else
        reg = coarse;
        error = 0;
    end
end

if isTEASER
    addpath('/home/logan/Documents/TEASER-plusplus/build/matlab')
    cbar2 = 1;
    noise_bound = voxel_size*10;
    rot_alg = 0;
    rot_gnc_factor = 1.4;
    rot_max_iters = 100;
    rot_cost_threshold = 1e-12;
    inlier_arg = 0;
    kcore_thr = 0.5;
    
    fixed.Normal = pcnormals(fixed);
    moving.Normal = pcnormals(moving);
    
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);

    [matching_pairs,~] = featureCorrespondence(moving_down,fixed_down,feature,is_graph);
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));

    src = double(matched_pts_moving.Location');
    dst = double(matched_pts_fixed.Location');
    
%     R = teaserSolveR(src,dst,cbar2,noise_bound,is_graph);
%     R = ransacSolveR(src,dst,cbar2,noise_bound,0.9,is_graph);

    [~, R, t, time_taken] = teaser_solve(src, dst, 'Cbar2', cbar2, 'NoiseBound', noise_bound, ...
        'EstimateScaling', false, 'RotationCostThreshold', rot_cost_threshold);
    T = eye(4);
    T(1:3,1:3) = R;
    T(1:3,4) = t;
    tform = rigid3d(T');
    
    if is_graph
        figure()
        coarse = pctransform(moving,tform);
        pcshowpair(coarse, fixed)
    end
    if is_refine
        [tform,reg,error] = pcregistericp(moving,fixed, ...
            'Metric', 'pointToPlane', ...
            'InlierRatio',0.8, ...
            'InitialTransform',tform, ...
            'Verbose', is_graph);
        if is_graph
            figure()
            pcshowpair(reg,fixed)
            title(['Matched Points' num2str(error)])
        end
    else
        reg = coarse;
        error = 0;
    end
end
end