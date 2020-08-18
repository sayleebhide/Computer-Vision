
%TITLE: HW03_BHIDE_SAYLEE
%NAME: SAYLEE BHIDE


%CHECKBOARD

%create new figure 
figure('Name', 'Checkboard - threshold+black and white');

%graythresh()calculates global image threshold level using 
%Otsus method. Used to
%minimize iterclass variance between black and white pixel. 
%imbinarize() converts image to BW by replacing all values above the globally 
%determined threshold with
%1's and setting all other values to 0's

checkboard = imread('Checkerboard_calib.tif');
imshow(checkboard);
level = graythresh(checkboard);
cb_bin = imbinarize(checkboard,level);
imshowpair(checkboard, cb_bin , 'montage');

%{
Alternatively, you can also use quantization to segment the image. 
%read the image
checkboard = imread('Checkerboard_calib.tif');
checkboard_quant = checkboard;

%Quantization into 2 levels. This boolean operation selects those pixel
%values above 128 and sets them to 255 (white) and the ones below 128 to 0
%(black)
checkboard_quant(checkboard_quant > 128) = 255;
checkboard_quant(checkboard_quant < 128) = 0;
imshow(checkboard_quant);
imshowpair(checkboard, checkboard_quant , 'montage');
%}
%--------------------------------------------------------------------------

%DICE

%create new figure 
figure('Name', 'Dice - threshold + convert to BW');

%read the image
dice =imread('img_7135__unk.jpg');

%since image is rgb image (3D) convert it into grayscale(2D) image using
%rgb2gray() function. It eliminates hue and saturation.
dice_gray = rgb2gray(dice);

%calculate global image threshold level using Otsus method. Used to
%minimize iterclass variance between black and white pixel
level_dice = graythresh(dice_gray);

%convert image to black and white using imbinarize() and threshold level. 
%Works by replacing all values above the globally determined threshold with
%1's and setting all other values to 0's
dice_bin = imbinarize(dice_gray,level_dice);

%display the images side by side to compare the difference
imshowpair(dice ,dice_bin,'montage');

%--------------------------------------------------------------------------

%SUDOKU

%create new figure
figure('Name' ,' Sudoku - threshold + convert');

%read image
sudoku = imread('SUDOKU_SCAN0011.JPG');

%since image is rgb image (3D) convert it into grayscale image using
%rgb2gray() function
sudoku_gray =rgb2gray(sudoku);

%calculate threshold level 
level_sudoku = graythresh(sudoku_gray);

%convert image to black and white using imbinarize() and threshold level 
sudoku_bin = imbinarize(sudoku_gray, level_sudoku);

%display the original image and resulting image side by side to compare the
%difference
imshowpair(sudoku, sudoku_bin , 'montage');

%Alternatively, used imadjust to improve the results.  It gave a better
%resulting image than before. Introduced the
%concept of using imadjust() which adds some contrast to the image. 

%Note that you cannot use imadjust for a binarized image . Hence you have to
%adjust the uint8 , double image before converting to a BW logical type
%image.

figure('Name','Comparision of converting to BW vs Adjusting and Converting');

%Adding contrast to the image / adjusting image intensity and value. It
%maps the intensity value of grayscale image hence I converted the image to
%grayscale image and applied this function to the grayscale image.
sudoku_adjust =imadjust(sudoku_gray, [0.6 0.7],[]);
imshow(sudoku_adjust);
 
%Calculated threshold value for the adjusted image and converted the image
%to Bland and White. 
level_sudoku_adjust = graythresh(sudoku_adjust);
sudoku_adjust_bin = imbinarize(sudoku_adjust, level_sudoku_adjust);
%display the original image and resulting image side by side to compare the
%difference
imshowpair(sudoku_bin,sudoku_adjust_bin,'montage');

%--------------------------------------------------------------------------


%FINGERPRINTS

%I wanted to highlight the lighter shades of grey in the resulting image to
%improve the image. Hence I tried various alternatives like :

%1. Tried enhancing highlights/shadows by multiplying each pixel with 2 or 
%more or 0.5 and less yet nothing was working to pick up light shades of 
%gray. Converted the image to double before performing these operations.
%By taking the power of each pixel to 0.5, it enchances the shadows and by 
%taking the power of each pixel to 2, it enhances the lighter parts. 

%2. edge detection was also not working using sobel filter.

%3. Tried smoothing filter and then working on it. However smoothening was also not helping
%   to capture lighter grey shades. 
figure('Name' , 'Fingerprints - basic threshold + convert');

%read the image
fingerprint = imread('finger_prints.jpg');

%convert rgb image to grayscale image. 
fingerprint_gray = rgb2gray(fingerprint);

%calculate threshold value
level_fingerprint = graythresh(fingerprint_gray);

%convert image to black and white
fingerprint_bin = imbinarize(fingerprint_gray, level_fingerprint);

%display the original image and resulting image side by side to compare the
%difference
imshowpair(fingerprint, fingerprint_bin, 'montage');

%--------------------------------------------------------------------------

%FINGERPRINT SINGLE

figure('Name' , 'Fingerprint - basic threshold + convert');

%read the image
fingerprint_single = imread('Finger_Print_DB2_B_107_7.tif');

%No need to convert to grayscale 
level_fingerprint_single = graythresh(fingerprint_single);

%convert image to black and white using threshold value
fingerprint_single_bin = imbinarize(fingerprint_single, level_fingerprint_single);

imshowpair(fingerprint_single, fingerprint_single_bin,'montage');

