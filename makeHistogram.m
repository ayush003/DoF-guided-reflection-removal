function h = makeHistogram(img,nbins)  
% returns the normalised histogram of the input img
        sum = 0;
        h = zeros(1,nbins);
        [height,width] = size(img);
        
        for yy = 1:height
            for xx = 1:width
                v = img(yy,xx);   %pixel intensity
                bin = uint8(v*nbins);  %calculating the bin for the pixel
                if(bin>=nbins)         %sanity check for the index
                    bin = bin-1;
                end
                h(bin) = h(bin)+1;      %counting the number of pixels in the bin
                sum = sum+1;            %normalisation factor = number of total pixels
            end
            
        end
        h(find(h==0)) = 0.00000001; %to handle log(0/0) = NaN case
        h = h./sum;     %normalisation
