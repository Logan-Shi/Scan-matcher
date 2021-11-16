clear;clc;
obj = 'bunny';
surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_raw.mat');
load(ptCloud_path,'ptCloud');

ptCloudTrans{1} = ptCloud{1};
for i = 2:length(ptCloud)
    ptCloudTrans{i} = pcmerge(ptCloud{i},ptCloudTrans{i-1},0.0001);
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