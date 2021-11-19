function dst = addNoise(dst,noise_bound,outliers_per,upper_bound)
num = size(dst,2);
noise = noise_bound * rand(3,num);
dst = dst+noise;
randseq = randperm(num);
outliers_num = min(outliers_per*num,num-3);
for i = 1:outliers_num
    rand_vec = upper_bound*rand(1)*ones(3,1);
    R = randRotation();
    rand_vec = R*rand_vec;
    dst(:,randseq(i)) = rand_vec;
end
end