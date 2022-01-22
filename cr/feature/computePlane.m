function [v1,v2] = computePlane(points)

% Find the covariance matrix.
covMatrix = cov(points);

% Compute eigenvalues of the covariance matrix.
[v,e] = eig(covMatrix);

% Sort eigenvalues.
[sorted_e,I] = sort(diag(e), 'ascend');
v1 = v(:,I(1));
v2 = v(:,I(2));
end