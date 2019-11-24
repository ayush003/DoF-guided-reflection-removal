function [ Pyramid ] = GetPyramid(img)
% img : input image for each channel in CIELAB space
% Pyramid : 1x3 array with DoF of three different resolutions

    nbins = 41;         %number of bins for makeHistogram
    k = [3,5,7];        %size of the gaussian blurring filter

    L = im2double(img); %for floating point operations
    f1 = [1,-1];        %for finding gradients along rows
    f2 = [1;-1];        %for finding gradients along columns

    rp = [1,0.8,0.5];   %Resize Parameter for each level of the pyramid
    
    Pyramid = cell(1,3);    %initialising an empty pyramid
    D = cell(1,3);          %storing the KL divergence of the blurred and reference image for each resolution
   
    for i = 1:3
        im = imresize(L,rp(i)); %different resolution image for each level of the pyramid
        
        rhox1 = -imfilter(im,f1,'circular'); %finding gradient along rows   
        rhox1 = (rhox1+1)./2;                %rescaling the values
        px1 = makeHistogram(rhox1,nbins);               
        
        rhoy1 = -imfilter(im,f2,'circular'); %finding gradient along columns
        rhoy1 = (rhoy1+1)./2;
        py1 = makeHistogram(rhoy1,nbins);
    
        for j = 1:3
            [N1,N2] = size(im);
            G = fspecial('gaussian',[k(j) k(j)],5); %Gaussian blurring filter with mean = 0 and standard deviation = 5      
            rhoxk = imfilter(im,G,'same');          %applying the filter
            rhoyk = rhoxk;
        
            rhoxk =  -imfilter(rhoxk,f1,'circular'); %finding gradient along rows    
            rhoxk = (rhoxk+1)./2;                    %rescaling the values
           pxk = makeHistogram(rhoxk,nbins);
        
            rhoyk =  -imfilter(rhoyk,f2,'circular'); %finding gradient along columns
            rhoyk = (rhoyk+1)./2; 
            pyk = makeHistogram(rhoyk,nbins);

            map = zeros(N1,N2);
            for y = 2 : N1-1
                for x = 2 : N2-1
                    map(y,x) = CalculateLogLikehood(x,y,rhoxk,rhox1,rhoyk,rhoy1,pxk,px1,pyk,py1,nbins);
                end
            end
            D{j} = map/70; 
        end
        DoF = D{1}+D{2}+D{3};
        Pyramid{i} = DoF;
    end
