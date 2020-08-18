//
// Created by Saylee Bhide on 2/20/18.
//

#include <iostream>
#include <opencv2/opencv.hpp>
#include "HW01_Bhide_Saylee_ImageRotation.h"
#include "HW01_Bhide_Saylee_Steganography.h"

using namespace cv;

using namespace std;

int HW01_Bhide_Saylee_Steganography::steganography() {


    //image matrix
    Mat image;

    //image matrix to store BGR channels of the image
    Mat bgr[3];

    //read an image
    image = imread("CAT_Kitten_img_22.jpg");

    if(! image.data )                              // Check for invalid input
    {
        cout <<  "Could not open or find the image" << std::endl ;
        return -1;
    }

    //split into channels and store image data in bgr image matrix
    split(image,bgr);


    /*namedWindow("Blue",CV_WINDOW_NORMAL);
    resizeWindow("bgr",200,200);
    imshow("Blue", bgr[0]);

    namedWindow("Green",CV_WINDOW_NORMAL);
    resizeWindow("bgr",200,200);
    imshow("Green", bgr[1]);

    namedWindow("Red",CV_WINDOW_NORMAL);
    resizeWindow("bgr",200,200);
    imshow("Red", bgr[2]);

    //dimensions of image
    row = image.rows;
    col = image.cols;

    printf("%d %d \n", image.rows, image.cols);*/

    //filename for writing to jpg files
    string file_name("Kitten_Gren0bit.jpg");

    //Algorithm to iterate over every bit plane and get the image corresponding to each bit plane

    for (uint32_t i(0); i < 8; ++i) {
        cv::Mat out(((bgr[1] / (1<<i)) & 1) * 255);

        cv::imwrite(file_name, out);

        file_name[11] += 1;
    }

    // Wait for a keystroke in the window
    waitKey(0);
    return 0;
}

