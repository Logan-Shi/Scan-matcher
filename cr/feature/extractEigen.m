function features = extractEigen(ptCloud, keyInds, numNeighbors,weight)
[indices, ~, valids] = performSearchImpl(ptCloud, keyInds, numNeighbors, inf);
start_idx = 0;
for i = 1:length(keyInds)
    p = ptCloud.Location(indices(start_idx:start_idx+valids(i)-1),:);
    start_idx = start_idx + valids(i);
    feature = zeros(1, 7, 'like', p);

    % Find the covariance matrix.
    covMatrix = cov(p);

    % Compute eigenvalues of the covariance matrix.
    e = eig(covMatrix);

    % Sort eigenvalues.
    e = sort(e, 'descend');

    % The covariance matrix is a positive-definite matrix so the eigenvalues
    % are expected to be non-negative. They can be negative due to floating
    % point arithmetic so clamping them to a small positive value to avoid
    % complex results.
    e = max(e, eps);

    sumEigen = sum(e);

    % Linearity
    feature(1) = (e(1) - e(2))/e(1);

    % Planarity
    feature(2) = (e(2) - e(3))/e(1);

    % Scattering
    feature(3) = e(3)/e(1);

    % Omnivariance
    feature(4) = ((e(1) * e(2) * e(3)) ^ (1/3));

    % Anisotropy
    feature(5) = (e(1) - e(3))/e(1);

    % Eigenentropy
    feature(6) = -e(1) * log(e(1)) - e(2) * log(e(2)) - e(3) * log(e(3));

    % Change of Curvature
    feature(7) = e(3)/sumEigen;
    features(i,:) = feature;
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