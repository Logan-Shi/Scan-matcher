clear;clc;

obj = {'fin','teapot','bunny'};
objs = 3;
methods = {'ICP','RANSAC','ZHOU','TEASER_incre','TEASER','benchmark'};
type = 5;

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

ply_path = strcat(surfix,'ply_',methods{type},'.ply');
pcwrite(ptCloud,ply_path);