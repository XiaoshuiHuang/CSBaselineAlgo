# Copyright (c) Chris Choy (chrischoy@ai.stanford.edu) and Wei Dong (weidong@andrew.cmu.edu)
#
# Please cite the following papers if you use any part of the code.
# - Christopher Choy, Wei Dong, Vladlen Koltun, Deep Global Registration, CVPR 2020
# - Christopher Choy, Jaesik Park, Vladlen Koltun, Fully Convolutional Geometric Features, ICCV 2019
# - Christopher Choy, JunYoung Gwak, Silvio Savarese, 4D Spatio-Temporal ConvNets: Minkowski Convolutional Neural Networks, CVPR 2019
# Run with python -m scripts.test_3dmatch_refactor
import os
import sys
import math
import logging
import open3d as o3d
import numpy as np
import time
import torch
import copy
from dataloader.transforms import *

#os.environ["CUDA_VISIBLE_DEVICES"] = "1"
sys.path.append('.')
import MinkowskiEngine as ME
from config import get_config
from model import load_model

from dataloader.crosssource_loader import CrosssourceDataset
from core.knn import find_knn_gpu
from core.deep_global_registration import DeepGlobalRegistration

from util.timer import Timer
from util.pointcloud import make_open3d_point_cloud

o3d.utility.set_verbosity_level(o3d.utility.VerbosityLevel.Warning)
ch = logging.StreamHandler(sys.stdout)
logging.getLogger().setLevel(logging.INFO)
logging.basicConfig(format='%(asctime)s %(message)s',
                    datefmt='%m/%d %H:%M:%S',
                    handlers=[ch])


# Criteria
def rte_rre(T_pred, T_gt, rte_thresh, rre_thresh, eps=1e-16):
    if T_pred is None:
        return np.array([0, np.inf, np.inf])

    rte = np.linalg.norm(T_pred[:3, 3] - T_gt[:3, 3])
    rre = np.arccos(
        np.clip((np.trace(T_pred[:3, :3].T @ T_gt[:3, :3]) - 1) / 2, -1 + eps,
                1 - eps)) * 180 / math.pi
    print("rte=%f, rre=%f" % (rte, rre))
    return np.array([rte < rte_thresh and rre < rre_thresh, rte, rre])


def analyze_stats(stats, mask, method_names):
    mask = (mask > 0).squeeze(1)
    stats = stats[:, mask, :]

    print('Total result mean')
    for i, method_name in enumerate(method_names):
        print(method_name)
        print(stats[i].mean(0))

    print('Total successful result mean')
    for i, method_name in enumerate(method_names):
        sel = stats[i][:, 0] > 0
        sel_stats = stats[i][sel]
        print(method_name)
        print(sel_stats.mean(0))


def analyze_stats_different_overlap(group_stats, mask):
    mask = (mask > 0).squeeze(1)
    group_stats = group_stats[:, mask, :]

    print('Total different overlap mean')
    result = np.zeros(5)
    for i in range(10):
        accuracy = np.zeros(5)
        error_t = np.zeros(5)
        sel = group_stats[i][:, 0] >= 0
        sel_stats = group_stats[i][sel]
        sel_1 = group_stats[i][:, 0] > 0
        sel_stats_1 = group_stats[i][sel_1]
        accuracy = sel_stats.mean(0)
        error_t = sel_stats_1.mean(0)
        result[0] = accuracy[0]
        result[1:] = error_t[1:]
        print(result)


def create_pcd(xyz, color):
    # n x 3
    n = xyz.shape[0]
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(xyz)
    pcd.colors = o3d.utility.Vector3dVector(np.tile(color, (n, 1)))
    pcd.estimate_normals(
        search_param=o3d.geometry.KDTreeSearchParamHybrid(radius=0.1, max_nn=30))
    return pcd


def draw_geometries_flip(pcds):
    pcds_transform = []
    flip_transform = [[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, -1, 0], [0, 0, 0, 1]]
    for pcd in pcds:
        pcd_temp = copy.deepcopy(pcd)
        pcd_temp.transform(flip_transform)
        pcds_transform.append(pcd_temp)
    o3d.visualization.draw_geometries(pcds_transform)


def apply_transform(pts, trans):
    R = trans[:3, :3]
    T = trans[:3, 3]
    pts = pts @ R.T + T
    return pts


def evaluate(methods, method_names, data_loader, config, debug=False):
    tot_num_data = len(data_loader.dataset)
    data_loader_iter = iter(data_loader)

    # Accumulate success, rre, rte, time, sid
    mask = np.zeros((tot_num_data, 1)).astype(int)
    stats = np.zeros((len(methods), tot_num_data, 5))
    group_stats = -np.ones((10, tot_num_data, 5))

    dataset = data_loader.dataset

    for batch_idx in range(tot_num_data):
        batch = data_loader_iter.next()

        # Skip too sparse point clouds
        xyz0, xyz1, trans = batch[0]


        sid = 1  # cross-source
        T_gt = (trans)

        for i, method in enumerate(methods):
            start = time.time()
            T = method.register(xyz0, xyz1)

            aa = np.isnan(T).any()
            if aa:
                T = np.identity(4)

            end = time.time()
            group_idx = int(0)

            stats[i, batch_idx, :3] = rte_rre(T, T_gt, config.success_rte_thresh,
                                              config.success_rre_thresh)
            stats[i, batch_idx, 3] = end - start
            stats[i, batch_idx, 4] = sid
            group_stats[group_idx, batch_idx, :] = stats[i, batch_idx, :]
            mask[batch_idx] = 1

            if stats[i, batch_idx, 0] == 0:
                print(f"{method_names[i]}: failed")

            # Visualize
            if debug and stats[i, batch_idx, 0] == 0 and 0:
                print(method_names[i])
                pcd0 = create_pcd(xyz0, np.array([1, 0.706, 0]))
                pcd1 = create_pcd(xyz1, np.array([0, 0.651, 0.929]))
                #draw_geometries_flip([pcd0, pcd1])

                o3d.io.write_point_cloud("./fragment0.ply", pcd0)
                o3d.io.write_point_cloud("./fragment1.ply", pcd1)
                pcd0.transform(T)
                o3d.io.write_point_cloud("./fragment0_T.ply", pcd0)
                draw_geometries_flip([pcd0, pcd1])
                pcd0.transform(np.linalg.inv(T))

        if batch_idx % 10 == 9:
            print('Summary {} / {}'.format(batch_idx, tot_num_data))
            analyze_stats(stats, mask, method_names)
            analyze_stats_different_overlap(group_stats, mask)

    # Save results
    filename = f'3dmatch-stats_{method.__class__.__name__}'
    if os.path.isdir(config.out_dir):
        out_file = os.path.join(config.out_dir, filename)
    else:
        out_file = filename  # save it on the current directory
    print(f'Saving the stats to {out_file}')
    np.savez("./result.txt", stats=stats, names=method_names)
    analyze_stats(stats, mask, method_names)



if __name__ == '__main__':
    config = get_config()
    print(config)

    dgr = DeepGlobalRegistration(config)

    methods = [dgr]
    method_names = ['ATOO']

    path = "/data/xiaoshua/will/cross-source-dataset/"

    dset = CrosssourceDataset(path)
    data_loader = torch.utils.data.DataLoader(dset, batch_size=1, shuffle=False,collate_fn=lambda x: x,
                                              pin_memory=False,
                                              drop_last=True)

    evaluate(methods, method_names, data_loader, config, debug=True)
