function HW12_Bhide_Saylee_MAIN

%Test images are present in the following folder which is above the folder
%in which the scripts are present
addpath( '../TEST_IMAGES/' );

%Read in the image
input_image = imread('img_cantaloupe_slices_1246.jpg');

figure('Name','Original')
imshow(input_image);
%-------------------------------------------------------------------------

%Noise reduction using Gaussian filter of size 5 and standard deviation 5.

%Gussian fiter size and sd varied as per the result. Initially set with the
%idea that the texture is slightly smeared out. 
fltr = fspecial('gauss' , 5 , 5);
im_smooth = imfilter(input_image,fltr,'same','repl');

imshow(im_smooth);

%-------------------------------------------------------------------------
%Add some contrast to the image to get a more visual contrast between the
%fruit and the skin

im_adjust = imadjust(im_smooth,[0.3 0.8], []);

imshow(im_adjust);

%-------------------------------------------------------------------------
%Color segmentation by segmenting the green and orange


%Green part of the image
im_g = im_adjust(:,:,1)<=45 & im_adjust(:,:,3)<=15 ;

%Orange part of the image
im_o = (im_adjust(:,:,1)>240) & (im_adjust(:,:,2)>100)& (im_adjust(:,:,3)<100);

figure('Name','green');
imshow(im_g);

%Do some morphology to get more distinguished edge of green 
se1 = strel('disk' , 3 );
im_gcanny = imdilate(im_g,se1);

figure('Name','green morphology');
imshow(im_gcanny);

%Plot on graph
sc = sum(im_gcanny,1);  %sum columns
figure;
bar(sc);

%Find the no of peaks above the threshold to identify the no of melons 
pks = findpeaks(sc,'MinPeakHeight',70 ,'MinPeakDistance', 70);
%disp(pks);
disp('The no of melons are');
peaksize = size(pks);
disp(peaksize(2));


figure('Name','orange');
imshow(im_o);

%The main part of the image we are bothered about without the background
im_go = im_g + im_o;
figure('Name','green+orange');
imshow(im_go);

%Plot on graph 
sc1 = sum(im_go,1);  %sum columns
figure;
bar(sc1);

%-------------------------------------------------------------------------

%Find the edges of the image
im_canny = edge(im_go , 'canny', 0.2 , 0.8);

figure()
imshow(im_canny);

%Dilate the edges to get more cleareer edges
se1 = strel('disk' , 6 );
im_cannymorph = imdilate(im_canny,se1);

figure();
imshow(im_cannymorph);

%-------------------------------------------------------------------------

%plot the line
im_green_canny = edge(im_g , 'canny', 0.2 , 0.8);

figure('Name','gren cany');
imshow(im_green_canny);

%I wanted to thin the edges more 
se1 = strel('disk' , 15 );
im_green_cannymorph = imclose(im_green_canny,se1);

figure();
imshow(im_green_cannymorph);

%find function finds the 1's in the matrix 
[x,y] = find(im_g);

%plot on the original image
figure;imshow(input_image);hold on;

plot(y,x,'b.');

hold off;

%-------------------------------------------------------------------------
%Implementing the polyfit function but didnt work
p = polyfit(y,x,2);

y1 = polyval(p,y);
figure
imshow(im_adjust);
hold on
plot(y1,y,'m.')
hold off

end
