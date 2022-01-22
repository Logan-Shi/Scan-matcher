function tsFeatures = extractTS(ptCloud, keyInds, numNeighbors,weight)
[indices, ~, valids] = performSearchImpl(ptCloud, keyInds, numNeighbors, inf);
G = [1 0 0 0 0;
    0 1 0 0 0;
    0 0 1 0 0;
    0 0 0 0 -1;
    0 0 0 -1 0];
start_idx = 1;
for i = 1:length(keyInds)
    target = ptCloud.Location(keyInds(i),:);
    Target = [target,sum(target.^2)/2,1];
    p = ptCloud.Location(indices(start_idx:start_idx+valids(i)-1),:);
    start_idx = start_idx + valids(i);
    [v1,v2] = computePlane(p);
    C1 = zeros(5);C2 = zeros(5);
    for j = 1:size(p,1)
        tmp = p(j,:);
        P = [tmp,sum(tmp.^2)/2,1];
        H1 = [v2',tmp*v2,0];
        H2 = [v1',tmp*v1,0];
        
        w1 = exp(-weight*abs(P.*H1));
        w2 = exp(-weight*abs(P.*H2));
        C1 = C1+w1*(P*P')*G;
        C2 = C2+w2*(P*P')*G;
    end
    [v1,e1] = eig(C1);

    % Sort eigenvalues.
    [~,I1] = sort(diag(e1), 'ascend');
    s1 = v1(:,I1(1));
    
    [v2,e2] = eig(C2);
    % Sort eigenvalues.
    [~,I2] = sort(diag(e2), 'ascend');
    s2 = v2(:,I2(1));
    tsFeatures(i,:) = Target*(s1+s2);
end
end

% Perform Hybrid or KNN search based on parameters
function [indices, dists, valids] = performSearchImpl(ptCloud, keyInds, numNeighbors, radius)

[tempIndices, tempDists, valids] = multiQueryKNNSearchImpl(ptCloud, ptCloud.Location(keyInds, :), numNeighbors);
if isfinite(radius)
    tempV   = sqrt(tempDists) <= radius;
    indices = tempIndices(tempV);
    dists   = tempDists(tempV);
    valids  = uint32(sum(tempV, 1)');
else
    indices = tempIndices(:);
    dists   = tempDists(:);
end
end