clear;clc;close all;
obj = 'wheel';
methods = {'TP','ICP'};
type = 2;
batch_size = 5;
surfix = strcat('./data/',obj,'/');
for number = 1:batch_size
    filename = [surfix,num2str(number),'.ply'];
    ptCloud = pcread(filename);
    xlimits = ptCloud.XLimits;
    ylimits = ptCloud.YLimits;
    zlimits = ptCloud.ZLimits;
    player{number} = pcplayer(xlimits,ylimits,zlimits);
    xlabel(player{number}.Axes,'X (mm)');
    ylabel(player{number}.Axes,'Y (mm)');
    zlabel(player{number}.Axes,'Z (mm)');
    view(player{number},ptCloud);
end