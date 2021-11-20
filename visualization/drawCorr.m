function drawCorr(src,dst,out)
hold on
drawPts(src,rand(3,1));
drawPts(dst,rand(3,1));
batch_size = size(src,2);
for i = 1:batch_size
    if find(out == i)
%         drawSingleLine(src(:,i),dst(:,i),'r')
    else
        drawSingleLine(src(:,i),dst(:,i),'g')
    end
end
hold off
end

