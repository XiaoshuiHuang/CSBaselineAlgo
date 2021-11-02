import torch
import numpy as np
import open3d
import os
from scipy.linalg import expm, norm


from glob import glob


# Rotation matrix along axis with angle theta
def M(axis, theta):
    return expm(np.cross(np.eye(3), axis / norm(axis) * theta))

def sample_random_trans(pcd, randg, rotation_range=360):
  T = np.eye(4)
  R = M(randg.rand(3) - 0.5, rotation_range * np.pi / 180.0 * (randg.rand(1) - 0.5))
  T[:3, :3] = R
  T[:3, 3] = R.dot(-np.mean(pcd, axis=0))
  return T

class CrosssourceDataset(torch.utils.data.Dataset):
    def __init__(self, data_path):
        self.names = self.find_pairs(data_path)
        self.randg = np.random.RandomState()
        self.rotation_range = 180 #rotation

    def __getitem__(self, item):
        pair_path = self.names[item]
        if "kinect_sfm" in pair_path:
            kinect_path = os.path.join(self.names[item],"kinect.ply")
            pc_kinect = open3d.io.read_point_cloud(kinect_path)
            sfm_path = os.path.join(self.names[item],"sfm.ply")
            pc_sfm = open3d.io.read_point_cloud(sfm_path)

            xyz0 = np.array(pc_kinect.points)
            xyz1 = np.array(pc_sfm.points)
            min0 = np.min(xyz0, axis=1)
            max0 = np.max(xyz0, axis=1)
            dist0 = np.linalg.norm(max0 - min0)
            min1 = np.min(xyz1, axis=1)
            max1 = np.max(xyz1, axis=1)
            dist1 = np.linalg.norm(max1 - min1)
            dist = np.maximum(dist0, dist1)
            xyz0 = xyz0 / dist * 300
            xyz1 = xyz1 / dist * 300

        elif "kinect_lidar" in pair_path:
            kinect_path = os.path.join(self.names[item], "kinect.ply")
            pc_kinect = open3d.io.read_point_cloud(kinect_path)
            lidar_path = os.path.join(self.names[item], "lidar.ply")
            pc_sfm = open3d.io.read_point_cloud(lidar_path)
            print(kinect_path)
            print(lidar_path)

            xyz0 = np.array(pc_kinect.points)
            xyz1 = np.array(pc_sfm.points)
            min0 = np.min(xyz0,axis=1)
            max0 = np.max(xyz0,axis=1)
            dist0 = np.linalg.norm(max0 - min0)
            min1 = np.min(xyz1,axis=1)
            max1 = np.max(xyz1,axis=1)
            dist1 = np.linalg.norm(max1 - min1)
            dist = np.maximum(dist0, dist1)
            xyz0 = xyz0/dist*500
            xyz1 = xyz1/dist*500
        T0_path = os.path.join(self.names[item], "T0.txt")
        T1_path = os.path.join(self.names[item], "T1.txt")
        if os.path.isfile(T0_path) and os.path.isfile(T1_path):
            T0 = np.loadtxt(T0_path)
            T1 = np.loadtxt(T1_path)
        else:
            T0 = sample_random_trans(xyz0, self.randg, self.rotation_range)
            T1 = sample_random_trans(xyz1, self.randg, self.rotation_range)
            np.savetxt(T0_path, T0)
            np.savetxt(T1_path, T1)
        trans = T1 @ np.linalg.inv(T0)

        pc0 = self.apply_transform(xyz0, T0)
        pc1 = self.apply_transform(xyz1, T1)
        Tgt = trans

        return pc0, pc1, Tgt

    def __len__(self):
        num = len(self.names)
        return num

    def find_pairs(self, path):
        easy_root = os.path.join(path, "kinect_sfm/easy/*/")
        subfolders_easy = glob(easy_root)
        hard_root = os.path.join(path, "kinect_sfm/hard/*/")
        subfolders_hard = glob(hard_root)
        kinect_lidar_root = os.path.join(path, "kinect_lidar/*/*/")
        subfolders_kinect_lidar = glob(kinect_lidar_root)
        subfolders = subfolders_easy + subfolders_hard + subfolders_kinect_lidar
        return subfolders

    def apply_transform(self, pts, trans):
        R = trans[:3, :3]
        T = trans[:3, 3]
        pts = pts @ R.T + T
        return pts

