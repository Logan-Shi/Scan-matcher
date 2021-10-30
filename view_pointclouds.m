clear;clc;

obj = {'teapot','bunny'};
objs = 2;
methods = {'ICP','benchmark','ICP_incre','FPFH'};
type = 1;

surfix = strcat('./data/',obj{objs},'/');
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