%% read the hyperspectral image

%% 1.Spectrocam dataset has 204 spectral bands and in 400-1000nm

load('Specim_reflectance_cube1.mat')
load('Specim_reflectance_cube2.mat')

%% load D65 illumination data corresponding to 150 bands
load('D65_204.mat');
%% load CMF function data corresponding to 150 bands
load('CMF_204.mat');
%% select D65 and CMF values for 150 bands

x = CMF_204(:,1);
y = CMF_204(:,2);
z = CMF_204(:,3);
x_204 = x(1:2.960784314:end);
y_204 = y(1:2.960784314:end);
z_204 = z(1:2.960784314:end);
CMF_204 = [x_204, y_204, z_204];
D65_204 = D65_204(1:2.960784314:end);


%% remove values higher than 1 and lower than 0

cube_corrected=cube2; % choose cube1 or cube2

for g=1:512
    for h=1:512
        for c = 1:204
            if cube_corrected(g,h,c) > 1
               cube_corrected(g,h,c) = 1;
            elseif cube_corrected(g,h,c) < 0
                   cube_corrected(g,h,c) = 0;
                         
            end
        end
    end
end
cube_corrected;

%% crop the spectral cube to exclude the outliers for segmentation using

cube_corrected = cube_corrected(134:438,37:475,:); % excute this line if doing the segmentation

%% render hyperspectral image colorimetrically

radiances_d65 = zeros(size(cube_corrected)); % initialize array
for i = 1:204
  radiances_d65(:,:,i) = cube_corrected(:,:,i)*D65_204(i); 

end

radiances = radiances_d65;

[row, col, k] = size(radiances); 
radiances = reshape(radiances, row*col, k);

cmf = CMF_204;

XYZ = ((cmf)'*(radiances'))'; % apply color matching funtion
XYZ = reshape(XYZ, row, col, 3); % reshape XYZ to color image size with only 3 bands 
XYZ = max(XYZ, 0); % exclude the negative values
XYZ = XYZ/max(XYZ(:)); % normalize XYZ with maximum values

% reshape XYZ to xyz for computing LAB 
xyz = XYZ;
[row, col, k] = size(xyz); 
xyz = reshape(xyz, row*col, k);
Lab = xyz2lab(xyz,whitepoint('d65')); % convert XYZ to LAB color space

RGB = XYZ2sRGB(XYZ); % convert XYZ to sRGB color space
RGB = max(RGB, 0); % clip the negative values, replace negative by 0   
RGB = min(RGB, 1); % clip the values larger than 1, replace by 1

%% Visualize CIELAB color space (do not excute crop spectral cube code if want to compute LAB based on original data)
figure;[conv,vol]=trigamut(Lab,RGB);
%%
%multiplying 0.6 to compensate roughly for the gamma
figure; imshow(RGB.^0.6, 'Border','tight'),title('Chromatically Rendered Image');


% imwrite(RGB.^0.6,'reconstructed_specim_cube2_0.6.png')

RGB = RGB.^0.6;

%% segmentation using PCA and k-Mean clustering

X = double(cube_corrected);
NumConponent = 204; % define the number of PCA components 
[Y, V, Lambda, Mu] = PCA(X, NumConponent); % perform PCA, Y:principal components; V:eigenvectors; Lambda:eigenvalues; Mu:mean of columns of X
Y_reshaped = reshape(Y, size(cube_corrected,1),  size(cube_corrected,2), NumConponent); % reshape 

NumCluster = 10; % define the number of clusters
[L,centers] = imsegkmeans(single(Y_reshaped),NumCluster); % perform K-mean clustering

%% show the segmentation results, the number of calss to show can be control by 'IncludedLabels'
B = labeloverlay(RGB,L,'IncludedLabels',[1:10],'Transparency',0.3); %
figure;imshow(B)
% fileName = sprintf('segmentation_spectral_specim NumComponent:%d,NumCluster:%d.png', NumConponent, NumCluster);
% imwrite(B, fileName)

%% manually segmentation to compute ground truth image by using Segmenter tool
load('ground_truth_specim.mat')

% divide image into 10 classes
BW1_num = double(BW1);
BW2_num = 2*double(BW2);
BW3_num = 3*double(BW3);
BW4_num = 4*double(BW4);
BW5_num = 5*double(BW5);
BW6_num = 6*double(BW6);
BW7_num = 7*double(BW7);
BW8_num = 8*double(BW8);
BW9_num = 9*double(BW9);
BW10_num = 10*double(BW10);



% add the class together
GT = BW1_num + BW2_num + BW3_num + BW4_num + BW5_num + BW6_num + BW7_num + BW8_num + BW9_num +BW10_num;

%% save the ground truth image

colors = distinguishable_colors(10); % generate 10 distinguishable colors
GT = labeloverlay(RGB,GT,'IncludedLabels',[1:10],'Transparency',0.3,'colormap',colors);
figure;imshow(GT)
% imwrite(GT,'ground_truth_specim_test_order_new.png')

%% refine the groud truth regions

% order ground truth class according to the segmentation class 
BW1_num = double(BW10);
BW2_num = 2*double(BW7);
BW3_num = 3*double(BW6);
BW4_num = 4*double(BW1);
BW5_num = 5*double(BW9);
BW6_num = 6*double(BW4);
BW7_num = 7*double(BW5);
BW8_num = 8*double(BW8);
BW9_num = 9*double(BW3);
BW10_num = 10*double(BW2);

% add the class together
l = BW1_num + BW2_num + BW3_num + BW4_num + BW5_num + BW6_num + BW7_num + BW8_num + BW9_num +BW10_num;

% assign the neighbor values to the position which has value zero
% zero means that the postions are omitted when doing manually segmentation
for m=1:305
    for n=1:439
        if l(m,n)==0
            if l(m,n-1)>0
                l(m,n) = l(m,n-1);
            elseif l(m,n+1)>0
                l(m,n) = l(m,n+1);
                    elseif l(m-1,n)>0
                        l(m,n) = l(m-1,n);
                            elseif l(m+1,n)>0
                                l(m,n) = l(m+1,n);
                
            end
        end
    end
end

% assign the neighbor values to the position which has value larger than biggest class number 
% zero means that the postions are omitted when doing manually segmentation
for m=1:305
    for n=1:439
        if l(m,n)>10
            if l(m,n-1)<10
                l(m,n) = l(m,n-1);
            elseif l(m,n+1)<10
                l(m,n) = l(m,n+1);
                    elseif l(m-1,n)<10
                        l(m,n) = l(m-1,n);
                            elseif l(m-2,n)<10
                                l(m,n) = l(m-2,n);
                
            end
        end
    end
end
l = min(l,10); 

%% compute  Jaccard Index

% compute Jaccard Index
similarity = jaccard(l,double(L))


%% compute VAF 

%- Calculate VARIANCE ACCOUNTED FOR (VAF) and plot
e = diag(Lambda);
vaf = NaN(1,204);
x = linspace(1,204,204); 
figure;
for i=1:204
    vaf(i) = (sum(e(1:i))/sum(e))*100;
end
plot(x,vaf,'LineWidth',1.5,'color','r')
title('VAF')
xlabel('Conponent Number') 
ylabel('% of variance')
