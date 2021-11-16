function R = teaserSolveR(src,dst,cbar2,noise_bound)

src_tims = computeTIM(src);
dst_tims = computeTIM(dst);

beta = 2*noise_bound*sqrt(cbar2);
v1_dist = sqrt(sum(src_tims(1:3,:).^2,1));
v2_dist = sqrt(sum(dst_tims(1:3,:).^2,1));
index = abs(v1_dist-v2_dist)<beta;
src_tims = src_tims(:,index);
dst_tims = dst_tims(:,index);

match_size = size(src_tims,2);
mu = 1;
prev_cost = inf;
noise_bound_sq = noise_bound^2;

if noise_bound<1e-16
    noise_bound = 0.01;
end

weights = ones(1,match_size);
cost_threshold = 1e-12;
max_iteration = 100;
for i = 1:max_iteration
    R = svdRot(src_tims,dst_tims,weights);
    diffs = (dst_tims-R*src_tims).^2;
    residuals_sq = sum(diffs);
    if i == 1
        max_residual = max(residuals_sq);
        mu = 1/(2*max_residual/noise_bound_sq-1);
        if mu<=0
            break;
        end
    end
    th1 = (mu+1)/mu*noise_bound_sq;
    th2 = mu/(mu+1)*noise_bound_sq;
    cost = 0;
    for j = 1:match_size
        cost = cost+weights(j)*residuals_sq(j);
        if residuals_sq(j)>=th1
            weights(j) = 0;
        elseif residuals_sq(j)<=th2
            weights(j) = 1;
        else
            weights(j) = sqrt(noise_bound_sq*mu*(mu+1)/residuals_sq(j))-mu;
        end
    end
    cost_diff = abs(cost - prev_cost);
    mu = mu*1.4;
    prev_cost = cost;
    if cost_diff < cost_threshold
        break;
    end
end
end