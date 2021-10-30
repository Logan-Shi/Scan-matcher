function trplot(t)
% plot transform
scale = 10;
origin = t(1:3,4);
x = t(1:3,1);
y = t(1:3,2);
z = t(1:3,3);
axis_x = quiver3(origin(1),origin(2),origin(3),x(1),x(2),x(3),scale);
axis_x.Color = 'r';
% axis_x.AutoScale = 'off';
axis_x.LineWidth = 2;
axis_y = quiver3(origin(1),origin(2),origin(3),y(1),y(2),y(3),scale);
axis_y.Color = 'g';
% axis_y.AutoScale = 'off';
axis_y.LineWidth = 2;
axis_z = quiver3(origin(1),origin(2),origin(3),z(1),z(2),z(3),scale);
axis_z.Color = 'b';
% axis_z.AutoScale = 'off';
axis_z.LineWidth = 2;
axis equal
end