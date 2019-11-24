function [ Pyramid ] = GetPyramid(img)
% img : input image for each channel in CIELAB space
% Pyramid : 1x3 array with DoF of three different resolutions

    nbins = 41;         %number of bins for histogram
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
        px1_struct = histogram(rhox1,nbins); %computing the histogram for calculating the probabilities
        px1 = px1_struct.Values;               
        
        rhoy1 = -imfilter(im,f2,'circular');
        rhoy1 = (rhoy1+1)./2;
        py1_struct = histogram(rhox1,nbins);
        py1 = py1_struct.Values;
    
        for j = 1:3
            [N1,N2] = size(im);
            G = fspecial('gaussian',[k(j) k(j)],5); %Gaussian blurring filter with mean = 0 and standard deviation = 5      
            rhoxk = imfilter(im,G,'same');
            rhoyk = rhoxk;
        
            rhoxk =  -imfilter(rhoxk,f1,'circular');
            rhoxk = (rhoxk+1)./2; 
            pxk_struct = histogram(rhoxk,nbins);
            pxk = pxk_struct.Values;
        
            rhoyk =  -imfilter(rhoyk,f2,'circular');
            rhoyk = (rhoyk+1)./2; 
            pyk_struct = histogram(rhoxk,nbins);
            pyk = pyk_struct.Values;

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
    
  
    function LL = CalculateLogLikehood(x,y,dxk,dx1,dyk,dy1,pxk,px1,pyk,py1,nbins)
        border = 2;
        LL = 0;
        for ii = y-border+1:y+border-1
            for jj = x-border+1:x+border-1
                vxk = dxk(ii,jj);
                bxk = uint8(vxk*nbins);
                if(bxk >= nbins) 
                    bxk = bxk - 1;
                end
                
                vx1 = dx1(ii,jj);
                bx1 = uint8(vx1*nbins);
                if(bx1 >= nbins)
                    bx1 = bx1 - 1;
                end
                
                vyk = dyk(ii,jj);
                byk = uint8(vyk*nbins);
                if(byk >= nbins) 
                    byk = byk - 1;
                end
                
                vy1 = dy1(ii,jj);
                by1 = uint8(vy1*nbins);
                if(by1 >= nbins)
                    by1 = by1 - 1;
                end
                
                pxk(bxk) = pxk(bxk)/(pxk(bxk) + px1(bx1));
                px1(bx1) = px1(bx1)/(pxk(bxk) + px1(bx1));
                
                pyk(byk) = pyk(byk)/(pyk(byk) + py1(by1));
                py1(by1) = py1(by1)/(pyk(byk) + py1(by1));
                
                
                LL = LL + (pxk(bxk)*log(pxk(bxk)/px1(bx1)) + pyk(byk)*log(pyk(byk)/py1(by1)));
            end
        end

