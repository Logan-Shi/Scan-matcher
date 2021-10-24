clear;clc;

surfix = './../data/shell/';

% Tool_T = [sqrt(1/2) -sqrt(1/2) 0 0;
%           -sqrt(1/2) -sqrt(1/2) 0 0;
%           0 0 -1 370;
%           0 0 0 1];
Tool_T = [-sqrt(1/2) sqrt(1/2) 0 0;
          sqrt(1/2) sqrt(1/2) 0 0;
          0 0 -1 370;
          0 0 0 1];

filename = strcat(surfix,'test.txt');
Ts = read_JAKA_pose(filename);

% to scanner base
for id = 1 : size(Ts,3)
    Ts(:,:,id) = Ts(:,:,id)*Tool_T;
end

% plot results
% figure()
for id = 1 : size(Ts,3)
    trplot(Ts(:,:,id));
    hold on
end

save([surfix,'/Ts_TP.mat'],'Ts')