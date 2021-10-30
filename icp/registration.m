function tform = registration(moving,fixed,type)
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
%     fixed = pcdownsample(fixed,'gridAverage',0.01);
%     moving = pcdownsample(moving,'gridAverage',0.01);
    fixedFeature = extractFPFHFeatures(fixed);
    movingFeature = extractFPFHFeatures(moving);
    
    [matchingPairs,~] = pcmatchfeatures(fixedFeature,movingFeature,fixed,moving);
    
%     figure()
%     plot(scores);
%     index = scores>0.004;
%     matchingPairs = matchingPairs(index,:);
    matchedPts1 = select(fixed,matchingPairs(:,1));
    matchedPts2 = select(moving,matchingPairs(:,2));
    
%     pcshowMatchedFeatures(fixed,moving,matchedPts1,matchedPts2, ...
%         "Method","montage")
%     title("Matched Points")
    
    tform = registration(matchedPts1,matchedPts2,'icp');
    tform = pcregistericp(moving,fixed, ...
        'InitialTransform',tform, ...
        'Verbose', true);
end
end