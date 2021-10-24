clear;clc;
obj = 'teapot';
methods = {'TP','ICP'};
type = 2;

surfix = strcat('./data/',obj,'/');
ptCloud_path = strcat(surfix,'ptCloud_',methods{type});
load(ptCloud_path, 'ptCloud');

% ptCloud = pcdownsample(ptCloud,'gridAverage',1);
xlimits = ptCloud.XLimits;
ylimits = ptCloud.YLimits;
zlimits = ptCloud.ZLimits;
player = pcplayer(xlimits,ylimits,zlimits);
xlabel(player.Axes,'X (mm)');
ylabel(player.Axes,'Y (mm)');
zlabel(player.Axes,'Z (mm)');
view(player,ptCloud);