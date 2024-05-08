# coding=UTF-8
from common import CoordinateUtil
from common import MatrixUtil
import numpy as np
import opengm
import scipy.io as sio
import matplotlib.pyplot as matplot
from common.InfereMonitor import InfereMonitor

if __name__ == '__main__':
    data = sio.loadmat('/home/charlie/Desktop/Parallels Shared Folders/Polarizaiton_Imaging_Aid_Coarse_Depth/5_7/2_penguin9_P.mat')
    # depthmap = data['depthmap']
    cam1 = data['cam1'][0][0]
    mask1 = cam1['mask']
    phi = cam1['phi_est']
    theta_diffuse = cam1['theta_est_diffuse']
    # theta_spec = cam1['theta_est_spec']
    N_guide = data['N_guide']

    # N_guide_valid （50378，3）
    N_guide_valid = N_guide[mask1 == 1]
    matplot.imshow((N_guide+1)/2)


    # Normals for diffuse
    N_diffuse = CoordinateUtil.polar2normal(theta_diffuse, phi)
    N_diffuse2 = CoordinateUtil.polar2normal(theta_diffuse, phi + np.pi)

    T = np.array(((-1, 0, 0), (0, -1, 0), (0, 0, 1)))
    # NT和N分别是漫反射对应的两条法线    N_valid（50378，3）   N_diffuse （410，633，3）
    N_valid = N_diffuse[mask1 == 1]
    NT_valid = np.dot(N_valid, T)

    #  N_diff_solutions （50378，3，2）
    N_diff_solutions = np.stack((NT_valid, N_valid), axis=2)
    Diff_flag1 = np.ones((N_diff_solutions.shape[0], N_diff_solutions.shape[2]), np.int)


    matplot.figure()
    matplot.subplot(1, 2, 1)
    matplot.imshow((N_diffuse+1)/2)
    matplot.title('diffuse normal')

    matplot.subplot(1, 2, 2)
    matplot.imshow((N_diffuse2+1)/2)
    matplot.title('diffuse normal2')


    N_solutions = N_diff_solutions
    rows, cols = mask1.shape

    ##=================> Optimised based on opengm

    noofNodes = np.sum(mask1)
    print(noofNodes)
    nodeStates = np.ones(noofNodes, dtype=opengm.index_type) * 2  # Possible answer are N or T*N
    gm = opengm.graphicalModel(nodeStates)
    # gm = opengm.adder.GraphicalModel(np.ones(noofNodes, dtype=opengm.index_type), reserveNumFactorsPerVariable=3)
    spec_threshold = 0.99

    flip_factor = 7
    w_u = 1
    # 1. add node factor
    for i in range(noofNodes):
        nState = np.int32(nodeStates[i])
        f = np.zeros(nState, dtype=np.float32)

        Ng_i = N_guide_valid[i, :]

        if np.any(np.isnan(Ng_i)):
            for k in range(nState):  # k 0-1
                f[k] = 1.0
        else:
            for k in range(nState):
                N_i = N_solutions[i, :, k]
                prop = np.dot(Ng_i, N_i)
                f[k] = prop
        f = np.exp(-f)
        f = f / np.sum(f)
        fid = gm.addFunction(f)
        gm.addFactor(fid, i)

    # 2. add pairwise factor
    # firstly, find its neighbours
    offsetm = MatrixUtil.maskoffset(mask1)
    # w_p = 2
    #
    # pairwiseNeighbours = {}
    # for m in range(rows):
    #     for n in range(cols):
    #         if mask1[m, n]:
    #             currentNode = cols * m + n - offsetm[m, n]
    #             pairwiseNeighbours[currentNode] = []
    #             if n + 1 < cols and mask1[m, n + 1]:
    #                 neighbour = cols * m + n + 1 - offsetm[m, n + 1]
    #                 pairwiseNeighbours[currentNode].append(neighbour)
    #
    #             if m + 1 < rows and mask1[m + 1, n]:
    #                 neighbour = cols * (m + 1) + n - offsetm[m + 1, n]
    #                 pairwiseNeighbours[currentNode].append(neighbour)
    #
    #             if len(pairwiseNeighbours[currentNode]) == 0:
    #                 pairwiseNeighbours.pop(currentNode, None)
    #
    # # Build pairwise cost function
    # for i, val in pairwiseNeighbours.iteritems():
    #     myStates = np.int32(nodeStates[i])
    #     mySolution = N_solutions[i, ...]
    #     for n in val:
    #         neighbourStates = np.int32(nodeStates[n])
    #         neighbourSolution = N_solutions[n, ...]
    #         f = np.zeros((myStates, neighbourStates), dtype=np.float32)
    #         for st1 in range(myStates):
    #             N1 = mySolution[:, st1]
    #             for st2 in range(neighbourStates):
    #                 N2 = neighbourSolution[:, st2]
    #                 f[st1, st2] = np.dot(N1, N2)
    #         f = np.exp(-f)
    #         f = f / np.sum(f)
    #         fid = gm.addFunction(f * w_p)
    #         gm.addFactor(fid, (i, n))


    # 3. Build second order triclique cost function
    tricliqueNeighbours = {}
    for m in range(rows):
        for n in range(cols):
            if mask1[m, n] and \
                    n + 1 < cols and mask1[m, n + 1] and \
                    m + 1 < rows and mask1[m + 1, n]:
                currentNode = cols * m + n - offsetm[m, n]
                tricliqueNeighbours[currentNode] = []
                neighbour = cols * m + n + 1 - offsetm[m, n + 1]
                tricliqueNeighbours[currentNode].append(neighbour)
                neighbour = cols * (m + 1) + n - offsetm[m + 1, n]
                tricliqueNeighbours[currentNode].append(neighbour)

    w_tri = 0.5
    for i, neighbour in tricliqueNeighbours.iteritems():
        myStates = np.int32(nodeStates[i])
        mySolution = N_solutions[i, ...]
        n1States = np.int32(nodeStates[neighbour[0]])
        n1Solution = N_solutions[neighbour[0], ...]
        n2States = np.int32(nodeStates[neighbour[1]])
        n2Solution = N_solutions[neighbour[1], ...]
        f = np.zeros((myStates, n1States, n2States), dtype=np.float32)
        for st1 in range(myStates):
            N1 = mySolution[:, st1]
            pq1 = -N1[0:2] / N1[2]
            for st2 in range(n1States):
                N2 = n1Solution[:, st2]
                pq2 = -N2[0:2] / N2[2]
                for st3 in range(n2States):
                    N3 = n2Solution[:, st3]
                    pq3 = -N3[0:2] / N3[2]
                    px = pq1[0] - pq2[0]
                    py = pq1[0] - pq3[0]
                    qx = pq1[1] - pq2[1]
                    qy = pq1[1] - pq3[1]
                    # score = np.abs(N1[0] - N3[0] - (N1[1] - N2[1]))
                    # score = np.abs(N1[1] - N3[1] - (N1[0] - N2[0]))
                    integrability_score = np.abs(py - qx)
                    # smooth_score = px ** 2 + py ** 2 + qx ** 2 + qy ** 2
                    score = integrability_score
                    f[st1, st2, st3] = score
        # f = np.exp(f)
        # f = f / np.sum(f)
        fid = gm.addFunction(f * w_tri)
        gm.addFactor(fid, (i, neighbour[0], neighbour[1]))


    inf = opengm.inference.BeliefPropagation(gm, accumulator='minimizer',
                                             parameter=opengm.InfParam(steps=200, convergenceBound=0.0001, damping=0.5))
    #
    # inf = opengm.inference.TreeReweightedBp(gm, accumulator='minimizer',
    #                                         parameter=opengm.InfParam(steps=100, convergenceBound=0.001))



    infereMonitor = InfereMonitor(noofNodes, nState)     #  存疑？？？ nstate是最后得到的参数吗
    visitor = inf.pythonVisitor(infereMonitor, visitNth=1)
    inf.infer(visitor)

    labels = inf.arg()       # 最后得到参数是label （50381，），通过label确定法线是四种里面的哪种

    # reconstruct labels to images
    N_reconstruct = np.zeros_like(N_valid)

    maskcolormap = np.zeros((rows, cols, 3), np.uint8)
    new_dsmask = np.zeros_like(mask1)
    new_dsmask[mask1 == 1] = labels + 1            # labes是从0开始的，所以加1，就变成1，2，3，4

    # 分别给每个像素点的法线根据第几种可能上色
    maskcolormap[new_dsmask == 1] = (50, 50, 100)
    maskcolormap[new_dsmask == 2] = (200, 70, 190)
    # maskcolormap[new_dsmask == 3] = (200, 70, 190)
    # maskcolormap[new_dsmask == 4] = (200, 70, 190)
    # maskcolormap[new_dsmask == 5] = (200, 70, 190)
    # maskcolormap[new_dsmask == 6] = (200, 70, 190)
    # new_specmask[new_dsmask == 3] = 1
    # new_specmask[new_dsmask == 4] = 1
    # new_specmask[new_dsmask == 5] = 1
    # new_specmask[new_dsmask == 6] = 1

    # 给每个像素点法线赋值
    for i in range(noofNodes):
        sel = labels[i]
        N_reconstruct[i, :] = N_solutions[i, :, sel]

    N_reco_full = np.zeros((rows, cols, 3), np.float32)

    N_reco_full[mask1 == 1] = N_reconstruct

    matplot.figure()
    matplot.subplot(1, 3, 1)
    matplot.imshow((N_diffuse + 1) / 2)
    matplot.title('Original normal')

    matplot.subplot(1, 3, 2)
    matplot.imshow((N_reco_full + 1) / 2)
    matplot.title('corrected normal')

    matplot.subplot(1, 3, 3)
    matplot.imshow(maskcolormap)
    matplot.title('new_mask color')
    matplot.show()

    sio.savemat('/home/charlie/Desktop/Parallels Shared Folders/Polarizaiton_Imaging_Aid_Coarse_Depth/5_7/3_penguin9_PD.mat', {'normal1': N_reco_full,
                                                              'mask': mask1, 'N_guide': N_guide})
