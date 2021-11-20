function src = centerAndScale(src)
batch_size = size(src,2);
center = mean(src,2);
src = src-repmat(center,[1,batch_size]);
scale = max(sqrt(sum(src.^2)));
src = src/scale;
end

