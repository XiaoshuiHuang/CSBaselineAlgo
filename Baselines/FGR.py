# examples/Python/Advanced/global_registration.py
import open3d as o3d
import numpy as np
import copy, math


def draw_registration_result(source, target, transformation,name="Result"):
    source_temp = copy.deepcopy(source)
    target_temp = copy.deepcopy(target)
    source_temp.paint_uniform_color([1, 0.706, 0])
    target_temp.paint_uniform_color([0, 0.651, 0.929])
    source_temp.transform(transformation)
    o3d.visualization.draw_geometries([source_temp, target_temp],width=1200,height=800,left=400,top=150,window_name=name)


def preprocess_point_cloud(pcd, voxel_size):
    pcd_down = pcd.voxel_down_sample(voxel_size)
    radius_normal = voxel_size * 2
    pcd_down.estimate_normals(
        o3d.geometry.KDTreeSearchParamHybrid(radius=radius_normal, max_nn=30))

    radius_feature = voxel_size * 5
    pcd_fpfh = o3d.pipelines.registration.compute_fpfh_feature(
        pcd_down,
        o3d.geometry.KDTreeSearchParamHybrid(radius=radius_feature, max_nn=100))
    return pcd_down, pcd_fpfh


def make_open3d_point_cloud(xyz, color=None):
  pcd = o3d.geometry.PointCloud()
  pcd.points = o3d.utility.Vector3dVector(xyz)
  if color is not None:
    if len(color) != len(xyz):
      color = np.tile(color, (len(xyz), 1))
    pcd.colors = o3d.utility.Vector3dVector(color)
  return pcd


def prepare_dataset(voxel_size, pcd0, pcd1):
    source = make_open3d_point_cloud(pcd0)
    target = make_open3d_point_cloud(pcd1)
    trans_init = np.asarray([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0],
                             [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]])
    source.transform(trans_init)
    # draw_registration_result(source, target, np.identity(4))

    source_down, source_fpfh = preprocess_point_cloud(source, voxel_size)
    target_down, target_fpfh = preprocess_point_cloud(target, voxel_size)
    return source, target, source_down, target_down, source_fpfh, target_fpfh


def execute_fast_global_registration(source_down, target_down, source_fpfh,
                                     target_fpfh, voxel_size):
    distance_threshold = voxel_size * 0.5
    result = o3d.pipelines.registration.registration_fast_based_on_feature_matching(
        source_down, target_down, source_fpfh, target_fpfh,
        o3d.pipelines.registration.FastGlobalRegistrationOption(
            maximum_correspondence_distance=distance_threshold))
    return result


def refine_registration(source, target, source_fpfh, target_fpfh, voxel_size,transformation):
    distance_threshold = voxel_size * 0.4
    result = o3d.pipelines.registration.registration_icp(
        source, target, distance_threshold, transformation,
        o3d.pipelines.registration.TransformationEstimationPointToPoint())
    return result


def FGR(pc0, pc1):
    voxel_size = 0.05  # means 1cm for the dataset
    source, target, source_down, target_down, source_fpfh, target_fpfh = prepare_dataset(voxel_size, pc0, pc1)

    result_ransac = execute_fast_global_registration(source_down, target_down,
                                                source_fpfh, target_fpfh,
                                                voxel_size)

    draw_registration_result(source_down, target_down, result_ransac.transformation,"FGR without ICP (press Esc to continue)")

    result_icp = refine_registration(source, target, source_fpfh, target_fpfh,
                                     voxel_size, result_ransac.transformation)

    draw_registration_result(source, target, result_icp.transformation,"FGR with ICP refinement (press Esc to continue)")

    trans = result_icp.transformation

    return trans

