#!/usr/bin/env python3
import open3d as o3d
import numpy as np
import time
import os
import sys
from global_reg import preprocess_point_cloud, execute_global_registration, refine_registration, draw_registration_result

def prepare_dataset(voxel_size):
    print(":: Load two point clouds and disturb initial pose.")
    # source = o3d.io.read_point_cloud("../data/scans/cloud_bin_0.pcd")
    # target = o3d.io.read_point_cloud("../data/scans/cloud_bin_1.pcd")
    source = o3d.io.read_point_cloud("../data/wheel/1.ply")
    target = o3d.io.read_point_cloud("../data/wheel/2.ply")
    trans_init = np.asarray([[0.0, 0.0, 1.0, 0.0], [1.0, 0.0, 0.0, 0.0],
                             [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0]])
    source.transform(trans_init)
    if not source.has_normals():
        source.estimate_normals()
    if not target.has_normals():
        target.estimate_normals()
    draw_registration_result(source, target, np.identity(4))

    source_down, source_fpfh = preprocess_point_cloud(source, voxel_size)
    target_down, target_fpfh = preprocess_point_cloud(target, voxel_size)
    return source, target, source_down, target_down, source_fpfh, target_fpfh

voxel_size = 0.5
source, target, source_down, target_down, source_fpfh, target_fpfh = prepare_dataset(
    voxel_size)
start = time.time()
result_ransac = execute_global_registration(source_down, target_down,
                                            source_fpfh, target_fpfh,
                                            voxel_size)
print("Global registration took %.3f sec.\n" % (time.time() - start))
print(result_ransac)
draw_registration_result(source_down, target_down, result_ransac.transformation)

result_icp = refine_registration(source, target, source_fpfh, target_fpfh, result_ransac.transformation,
                                 voxel_size)
print(result_icp)
draw_registration_result(source, target, result_icp.transformation)