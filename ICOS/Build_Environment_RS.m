function [pts_3d,pts_3d_,R]=Build_Environment_RS(n_ele,noise,outlier_ratio)

pts_3d=rand(n_ele,3)-0.5;

n_pts=n_ele;

%% Transformation

% rotation
axis1= rand(1,3)-0.5;

axis1=axis1/norm(axis1);

ag=2*pi*rand(1);

A1 = ag * axis1;

if norm(A1) < 2e-16
         R=eye(3);
else a = A1 / norm(A1);
K1=[0, -a(3), a(2); ...
    a(3), 0, -a(1); ...
    -a(2), a(1), 0];

R = eye(3) + sin(norm(A1)) * K1 + (1 -cos(norm(A1))) * K1 * K1;
end


for i=1:n_ele
    pts_3d(i,:)=pts_3d(i,:)/norm(pts_3d(i,:));
end

%transform by R & t
pc_med= pts_3d * R';

% add noise
    for i=1:n_ele
    pc_med(i,:)=pc_med(i,:)+noise*randn(1,3);
    pts_(i,:) = pc_med(i,:)/norm(pc_med(i,:));
    end

pts_3d_=pts_;

% create outliers
for i=1:round(n_ele*outlier_ratio)
    
    for iii=1:1e+18
    rand_vec=2*1*rand(1,3)-1;
        if norm(rand_vec)<=0.5*sqrt(3)*1
            break
        end
    end
    
pts_3d_(i,:)=rand_vec/norm(rand_vec);

end

end