function [R,im] = teaserSolveR(src,dst,cbar2,noise_bound,is_graph)
src_tims = computeTIM(src);
dst_tims = computeTIM(dst);

beta = 2*noise_bound*sqrt(cbar2);
v1_dist = sqrt(sum(src_tims(1:3,:).^2,1));
v2_dist = sqrt(sum(dst_tims(1:3,:).^2,1));
index = abs(v1_dist-v2_dist)<beta;
src_tims = src_tims(:,index);
dst_tims = dst_tims(:,index);

map = src_tims(4:5,:);
src_tims = src_tims(1:3,:);
dst_tims = dst_tims(1:3,:);

match_size = size(src_tims,2);
mu = 1;
prev_cost = inf;
noise_bound_sq = noise_bound^2;

if is_graph
    tims_size = 5;
    rand_seq = randperm(match_size);
    inlier_seq = [367 380 894 904 937];
    rand_seq = rand_seq(1:tims_size);
    weightsRecorderRan = zeros(tims_size,1);
    weightsRecorder = zeros(tims_size,1);
    fig = figure;
    c = rand(tims_size*2+2,3);
end

if noise_bound<1e-16
    noise_bound = 0.01;
end

weights = ones(1,match_size);
cost_threshold = 1e-13;
max_iteration = 1000;
for i = 1:max_iteration
    R = svdRot(src_tims,dst_tims,weights);
    diffs = (dst_tims-R*src_tims).^2;
    residuals_sq = sum(diffs);
    if i == 1
        max_residual = max(residuals_sq);
        mu = 1/(2*max_residual/noise_bound_sq-1);
        if mu<=0
            break;
        end
    end
    th1 = (mu+1)/mu*noise_bound_sq;
    th2 = mu/(mu+1)*noise_bound_sq;
    cost = 0;
    for j = 1:match_size
        cost = cost+weights(j)*residuals_sq(j);
        if residuals_sq(j)>=th1
            weights(j) = 0;
        elseif residuals_sq(j)<=th2
            weights(j) = 1;
        else
            weights(j) = sqrt(noise_bound_sq*mu*(mu+1)/residuals_sq(j))-mu;
        end
    end
    
    if is_graph
        %         visualizeWeight(src,dst,map,tims_num);
        
        subplot(3,1,1)
        visualizeWeight(R*src,dst,map,[rand_seq inlier_seq],weights,c);
        title('TLS-GNC for robust ICP problem')
        
        subplot(3,1,2)
        weightsRecorderRan = [weightsRecorderRan weights(rand_seq)'];
        hold off
        for iter = 1:tims_size
            plot(weightsRecorderRan(iter,:),'color',c(iter+2,:));
            hold on
        end
        %         set(gca, 'YScale', 'log')
        xlabel('iteration')
        ylabel('weight')
        title('random weight for GNC')
        %         axis([0 60 0 1])
        
        subplot(3,1,3)
        weightsRecorder = [weightsRecorder weights(inlier_seq)'];
        hold off
        for iter = 1:tims_size
            plot(weightsRecorder(iter,:),'color',c(iter+2+tims_size,:));
            hold on
            
        end
        %         set(gca, 'YScale', 'log')
        xlabel('iteration')
        ylabel('weight')
        title('inlier weight for GNC')
        %         axis([0 60 0 1])
        set(gcf,'position',[0,0,500,900])
        drawnow
        frame = getframe(fig);
        im{i} = frame2im(frame);
    end
    
    cost_diff = abs(cost - prev_cost);
    mu = mu*1.4;
    prev_cost = cost;
    if cost_diff < cost_threshold
        break;
    end
end
% tims_index = find(weights==1)
if is_graph
    filename = 'figs/teaser.gif';
    for idx = 1:length(im)
        [S,mapgif] = rgb2ind(im{idx},256);
        if idx == 1
            imwrite(S,mapgif,filename,'gif', 'Loopcount',inf,'DelayTime',0.5);
        else
            imwrite(S,mapgif,filename,'gif','WriteMode','append','DelayTime',0.16);
        end
    end
end
end