
%Name: Saylee Bhide

%1. BALLS_FOUR_5244_shrunk.jpg - Isolate the yellow ball

% Techniques tried: 
%1. Initially I tried to add red and green channels to get yellow channel 
%   but my technique didnt work.
%2. I thought maybe a sharpened image will give me a good base to enhance
%   the image so I sharpened the image by doing unsharped masking. 
%3. Realized sharpening the image will sharpen the carpet as well so
%   discarded this technique. 
%4. Next, I subtracted blue channel from the original image. The other
%   three balls got emphasized but this is not the result I wanted
%5. Then I realized, maybe if I find the range of hue that represents
%   yellow, I can segment the image accordingly. So I converted the image
%   to hsv colorspace and segmented in the range of 0.15 -0.16 and
%   recombined the image but this technique failed as well
%6. I referred to professors HW03 code of isolating squares and figured out
%   the following boolean logic technique which worked for segmenting the
%   yellow ball. 

%read the image
fourballs = imread('BALLS_FOUR_5244_shrunk.jpg');
 
%new figure
figure('Name' , 'Yellow Ball');

% Was getting background yellow pixels so removed them by smoothening the
% carpet before performing boolean logic to isolate the yellow ball.
% Smoothening the carpet using Gaussian filter removed the graininess of
% the carpet 
    
%Smoothening filter - Gaussian filter with standard deviation 3 to
%achieve a more blurry image i.e to achieve more smoothness on the
%carpet. As you increase the SD, the bluriness also increases
fltr = fspecial('Gauss', 7 , 3 );
    
%Applying the Gaussian filter to the original image
fourballs_smooth =  imfilter(fourballs, fltr, 'same', 'repl');
    
%Here we do boolean math to combine information from the red, green, and 
%blue channels to ~using logic~ isolate the pixels in the yellow ball. The
%resulting region wherein the condition is satisfied is evaluated true
%hence the yellow ball region will be evaluated true (1) and everything
%else as false (0).
    
% Referred http://www.workwithcolor.com/yellow-color-hue-range-01.htm for
% RGB range of yellow color. Performed trial and error with different 
% value ranges for the RGB channels to get the perfect capture. Used the
% Data Cursor tool for checking the RGB values of some pixels in the desired 
% region and jotted some of them down to get an idea of the range that  
% needs to be isolated
yellow_ball = (fourballs_smooth(:,:,1) > 180) & (fourballs_smooth(:,:,2) > 165 ) & (fourballs_smooth(:,:,3) < 225 );
    
%dispaly the image
imshow(yellow_ball);

%--------------------------------------------------------------------------

%2. Additive_Color_Helmhotz_on_Gray.png
%  Isolate the yellow pixels only not the white pixels

%In this I directly applied the technique used previously for segmenting
%the yellow ball since the pixel values in this image were the perfect
%colors and not shades. Yellow was [255 254 0] so in my condition I
%selected all pixel values above and equal to 255 for red channel , above
%and equal to 254 for yellow channel and 0 and less than 0 for blue channel

%new figure
figure('Name', 'Helmhotz - yellow pixels');

%read the image
helmhotz = imread('Additive_Color_Helmhotz_on_Gray.png');

%Here we do boolean math to combine information from the red, green, and 
%blue channels to ~using logic~ isolate the yellow pixels. The
%resulting region wherein the condition is satisfied is evaluated true
%hence the yellow pixels will be evaluated true (1) and everything
%else as false (0).

%Checked RGB values of the pixels in the desired region
%in the original image using the Data Cursor tool and decided the
%range of values in the boolean logic for isolating yellow pixels. Also, it
%mentions that we need to isolate the yellow pixels not region hence the
%BLUE label is also isolated since its background is in yellow.
yellow_region = (helmhotz(:,:,1) >= 255) & (helmhotz(:,:,2) >= 254 ) & (helmhotz(:,:,3) <= 0 );

