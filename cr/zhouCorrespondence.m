function [best_tform,filtered_pairs] = zhouCorrespondence(moving,fixed,matching_pairs,sample_size,voxel_size,is_graph)
credibility = 0.999;
inlier_percentage = 0.2;
max_iteration = log(1-credibility)/log(1-inlier_percentage^sample_size);
max_iteration = size(matching_pairs,1)*100;
counter = 0;
filtered_pairs = [];
mov_pts = moving.Location;
fix_pts = fixed.Location;
while counter < max_iteration
    sample_pairs = sampleFromPairs(matching_pairs,sample_size);
    if checkPairs(mov_pts,fix_pts,sample_pairs)
        filtered_pairs = [filtered_pairs;sample_pairs];
    end
    counter = counter + 1;
end

moving_filtered = select(moving,filtered_pairs(:,1));
fixed_filtered = select(fixed,filtered_pairs(:,2));

best_tform = pcregistericp(moving_filtered,fixed_filtered,...
        'MaxIterations',1);
end