#!/usr/bin/env python

'''
Performs OpenCV's StereoSGBM stereo matching. Usage py_stereo.py LeftImg RightImg
'''

import numpy as np
import cv2
import matplotlib as plt
import sys


def showLeftImage():
    print 'showing left image...'
    cv2.imshow('left', imgL)
    
def showDisparityImage():
    print 'showing disparity...'
    cv2.imshow('disparity', (disp-min_disp)/num_disp)

def loadImages(left_file, right_file):
    global imgL, imgR
    print 'loading images...'
    imgL = cv2.pyrDown( cv2.imread(left_file) )  # downscale images for faster processing
    imgR = cv2.pyrDown( cv2.imread(right_file) )

def doStereo():
    print 'doing stereo...'
    """
    Parameters tuned for q50 car images.

    Parameters:
    minDisparity - Minimum possible disparity value. Normally, it is zero but sometimes rectification algorithms can shift images, so this parameter needs to be adjusted accordingly.
    numDisparities - Maximum disparity minus minimum disparity. The value is always greater than zero. In the current implementation, this parameter must be divisible by 16.
    SADWindowSize - Matched block size. It must be an odd number >=1. Normally, it should be somewhere in the 3..11 range.
    P1 - The first parameter controlling the disparity smoothness. See below.
    P2 - The second parameter controlling the disparity smoothness. The larger the values are, the smoother the disparity is. P1 is the penalty on the disparity change by plus or minus 1 between neighbor pixels. P2 is the penalty on the disparity change by more than 1 between neighbor pixels. The algorithm requires P2 > P1. See stereo_match.cpp sample where some reasonably good P1 and P2 values are shown (like 8*number_of_image_channels*SADWindowSize*SADWindowSize and 32*number_of_image_channels*SADWindowSize*SADWindowSize, respectively).
    disp12MaxDiff - Maximum allowed difference (in integer pixel units) in the left-right disparity check. Set it to a non-positive value to disable the check.
    preFilterCap - Truncation value for the prefiltered image pixels. The algorithm first computes x-derivative at each pixel and clips its value by [-preFilterCap, preFilterCap] interval. The result values are passed to the Birchfield-Tomasi pixel cost function.
    uniquenessRatio - Margin in percentage by which the best (minimum) computed cost function value should "win" the second best value to consider the found match correct. Normally, a value within the 5-15 range is good enough.
    speckleWindowSize - Maximum size of smooth disparity regions to consider their noise speckles and invalidate. Set it to 0 to disable speckle filtering. Otherwise, set it somewhere in the 50-200 range.
    speckleRange - Maximum disparity variation within each connected component. If you do speckle filtering, set the parameter to a positive value, it will be implicitly multiplied by 16. Normally, 1 or 2 is good enough.
    fullDP - Set it to true to run the full-scale two-pass dynamic programming algorithm. It will consume O(W*H*numDisparities) bytes, which is large for 640x480 stereo and huge for HD-size pictures. By default, it is set to false.
    """
    global disp, min_disp, num_disp;

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

    disp = stereo.compute(imgL, imgR).astype(np.float32) / 16.0

"""
If necessary, the image can be reprojected to 3d to apply filters etc.

"""
def get3dPoints():
    """
    Q is the disparity to depth mapping calibrated with open CV code and Sameep's parameters
    """

    Q = np.float32([[1, 0, 0, -1008.174053192139],
    [0, 1, 0, -469.5005378723145],
    [0, 0, 0, 2061.201143658453],
    [0, 0, 1.683177465418866, -0]])
    
    points = cv2.reprojectImageTo3D(disp, Q)
    colors = cv2.cvtColor(imgL, cv2.COLOR_BGR2RGB)

    #possible to do other filters such as removing objects beyond certain distance, height filters etc
    mask = disp > disp.min()
    
    #applying mask to points and colors
    out_points = points[mask]
    out_colors = colors[mask]
    return (out_points, out_colors)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise Exception("Usage py_stereo.py LeftImgFile RightImgFile")
    
    loadImages(sys.argv[1], sys.argv[2]);
    doStereo()
    #get3dPoints() #if necessary for other modules
    showLeftImage()
    showDisparityImage()
    cv2.waitKey()     #press q on keyboard to close
    cv2.destroyAllWindows()
