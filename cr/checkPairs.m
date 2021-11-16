function loop_flag = checkPairs(moving,fixed,sample_pairs)
    sample_size = size(sample_pairs,1);
    p_m = select(moving,sample_pairs(:,1)).Location;
    p_f = select(fixed,sample_pairs(:,2)).Location;

    loop_flag = true;
    for id = 1:(sample_size-1)
        for id_check = (id+1):sample_size
%             loop_flag = loop_flag && norm(p_f(id_check,:)-p_f(id,:)) > voxel_size;
            dist_m = norm(p_m(id_check,:)-p_m(id,:));
            dist_f = norm(p_f(id_check,:)-p_f(id,:));
            ratio = dist_m/dist_f;
            loop_flag = loop_flag && (ratio > 0.9) && (ratio < 1/0.9);
        end
    end
end