%display image
imshow(yellow_region);
%--------------------------------------------------------------------------

%3. ANPR_YELLOW_IMG_0722.jpg - Isolate the yellow pixels.
%The driver obviously cannot see yellow.


% First I didnt understand what driver cant see yellow means - so I thought
% maybe only the parking lines need to be isolated which means not all
% shades of yellow. 

%new figure
figure('Name' , 'Car - Isolate yellow pixels');

%read image
apnr = imread('ANPR_YELLOW_IMG_0722.jpg');

% Referred http://www.workwithcolor.com/yellow-color-hue-range-01.htm for
% RGB range of yellow color. Performed trial and error with different 
% color ranges to get the perfect capture. Used the Data Cursor tool and 
% jotted down the RGB values of each pixel in the desired region and  
% approximated the RGB channels range of pixels that need to be isolated.

%Here we do boolean math to combine information from the red, green, and 
%blue channels to ~using logic~ isolate the yellow pixels in the parking line
%/all shades of yellow on the buildings and the parking line as well and a 
%sticker on the car.
%The resulting region wherein the condition is satisfied is evaluated true
%hence the yellow parking line region will be evaluated true (1) and everything
%else as false (0).

%all shades of yellow (everything else on the building, car , foothpath as
%well)
%apnr_yellow = (apnr(:,:,1) >= 189) & (apnr(:,:,2) >= 183 ) & (apnr(:,:,3) <=142 );

%parking line yellow
apnr_yellow = (apnr(:,:,1) >= 189) & (apnr(:,:,2) >= 168 ) & (apnr(:,:,3) <=142 );

%display image
imshow(apnr_yellow);

%I added a smoothening filter in this to see if I can achieve better results 
%by removing the patches on the footpath and blurring the lighter shades of 
%yellow.
%The results are similar but according to me slightly better than before.

%new figure
figure('Name','Car - Smoothened');

%Smoothening filter - Gaussian filter with standard deviation 3 to
%achieve a more blurry image 
fltr = fspecial('Gauss', 7 , 3 );

%Applying the filter on the original image
apnr_smooth =  imfilter(apnr, fltr, 'same', 'repl');

% Performed trial and error with different RGB value ranges.
% Used the Data Cursor tool and jotted down the RGB values of some pixels 
% in the desired region and approximated  the RGB channels range of pixels 
% that need to be isolated.

%Here we do boolean math to combine information from the red, green, and  
%blue channels to ~using logic~ isolate the yellow pixels of the parking line. 
%The resulting region wherein the condition is satisfied is evaluated true
%hence the yellow parking line region will be evaluated true (1) and everything
%else as false (0).
apnr_yellow = (apnr_smooth(:,:,1) >= 191) & (apnr_smooth(:,:,2) >= 160 ) & (apnr_smooth(:,:,3) <=170 );

%display image
imshow(apnr_yellow);

%--------------------------------------------------------------------------

%4. TBK_Buckle_Up_Next_Million_Miles_DSCF0372.jpg

%I first smoothened the image to blur the road.
%I wanted to try the LAB color space so I converted the image to lab using
%rgb2lab and I found that the miles board had become white and everything
%else was red/magenta. But after performing the boolean logic after
%approximating the RGB channel values, I figured I was getting the
%headlights of the cars as well into the final result.

%new figure
figure('Name','Milestone-yellow');

%read image
miles = imread('TBK_Buckle_Up_Next_Million_Miles_DSCF0372.jpg');

%Define gaussian filter to smoothen image
fltr = fspecial('Gauss', 7 , 3 );

%Apply filter to original image to achieve blurrier image
miles_smooth =  imfilter(miles, fltr, 'same', 'repl');

%Converting to LAB color space where L stands for luminance and a and b
%stand for where color falls along the Red/Green axis and Blue/Yellow axis.
%It is a chromatic value color space.
miles_lab = rgb2lab(miles_smooth);

