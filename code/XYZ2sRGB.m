function sRGB = XYZ2sRGB(XYZ)

%% will perform linear transformation

% checking image dimensions
d = size(XYZ);

% taking sizes of all dimensions except last one (i.e wavelength)
r = prod(d(1:end-1));   

% size of last dimension (i.e wavelength)
w = d(end);             

% Reshaping the metrics for calculation
XYZ = reshape(XYZ, [r w]);

% The forward transformation (CIE XYZ to sRGB)[1]
M = [3.2406 -1.5372 -0.4986
    -0.9689 1.8758 0.0414
     0.0557 -0.2040 1.0570];
sRGB = (M*XYZ')';

% Reshaping the metrix to obtain of original input.
sRGB = reshape(sRGB, d);

return;
     
      
%Refrence

%[1]https://en.wikipedia.org/wiki/SRGB