%% Source Code of ICOS for Point Cloud Registration

% Paper: 'ICOS: Efficient and Highly Robust Rotation Search and Point Cloud
% Registration using Compatible Structures'

% Copyright by Lei Sun (leisunjames@126.com)

% This source code is only for academic use.

clc;
clear all;
close all;

%% User(s) should set the following parameters:

% set outlier ratio in percentage
outlier_ratio=90; % (0-99)

% set scale condition
known_scale=0; % (0 for unknown scale, 1 for known-scale)



%% The following parameters do not need to be adjusted:

n_ele=1000;

outlier_ratio=outlier_ratio/100;

noise=0.01;

if known_scale==1 %known scale
scale_gt=1;
elseif known_scale==0 % unknown scale
scale_gt=roundn(1+4*rand(1),-4);
end

% Input format:
% n_ele denotes N (number of correspondences including outliers)
% pts_3d is a Nx3 matrix
% pts_2d is a Nx2 matrix
% R_gt is a 3x3 SO(3) matrix ('gt' means ground-truth)
% t_gt is a 1x3 vector

[pts_3d,pts_3d_,R_gt,t_gt]=Build_Environment_PCR(n_ele,noise,outlier_ratio,scale_gt,1);


%% ICOS Initiates from here:

tic;

[R_opt,t_opt,scale_opt,inlier_set]=ICOS_PCR(n_ele,noise,pts_3d,pts_3d_,known_scale);

time=toc();

R_error=AngErr(R_gt,R_opt)*180/pi;

t_error=norm(t_opt - t_gt');

s_error=abs(scale_opt - scale_gt);

recall=min([length(inlier_set)/((1-outlier_ratio)*n_ele),1])*100;



%% Display Results: 

disp(['The ground-truth scale is : ']);

scale_gt

disp(['The scale estimated by ICOS is : ']);

scale_opt

disp(['The ground-truth rotation is : ']);

R_gt

disp(['The rotation estimated by ICOS is : ']);

R_opt

disp(['The ground-truth translation is : ']);

transpose(t_gt)

disp(['The translation estimated by ICOS is : ']);

t_opt

disp(['Scale Error : ', num2str(s_error)]);

disp(['Rotation Error (in degree): ', num2str(R_error)]);

disp(['Translation Error (in meter): ', num2str(t_error)]);

disp(['Runtime (in second): ', num2str(time)]);

disp(['Inlier Recall Ratio (in percentage): ', num2str(recall)]);

