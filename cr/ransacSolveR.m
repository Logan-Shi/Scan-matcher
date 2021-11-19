function R = ransacSolveR(src,dst,cbar2,noise_bound,outlier_per,is_graph)
src_tims = computeTIM(src);
dst_tims = computeTIM(dst);

beta = 2*noise_bound*sqrt(cbar2);
v1_dist = sqrt(sum(src_tims(1:3,:).^2,1));
v2_dist = sqrt(sum(dst_tims(1:3,:).^2,1));
index = abs(v1_dist-v2_dist)<beta;
src_tims = src_tims(:,index);
dst_tims = dst_tims(:,index);

map = src_tims(4:5,:);
src_tims = src_tims(1:3,:);
dst_tims = dst_tims(1:3,:);

credibility = 0.999;
inlier_percentage = 1-outlier_per;
sample_size = 3;
max_iteration = log(1-credibility)/log(1-inlier_percentage^sample_size);
counter = 0;
R = eye(3);
least_error = inf;
match_size = size(src_tims,2);
while counter < max_iteration
    randseq = randperm(match_size);
    sample_pairs = randseq(1:sample_size);
    
    Rt = svdRot(src_tims(:,sample_pairs),dst_tims(:,sample_pairs),ones(1,sample_size));
    diffs = (dst_tims-Rt*src_tims).^2;
    residuals_sq = sum(diffs);
    error = sum(residuals_sq);

    if error < least_error
        least_error = error;
        R = Rt;
    end
    counter = counter + 1;
end
end