%Using the Data Cursor tool, observed the range of RGB channels for the  
%pixels of the sign board and
%approximated the RGB channel value range for isolating the sign board and 
%performed boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the yellow pixels of the yellow board. 
%The resulting region wherein the condition is satisfied is evaluated true
%hence the yellow pixel on the board region will be evaluated true (1) and
% everything else as false (0).
miles_yellow= (miles_lab(:,:,1) >= 1) & (miles_lab(:,:,2) >= 1 ) & (miles_lab(:,:,3) >=1 );

%display the image
imshow(miles_yellow);

%I was not satisfied with these results so I thought of adding some
%contrast to the smoothened image. This gave me better results since now 
%the blue channel became 0 hence it became easier to segment the image and 
%it gave me better results after performing this image enhancement. Also I 
%nomore get the headlights from the car in the following image:

figure('Name','Milestone LAB vs Milestone-Contrasted');

%Adding contrast to the image / adjusting image intensity and value.
miles_adjust = imadjust(miles_smooth,[0.3 0.8] ,[]);


% Performed trial and error with different RGB value ranges.
% Used the Data Cursor tool and jotted down the RGB values of some pixels 
% in the desired region and approximated  the RGB channels range of pixels 
% that need to be isolated.

%Performed boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the yellow pixels of the yellow board. 
%The resulting region wherein the condition is satisfied is evaluated true
%hence the yellow pixels of the board region will be evaluated true
%(1) and everything else as false (0).
sign = (miles_adjust(:,:,1) >= 119) & (miles_adjust(:,:,2) >= 17 ) & (miles_adjust(:,:,3) <=0 );

%Display the previous result and newly obtained result side by side for
%comparision
imshowpair(miles_yellow,sign,'montage');

%--------------------------------------------------------------------------

%5. Toblerone_LOGO.jpg - Isolate the white bear on the mountain.
%Make the bear pixels white, and the other pixels black.

%Initially I thought that the background should not be isolated and somehow
%it should map to false and not true since only bear needs to be isolated.
%So I tried different techniques like subtracting The yellow pixels from
%mountain from the original image to get the bear but I failed in my
%technique. Then I thought of using edge detection on the bear but couldnt
%figure out how I would be able to segment the bear. Also, I got a very bad
%result with edge detection. I also learnt how to be careful since I ran
%into many conversion errors while doing the subtraction process because of
%the images being in uint/double/logical type. So I isolated the bear and
%the background got isolated as well due to the same RGB range values of
%both the regions. 

%new figure
figure('Name','Toblerone');

%read the image
bear = imread('Toblerone_LOGO.jpg');

% Performed trial and error with different 
% RGB channels ranges to get the perfect capture. Used the Data Cursor tool 
% and jotted down the RGB values of several pixels in the desired region and
% approximated the RGB channels range of pixels that need to be isolated. 

% I wanted the perfect capture hence I had to be careful of including all 
% the pixel values of the mountain in the RGB channels range so I had to 
% decide my range carefully. 

%Performed boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the pixels of the mountain. 
%The resulting region wherein the condition is satisfied is evaluated true
%hence the pixels of the mountain region will be evaluated true (1) and 
%everything else as false (0).
mountain = (bear(:,:,1) >= 240) & (bear(:,:,2) >= 200 ) & (bear(:,:,3) <=90 );

%I then took inverse of the image where mountain was isolated to get the
%inverse i.e a new image where the bear is mapped to true and mountain to
%false.
only_bear = imcomplement(mountain);

%display image
imshow(only_bear);

%--------------------------------------------------------------------------

%6. TBK_Orange_Balloon_Infinity.jpg - Isolate the orange balloon

%Initially I thought maybe I should smoothen the image to remove the noise
%on the bricks which resembled salt and pepper noise to me. Hence I performed 
%some smoothening using the Gaussian filter.
 
%new figure
figure('Name', 'Orange Balloon');

