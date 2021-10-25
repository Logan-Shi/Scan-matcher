clear;clc;

obj = {'teapot','bunny'};
objs = 2;
methods = {'ICP','benchmark'};
types = 1;

for item = objs
    surfix = strcat('./data/',obj{item},'/');
    for type = types
        Ts_path = strcat(surfix,'Ts_',methods{type},'.mat');
        load(Ts_path, 'Ts');
        ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
        load(ptCloud_path,'ptCloud');

        for number = 1:length(ptCloud)
            T = Ts(:,:,number);
            tform = rigid3d(T');
            ptCloudTrans{number} = pctransform(ptCloud{number},tform);
        end

        for i = 2:size(ptCloudTrans,2)
            ptCloudTrans{i} = pcmerge(ptCloudTrans{i-1},ptCloudTrans{i},0.001);
        end

        ptCloud = ptCloudTrans{end};
        save([surfix,'/ptCloud_',methods{type},'.mat'],'ptCloud')
    end
end