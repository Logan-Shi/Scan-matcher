clear;clc;

obj = 'teapot';
batch_size = 2;
methods = {'ICP'};
mask = [];

surfix = strcat('./data/',obj,'/');
for type = 1:length(methods)
    Ts_path = strcat(surfix,'Ts_',methods{type},'.mat');
    load(Ts_path, 'Ts');

    count = 0;
    for number = 1:batch_size
        if any(number == mask)
            continue
        end
        filename = [surfix,num2str(number),'.ply'];
        ptCloud = pcread(filename);
        T = Ts(:,:,number);
        tform = rigid3d(T');
        count = count+1;
        ptCloudTrans{count} = pctransform(ptCloud,tform);
    end

    for i = 2:size(ptCloudTrans,2)
        ptCloudTrans{i} = pcmerge(ptCloudTrans{i-1},ptCloudTrans{i},0.01);
    end

    ptCloud = ptCloudTrans{end};
    save([surfix,'/ptCloud_',methods{type},'.mat'],'ptCloud')
end