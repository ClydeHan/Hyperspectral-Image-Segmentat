%% This function was created using the base code of:
%% http://scarlet.stanford.edu/~brian/scielab/scielab.html

function [SCIELABDeltaE] = computeMatrixSCIELABWithPlots(RGB,shifted_RGB)

% Assign the channels of the images (Just to fit this code to the original code)
% Important: BOTH RGB and shifted_RGB should be double type [0-1]
rHats = RGB(:,:,1);
gHats = RGB(:,:,2);
bHats = RGB(:,:,3);

rHatsc = shifted_RGB(:,:,1);
gHatsc = shifted_RGB(:,:,2);
bHatsc = shifted_RGB(:,:,3);



% 2.  Load the calibration information
%
sampPerDeg = 23;
load displaySPD;
load SmithPokornyCones;
rgb2lms = cones'* displaySPD;
load displayGamma;
rgbWhite = [1 1 1];
whitepoint = rgbWhite * rgb2lms';

% 3.1  -- Convert the RGB data to LMS (or XYZ if you like).
%
img = [ rHats gHats bHats];
imgRGB = dac2rgb(img,gammaTable);
img1LMS = changeColorSpace(imgRGB,rgb2lms);
img = [ rHatsc gHatsc bHatsc];
imgRGB = dac2rgb(img,gammaTable);
img2LMS = changeColorSpace(imgRGB,rgb2lms);
imageformat = 'lms';

% 4. --  Run the scielab function.
errorImage = scielab(sampPerDeg, img1LMS, img2LMS, whitepoint, imageformat);
SCIELABDeltaE = errorImage;

% 5. --  Examining and interpreting the results.
%
% max(img1LMS(:)), min(img1LMS(:))
% max(img2LMS(:)), min(img2LMS(:))
figure(1)
hist(errorImage(:),[1:2:14])
xlabel('SCIELAB Delta E') 
ylabel('Number of pixels of the image') 
sum(errorImage(:) > 20)   % We think this is 173

% Look at the spatial distribution of the errors.
%
errorTruncated = min(128*(errorImage/10),128*ones(size(errorImage)));
%figure(2)
%colormap(gray(128));
%image(errorTruncated); axis image;

% If you have the image processing toolbox, you can find out where the
% edges are and overlay the edges with the locations of the scielab
% errors

%% For Matlab version 5, use the following command:
edgeImage = 129 * double(edge(rHats,'prewitt'));
%% For Matlab version 4 or 3, use the following command:
edgeImage = 129 * double(edge(rHats,'prewitt'));

comparison = max(edgeImage,errorTruncated);
mp = [gray(127); [0 1 0]; [1 0 0] ];
figure(3)
colormap(mp)
image(comparison)
title('SCIELAB Delta E Image');

% You can look at the image as a gray-scale
%
%figure(3)
%colormap(gray(128));
%imagesc([rHats + gHats + bHats] / 3)

end