%read image
balloon = imread('TBK_Orange_Balloon_Infinity.jpg');

%Define Gaussian filter
fltr = fspecial('Gauss', 7 , 3 );

%Apply filter to image 
balloon_smooth =  imfilter(balloon, fltr, 'same', 'repl');

% Performed trial and error with different RGB value ranges.
% Used the Data Cursor tool and jotted down the RGB values of some pixels 
% in the desired region and approximated  the RGB channels range of pixels 
% that need to be isolated.
% I also checked the color ranges for Red-Orange, Orange-Yellow and
% Orange-Brown. 

%Here we do boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the orange pixels in the balloon. I had
%to vary the pixel ranges to not let the background pixels come in the
%image. For example if we select all the pixels above 180 in red channel,
%we get the background pixels as well hence I had to increase the lower
%limit.
orange_pix = (balloon(:,:,1) >= 191) & (balloon(:,:,2) <=196 ) & (balloon(:,:,3) <=110 );

%display the image
imshow(orange_pix);

%--------------------------------------------------------------------------

%7. TBK_science_frog_Thomas_Kinsman.jpg - Isolate frog

%Initially, I didnt add any contrast and tried with several different RGB
%value ranges but I was not successful in getting even a close result to
%expected. Then I added some contrast which added some hue and saturation
%in the image. By doing so, though I didnt get the result as expected, I
%got a result close to the desired result. I failed to eliminate the pixels
%on the border of the board. I tried every possible range but did not
%succeed in getting the desired result.

%I first tried isolating the frog by observing the values of the frog
%pixels but that technique didnt work. Therefore, I decided to segment the
%image one by one by observing the pixel values of the board, brick and
%then the frog and see how I can eliminate the board and the brick.
%However, I failed to eliminate the sides of the board and some pixels of
%the bricks. 

%new figure
figure('Name','Frog');

%read the image
science = imread('TBK_science_frog_Thomas_Kinsman.jpg');

%Adding contrast to the image 
science_smooth = imadjust(science,[0.3 0.9],[]);

% Performed trial and error with different RGB value ranges.
% Used the Data Cursor tool and jotted down the RGB values of some pixels 
% in the desired region and approximated  the RGB channels range of pixels 
% that need to be isolated.

%Here we do boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the american gray frog pixels
frog = (science_smooth(:,:,1) >= 40) & (science_smooth(:,:,1) <= 210) & (science_smooth(:,:,2) >=80 )& (science_smooth(:,:,2) <=255 ) & (science_smooth(:,:,3) >=220 )& (science_smooth(:,:,3) <=255 );

%display the image
imshow(frog);
%--------------------------------------------------------------------------

%8. TBK_Kite.jpg - Isolate the orange kite

%My idea was to isolate the sky and take a complement of the resulting image 
%to isolate the orange kite since it is easier to do so rather than 
%observing each of the RGB values of the pixels of the multi colored kite.

%I tried working with only one bound and not two bounds for the RGB values
%hence was not getting the desired result. I then added the upper bound and
%lower bound for each of the channels by observing the RGB values of the
%pixels of the sky.

%new figure
figure('Name' , 'Kite');

%read the image
kite = imread('TBK_Kite.jpg');

% Performed trial and error with different RGB value ranges.
% Used the Data Cursor tool and jotted down the RGB values of some pixels 
% in the desired region and approximated  the RGB channels range of pixels 
% that need to be isolated.

%Here we do boolean math to combine information from the red, green, and blue 
%channels to ~using logic~ isolate the sky
sky = (kite(:,:,1)>=86) & (kite(:,:,1) <= 177) & (kite(:,:,2) >=115 )& (kite(:,:,2) <=191 )& (kite(:,:,3) >=140) & (kite(:,:,3) <=215);

%I inverted the image to get the image that isolates the kite. 
kite_only = imcomplement(sky);

%display the image
imshow(kite_only);