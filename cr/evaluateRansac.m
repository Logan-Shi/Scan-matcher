function error = evaluateRansac(tform,moving, fixed,voxel_size)
    fixed_down = pcdownsample(fixed,'gridAverage',voxel_size);
    moving_down = pcdownsample(moving,'gridAverage',voxel_size);
    moving_tfed = pctransform(moving_down,tform);
    [~,~,error] = pcregistericp(moving_tfed,fixed_down,...
        'MaxIterations',1);
end