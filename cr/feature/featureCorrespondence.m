function [matching_pairs,time_taken] = featureCorrespondence(moving_down,fixed_down,type,is_graph)
isFPFH = strcmp('FPFH',type);
isCGA = strcmp('CGA',type);
isEigen = strcmp('Eigen',type);
isNew = strcmp('New',type);

if isFPFH
    tic
    fixed_FPFH = extractFPFHFeatures(fixed_down);
    moving_FPFH = extractFPFHFeatures(moving_down);

    match_threshold = 100;
    matching_pairs = findCorrespondenceFromFeature(moving_FPFH,fixed_FPFH,match_threshold);
    time_taken = toc;
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    if is_graph
        figure()
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("FPFH's Matched Points")
    end
end

if isCGA
    weight = 0.2;
    tic
    fixed_TS = extractTSFeatures(fixed_down,weight);
    moving_TS = extractTSFeatures(moving_down,weight);

    match_threshold = 100;
    matching_pairs = findCorrespondenceFromFeature(moving_TS,fixed_TS,match_threshold);
    time_taken = toc;
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    if is_graph
        figure()
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("CGA's Matched Points")
    end
end

if isEigen
    tic
    fixed_Eigen = extractEigenFeaturesMe(fixed_down);
    moving_Eigen = extractEigenFeaturesMe(moving_down);

    match_threshold = 100;
    matching_pairs = findCorrespondenceFromFeature(moving_Eigen,fixed_Eigen,match_threshold);
    time_taken = toc;
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    if is_graph
        figure()
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("Eigen Matched Points")
    end
end

if isNew
    if isempty(weight)
        weight = 0.2;
    end
    tic
    fixed_TS = extractTSFeatures(fixed_down,weight);
    moving_TS = extractTSFeatures(moving_down,weight);

    match_threshold = 100;
    matching_pairs = findCorrespondenceFromFeature(moving_TS,fixed_TS,match_threshold);
    time_taken = toc;
    matched_pts_moving = select(moving_down,matching_pairs(:,1));
    matched_pts_fixed = select(fixed_down,matching_pairs(:,2));
    if is_graph
        figure()
        pcshowMatchedFeatures(fixed_down,moving_down,matched_pts_fixed,matched_pts_moving, ...
            "Method","montage")
        title("CGA's Matched Points")
    end
end
end