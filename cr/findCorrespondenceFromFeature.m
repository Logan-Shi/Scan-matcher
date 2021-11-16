function index_pairs = findCorrespondenceFromFeature(moving_feature, fixed_feature, difference_threshold)
% index_pairs: [moving index, fixed index, dist]
    tree_f = KDTreeSearcher(fixed_feature);
    tree_m = KDTreeSearcher(moving_feature);
    data_size_m = size(moving_feature,1);
    index_pairs = [];
    for id_in_m = 1:data_size_m
        [id_in_f,dist] = knnsearch(tree_f,moving_feature(id_in_m,:));
        [id_in_m_temp,dist2] = knnsearch(tree_m,fixed_feature(id_in_f,:));
        if id_in_m_temp == id_in_m
            index_pairs = [index_pairs;id_in_m,id_in_f,dist + dist2];
        end
    end
end