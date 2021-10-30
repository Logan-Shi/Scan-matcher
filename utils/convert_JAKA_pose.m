function T = convert_JAKA_pose(pose)
% convert [x y z r p y] to standard 4*4 transform
T = eul2tform(pose(4:6)'/180*pi);
T(1:3,4) = pose(1:3);
end