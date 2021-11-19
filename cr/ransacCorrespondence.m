function [best_tform,ransac_pairs] = ransacCorrespondence(moving,fixed,matching_pairs,sample_size,voxel_size,is_graph)
credibility = 0.999;
inlier_percentage = 0.2;

max_iteration = log(1-credibility)/log(1-inlier_percentage^sample_size);
counter = 0;
best_tform = rigid3d(eye(4));
least_error = inf;
mov_pts = moving.Location;
fix_pts = fixed.Location;
while counter < max_iteration
    sample_pairs = sampleFromPairs(matching_pairs,sample_size);
    check_counter = 0;
    while ~checkPairs(mov_pts,fix_pts,sample_pairs)
        check_counter = check_counter+1;
        sample_pairs = sampleFromPairs(matching_pairs,sample_size);
    end
    
    sample_moving = select(moving,sample_pairs(:,1));
    sample_fixed = select(fixed,sample_pairs(:,2));
    
    ransac_tform = pcregistericp(sample_moving,sample_fixed);
    error = evaluateRansac(ransac_tform,moving,fixed,voxel_size);

    if error < least_error
        least_error = error;
        ransac_pairs = sample_pairs;
        best_tform = ransac_tform;   
    end
    counter = counter + 1;
end
end