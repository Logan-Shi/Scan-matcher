%% Source Code of ICOS for Rotation Search

% Paper: 'ICOS: Efficient and Highly Robust Rotation Search and Point Cloud
% Registration using Compatible Structures'

% Copyright by Lei Sun (leisunjames@126.com)

% This source code is only for academic use.

clc;
clear all;
close all;

%% User(s) should set the following parameters:

% set point correspondence number N
n_ele=1000; % (should be chosen from 100, 500 or 1000 only)

% set outlier ratio in percentage
outlier_ratio=90; % (0-99 for N=1000, 0-98 for N=500, and 0-95 for N=100)



%% The following parameters do not need to be adjusted:

noise=0.01;

outlier_ratio=outlier_ratio/100;

%% Build simulation environment:

% Input format:
% n_ele denotes N (number of correspondences including outliers)
% pts_3d is a Nx3 matrix
% pts_2d is a Nx2 matrix
% R_gt is a 3x3 SO(3) matrix ('gt' means the ground-truth)

[pts_3d,pts_3d_,R_gt]=Build_Environment_RS(n_ele,noise,outlier_ratio);

% adjust parameters according to the correspondence number

if n_ele==1000
    X=5;
elseif n_ele==500
    X=4;
elseif n_ele==100
    X=2; % X=3
end


%% ICOS initiates from here:

tic;

[R_opt,inlier_set]=ICOS_RS(n_ele,noise,pts_3d,pts_3d_,X);

time=toc();

R_error=AngErr(R_opt,R_gt)*180/pi;

recall=min([length(inlier_set)/((1-outlier_ratio)*n_ele),1])*100;



%% Display results:

disp(['The ground-truth rotation is : ']);

R_gt

disp(['The rotation estimated by ICOS is: ']);

R_opt

disp(['Rotation Error (in degree): ', num2str(R_error)]);

disp(['Runtime (in second): ', num2str(time)]);

disp(['Inlier Recall Ratio (in percentage): ', num2str(recall)]);

