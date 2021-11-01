function index_pairs = findCorrespondenceFromFeature(moving_feature, fixed_feature, difference_threshold)
    tree = KDTreeSearcher(fixed_feature);
    data_size_m = size(moving_feature,1);
    index_pairs = [];
    for id_in_m = 1:data_size_m
        [idc,dist] = knnsearch(tree,moving_feature(id_in_m,:));
        if dist < difference_threshold
            index_pairs = [index_pairs;id_in_m,idc,dist];
        end
    end
    
    tree_m = KDTreeSearcher(moving_feature);
    index_pairs_size = size(index_pairs,1);
    index_pairs_m = [];
    for id_in_pair = 1:index_pairs_size
        id_in_fixed = index_pairs(id_in_pair,2);
        [idc,dist2] = knnsearch(tree_m,fixed_feature(id_in_fixed,:));
        if idc == index_pairs(id_in_pair,1)
            index_pairs_m = [index_pairs_m;idc,id_in_pair,dist2];
        end
    end
    index_pairs = index_pairs_m;
end