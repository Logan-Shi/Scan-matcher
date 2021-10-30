import open3d as o3d
import numpy as np
from collections import namedtuple
from global_reg import preprocess_point_cloud, execute_global_registration, refine_registration
from global_reg import execute_fast_global_registration
from visual_aids import display_inlier_outlier, draw_registration_result
def load_setup():
    setup = []
    type = 0
    setup.append(('bunny', 2, 0.1))
    setup.append(('wheel', 3, 2))
    return setup[type]

def load_point_clouds(obj,voxel_size=0.0):
    pcds = []
    pcd_fpfhs = []
    pcds_down = []
    for i in range(obj[1]):
        pcd = o3d.io.read_point_cloud("../data/"+obj[0]+"/%d.ply" %
                                      (i+1))
        if not pcd.has_normals():
            pcd.estimate_normals()
        if obj[0] == 'bunny':
            pcd.scale(50, pcd.get_center())
        # cl, ind = pcd.remove_statistical_outlier(nb_neighbors=30,
        #                                                         std_ratio=2.0)
        # display_inlier_outlier(pcd, ind)
        # pcd = cl
        pcd_down, pcd_fpfh = preprocess_point_cloud(pcd, voxel_size)
        pcds.append(pcd)
        pcds_down.append(pcd_down)
        pcd_fpfhs.append(pcd_fpfh)
    return pcds, pcds_down, pcd_fpfhs

def pairwise_registration(source, target, source_down, target_down, source_fpfh, target_fpfh):
    result_ransac = execute_global_registration(source_down, target_down,
                                            source_fpfh, target_fpfh,
                                            voxel_size)
    result_icp = refine_registration(source, target, source_fpfh, target_fpfh, result_ransac.transformation,
                                 voxel_size)
    transformation_icp = result_icp.transformation
    information_icp = o3d.pipelines.registration.get_information_matrix_from_point_clouds(
        source, target, voxel_size*0.4,
        result_icp.transformation)
    # draw_registration_result(source, target, result_icp.transformation)
    return transformation_icp, information_icp

def incre_registration(source, target, target_down, target_fpfh):
    source_down = source.voxel_down_sample(voxel_size)
    source_fpfh = o3d.pipelines.registration.compute_fpfh_feature(source_down,
                                                                  o3d.geometry.KDTreeSearchParamHybrid(radius=voxel_size*5, max_nn=100))
    result_ransac = execute_global_registration(source_down, target_down,
                                            source_fpfh, target_fpfh,
                                            voxel_size)
    result_icp = refine_registration(source, target, source_fpfh, target_fpfh, result_ransac.transformation,
                                 voxel_size)
    transformation_icp = result_icp.transformation
    information_icp = o3d.pipelines.registration.get_information_matrix_from_point_clouds(
        source, target, voxel_size*0.4,
        result_icp.transformation)
    # draw_registration_result(source, target, result_icp.transformation)
    return transformation_icp, information_icp

def full_registration(pcds, pcds_down, voxel_size):
    pose_graph = o3d.pipelines.registration.PoseGraph()
    odometry = np.identity(4)
    pose_graph.nodes.append(o3d.pipelines.registration.PoseGraphNode(odometry))
    n_pcds = len(pcds)
    for source_id in range(n_pcds):
        for target_id in range(source_id + 1, n_pcds):
            transformation_icp, information_icp = pairwise_registration(
                pcds[source_id], pcds[target_id], pcds_down[source_id],
                pcds_down[target_id], pcd_fpfhs[source_id], pcd_fpfhs[target_id])
            print("Build o3d.pipelines.registration.PoseGraph")
            if target_id == source_id + 1:  # odometry case
                odometry = np.dot(transformation_icp, odometry)
                pose_graph.nodes.append(
                    o3d.pipelines.registration.PoseGraphNode(
                        np.linalg.inv(odometry)))
                pose_graph.edges.append(
                    o3d.pipelines.registration.PoseGraphEdge(source_id,
                                                             target_id,
                                                             transformation_icp,
                                                             information_icp,
                                                             uncertain=False))
            else:  # loop closure case
                pose_graph.edges.append(
                    o3d.pipelines.registration.PoseGraphEdge(source_id,
                                                             target_id,
                                                             transformation_icp,
                                                             information_icp,
                                                             uncertain=True))
    return pose_graph

