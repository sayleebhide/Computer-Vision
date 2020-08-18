function HW11_Bhide_Saylee_MAIN

%Good to convert to double for avoiding loss of precision 
input_image = im2double(imread('SCAN0005.JPG'));

%Convert image to grayscale
im_gray = rgb2gray(input_image);

%Add some contrast to the Image to get more visual distinction between
%Foreground and Background
im_adjust = imadjust(im_gray, [0.3 0.7],[]);

figure();
imshow(im_adjust);

%Do some morphology to erode the middle thin lines. I used a square element
%because I thought it would wowrk well for a square grid. I dilated it so
%that the characters get filled and I am left with only the grid
%se          = strel('disk',11);  
se  = strel('square',7);
im_morph     = imdilate(im_adjust, se);

figure();
imshow(im_morph);

%Create black and white image

%im_bw = imbinarize(im_gray);

im_bw = edge(im_morph,'canny' , 0.5 , 1);
figure()
imshow(im_bw);

%Do some morphology to fill holes but retain the size. By performing
%closing, first I dilate the edges found by canny. Had I not performed
%this, the broken edges would not have been strong enough hence I dilated
%them so that the gaps are filled. Then I eroded the thin white lines since
%they seemed unimportant to me. Had I only eroded, everything would have
%disappeared since the canny edges were weak and broken. 
se1 = strel('square' ,9 );
im_bw = imclose(im_bw,se1);

%se2 = strel('square' , 2 );
%im_bw = imerode(im_bw,se2);

%Display the image
figure();
imshowpair(im_bw , input_image , 'montage');

%Hough transform MATLAB function computes the standard hough transform of
%binary image BW. It is designed to detect lines. Function uses parametric
%representation of a line. rho is the distance from origin to line along a
%vector perpendicular to the line. theta is the angle in degrees between x
%axis and this vector. The range is generally beween [-90,90] degrees

%we have to find the x_ and y_ points. These are the end points of the
%potential line segments

%Hough transform matrix, returned as a numeric array, nrho-by-ntheta in size. 
%The rows and columns correspond to rho and theta values.

%[H,T,R] = hough(im_bw,'RhoResolution',1,'ThetaResolution',-90:89);

%Find T,R and H using hough function 
[H,T,R] = hough(im_bw);

%Find hough peaks
P  = houghpeaks(H,8,'threshold',ceil(0.3*max(H(:))));

%Find hough lines
lines = houghlines(im_bw,T,R,P);
figure, imshow(input_image), hold on

max_len = 0;

%leftmost line
min_rho = abs(lines(1).rho);

%rightmost line
max_rho = abs(lines(1).rho);

%topmost line
min_rho_hz = lines(1).rho;

%bottommost line
max_rho_hz = lines(1).rho;

lenline = length(lines);
disp(lenline);

%Find the leftmost, rightmost, topmost and bottommost lines
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   
   %If it is a vertical line - find leftmost line and right most line
   if(lines(k).theta>0)
       if(lines(k).rho <= min_rho)
           min_rho = lines(k).rho;
       end
       
       if(lines(k).rho >= max_rho)
           max_rho = lines(k).rho;
       end
   end
   
   %If it is a horizontal line - find topmost and bottommost line
    if(lines(k).theta<0)
       if(abs(lines(k).rho) <= abs(min_rho_hz))
           min_rho_hz = lines(k).rho;
       end
       
       if(abs(lines(k).rho) >= abs(max_rho_hz))
           max_rho_hz = lines(k).rho;
       end
   end
   
   %plot(xy(:,1),xy(:,2),'LineWidth',4,'Color','magenta');
   disp(lines(k));
end

disp(min_rho);
disp(max_rho);
disp(min_rho_hz);
disp(max_rho_hz);

%If its any of these lines, plot the lines
for k = 1:length(lines)
   if(lines(k).rho == min_rho || lines(k).rho == max_rho || lines(k).rho == min_rho_hz || lines(k).rho == max_rho_hz)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',4,'Color','magenta');
   end

end

end