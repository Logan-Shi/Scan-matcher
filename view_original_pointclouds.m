clear;clc;
obj = 'teapot';
methods = {'TP','ICP'};
type = 2;
batch_size = 5;
surfix = strcat('./data/',obj,'/');
for number = 1:batch_size
    filename = [surfix,num2str(number),'.ply'];
    ptCloudTrans{number} = pcread(filename);
end

for i = 2:size(ptCloudTrans,2)
    ptCloudTrans{i} = pcmerge(ptCloudTrans{i-1},ptCloudTrans{i},0.01);
end

ptCloud = ptCloudTrans{end};
xlimits = ptCloud.XLimits;
ylimits = ptCloud.YLimits;
zlimits = ptCloud.ZLimits;
player = pcplayer(xlimits,ylimits,zlimits);
xlabel(player.Axes,'X (mm)');
ylabel(player.Axes,'Y (mm)');
zlabel(player.Axes,'Z (mm)');

view(player,ptCloud);