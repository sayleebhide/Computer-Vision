//
// Created by Saylee Bhide on 4/30/18.
//

#include "Calibration.h"
#include <opencv2/opencv.hpp>
#include <iostream>

using namespace cv;
using namespace std;

int Calibration::calibrate() {

    //part A

    //Create and Initialise the the number of boards,
    int numBoards;
    int numCornersHor;
    int numCornersVer;
    Size imageSize;
    Mat image,GrayImage, cornerImage;
    Mat intrinsic_matrix_loaded, distortion_coeffs_loaded;


    //Inbuilt String datatype. Represents a vector of filenames of type String
    vector<String> filename;

    //Path to the folder where the videos are stored
    String folder = "/Users/sayleebhide/CLionProjects/ACV_HW5/IMAGES_02_CALIBRATION";

    //For non recursive tracing, we set the parameter to false. Takes in the path name and vector of file names.
    glob(folder,filename, false);

    numBoards = 31;
    numCornersHor = 6;
    numCornersVer = 8;

    //Calculate the number of squares
    int numSquares = numCornersHor * numCornersVer;

    //Compute the size of the board
    Size board_sz = Size(numCornersHor, numCornersVer);

    //Object point is the physical position of the corners in 3D space.
    vector<vector<Point3f>> object_points;

    //Image point is the location of the corners in the image in two dimensions.
    vector<vector<Point2f>> image_points;

    //Different vertices of camera when chessboard is placed at origin
    vector<Point3f> objCord;
    vector<Point2f> corners;

    //succesful entries
    int successes=0;

    //Iterate over the vector of filenames to process each video
    for(int fileNo = 0 ; fileNo < filename.size(); fileNo++) {

        //Video capture
        VideoCapture capture(filename[fileNo]);
        if (!capture.isOpened()) {
            cout << "\nVideoCapture not initialized properly\n";
            return -1;
        }

        capture >> image;
        imageSize = image.size();

        // Vector of object coordinates referencing the position of camera which is moving
        for (int j = 0; j < numSquares; j++)
            objCord.push_back(Point3f(j / numCornersHor, j % numCornersHor, 0.0f));

        // Iterate until we find chessboard corners
        while (successes < numBoards) {

            if (image.empty()) {
                cerr << "Failed to open Image or Video Sequence!\n" << endl;
                return -1;
            }

            // Conversion to grayscale image
            cvtColor(image, GrayImage, CV_BGR2GRAY);

            // findChessboardCorners to find the corners in the given image.

            //It looks for corners in the image and if it finds it, the pixel locations are stored in corners parameter
            // and found becomes true.
            bool found = findChessboardCorners(image, board_sz, corners,
                                               CV_CALIB_CB_ADAPTIVE_THRESH | CALIB_CB_FILTER_QUADS);

            // If they are found find the subpixel accuracy
            if (found) {
                cornerSubPix(GrayImage, corners, Size(11, 11), Size(-1, -1),
                             TermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 30, 0.1));

                // Store the image corners and object corners in the vectors
                // and increase the successful entry count
                image_points.push_back(corners);
                object_points.push_back(objCord);
                successes++;

                if (successes >= numBoards)
                    break;
            }

            //draw the corners on the image
            drawChessboardCorners(image, board_sz, corners, found);

            // Resize and display the image with the found corners.
            resize(image, cornerImage, Size(640, 480));


            imshow("Part A: find corners", cornerImage);

            // Capture the next image
            capture >> image;

            if ((waitKey(30)) == 27) break;

        }

        // Initalize Matrices objects to store intrinsic, distortion coefficients.
        // rotation and translation vectors.
        Mat intrinsic = Mat(3, 3, CV_32FC1);
        Mat distCoeffs;

        //rotational vector
        vector<Mat> rvecs;

        //translational vector
        vector<Mat> tvecs;

        //Set the aspect ratiro of the camera as 1.
        intrinsic.ptr<float>(0)[0] = 1;
        intrinsic.ptr<float>(1)[1] = 1;

        // Call the calibration function to caliberate the camera.
        calibrateCamera(object_points, // K vecs (N pts each, object frame)
                        image_points, // K vecs (N pts each, image frame)
                        image.size(), // Size of input images (pixels)
                        intrinsic, // Resulting 3-by-3 camera matrix
                        distCoeffs,// Vector of 4, 5, or 8 coefficients
                        rvecs,  // Vector of K rotation vectors
                        tvecs, // Vector of K translation vectors
                        0, // Flags control calibration options
                        TermCriteria(
                                TermCriteria::COUNT | TermCriteria::EPS,
                                30, // ...after this many iterations
                                DBL_EPSILON // ...at this total reprojection error
                        )
        );

        // Store the calibrated intrinsic, distortion coefficients and write it to a xml file
        FileStorage fs("calibrationParams.xml", FileStorage::WRITE);
        fs << "image_width" << imageSize.width << "image_height" << imageSize.height
           << "camera_matrix" << intrinsic << "distortion_coefficients"
           << distCoeffs;
        fs.release();

        fs.open("calibrationParams.xml", FileStorage::READ);
        cout << "\nimage width: " << (int) fs["image_width"];
        cout << "\nimage height: " << (int) fs["image_height"];

        fs["camera_matrix"] >> intrinsic_matrix_loaded;
        fs["distortion_coefficients"] >> distortion_coeffs_loaded;
        cout << "\nintrinsic matrix:" << intrinsic_matrix_loaded;
        cout << "\ndistortion coefficients: " << distortion_coeffs_loaded << endl;

        capture.release();
    }



    //Part B

    // Calculate the undistorted maps using the camera caliberation
    // parameters.

    //Output Maps generated for undistorting image.
    Mat map1, map2;

    //It computes the distortion and rectification transformation map. It represents the results in the form of maps
    // for the remap() function.
    initUndistortRectifyMap(
            intrinsic_matrix_loaded,  // 3-by-3 camera matrix
            distortion_coeffs_loaded, // Vector of 4, 5, or 8 coefficients
            cv::Mat(),                // Rectification transformation
            intrinsic_matrix_loaded,  // New camera matrix (3-by-3)
            image.size(),             // Undistorted image size
            CV_16SC2,                 // 'map1' type: 16SC2, 32FC1, or 32FC2
            map1,                     // First output map
            map2                      // Second output map
    );

        VideoCapture capture("/Users/sayleebhide/CLionProjects/ACV_HW5/IMAGES_02_CALIBRATION/IMG_0404.JPG");
        if (!capture.isOpened()) {
            cout << "\nVideoCapture not initialized properly\n";
            return -1;
        }

        capture >> image;

        do {
            //Initialize Mat object for storing unmapped and difference images
            Mat imageUndistorted, absDiff;

            // After computing undistortion maps, apply them to the input images.

            //applies a geometrical transformation to an image. The first map contains x values and second map contains
            //y values.
            remap(
                    image,             // Input Image
                    imageUndistorted,  // Output undistorted image
                    map1,              // First output map
                    map2,              // Second output map
                    cv::INTER_LINEAR,
                    cv::BORDER_CONSTANT,
                    cv::Scalar()
            );

            // Calculate the absolute difference between the input image
            // and the caliberated image.
            absdiff(image, imageUndistorted, absDiff);

            // Resize the images.
            resize(image, image, Size(640, 480));
            resize(imageUndistorted, imageUndistorted, Size(640, 480));
            resize(absDiff, absDiff, Size(640, 480));

            // Display the images
            imshow("original Image", image);
            imshow("Undistorted Image", imageUndistorted);
            imshow("Absolute Difference", absDiff);

            if ((waitKey(30)) == 27) break;
            capture >> image;
        } while (!image.empty());
        waitKey(0);
        capture.release();

    return 0;
}
