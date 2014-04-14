'''
Simple example of stereo image matching and point cloud generation.

Resulting .ply file cam be easily viewed using MeshLab ( http://meshlab.sourceforge.net/ )
'''

import numpy as np
import cv2
import matplotlib as plt

ply_header = '''ply
format ascii 1.0
element vertex %(vert_num)d
property float x
property float y
property float z
property uchar red
property uchar green
property uchar blue
end_header
'''

def write_ply(fn, verts, colors):
    verts = verts.reshape(-1, 3)
    colors = colors.reshape(-1, 3)
    verts = np.hstack([verts, colors])
    with open(fn, 'w') as f:
        f.write(ply_header % dict(vert_num=len(verts)))
        np.savetxt(f, verts, '%f %f %f %d %d %d')


if __name__ == '__main__':
    print 'loading images...'
    #imgL = cv2.pyrDown( cv2.imread('../opencv-2.4.8/samples/cpp/samp1.jpeg') )  # downscale images for faster processing
    #imgR = cv2.pyrDown( cv2.imread('../opencv-2.4.8/samples/cpp/samp2.jpeg') )

    imgL = cv2.pyrDown( cv2.imread('goodl.jpeg') )  # downscale images for faster processing
    imgR = cv2.pyrDown( cv2.imread('goodr.jpeg') )

    # disparity range is tuned for 'aloe' image pair
    window_size = 5
    min_disp = 0
    num_disp = 64
    stereo = cv2.StereoSGBM(minDisparity = min_disp,
        numDisparities = num_disp,
        SADWindowSize = window_size,
        uniquenessRatio = 10,
        speckleWindowSize = 0,
        speckleRange = 2,
        disp12MaxDiff = 1,
        P1 = 8*3*window_size**2,
        P2 = 32*3*window_size**2,
        fullDP = True
    )
    
    #reenable speckle, change window size, and tinker with disparity

    print 'computing disparity...'
    disp = stereo.compute(imgL, imgR).astype(np.float32) / 16.0

    print 'generating 3d point cloud...',
    h, w = imgL.shape[:2]

    #Q is the disparity to depth mapping
    Q = np.float32([[1, 0, 0, -1008.174053192139],
    [0, 1, 0, -469.5005378723145],
    [0, 0, 0, 2061.201143658453],
    [0, 0, 1.683177465418866, -0]])
    
    points = cv2.reprojectImageTo3D(disp, Q)
    colors = cv2.cvtColor(imgL, cv2.COLOR_BGR2RGB)
    

    mask = disp > disp.min()
    #a = points[:,:, 2]
    #mask = np.where(a < 0)
    out_points = points[mask]
    out_colors = colors[mask]
    out_fn = 'out.ply'
    write_ply('out.ply', out_points, out_colors)
    print '%s saved' % 'out.ply'
#filter out stuff but before copy good images
    cv2.imshow('left', imgL)
    cv2.imshow('disparity', (disp-min_disp)/num_disp)
    cv2.waitKey()
    cv2.destroyAllWindows()