def full_incre_registration(pcds, pcds_down, voxel_size):
    pose_graph = o3d.pipelines.registration.PoseGraph()
    odometry = np.identity(4)
    pose_graph.nodes.append(o3d.pipelines.registration.PoseGraphNode(odometry))
    n_pcds = len(pcds)
    current_pcd = pcds[0]
    for target_id in range(n_pcds):
        if target_id == 1:
            pass
        source_id = target_id - 1
        transformation_icp, information_icp = incre_registration(
            current_pcd, pcds[target_id],
            pcds_down[target_id],  pcd_fpfhs[target_id])
        added_piece = pcds_down[target_id].transform(transformation_icp)
        current_pcd = current_pcd + added_piece
        print("Build o3d.pipelines.registration.PoseGraph")
        if target_id == source_id + 1:  # odometry case
            pose_graph.nodes.append(
                o3d.pipelines.registration.PoseGraphNode(
                    np.linalg.inv(transformation_icp)))
            pose_graph.edges.append(
                o3d.pipelines.registration.PoseGraphEdge(source_id,
                                                         target_id,
                                                         transformation_icp,
                                                         information_icp,
                                                         uncertain=False))
        else:  # loop closure case
            pose_graph.edges.append(
                o3d.pipelines.registration.PoseGraphEdge(source_id,
                                                         target_id,
                                                         transformation_icp,
                                                         information_icp,
                                                         uncertain=True))
    return pose_graph

setup = load_setup()
type = 0
voxel_size = setup[2]
pcds, pcds_down, pcd_fpfhs = load_point_clouds(setup, voxel_size)
print("Full registration ...")
with o3d.utility.VerbosityContextManager(
        o3d.utility.VerbosityLevel.Debug) as cm:
    pose_graph = full_incre_registration(pcds, pcds_down,
                                   voxel_size)

# print("Optimizing PoseGraph ...")
# option = o3d.pipelines.registration.GlobalOptimizationOption(
#     max_correspondence_distance=voxel_size*15,
#     edge_prune_threshold=0.25,
#     reference_node=0)
# with o3d.utility.VerbosityContextManager(
#         o3d.utility.VerbosityLevel.Debug) as cm:
#     o3d.pipelines.registration.global_optimization(
#         pose_graph,
#         o3d.pipelines.registration.GlobalOptimizationLevenbergMarquardt(),
#         o3d.pipelines.registration.GlobalOptimizationConvergenceCriteria(),
#         option)

print("Transform points and display")
for point_id in range(len(pcds)):
    print(pose_graph.nodes[point_id].pose)
    pcds[point_id].transform(pose_graph.nodes[point_id].pose)
o3d.visualization.draw_geometries(pcds,
                                  zoom=0.3412,
                                  front=[0.4257, -0.2125, -0.8795],
                                  lookat=[2.6172, 2.0475, 1.532],
                                  up=[-0.0694, -0.9768, 0.2024])

# pcds = load_point_clouds(voxel_size)
# pcd_combined = o3d.geometry.PointCloud()
# for point_id in range(len(pcds)):
#     pcds[point_id].transform(pose_graph.nodes[point_id].pose)
#     pcd_combined += pcds[point_id]
# pcd_combined_down = pcd_combined.voxel_down_sample(voxel_size=voxel_size)
# o3d.io.write_point_cloud("multiway_registration.pcd", pcd_combined_down)
# o3d.visualization.draw_geometries([pcd_combined_down],
#                                   zoom=0.3412,
#                                   front=[0.4257, -0.2125, -0.8795],
#                                   lookat=[2.6172, 2.0475, 1.532],
#                                   up=[-0.0694, -0.9768, 0.2024])