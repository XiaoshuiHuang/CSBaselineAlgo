"""
Data loader of cross-source point cloud benchmark
creator: Xiaoshui Huang
date: 2021-03-20
"""
import torch
import open3d
import os
from scipy.linalg import expm, norm
import numpy as np
from glob import glob

class CrosssourceDataset(torch.utils.data.Dataset):
    """
    Data loader class to read cross-source point clouds
    """
    def __init__(self, data_path):
        """ initialize the dataloader. get all file names"""
        self.names = self.find_pairs(data_path)
        self.randg = np.random.RandomState()
        self.rotation_range = 180  # rotation

    def __getitem__(self, item):
        """ get data item """
        pair_path = self.names[item]
        # read point cloud data
        if "kinect_sfm" in pair_path:
            kinect_path = os.path.join(self.names[item], "kinect.ply")
            pc_kinect = open3d.io.read_point_cloud(kinect_path)
            sfm_path = os.path.join(self.names[item], "sfm.ply")
            pc_sfm = open3d.io.read_point_cloud(sfm_path)

            xyz0 = np.array(pc_kinect.points)
            xyz1 = np.array(pc_sfm.points)

            # scaled the point clouds to [-1 1]
            centroid = np.mean(xyz0, axis=0)
            xyz0 -= centroid
            furthest_distance = np.max(np.sqrt(np.sum(abs(xyz0) ** 2, axis=-1)))
            xyz0 /= furthest_distance

            centroid = np.mean(xyz1, axis=0)
            xyz1 -= centroid
            furthest_distance = np.max(np.sqrt(np.sum(abs(xyz1) ** 2, axis=-1)))
            xyz1 /= furthest_distance

        elif "kinect_lidar" in pair_path:
            kinect_path = os.path.join(self.names[item], "kinect.ply")
            pc_kinect = open3d.io.read_point_cloud(kinect_path)
            sfm_path = os.path.join(self.names[item], "lidar.ply")
            pc_sfm = open3d.io.read_point_cloud(sfm_path)

            xyz0 = np.array(pc_kinect.points)
            xyz1 = np.array(pc_sfm.points)

            # scaled the point clouds to [-1 1]
            centroid = np.mean(xyz0, axis=0)
            xyz0 -= centroid
            furthest_distance = np.max(np.sqrt(np.sum(abs(xyz0) ** 2, axis=-1)))
            xyz0 /= furthest_distance

            centroid = np.mean(xyz1, axis=0)
            xyz1 -= centroid
            furthest_distance = np.max(np.sqrt(np.sum(abs(xyz1) ** 2, axis=-1)))
            xyz1 /= furthest_distance
        # read ground truth transformation
        T_gt = np.loadtxt(os.path.join(self.names[item], "T_gt.txt"))

        return xyz0, xyz1, T_gt

    def __len__(self):
        """
        calculate sample number of the dataset
        :return:
        """
        num = len(self.names)
        return num

    def find_pairs(self, path):
        """
        # find all the ply filenames in the given path
        :param path: given data set directory
        :return:
        """
        easy_root = os.path.join(path, "kinect_sfm/easy/*/")
        subfolders_easy = glob(easy_root)
        hard_root = os.path.join(path, "kinect_sfm/hard/*/")
        subfolders_hard = glob(hard_root)
        kinect_lidar_root = os.path.join(path, "kinect_lidar/*/*/")
        subfolders_kinect_lidar = glob(kinect_lidar_root)
        subfolders = subfolders_easy + subfolders_hard + subfolders_kinect_lidar
        return subfolders


    def apply_transform(self, pts, trans):
        """
        # apply transformation to a point cloud
        :param pts: N x 3
        :param trans: 4 x 4
        :return: N X 3
        """
        R = trans[:3, :3]
        T = trans[:3, 3]
        pts = pts @ R.T + T
        return pts

    def M(self, axis, theta):
        """
        # Genearte rotation matrix along axis with angle theta
        :param axis: axis number [0, 1, 2] means [x, y, z]
        :param theta: rotation angle [-3.14, 3.14]
        :return: rotation matrix [3 x 3]
        """
        return expm(np.cross(np.eye(3), axis / norm(axis) * theta))

    def sample_random_trans(self, pcd, randg, rotation_range=360):
        """
        # generate a trasnformation matrix with Random rotation
        :param pcd: input point cloud, numpy
        :param randg: random method
        :param rotation_range: random rotation angle [-180, 180]
        :return: a transformation matrix [4 x 4]
        """
        T = np.eye(4)
        R = self.M(randg.rand(3) - 0.5, rotation_range * np.pi / 180.0 * (randg.rand(1) - 0.5))
        T[:3, :3] = R
        T[:3, 3] = R.dot(-np.mean(pcd, axis=0))
        return T
