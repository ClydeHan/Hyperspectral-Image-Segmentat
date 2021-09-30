function [conv,vol]=trigamut(lab,RGB)
% TRIGAMUT: Plots the gamut of a set of CIELAB data as a convex hull 
%
% Example: trigamut(lab)
% where lab contains CIELAB data arranged in columns L*, a* and b*
% 
% Plot additional gamuts by using the command 'hold on' after plotting the
% first gamut
%
% out=trigamut(lab) returns the indices of the triangles which form the convex hull 
%
% [out,volume] = trigamut(lab) also returns the volume of the gamut solid convex hull 
% of lab in cubic CIELAB units.
%
%   Colour Engineering Toolbox
%   author:    � Phil Green
%   version:   1.2
%   date:  	   17-01-2010
%   book:      http://www.wileyeurope.com/WileyCDA/WileyTitle/productCd-0471486884.html
%   web:       http://www.digitalcolour.org

[conv,vol]=convhulln(lab);


[row, col, k] = size(RGB); 
RGB = reshape(RGB, row*col, k);





% RGB=xyzTOsrgb(lab2xyz(lab,whitepoint('d65')));
% Max_RGB = max(RGB,[],'all');
% RGB = RGB/Max_RGB;

trisurf(conv,lab(:,2),lab(:,3),lab(:,1),'FaceVertexCData',RGB,'FaceColor','interp','EdgeColor','interp');
disp(['Gamut volume is ',num2str(round(vol))])

grid on;
xlabel('a*')
ylabel('b*')
zlabel('L*')
set(gca,'ZLim',[0,100]);