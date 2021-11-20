function R = solveR(src,dst,type,noise,outlier_per)
isICP = strcmpi(type,'ICP');
isRANSAC1k = strcmpi(type,'RANSAC1k');
isRANSAC10k = strcmpi(type,'RANSAC10k');
isZHOU = strcmpi(type,'ZHOU');
isTEASER = strcmpi(type,'TEASER');
isTEASERC = strcmpi(type,'TEASERC');
if isTEASER
    R = teaserSolveR(src,dst,1,5.54*noise,0);
end
if isTEASERC
    [~, R, ~, ~] = teaser_solve(double(src), double(dst), 'Cbar2', 1, 'NoiseBound', 5.54*noise, ...
        'EstimateScaling', false, 'RotationCostThreshold', 1e-13);
end
if isZHOU
    R = zhouSolveR(src,dst,1,5.54*noise,0);
end
if isRANSAC1k
    R = ransacSolveR(src,dst,1,5.54*noise,1000,outlier_per,0);
end
if isRANSAC10k
    R = ransacSolveR(src,dst,1,5.54*noise,10000,outlier_per,0);
end
end