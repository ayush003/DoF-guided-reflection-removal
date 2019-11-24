function h = makeHistogram(img,nbins)   
        sum = 0;
        h = zeros(1,nbins);
        [height,width] = size(img);
        for yy = 1:height
            for xx = 1:width
                v = img(yy,xx);
                bin = uint8(v*nbins);
                if(bin>=nbins)
                    bin = bin-1;
                end
                h(bin) = h(bin)+1;
                sum = sum+1;
            end
            
        end
        h(find(h==0)) = 0.00000001;
        h = h./sum;