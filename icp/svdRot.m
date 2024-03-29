function [T,S] = svdRot(X,Y,W)
H = X*diag(W)*Y';
[U,S,V] = svd(H);
if det(U)*det(V)<0
    V(:,end) = -V(:,end);
end
T = V*U';
end