%Next, used imadjust() to see if it improves the results. Got
%better results when imadjust() was used to adjust the intensity values of
%the image before converting it to a black and white image. 

figure('Name','Comparision of converting to BW vs Adjusting and Converting in Fingerprint');
%Adding contrast to the image / adjusting image intensity and value. It
%maps the intensity value of grayscale image 
adjust = imadjust(fingerprint_single,[0.8 0.9],[]);
level_adjust = graythresh(adjust);
adjust_bin = imbinarize(adjust,level_adjust);
imshowpair(fingerprint_single_bin,adjust_bin,'montage');

%Found image to be too grainy. Thought that maybe smoothening it would
%improve my results. Hence, 
%used smoothening filter. Got a less grainy image! The filter I used is a local 
%averaging filter which is an Approximation of
%Gaussian filter.'same' means let the input and output image size be same
%'repl' means replicate the edges. 

figure('Name','Adjusting and Converting in Fingerprint vs filter+convert');
vt_smooth = [ 1 2 1 ; 2 4 2 ; 1 2 1]/16;
finger_temp = imfilter(fingerprint_single , vt_smooth, 'same' , 'repl');

%Adjust image intensity value
finger_adjust = imadjust(finger_temp , [0.8,0.9],[]);

%Calculate global threshold value of the adjusted image
level_filter_adjust = graythresh(finger_adjust);

%Convert to BW
adjust_filter_bin = imbinarize(finger_adjust,level_filter_adjust);
imshowpair(adjust_bin, adjust_filter_bin, 'montage');


%--------------------------------------------------------------------------

%EFFECT OF ALCOHOL
%Basic converstion to BW
figure('Name' ,'Alcohol-basic');
alcohol = imread('Effect_of_alcohol_on_brain-b.tif');
imshow(alcohol);
level_alcohol = graythresh(alcohol);
alcohol_bin = imbinarize(alcohol,level_alcohol);
imshowpair(alcohol,alcohol_bin,'montage');


%I used the smoothening filter first to remove the
%graininess which was appearing in the previous attempt to enhance the
%image. Then to remove the background which got scanned, I cropped the
%image to the article size. Then after getting the desired cropped image, I
%added contrast by using imadjust() function. I played around various
%contrast bounds and then get the desired bounds for contrast values. After
%getting the desired contrast, I calculated the global threshold value
%using the graythresh() function and converted the image into BW using
%imbinarize() and the global threshold value. Since the question asked to
%isolate only the black ink - black text, I assumed that only the black
%text needs to be seen hence the picture of the man and the text in white
%should be removed. So I isolated that one square which sized the mans face
%and replaced all the pixels to white in that region so that the image of 
%the man is not seen. 

figure('Name', 'Original Alcohol Article vs Smoothening+adjust+crop');

%Approximation of Gaussian filter for smoothening
vt_smooth = [ 1 2 1 ; 2 4 2 ; 1 2 1]/16;
alcohol_smooth_temp = imfilter(alcohol , vt_smooth, 'same' , 'repl');

%Chopping the background
alcohol_smooth_crop = alcohol_smooth_temp(250:2420,1050:2320);

%Adding contrast
alcohol_smooth_crop_adjust = imadjust(alcohol_smooth_crop , [0.3 0.8] , []);

%Calculating global threshold value
alcohol_smooth_crop_adjust_level = graythresh(alcohol_smooth_crop_adjust);

%Converting image to BW
alchol_smooth_crop_adjust_BW = imbinarize(alcohol_smooth_crop_adjust,alcohol_smooth_crop_adjust_level);

%Removing the mans face by replacing all pixel vals in the given region to 1.0
%(white)
alchol_smooth_crop_adjust_BW(365:582,1003:1246) = 1.0;

%Removing the letters in white under the mans image by replacing all pixel  
% values in the given region to 1.0(white)
alchol_smooth_crop_adjust_BW(563:640,667:1260) = 1.0;
imshowpair(alcohol, alchol_smooth_crop_adjust_BW, 'montage');


%--------------------------------------------------------------------------

%JC PENNY

%Normal conversion to BW after finding threshold value and binarizing it
%using the threshold value.
figure('Name','JCPenny-Basic');
jcpen = imread('IMG_Aliasing__JCPenny_Top_06_PHOTOSHOPPED_SMILE.tif');
jcpen_gray = rgb2gray(jcpen);
level_jcpen = graythresh(jcpen_gray);
jcpen_bin = imbinarize(jcpen_gray , level_jcpen);
imshowpair(jcpen, jcpen_bin , 'montage');

%To isolate the lines on the top, the background needs to be cropped alogn
%with hands and pant and face. Add some contrast between the white and
%black pixels. Find threshold level of this adjusted image and binarize by
%using the calculated threshold image. The black and white distinction is
%clearly seen now, due to the high contrast. 
figure('Name','Jcpen with contrast and crop');

%Cropped the image to isolate the top
jcpen_gray_crop  = jcpen_gray(133:1264,384:1055);

%Adding contrast to the image to better see the distinct black and white
%lines
jcpen_gray_crop_adjust = imadjust(jcpen_gray_crop,[0.3 0.8],[]);

%Calculating the global threshold value of the cropped and adjusted image
level_jcpen_adjust = graythresh(jcpen_gray_crop_adjust);

%Converting the image into black and white
jcpen_final = imbinarize(jcpen_gray_crop_adjust, level_jcpen_adjust);

imshowpair(jcpen,jcpen_final,'montage');
