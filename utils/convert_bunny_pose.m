function m = convert_bunny_pose(q)
    t = q(1:3);
    w = q(4);
    x = q(5);
    y = q(6);
    z = q(7);
    m = quat2tform([w,x,y,z]);
    m(1:3,4) = t;
end