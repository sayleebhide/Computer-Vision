
%Name : Saylee Bhide
function list_images()

	file_names = dir( '*.jpg' );

	for idx = 1 : length( file_names )
        
		a_file_name = file_names(idx).name;
        
		fprintf('File Name is: %s\n', a_file_name );
    end

        threshold1 = 0.02;
        
        threshold2 = 0.01;
        
        sigma_for_gaussian_filter = 3;
        
        canny_edges('ANPR_img_00.jpg', threshold1, threshold2, sigma_for_gaussian_filter);
       
end

function canny_edges(im,t1,t2,sigma)

% Read the original image
im = imread(im);

%--------------------------------------------------------------------------

% #1. Convert image to double to get extra precision

im_double = im2double(im);

%--------------------------------------------------------------------------

% #2. if image is RGB true color image convert to GrayScale Intensity image
dims = size(im_double);

if(length(dims) > 2)
    %disp('It is color image');
    im_double = rgb2gray(im_double);
else
    %disp('It is GS image');
end

%figure('Name','Original');
%colormap(gray(256));
%imagesc(im_double);

%--------------------------------------------------------------------------

% adjust the image i.e add contrast to enhance the image

im_double = imadjust(im_double,[0.3 0.38], [ ]);

%--------------------------------------------------------------------------
%
% NOISE REDUCTION 
%

% #3. Use Gaussian Filter to remove nuisance edges. False detection could
% occur due to presence of noise 

%Larger value of standard of deviation leads to more blurring. Larger the
% size, lower the sensitivity to detect noise. 5 is a good size

%Smoothening filter - Gaussian filter with standard deviation 3 to
%achieve a blurry image. A size of 15 will help me achieve a more blurry
%image
fltr = fspecial('Gauss' , 15 , sigma);

%Applying the filter on the original image. Here same means maintain size
%of image and repl means replicate the edges

im_smooth = imfilter(im_double , fltr, 'same' ,'repl');

%--------------------------------------------------------------------------

% #4. Use Sobel filter to estimate df/dx and df/dy of gradient at each
% pixel

%Edge gradient defines the gradual blend of colors from low to high
%values.Image gradient can be formed by convolving with a filter. Each
%pixel of gradient image measures change in intensity of that same point in
%the original image in a given direction. Gray pixels have smaller gradient
%and Black and White pixels have higher gradient

%Define sobel filters

%Define Horizontal sobel filter to find gradient in horizontal direction
sobel_dx = [-1 0 1; -2 0 2 ; -1 0 1]/8;

%Define Vertical sobel filter to find gradient in vertical direction
sobel_dy = [1 2 1; 0 0 0 ; -1 -2 -1]/8;

%Apply filter on smoothened image to get horizontal gradient image. 
im_horizontal = imfilter(im_smooth , sobel_dx , 'same' ,'repl');

%Apply filter on smoothened image to get vertical gradient image. 
im_vertical = imfilter(im_smooth , sobel_dy , 'same' ,'repl');

%figure('Name','im horizontal vs im vertical');
%colormap(gray(256));
%imshowpair(im_horizontal, im_vertical,'montage');

%--------------------------------------------------------------------------

% #5. Compute edge magnitude at each and every pixel 

%edge magnitude indicates contrast

%Euclidian distance formula to calculate edge 
%magnitude at each and every pixel
im_magnitude = (im_horizontal.^2 + im_vertical.^2).^(1/2);

%disp(im_magnitude)

%figure('Name' , 'Edge strength');
%colormap(gray(256));
%imagesc(im_magnitude);

%--------------------------------------------------------------------------

%#6. Compute edge gradient direction at each pixel

%Convert from radians to degrees by multiplying with 180/PI
im_direction = atan2(-im_vertical, im_horizontal) * 180/pi;

%Used -dy because in image processing we use left handed coordinate system

%figure('Name' ,'Gradient Direction');
%colormap(gray(256));
%imagesc(im_direction);

%--------------------------------------------------------------------------

% #7. Convert edge angle to multiple of 45 degrees using round() or floor()

 %Canny's algorithm requires that all gradient angles be normalized to one 
 % [0 , 45 , 90 , 135 ] 

 %if angle is 0 degrees, value = 0
 %{
 if ( im_direction == 0)
     im_direction =0;
 else if ( im_direction >= -22.5 & im_direction <=22.5)
         im_direction = 0;
     end 
 end
 %}

 im_direction      = round( im_direction / 45 ) * 45;
 
 %Fix negative angles
 
 %Without this, the image had negative angles multiples of 45. To fix it, I
 %applied this logic. I determined the presence of negative angles by
 %printing the image
 
 bool_negative_angle = im_direction < 0;
 im_direction( bool_negative_angle ) = im_direction( bool_negative_angle ) + 180; 
 im_direction( im_direction == 180 ) = 0;
 
 %size of image
 im_size = size(im_direction);
 [r,c] =size(im_direction);

 %disp(im_size);
 
 %disp(im_direction);
 
 %figure('Name', 'Gradient Direction rounded');
 %colormap(gray(256));
 %imagesc(im_direction);
 
%--------------------------------------------------------------------------

% #8. Perform non maximal suppression. It is an edge thinning technique

% This means If the edge magnitude is stronger than the edge in front of
% it, and behind it and edge magnitude is over some first threshold, then
% copy it to final edge image

%So, if the edge gradient at a location has an angle of 0 degrees, then it 
%is a vertical edge, and you need to compare to the pixels left and right 
%of that location (East and West of that location). If the edge gradient at
%a location has an angle of 45 degrees, then the edge has a slope of -1, 
%and you need to compare to the edge strengths that are North-East and South-West. 
%If the edge gradient has an angle of 90 degrees then you have a horizontal
%edge, and you need to compare to the pixels above and below that location
% (North and South of that pixel).

