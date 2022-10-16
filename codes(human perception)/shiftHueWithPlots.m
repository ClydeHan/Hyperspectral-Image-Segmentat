function [shifted_RGB, MEAN_CIE76, MEAN_SCIELABDeltaE] = shiftHueWithPlots(RGB,s)
close all;
%RGB: input image in rgb format [double between 0 and 1]
%s: shift parameter

% Convert RGB to LAB
CIELAB_img = rgb2lab(RGB);

% Convert LAB to LCH
cform = makecform('lab2lch');
lch_img = applycform(CIELAB_img,cform); 

% Shift C channel 
l = lch_img(:,:,1);
c = lch_img(:,:,2);
h = lch_img(:,:,3);
h2 = h+s ;
lch_shifted = cat(3,l,c,h2);

% Convert it back to RGB
cform = makecform('lch2lab');
lab_shifted = applycform(lch_shifted,cform);
shifted_RGB = lab2rgb(lab_shifted);

% Truncate outliers
shifted_RGB(shifted_RGB>1.0)=1.0;
shifted_RGB(shifted_RGB<0.0)=0.0;

% Calculate the CIE76 Matrix
CIE76 = sqrt(sum(((CIELAB_img - lab_shifted).^2),3));
%CIE76 = deltaE(RGB,shifted_RGB);
%CIEDE2000 = imcolordiff(RGB,shifted_RGB,"Standard","CIEDE2000");

% Calculate the average of the CIE76 Matrix
MEAN_CIE76 = mean(CIE76(:));

% Calculate the SCIELAB Delta E Matrix
SCIELABDeltaE = computeMatrixSCIELABWithPlots(RGB,shifted_RGB);

% Calculate the average of the SCIELAB Delta E Matrix
MEAN_SCIELABDeltaE = mean(SCIELABDeltaE(:));

% Show the images (Optional)
figure(4)
subplot(1,2,1);
imshow(RGB);
title("ORIGINAL");
subplot(1,2,2);
imshow(shifted_RGB);
title(['Hue shifted by ' num2str(s) ' degrees']);

end