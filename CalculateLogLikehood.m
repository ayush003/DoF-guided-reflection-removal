function LL = CalculateLogLikehood(x,y,dxk,dx1,dyk,dy1,pxk,px1,pyk,py1,nbins)
        border = 2;                                     
        LL = 0;
        for ii = y-border+1:y+border-1
            for jj = x-border+1:x+border-1
                vxk = dxk(ii,jj);               % intensity value of row gradient of the blurred images
                bxk = uint8(vxk*nbins);         % calculating the bin for the histogram
                if(bxk >= nbins) 
                    bxk = bxk - 1;              
                end
                
                vx1 = dx1(ii,jj);               % intensity value of row gradient of the reference image
                bx1 = uint8(vx1*nbins);         % calculating the bin for the histogram
                if(bx1 >= nbins)
                    bx1 = bx1 - 1;
                end
                
                vyk = dyk(ii,jj);               % intensity value of coloumn gradient of the blurred images
                byk = uint8(vyk*nbins);         % calculating the bin for the histogram
                if(byk >= nbins) 
                    byk = byk - 1;
                end
                
                vy1 = dy1(ii,jj);               % intensity value of coloumn gradient of the reference images
                by1 = uint8(vy1*nbins);         % calculating the bin for the histogram
                if(by1 >= nbins)
                    by1 = by1 - 1;
                end
                
                pxk(bxk) = pxk(bxk)/(pxk(bxk) + px1(bx1));      % calculating the probabilities for the row gradient of the blurred image
                px1(bx1) = px1(bx1)/(pxk(bxk) + px1(bx1));      % calculating the probabilities for the row gradient of the reference image
                
                pyk(byk) = pyk(byk)/(pyk(byk) + py1(by1));      % calculating the probabilities for the coloumn gradient of the blurred image
                py1(by1) = py1(by1)/(pyk(byk) + py1(by1));      % calculating the probabilities for the coloumn gradient of the reference image
                
                
                LL = LL + (pxk(bxk)*log(pxk(bxk)/px1(bx1)) + pyk(byk)*log(pyk(byk)/py1(by1)));
            end
        end

