"""
An example to use cross-source point cloud benchmark
creator: Xiaoshui Huang
date: 2021-03-20
"""
from crosssource_loader import CrosssourceDataset
from FGR import FGR
import torch, math, time
import numpy as np

success_rte_thresh = 0.3 # translation threshold
success_rre_thresh = 15 # rotation threshold


def rte_rre(T_pred, T_gt, rte_thresh, rre_thresh, eps=1e-16):
    """
    Calculate the translation error(rte) and rotation error(rre)
    :param T_pred: predicted transformation
    :param T_gt:  ground truth transformation
    :param rte_thresh: translation threshold
    :param rre_thresh: rotation threshold
    :param eps:
    :return: True, if both rte and rre are less than thresholds, otherwise False.
    """
    if T_pred is None:
        return np.array([0, np.inf, np.inf])

    rte = np.linalg.norm(T_pred[:3, 3] - T_gt[:3, 3])
    rre = np.arccos(
        np.clip((np.trace(T_pred[:3, :3].T @ T_gt[:3, :3]) - 1) / 2, -1 + eps,
                1 - eps)) * 180 / math.pi
    print("rte=%f, rre=%f" % (rte, rre))
    return np.array([rte < rte_thresh and rre < rre_thresh, rte, rre])


def analyze_stats(stats, mask, method_names):
    """
    calculate the overall accuracy
    :param stats: an array store all the evaluation results
    :param mask:
    :param method_names:
    :return:
    """
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


def evaluate(benchmark_path):
    """
    Given the benchmark directory, this function runs to evaluate the performance of FGR.
    :param benchmark_path: directory of benchmark
    :return:
    """
    dset = CrosssourceDataset(benchmark_path)
    train_loader = torch.utils.data.DataLoader(dset, batch_size=1, shuffle=False, collate_fn=lambda x: x,
                                               pin_memory=False,
                                               drop_last=True)
    tot_num_data = len(train_loader.dataset)
    mask = np.zeros((tot_num_data, 1)).astype(int)
    stats = np.zeros((1, tot_num_data, 5))

    # iterate every sample in the data set and evaluate its accuracy
    for batch_idx, data in enumerate(train_loader):
        data = data[0]
        pcd0 = data[0]
        pcd1 = data[1]
        T_gt = data[2]

        start = time.time()
        T = FGR(pcd0, pcd1)
        end = time.time()
        stats[0, batch_idx, :3] = rte_rre(T, T_gt, success_rte_thresh,
                                          success_rre_thresh)
        stats[0, batch_idx, 3] = end - start
        stats[0, batch_idx, 4] = 1
        mask[batch_idx] = 1

    analyze_stats(stats, mask, ["FGR"])


if __name__ == '__main__':
    # data set path [change it]
    benchmark_path = "C:\\Users\\xhua5093\\Desktop\\cross-source-dataset"
    evaluate(benchmark_path)


