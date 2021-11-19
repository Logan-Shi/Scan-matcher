function R = solveR(src,dst,type)
isICP = strcmpi(type,'ICP');
isRANSAC = strcmpi(type,'RANSAC');
isZHOU = strcmpi(type,'ZHOU');
isTEASER = strcmpi(type,'TEASER');
if isTEASER
    R = teaserSolveR(src,dst,1,0.001,0);
end
if isZHOU
    R = zhouSolveR(src,dst,1,0.001,0);
end
if isRANSAC
    R = ransacSolveR(src,dst,1,0.001,0);
end
end