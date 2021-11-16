clear;clc;
obj = 'teapot';
batch_size = 5;
mask = [];

surfix = strcat('./data/',obj,'/');
count = 0;
for number = 1:batch_size
    if any(number == mask)
        continue
    end
    filename = [surfix,num2str(number),'.ply'];
    ptCloud{count+1} = pcread(filename);
    count = count+1;
end

save([surfix,'/ptCloud_raw.mat'],'ptCloud')