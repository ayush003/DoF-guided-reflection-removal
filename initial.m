close all;
img = imread('input.jpg');

%%%% Conversion to Lab colours %%%%
cform = makecform('srgb2lab');
I = applycform(img,cform);
L = I(:,:,1); a = I(:,:,2); b = I(:,:,3);

%%%% Building Pyramid for L image%%%%
nbins = 41;
k = [3,5,7];

imL = im2double(L);
f1 = [1,-1];f2 = [1;-1];

rp = [1,0.8,0.5];
Pyramid = cell(1,3);
D = cell(1,3);

for kk = 1:3
    im = imresize(imL,rp(kk));
        
    rhox1 = -imfilter(im,f1,'circular');
    rhox1 = (rhox1+1)./2;
    px1 = makeHistogram(nbins,rhox1);
    
    rhoy1 = -imfilter(im,f2,'circular');
    rhoy1 = (rhoy1+1)./2;
    py1 = makeHistogram(nbins,rhoy1);
end