//
// Created by Saylee Bhide on 3/2/18.

// I have described the documentation in detail in the PDF. The implementation is taken from
// https://docs.opencv.org/3.1.0/d2/dbd/tutorial_distance_transform.html
//



#include <iostream>
#include <opencv2/opencv.hpp>

#include "HW02_Bhide_Saylee_B.h"

using namespace cv;

using namespace std;

int HW02_Bhide_Saylee_B::watershedAlgorithm2() {

    // Load the image
    Mat src = imread("/Users/sayleebhide/CLionProjects/ACV_HW2/IMG_7779_shrunk_2ovr.jpg");

    // Check if everything was fine
    if (!src.data)
        return -1;

    // Show source image
    imshow("Source Image", src);
    //! [load_image]


    // Change the background from white to black, since that will help later to extract
    // better results during the use of Distance Transform
    for( int x = 0; x < src.rows; x++ ) {
        for( int y = 0; y < src.cols; y++ ) {
            if ( src.at<Vec3b>(x, y)[0] == 255 && src.at<Vec3b>(x, y)[1] == 255 && src.at<Vec3b>(x, y)[2] == 255 ) {
                src.at<Vec3b>(x, y)[0] = 0;
                src.at<Vec3b>(x, y)[1] = 0;
                src.at<Vec3b>(x, y)[2] = 0;
            }
        }
    }

    // Show output image
    imshow("Black Background Image", src);



    // Create a kernel that we will use for accuting/sharpening our image
    /*Mat kernel = (Mat_<float>(3,3) <<
                                   1,  1, 1,
            1, -8, 1,
            1,  1, 1); // an approximation of second derivative, a quite strong kernel*/


    //Creation of kernel
    Mat kernel(3,3,CV_32F);

    kernel.at<float>(0,0) = 1;
    kernel.at<float>(0,1) = 1;
    kernel.at<float>(0,2) = 1;

    kernel.at<float>(1,0) = 1;
    kernel.at<float>(1,1) = -8;
    kernel.at<float>(1,2) = 1;

    kernel.at<float>(2,0) = 1;
    kernel.at<float>(2,1) = 1;
    kernel.at<float>(2,2) = 1;


    // we need to convert everything in something more deeper then CV_8U
    // because the kernel has some negative values,
    // and we can expect in general to have a Laplacian image with negative values
    // BUT a 8bits unsigned int (the one we are working with) can contain values from 0 to 255
    // so the possible negative number will be truncated

    Mat imgLaplacian;

    // copy source image to another temporary one
    Mat sharp = src;

    // do the laplacian filtering as it is
    filter2D(sharp, imgLaplacian, CV_32F, kernel);
    src.convertTo(sharp, CV_32F);

    //sharp image
    Mat imgResult = sharp - imgLaplacian;

    // convert back to 8bits gray scale
    imgResult.convertTo(imgResult, CV_8UC3);
    imgLaplacian.convertTo(imgLaplacian, CV_8UC3);

    // imshow( "Laplace Filtered Image", imgLaplacian );
    imshow( "New Sharped Image", imgResult );

    // copy back
    src = imgResult;

    // Create binary image from source image
    Mat bw;

    //Convert the color space of the source image to grayscale image
    cvtColor(src, bw, COLOR_BGR2GRAY);

    //Perform Otsu's binarization
    threshold(bw, bw, 40, 255, THRESH_BINARY | THRESH_OTSU);

    //display the binarized image
    imshow("Binary Image", bw);


    // Perform the distance transform algorithm
    Mat dist;
    distanceTransform(bw, dist, DIST_L2, 3);

    // Normalize the distance image for range = {0.0, 1.0}
    // so we can visualize and threshold it
    normalize(dist, dist, 0, 1., NORM_MINMAX);
    imshow("Distance Transform Image", dist);


    // Threshold to obtain the peaks
    // This will be the markers for the foreground objects
    threshold(dist, dist, .4, 1., THRESH_BINARY);

    // Dilate a bit the dist image. This increases the object boundary to background
    Mat kernel1 = Mat::ones(3, 3, CV_8UC1);
    dilate(dist, dist, kernel1);
    imshow("Peaks", dist);


    // Create the CV_8U version of the distance image
    // It is needed for findContours()
    Mat dist_8u;
    dist.convertTo(dist_8u, CV_8U);

    // Find total markers
    vector<vector<Point> > contours;
    findContours(dist_8u, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

    // Create the marker image for the watershed algorithm
    Mat markers = Mat::zeros(dist.size(), CV_32SC1);

    // Draw the foreground markers
    for (size_t i = 0; i < contours.size(); i++)
        drawContours(markers, contours, static_cast<int>(i), Scalar::all(static_cast<int>(i)+1), -1);

    // Draw the background marker
    circle(markers, Point(5,5), 3, CV_RGB(255,255,255), -1);
    imshow("Markers", markers*10000);


    // Perform the watershed algorithm
    watershed(src, markers);

    Mat mark = Mat::zeros(markers.size(), CV_8UC1);
    markers.convertTo(mark, CV_8UC1);
    bitwise_not(mark, mark);

    // Generate random colors
    vector<Vec3b> colors;
    for (size_t i = 0; i < contours.size(); i++)
    {
        int b = theRNG().uniform(0, 255);
        int g = theRNG().uniform(0, 255);
        int r = theRNG().uniform(0, 255);

        colors.push_back(Vec3b((uchar)b, (uchar)g, (uchar)r));
    }

    // Create the result image
    Mat dst = Mat::zeros(markers.size(), CV_8UC3);

    // Fill labeled objects with random colors
    for (int i = 0; i < markers.rows; i++)
    {
        for (int j = 0; j < markers.cols; j++)
        {
            int index = markers.at<int>(i,j);
            if (index > 0 && index <= static_cast<int>(contours.size()))
                dst.at<Vec3b>(i,j) = colors[index-1];
            else
                dst.at<Vec3b>(i,j) = Vec3b(0,0,0);
        }
    }

    // Visualize the final image
    imshow("Final Result", dst);


    waitKey(0);
    return 0;
}


