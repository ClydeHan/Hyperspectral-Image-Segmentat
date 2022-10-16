%% This function was created using the base code of:
%% http://scarlet.stanford.edu/~brian/scielab/scielab.html

function [SCIELABDeltaE] = computeMatrixSCIELAB(RGB,shifted_RGB)

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
whitepoint = rgbWhite * rgb2lms'

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

end