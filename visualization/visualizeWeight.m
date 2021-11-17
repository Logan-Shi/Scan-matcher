function visualizeWeight(src,dst,map,tims_index,weights,c)
hold off
drawPts(src,c(1,:));
hold on
drawPts(dst,c(2,:));
match_size = size(map,2);
counter = 0;
for i = tims_index
    counter = counter+1;
    src_pt1 = src(:,map(1,i));
    src_pt2 = src(:,map(2,i));
    dst_pt1 = dst(:,map(1,i));
    dst_pt2 = dst(:,map(2,i));
    
    drawLine(src_pt1,src_pt2,dst_pt1,dst_pt2,weights(i),c(counter+2,:));
end
view(30,0)
axis equal
end