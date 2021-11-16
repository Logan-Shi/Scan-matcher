function [ptCloud,Ts] = read_mesh_conf(surfix,obj,batch_size)
% read pointcloud data
filename = strcat(surfix,obj,'.conf');
fid = fopen(filename, 'r');
C = textscan(fid, '%s %f %f %f %f %f %f %f', 'HeaderLines', 1, 'CollectOutput', true);
fclose(fid);
ptCloudFile = C{1};
qs = C{2};
number = min(size(qs,1),batch_size);
for id = 1:number
    Ts(:,:,id) = convert_bunny_pose(qs(id,:));
    ptCloud{id} = pcread(strcat(surfix,ptCloudFile{id}));
    filepath = strcat(surfix,num2str(id),'.ply');
    pcwrite(ptCloud{id},filepath);
end
end