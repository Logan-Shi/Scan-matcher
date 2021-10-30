function [T] = read_JAKA_pose(filename)
% data format
%   [pos_x ...
%    pos_y ...
%    pos_z ...
%    rot_r ...
%    rot_p ... 
%    rot_y ...]
file = fopen(filename,'r');
formatSpec = '%f, %f, %f, %f, %f, %f\n';
data = fscanf(file,formatSpec,[6, Inf]);
fclose(file);
for i = 1:size(data,2)
    T(:,:,i) = convert_JAKA_pose(data(:,i));
end
end