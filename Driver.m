clc;
clear all;

tic
im = imread("./Source\ Images/1.jpg");                         % reads the input image

%% Background Image %%
lab = makecform('srgb2lab');                    % creates color transformation structure
Im = applycform(im,lab);                        %Conversion to Lab color space
L = Im(:,:,1); a = Im(:,:,2); b = Im(:,:,3);    % 3 channels L, a and b

%%% Pyramid building for all channels %%%
% Function GetPyramid returns DoFs for 3 different resolution images of the same reference image of one channel
PyramidL = GetPyramid(L);
Pyramida = GetPyramid(a);
Pyramidb = GetPyramid(b);

%%% Fusion of 3 DoFs into one DoF for one channel %%%
% L channel %
[N1,N2,N3] = size(PyramidL{1});
dl1 = PyramidL{1};                      
dl2 = imresize(PyramidL{2},[N1 N2]);    % upscaling to the resolution of the original image
dl3 = imresize(PyramidL{3},[N1 N2]);    % upscaling to the resolution of the original image

t = 0.4;                                % lambda = 0.4
Lmap = (t*dl2 + (1-t)*dl3).*(dl1);      % DoF of L channel
Thl = threshold(Lmap);                  % initial threshold value
map1 = heaviside(Lmap - Thl);           % edgemap for L color space

% a channel %
da1 = Pyramida{1};
da2 = imresize(Pyramida{2},[N1 N2]);    % upscaling to the resolution of the original image
da3 = imresize(Pyramida{3},[N1 N2]);    % upscaling to the resolution of the original image

amap = (t*da2 + (1-t)*da3).*(da1);      % DoF of a channel
Tha = Thl/1.5;                          % Threshold for a channel
map2 = heaviside(amap - Tha);           % edgemap for a color space

% b channel %
db1 = Pyramidb{1};
db2 = imresize(Pyramidb{2},[N1 N2]);    % upscaling to the resolution of the original image
db3 = imresize(Pyramidb{3},[N1 N2]);    % upscaling to the resolution of the original image

bmap = (t*db2 + (1-t)*db3).*(db1);      % DoF of b channel
Thb = Thl/1.5;                          % threshold for b channel
map3 = heaviside(bmap - Thb);           % edgemap for b color space

EdgeBackground = map1|map2|map3;        % edgemap for Background
%%
%% Reflection image %%
w = fspecial('sobel');                  % 2D sobel filter
for ch = 1:size(im,3)
    im = im2double(im);                     % For floating point operation
    Gx(:,:,ch) = imfilter(im(:,:,ch),w);    % gradient along x
    Gy(:,:,ch) = imfilter(im(:,:,ch),w');   % gradient along y
end
grad = sqrt(Gx.^2 + Gy.^2);                 % Combined gradient of x and y direction
grad = max(grad,[],3);                      % gradient image of the original image
reflectionPoints = find(grad<0.3&grad>0.05); % inital refection points
mapR = zeros(N1,N2);
mapR(reflectionPoints) = 1;                 % initial reflection edgemap

EdgeReflection = mapR;                      % final reflection edgemap which will be updated

% Masking from background edgemap and final reflection edgemap generation
for i = 1:length(reflectionPoints)
    pnt = reflectionPoints(i);                  % index around which the patch is to be extracted
    [Hp,rows,cols] = PatchExtract([N1,N2],pnt); % 
    m = EdgeBackground(Hp);
    flag = find(m==1);
    if(EdgeBackground(pnt)==1||~isempty(flag)) 
        EdgeReflection(pnt)= 0;
    end
end

%%
%% Layer Reconstruction %%
indR = find(EdgeReflection==1);
indB = find(EdgeBackground==1);

[h,w,d] = size(grad);
G = struct;
[G.gx,G.gy,G.gxx,G.gyy,G.gxy] = GradMat(w,h);

for ch = 1:3
    [R(:,:,ch),B(:,:,ch)] = layerReconstruct(im(:,:,ch),G,indR,indB);
end

%%
%% Output %%
figure;
title('Reflection Image');
imshow(R);
figure;
title('Background Image');
imshow(B);
toc
