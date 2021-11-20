function drawSingleLine(p1,p2,c)
x1 = [p1(1), p2(1)];
y1 = [p1(2), p2(2)];
z1 = [p1(3), p2(3)];

plot3(x1,y1,z1,'color',c,'LineWidth',0.01)
axis equal
end