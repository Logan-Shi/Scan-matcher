function drawLine(p1,p2,p3,p4,weight,c)
x1 = [p1(1), p2(1)];
y1 = [p1(2), p2(2)];
z1 = [p1(3), p2(3)];
x2 = [p3(1), p4(1)];
y2 = [p3(2), p4(2)];
z2 = [p3(3), p4(3)];
if weight ~= 0
    plot3(x1,y1,z1,'LineWidth',weight*5,'color',c)
    plot3(x2,y2,z2,'LineWidth',weight*5,'color',c)
    axis equal
end
end