%strong_edge_image = im_magnitude;

%Initialize output image to 0's

strong_edges = zeros(size(im_direction));

% Retain edges that are stronger than its neighbours depending on the cases
for x = 2 : r - 1
    for y = 2 : c - 1
        
        %Case 1: If vertical edge i.e if angle = 0 . Compare with left and right. 
        if im_direction(x,y) == 0 
            if im_magnitude(x,y) > im_magnitude(x,y-1) && im_magnitude(x,y) > im_magnitude(x,y+1)
                strong_edges(x,y) = im_magnitude(x,y);
            end
        end
        
        %Case 2: If line is diagonal i.e if angle = 45. Compare NE and SW
        if im_direction(x,y) == 45
            if im_magnitude(x,y) > im_magnitude(x-1,y+1) && im_magnitude(x,y) > im_magnitude(x+1,y-1)
                strong_edges(x,y) = im_magnitude(x,y);
            end
        end
        
        %Case 3 : If line is horizontal i.e angle = 90. Compare N and S
        %direction
         if im_direction(x,y) == 90 
            if im_magnitude(x,y) > im_magnitude(x-1,y) && im_magnitude(x,y) > im_magnitude(x+1,y)
                strong_edges(x,y) = im_magnitude(x,y);
            end
         end
        
        %Case 4: If line is diagonal i.e angle = 135. Compare NW and SE
         if im_direction(x,y) == 135
             if im_magnitude(x,y) > im_magnitude(x-1,y-1) && im_magnitude(x,y) > im_magnitude(x+1,y+1)
                    strong_edges(x,y) = im_magnitude(x,y);
             end
         end          
    end
end

%figure();
%colormap(gray(256));
%imagesc(strong_edges);

%To check range of magnitues present in current magnitude matrix to det
%threshold

%disp(size(strong_edges));

%I displayed this to observe overall range of edge magnitudes
%disp(strong_edges);
 
%--------------------------------------------------------------------------

% #9. Apply Threshold 1

%Threshold is determined empirically. There is no set values. Threshold set
%too high can miss important information. Threshold set too low can falsely
%identify irrelevant information as important information. If edges
%gradient value is smaller than lower threshold value, it is suppressed to
%0

strong_edges_T1 = strong_edges;

threshold1 = t1;

for x = 2 : r-1
    for y = 2 : c-1
        if strong_edges_T1(x,y) < threshold1
            strong_edges_T1(x,y) = 0;
        end
    end
end

figure('Name' , 'T1');
colormap(gray(256));
imagesc(strong_edges_T1);

%disp(size(strong_edges_T1));
%disp(strong_edges_T1);

%--------------------------------------------------------------------------

% #10. Edge propogation.

%For every seed point that is at least as strong as the first threshold, 
%you need to propagate the edges as long as the edges are more then the 
%second threshold. And you need to repeat this process as long as there are
%changes to the edge_map.

strong_edges_T2 = zeros(size(strong_edges_T1));


threshold2 = t2;

for x = 2 : r -1
    for y = 2 : c -1
        %Case 1: If vertical edge i.e if angle = 0 . Compare with left and right. 
         if im_direction(x,y) == 0 && strong_edges_T1(x,y)~=0
                if im_magnitude(x,y-1) > threshold2 && im_magnitude(x,y+1) > threshold2
                    strong_edges_T2(x,y) = 1;
                    strong_edges_T2(x,y-1) = 1;
                    strong_edges_T2(x,y+1) = 1;
                end
         end
         
        %Case 2: If line is diagonal i.e if angle = 45. Compare NE and SW
        if im_direction(x,y) == 45 && strong_edges_T1(x,y)~=0
            if im_magnitude(x-1,y+1) > threshold2 &&  im_magnitude(x+1,y-1) > threshold2
                strong_edges_T2(x,y) = 1;
                strong_edges_T2(x-1,y+1) = 1;
                strong_edges_T2(x+1,y-1) = 1;
            end
        end
        
        %Case 3 : If line is horizontal i.e angle = 90. Compare N and S
        %direction
         if im_direction(x,y) == 90 && strong_edges_T1(x,y)~=0
            if im_magnitude(x-1,y)>threshold2 &&  im_magnitude(x+1,y)>threshold2
                  strong_edges_T2(x,y) = 1;
                  strong_edges_T2(x-1,y) = 1;
                  strong_edges_T2(x+1,y) = 1;
            end
         end
        
        %Case 4: If line is diagonal i.e angle = 135. Compare NW and SE
         if im_direction(x,y) == 135 && strong_edges_T1(x,y)~=0
             if im_magnitude(x-1,y-1) > threshold2 && im_magnitude(x+1,y+1) > threshold2
                  strong_edges_T2(x,y) = 1;
                  strong_edges_T2(x-1,y-1) = 1;
                  strong_edges_T2(x+1,y+1) = 1;
             end
         end
    end
end

figure('Name' , 'T2');
colormap(gray(256));
imagesc(strong_edges_T2)

%figure('Name', 'original');
%colormap(gray(256));
%imagesc(im_double);

%Built in function of Matlab
expected_edge = edge( im_double, 'Canny' );

%New Figure
figure('Name' , 'My Result vs MATLAB Result');

%Comparision between my result and MATLAB result
imshowpair(strong_edges_T2,expected_edge,'montage');

%--------------------------------------------------------------------------

%11. Write image to file

%Writes the image to file HWO5_final_Image.jpg
imwrite(strong_edges_T2,'HW05_final_Image.jpg');


end