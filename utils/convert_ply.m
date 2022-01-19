clear;clc;
obj = 'fin';
batch_size = 8;
mask = [1 2 3 4];

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