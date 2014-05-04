/**
Unfinished code on stereo recitification. TODO: complete
**/


#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <vector>
#include <string>
#include <algorithm>
#include <iostream>
#include <iterator>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

using namespace cv;
using namespace std;

static bool readStringList( const string& filename, vector<string>& l )
{
    l.resize(0);
    FileStorage fs(filename, FileStorage::READ);
    if( !fs.isOpened() )
        return false;
    FileNode n = fs.getFirstTopLevelNode();
    if( n.type() != FileNode::SEQ )
        return false;
    FileNodeIterator it = n.begin(), it_end = n.end();
    for( ; it != it_end; ++it )
        l.push_back((string)*it);
    return true;
}


int main(int argc, char** argv)
{
	vector<string> imagelist;
	string imagelistfn = "stereo_calib.xml";
    bool ok = readStringList(imagelistfn, imagelist);

	Size imageSize(1280, 960);
    Mat R1, R2, P1, P2, Q;
    Mat cameraMatrix[2], distCoeffs[2];
    cameraMatrix[0] = Mat::eye(3, 3, CV_64F);
    cameraMatrix[1] = Mat::eye(3, 3, CV_64F);
    Rect validRoi[2];
    cameraMatrix[0] = (Mat_<double>(3,3) << 2254.7629881361104, 0.0, 655.5568389543264, 0.0, 2266.3053663916653, 488.8502207665989, 0.0, 0.0, 1.0);
    cameraMatrix[1] = (Mat_<double>(3,3) << 2250.7203235684196, 0.0, 648.9587583746263, 0.0, 2263.7523809342106, 450.2497022795749, 0.0, 0.0, 1.0);
   	distCoeffs[0] = (Mat_<double>(5,1) << -0.22146000368016028, 0.7987879799679538, -6.542034918087567e-05, 2.8680581938024014e-05, 0.0);
	distCoeffs[1] = (Mat_<double>(5,1) << -0.16879238412882028, 0.11971166628565273, -0.0017457365846050555, 0.0001853749033525837, 0.0);
	Mat T  = (Mat_<double>(3,1) << -0.5873763710461054, 0.00012196510170337307, 0.08922401781210791);
 	Mat R  = (Mat_<double>(3,3) << 0.9999355343485463, -0.00932576944123699, 0.006477435558612815, 0.009223923954826548, 0.9998360945238545, 0.015578938158992275, -0.006621659456863392, -0.01551818647957998, 0.9998576596268203);

    stereoRectify(cameraMatrix[0], distCoeffs[0],
                  cameraMatrix[1], distCoeffs[1],
                  imageSize, R, T, R1, R2, P1, P2, Q,
                  CALIB_ZERO_DISPARITY, 1, imageSize, &validRoi[0], &validRoi[1]);

    cout << Q << endl;

    Mat rmap[2][2];
    initUndistortRectifyMap(cameraMatrix[0], distCoeffs[0], R1, P1, imageSize, CV_16SC2, rmap[0][0], rmap[0][1]);
    initUndistortRectifyMap(cameraMatrix[1], distCoeffs[1], R2, P2, imageSize, CV_16SC2, rmap[1][0], rmap[1][1]);

	Mat canvas;
    double sf;
    int w, h;
    sf = 600./MAX(imageSize.width, imageSize.height);
    w = cvRound(imageSize.width*sf);
    h = cvRound(imageSize.height*sf);
    canvas.create(h, w*2, CV_8UC3);

    for( k = 0; k < 2; k++ )
        {
            Mat img = imread(imageList[i*2+k], 0), rimg, cimg;
            remap(img, rimg, rmap[k][0], rmap[k][1], CV_INTER_LINEAR);
            cvtColor(rimg, cimg, COLOR_GRAY2BGR);
            Mat canvasPart = !isVerticalStereo ? canvas(Rect(w*k, 0, w, h)) : canvas(Rect(0, h*k, w, h));
            resize(cimg, canvasPart, canvasPart.size(), 0, 0, CV_INTER_AREA);
            if( useCalibrated )
            {
                Rect vroi(cvRound(validRoi[k].x*sf), cvRound(validRoi[k].y*sf),
                          cvRound(validRoi[k].width*sf), cvRound(validRoi[k].height*sf));
                rectangle(canvasPart, vroi, Scalar(0,0,255), 3, 8);
            }
        }

       for( j = 0; j < canvas.rows; j += 16 )
       	line(canvas, Point(0, j), Point(canvas.cols, j), Scalar(0, 255, 0), 1, 8);
        imshow("rectified", canvas);
        char c = (char)waitKey();
        if( c == 27 || c == 'q' || c == 'Q' )
            break;
    
}


